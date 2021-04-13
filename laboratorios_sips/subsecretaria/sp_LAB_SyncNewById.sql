/*
 * Version: 1.0
 * Descripción: Mueve los registros de las tablas temporales del efector pasado como parametro a la tabla temporal principal
 *
 * Update: 2020-11-20 - Orlando: Creación del stored
 */
CREATE PROCEDURE [dbo].[LAB_SyncNewById]
	@idEfector as INT -- pk del efector a actualizar en las tablas de SIPS
WITH EXECUTE AS CALLER
AS
BEGIN

    DECLARE @tablaEncabezado VARCHAR(100), @tablaDetalle VARCHAR(100);
    PRINT 'INICIO DEL PROCESO LAB_SyncNewById';
    PRINT GETDATE();
    --DBCC TRACEON (610) WITH NO_INFOMSGS;

    DECLARE @TSQL NVARCHAR(2000);

    -- PROTOCOLOS
    CREATE TABLE #LAB_ResultadoEncabezado
        (
          [idProtocolo] [INT] NOT NULL ,
          [idEfector] [INT] NOT NULL ,
          [apellido] [NVARCHAR](100) NOT NULL ,
          [nombre] [NVARCHAR](100) NOT NULL ,
          [edad] [INT] NOT NULL ,
          [unidadEdad] [VARCHAR](5) NULL ,
          [fechaNacimiento] [VARCHAR](10) NULL ,
          [sexo] [NVARCHAR](1) NOT NULL ,
          [numeroDocumento] [INT] NOT NULL ,
          [fecha] [VARCHAR](10) NULL ,
          [fecha1] [DATETIME] NOT NULL ,
          [domicilio] [NVARCHAR](261) NULL ,
          [HC] [INT] NOT NULL ,
          [prioridad] [NVARCHAR](50) NOT NULL ,
          [origen] [NVARCHAR](50) NOT NULL ,
          [numero] [VARCHAR](50) NULL ,
          [hiv] [BIT] NULL ,
          [solicitante] [NVARCHAR](205) NULL ,
          [sector] [VARCHAR](50) NOT NULL ,
          [sala] [VARCHAR](50) NOT NULL ,
          [cama] [VARCHAR](50) NOT NULL ,
          [embarazo] [VARCHAR](1) NOT NULL ,
          [EfectorSolicitante] [NVARCHAR](100) NOT NULL ,
          [idSolicitudScreening] [INT] NULL ,
          [fechaRecibeScreening] [DATETIME] NULL ,
          [observacionesResultados] [NVARCHAR](4000) NULL ,
          [tipoMuestra] [NVARCHAR](500) NULL,
          [baja] [bit] NOT NULL default(0),
          [idLocalidad] int,
          [idProvincia] int,
          [telefonoFijo] nvarchar(20),
          [telefonoCelular] nvarchar(20)
        );
    -- DETALLLES
    CREATE TABLE #LAB_ResultadoDetalle
        (
          [idProtocolo] [INT] NOT NULL ,
          [idEfector] [INT] NOT NULL ,
          [idDetalleProtocolo] [INT] NOT NULL ,
          [codigoNomenclador] [VARCHAR](50)
            NULL
            CONSTRAINT [DF_LAB_Temp_ResultadoDetalle_codigoNomenclador]
            DEFAULT ( '' ) ,
          [codigo] [NVARCHAR](50) NOT NULL ,
          [ordenArea] [INT] NOT NULL ,
          [orden] [INT] NOT NULL ,
          [area] [NVARCHAR](50) NOT NULL ,
          [grupo] [NVARCHAR](500) NOT NULL ,
          [item] [NVARCHAR](500) NOT NULL ,
          [observaciones] [NVARCHAR](500) NOT NULL ,
          [esTitulo] [VARCHAR](2) NOT NULL ,
          [derivado] [NVARCHAR](100) NOT NULL ,
          [unidad] [NVARCHAR](500) NOT NULL ,
          [hiv] [BIT] NULL ,
          [metodo] [NVARCHAR](500) NOT NULL ,
          [valorReferencia] [NVARCHAR](500) NOT NULL ,
          [orden1] [INT] NOT NULL ,
          [muestra] [NVARCHAR](2) NOT NULL ,
          [conresultado] [INT] NOT NULL ,
          [resultado] [NVARCHAR](4000) NULL ,
          [codigo2] [NVARCHAR](50) NOT NULL ,
          [profesional_val] [NVARCHAR](500)
            NOT NULL
            CONSTRAINT [DF_LAB_Temp_ResultadoDetalle_profesional_val]
            DEFAULT ( '' )
    );


    select @tablaEncabezado=tablaEncabezado, @tablaDetalle=tablaDetalle from LAB_EstadoSyncGeneral where idEfector=@idEfector

    BEGIN TRY
      -- Marco que comenzo migracion de este efector
      SET @TSQL = 'UPDATE LAB_EstadoSyncGeneral set ultimoSyncFechaInicio=GETDATE(), ultimoSyncFechaFin=NULL where idEfector=' + CAST(@idEfector as VARCHAR(10))
      EXEC ( @TSQL )
      -- traigo protocolos
      SET @TSQL = 'INSERT INTO #LAB_ResultadoEncabezado
                   SELECT [idProtocolo]
                    ,[idEfector]
                    ,[apellido]
                    ,[nombre]
                    ,[edad]
                    ,[unidadEdad]
                    ,[fechaNacimiento]
                    ,[sexo]
                    ,[numeroDocumento]
                    ,[fecha]
                    ,[fecha1]
                    ,[domicilio]
                    ,[HC]
                    ,[prioridad]
                    ,[origen]
                    ,[numero]
                    ,[hiv]
                    ,[solicitante]
                    ,[sector]
                    ,[sala]
                    ,[cama]
                    ,[embarazo]
                    ,[EfectorSolicitante]
                    ,[idSolicitudScreening]
                    ,[fechaRecibeScreening]
                    ,[observacionesResultados]
                    ,[tipoMuestra]
                    ,[baja]
                    ,[idLocalidad]
                    ,[idProvincia]
                    ,[telefonoFijo]
                    ,[telefonoCelular]
                      FROM '+ @tablaEncabezado +' ORDER BY idProtocolo';
      EXEC ( @TSQL );

      -- traigo detalles
      SET @TSQL = 'INSERT INTO #LAB_ResultadoDetalle SELECT * FROM '+ @tablaDetalle;
      EXEC ( @TSQL );

      -- Marco que finalizo la migracion de este efector
      SET @TSQL = 'UPDATE LAB_EstadoSyncGeneral set ultimoSyncFechaFin=GETDATE() where idEfector=' + CAST(@idEfector as VARCHAR(10))
      EXEC ( @TSQL )

      CREATE TABLE #TableAuxDetalle
      (
       [idProtocolo] [int] NOT NULL,
       [idEfector] [int] NOT NULL ,
       [idDetalleProtocolo] [int] NOT NULL
      )
      --------///////////--------------


      DECLARE @idProtocolo int
      DECLARE @idDetalleProtocolo int
      DECLARE @idSolicitudScreening int


      -- Borro los detalles y encabezados que en el Hospital que hayan borrado
      DELETE LAB_ResultadoDetalle
        FROM LAB_ResultadoDetalle RD
      inner join #LAB_ResultadoEncabezado T
      on RD.idEfector=T.idEfector and RD.idProtocolo = T.idProtocolo
      where T.baja=1

      DELETE LAB_ResultadoEncabezado
        FROM LAB_ResultadoEncabezado R
      inner join #LAB_ResultadoEncabezado T
      on R.idEfector=T.idEfector and R.idProtocolo = T.idProtocolo
      where T.baja=1

      DELETE FROM #LAB_ResultadoEncabezado where baja=1


      WHILE EXISTS ( Select 1 from #LAB_ResultadoEncabezado)
       BEGIN
        SET @idSolicitudScreening=0
        SELECT top 1 @idProtocolo=idProtocolo, @idEfector=idEfector, @idSolicitudScreening=idSolicitudScreening FROM #LAB_ResultadoEncabezado

        IF EXISTS ( SELECT  1 FROM LAB_ResultadoEncabezado WHERE idProtocolo = @idProtocolo and idEfector=@idEfector  )
        begin
         delete from LAB_ResultadoEncabezado WHERE idProtocolo = @idProtocolo and idEfector=@idEfector
         ---no borra detalles existentes por que es posible que se vaya subiendo parcialmente los detalles.
         --delete from LAB_ResultadoDetalle WHERE idProtocolo = @idProtocolo and idEfector=@idEfector
        end

        -----Bucle @TableAuxDetalle: Por cada encabezado se fija si tiene detalles anteriores ya subidos en otra fecha
        -----si ya tiene y los temporales de hoy coinciden es por que hubo correccion y se sobreescribiran;
        -----sino no se borran.

        SET @TSQL = 'INSERT INTO #TableAuxDetalle
        SELECT [idProtocolo], [idEfector], [idDetalleProtocolo] FROM '+@tablaDetalle+' WHERE idProtocolo = '+CAST(@idProtocolo as VARCHAR(20))+' and idEfector='+CAST(@idEfector as VARCHAR(10))+'  order by idEfector, idProtocolo , iddetalleprotocolo'
        EXEC ( @TSQL );

        WHILE EXISTS (Select 1 from #TableAuxDetalle)
        BEGIN
         SELECT top 1 @idProtocolo=idProtocolo, @idEfector=idEfector, @idDetalleProtocolo=idDetalleProtocolo FROM #TableAuxDetalle;
      -- print @idDetalleProtocolo
         IF EXISTS ( SELECT  1 FROM LAB_ResultadoDetalle WHERE idProtocolo = @idProtocolo and idEfector=@idEfector and idDetalleProtocolo=@idDetalleProtocolo  )
         begin
          -- borra solo los detalles que ya existen por si se modificó.
          delete from LAB_ResultadoDetalle WHERE idProtocolo = @idProtocolo and idEfector=@idEfector and idDetalleProtocolo=@idDetalleProtocolo
         end
         delete from #TableAuxDetalle where idProtocolo = @idProtocolo and idEfector=@idEfector and idDetalleProtocolo=@idDetalleProtocolo
        end

        --------------------------------------------------------------------------------------------------------------------------------------------
        ---Despues de haber verificado la existencia de datos anteriores para el protcolo actual; ingresa los datos traidos.
        --------------------------------------------------------------------------------------------------------------------------------------------
        INSERT INTO LAB_ResultadoEncabezado
        select idProtocolo, idEfector, apellido, nombre, edad, unidadEdad, fechaNacimiento, sexo, numeroDocumento, fecha, fecha1, domicilio,
       HC,  prioridad, origen, numero, hiv, solicitante, sector, sala, cama, embarazo, EfectorSolicitante, idSolicitudScreening, fechaRecibeScreening,
       observacionesResultados, tipoMuestra, NULL AS cda, idLocalidad, idProvincia, telefonoFijo, telefonoCelular
        from #LAB_ResultadoEncabezado WHERE idProtocolo = @idProtocolo and idEfector=@idEfector

        INSERT INTO LAB_ResultadoDetalle
                 ([idProtocolo] ,[idEfector],[idDetalleProtocolo] ,[codigo] ,[ordenArea],[orden] ,[area] ,[grupo] ,[item] ,[observaciones]
                 ,[esTitulo]  ,[derivado] ,[unidad],[hiv] ,[metodo] ,[valorReferencia] ,[orden1] ,[muestra] ,[conresultado] ,[resultado]
                 ,[codigo2]   ,[codigoNomenclador],[profesional_val] )
        SELECT [idProtocolo]  ,[idEfector] ,[idDetalleProtocolo] ,[codigo] ,[ordenArea],[orden],[area],[grupo],[item],[observaciones]
         ,[esTitulo] ,[derivado] ,[unidad] ,[hiv],[metodo] ,[valorReferencia],[orden1] ,[muestra]  ,[conresultado] ,[resultado]
         ,[codigo2],[codigoNomenclador],[profesional_val]
        FROM #LAB_ResultadoDetalle WHERE idProtocolo = @idProtocolo and idEfector=@idEfector


       ----actualiza el estado de la tarjeta de screening
        if (@idSolicitudScreening>0)
         begin
          UPDATE LAB_SolicitudScreening set estado=3, fechaValida= GETDATE() where idSolicitudScreening=@idSolicitudScreening

          UPDATE LAB_DetalleSolicitudScreening  set  resultado=T.resultado, metodo=T.metodo, valorReferencia= T.valorReferencia, idUsuarioValida=802, fechaValida= GETDATE()
          from LAB_DetalleSolicitudScreening  as D
          inner join LAB_ItemScreening as I on D.idItem= I.idItemScreening
          inner join LAB_ResultadoDetalle as T on T.codigo=I.abreviatura
          where D.idSolicitudScreening=@idSolicitudScreening and idEfector= @idEfector and idProtocolo=@idProtocolo

         end


        delete from #LAB_ResultadoEncabezado where idProtocolo = @idProtocolo and idEfector=@idEfector
        delete from #LAB_ResultadoDetalle where idProtocolo = @idProtocolo and idEfector=@idEfector
       END



      -- FIN COPIAR
  END TRY
  BEGIN CATCH
    PRINT 'Error en la migracion del efector ';
    SELECT
      ERROR_NUMBER() AS ErrorNumber
      ,ERROR_MESSAGE() AS ErrorMessage;
  END CATCH;


  -- Actualizo las fechas de actualizacion de los protocolos
  MERGE dbo.LAB_Efector AS Target
  USING
      ( SELECT MAX(R.fecha1) AS FechaActualizacion ,
                  R.idEfector
        FROM      LAB_ResultadoEncabezado R
        GROUP BY  R.idEfector
      ) AS Source
  ON Target.idEfector = Source.idEfector
  WHEN MATCHED THEN
      UPDATE SET
              Target.FechaActualizacion = Source.FechaActualizacion;

  --DBCC TRACEOFF (610) WITH NO_INFOMSGS;

END;
