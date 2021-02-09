/**
 * Stored para ejecutar antes y despues de cada exportacion de laboratorio
 * Paso 1: marca inicio de script
 * Paso 2: marca fin de script y sube los resultados a SIPS central
 */
CREATE PROCEDURE dbo.LAB_SyncStep
	@paso as INT -- Paso 1 es inicio / 2 se creo tabla temporal local => migrar a remoto + marcar procesos
	WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON;

DECLARE @error int, @rowcount int;


-- Paso 1: Marcar en la tabla LAB_SyncStatus que comenzo el proceso
if (@paso=1)
begin
	print 'Marcando inicio de sync local';
	INSERT INTO dbo.LAB_SyncStatus (fechaInicio) values (GETDATE())
end

-- Paso 2:
-- 		Marcar en la tabla LAB_SyncStatus que finalizo el proceso de generación de tabla temp
--		Migrar datos a server upstream (tomando como config tabla LAB_SyncConfig)
--		Marcar en la tabla LAB_SyncStatus que finalizo el upload
if (@paso=2)
begin
	-- Marcar fin de sync a tabla temporal local
	DECLARE @cantidadRegistrosEncabezado INT;
	DECLARE @cantidadRegistrosDetalle INT;
	print 'Marcando fin de sync local';

	set @cantidadRegistrosEncabezado = (select count(*) from LAB_Temp_ResultadoEncabezado)
	set @cantidadRegistrosDetalle = (select count(*) from LAB_Temp_ResultadoDetalle)

	UPDATE dbo.LAB_SyncStatus set fechaFin=GETDATE(), cantidadRegistrosEncabezado=@cantidadRegistrosEncabezado, cantidadRegistrosDetalle=@cantidadRegistrosDetalle where  id = (select top 1 id from dbo.LAB_SyncStatus where fechaFin is null or fechaFinUpload is null order by id desc);
	SELECT @error = @@ERROR, @rowcount = @@ROWCOUNT;

	if (@rowcount=0)
	begin
		print 'No hay sync iniciada para actualizar';

		RETURN;
	end


	if (@error>0)
	begin
		print 'Error al ejecutar el query UPDATE ' + @error + ': ' + @rowcount;
		RETURN
	end


	-- Obtengo configuracion de upstream server
	DECLARE @servidorUpstream VARCHAR(100);
	DECLARE @dbUpstream VARCHAR(100);
	DECLARE @idEfector INT;
	DECLARE @upstreamMinutosMinimoSyncEfector INT;
	DECLARE @upstreamTablaEncabezado VARCHAR(100);
	DECLARE @upstreamTablaDetalle VARCHAR(100);
	DECLARE @upstreamUltimoSyncFechaInicio DateTime;
	DECLARE @upstreamUltimoSyncFechaFin DateTime;
	DECLARE @linkedQueryStart VARCHAR(200);
	DECLARE @linkedQueryEnd VARCHAR(200);
	DECLARE @linkedExec NVARCHAR(200);
	DECLARE @sql NVARCHAR(800);
	DECLARE @upstreamFullPath NVARCHAR(100);

	-- Obtengo el servidor upstream (superior - central) y el efector que soy
	select top 1 @servidorUpstream=servidorUpstream, @dbUpstream=dbUpstream, @idEfector=idEfector from LAB_SyncConfig
	set @upstreamFullPath = QUOTENAME(@servidorUpstream) + '.' + @dbUpstream + '.';

  set @linkedQueryStart = 'SELECT * FROM OPENQUERY([' + @servidorUpstream + '], ''';
	set @linkedQueryEnd = ''')';
  set @linkedExec = N'EXEC (@sql) AT ' + QUOTENAME(@servidorUpstream) + N';';

	-- Obtengo las tablas upstream en las cuales guardar desde LAB_EstadoSyncGeneral
	set @sql = 'select @upstreamTablaEncabezado=tablaEncabezado, @upstreamTablaDetalle=tablaDetalle, @upstreamUltimoSyncFechaInicio=ultimoSyncFechaInicio, @upstreamUltimoSyncFechaFin=ultimoSyncFechaFin, @upstreamMinutosMinimoSyncEfector=minutosMinimoSyncEfector from ' + @upstreamFullPath + 'LAB_EstadoSyncGeneral where idEfector=' + CAST(@idEfector as varchar(10));


	EXEC sys.sp_executesql @sql,
			N'@upstreamTablaEncabezado VARCHAR(100) OUTPUT, @upstreamTablaDetalle VARCHAR(100) OUTPUT, @upstreamUltimoSyncFechaInicio DateTime OUTPUT, @upstreamUltimoSyncFechaFin DateTime OUTPUT, @upstreamMinutosMinimoSyncEfector INT OUTPUT',
			@upstreamTablaEncabezado=@upstreamTablaEncabezado OUTPUT,
			@upstreamTablaDetalle=@upstreamTablaDetalle OUTPUT,
			@upstreamUltimoSyncFechaInicio=@upstreamUltimoSyncFechaInicio OUTPUT,
			@upstreamUltimoSyncFechaFin=@upstreamUltimoSyncFechaFin OUTPUT,
			@upstreamMinutosMinimoSyncEfector=@upstreamMinutosMinimoSyncEfector OUTPUT;


	-- Si upstreamUltimoSyncFechaFin es null => esta migrando ahora => para ejecucion
	if (@upstreamUltimoSyncFechaInicio is not null and @upstreamUltimoSyncFechaFin is null)
	begin
		print 'El servidor upstream esta actualizando => aborto upstream sync';
		return;
	end

	-- Comentado porque no se valida tiempo desde ultima sync => siempre se actualiza el remoto
	-- Verifico si ya transcurrio el tiempo necesario para hacer un nuevo update en el upstream
	-- <ultima hora de sync del remoto con SIPS> + @upstreamMinutosMinimoSyncEfector < <fecha actual> => cancelar
	--if (@upstreamUltimoSyncFechaFin is not null AND DATEADD(MINUTE, @upstreamMinutosMinimoSyncEfector, @upstreamUltimoSyncFechaFin) > GETDATE())
	--begin
  --	print 'No ha transcurrido el tiempo suficiente para actualizar el upstream';
  --		return;
	--end



	-- Indico que inicio el upstream sync en la tabla upstream
	set @sql = 'update ' + @upstreamFullPath + 'LAB_EstadoSyncGeneral set ultimoUpdateEfectorInicio=GETDATE(), ultimoUpdateEfectorFin=NULL, ultimoSyncRegistrosEncabezado=' + CAST(@cantidadRegistrosEncabezado as VARCHAR(10)) + ', ultimoSyncRegistrosDetalle=' + CAST(@cantidadRegistrosDetalle as VARCHAR(10)) + ' where idEfector=' + CAST(@idEfector as varchar(10))
  EXEC sys.sp_executesql @sql


	-- Migración a upstream
	--BEGIN TRANSACTION; -- No puedo realizar transacciones en linked


	-- Migración de encabezado

	-- Borrar temp upstream
	print 'Migrando sync local a upstream (encabezado)';
	BEGIN TRY
		set @sql = 'delete from ' + @upstreamFullPath + @upstreamTablaEncabezado;
		print @sql
    EXEC sys.sp_executesql @sql
	END TRY
	BEGIN CATCH
	END CATCH

	-- Upload
	set @sql = 'insert into ' + @upstreamFullPath + @upstreamTablaEncabezado + ' select
		idProtocolo,
		idEfector,
		apellido ,
		nombre ,
		edad ,
		unidadEdad ,
		fechaNacimiento ,
		sexo ,
		numeroDocumento ,
		fecha ,
		fecha1 ,
		domicilio ,
		HC ,
		prioridad ,
		origen ,
		numero ,
		hiv ,
		solicitante ,
		sector ,
		sala ,
		cama ,
		embarazo ,
		EfectorSolicitante ,
		idSolicitudScreening,
		fechaRecibeScreening,
		observacionesResultados ,
		tipoMuestra ,
		baja ,
		idLocalidad ,
		idProvincia ,
		telefonoFijo,
		telefonoCelular
		from dbo.LAB_Temp_ResultadoEncabezado';
	print @sql;
  EXEC sys.sp_executesql @sql
	-- Hubo error?
	SELECT @error = @@ERROR, @rowcount = @@ROWCOUNT;
	if (@error>0)
	begin
		--ROLLBACK;
		print 'Error al ejecutar el query sync upstream (encabezado records) ' + @error + ': ' + @rowcount;
		RETURN
	end

	-- Migración de detalle
	print 'Migrando sync local a upstream (detalle)';

	-- Borrar temp upstream
	BEGIN TRY
		set @sql = 'delete from ' + @upstreamFullPath + @upstreamTablaDetalle;
    EXEC sys.sp_executesql @sql
	END TRY
	BEGIN CATCH
	END CATCH

	set @sql = 'insert into ' + @upstreamFullPath + @upstreamTablaDetalle + ' select * from LAB_Temp_ResultadoDetalle';
  EXEC sys.sp_executesql @sql
	-- Hubo error?
	SELECT @error = @@ERROR, @rowcount = @@ROWCOUNT;
	if (@error>0)
	begin
		--ROLLBACK;
		print 'Error al ejecutar el query sync upstream (detalle records) ' + @error + ': ' + @rowcount;
		RETURN
	end

	--COMMIT TRANSACTION;

	UPDATE dbo.LAB_SyncStatus set fechaFinUpload=GETDATE() where  id = (select top 1 id from dbo.LAB_SyncStatus where fechaFinUpload is null order by id desc)

	-- Indico que el fin el upstream sync en la tabla upstream
	set @sql = 'update ' + @upstreamFullPath + 'LAB_EstadoSyncGeneral set ultimoUpdateEfectorFin=GETDATE() where idEfector=' + CAST(@idEfector as varchar(10))
  EXEC sys.sp_executesql @sql
end
