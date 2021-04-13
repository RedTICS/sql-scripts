/**
 * Mueve los registros de las tablas temporales de cada efector a la tabla temporal principal
 *   LAB_Temp_ResultadoEncabezado y LAB_Temp_ResultadoDetalle
 */


/****** Object:  StoredProcedure [dbo].[LAB_Sync]    Script Date: 29/10/2020 02:41:19 ******/

CREATE PROCEDURE [dbo].[LAB_SyncNew]
WITH EXECUTE AS CALLER
AS
BEGIN

				-- SET NOCOUNT ON;
        DECLARE @idEfector INT,  @tablaEncabezado VARCHAR(100), @tablaDetalle VARCHAR(100);
        PRINT 'INICIO DEL PROCESO';
        PRINT GETDATE();
        DBCC TRACEON (610) WITH NO_INFOMSGS;

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
				-- Se toman los efectores que:
				-- 		- Tienen ultimoUpdateEfectorFin
				--		- Si tienen ultimoSyncFechaFin, que el mismo sea + minutosMinimoSyncPrincipal < GETDATE() [Que hayan pasado al menos minutosMinimoSyncPrincipal del ultimo update]
				-- 		- La fecha de ultimoSyncFechaFin < ultimoUpdateEfectorFin [hubo al menos un update desde el efector desde el ultimo update aca]

           		BEGIN TRY
           		DROP TABLE #EFECTORES_SYNC
           		END TRY
           		BEGIN CATCH
           		END CATCH
				SELECT *
						INTO #EFECTORES_SYNC
						FROM LAB_EstadoSyncGeneral
						WHERE
								( ultimoUpdateEfectorFin is not null )
						AND ( ultimoSyncFechaFin is null OR (ultimoSyncFechaFin is not null AND DATEADD(MINUTE, minutosMinimoSyncPrincipal, ultimoSyncFechaFin) < GETDATE() ) )
						AND ( ultimoSyncFechaFin is null OR (ultimoSyncFechaFin is not null AND ultimoSyncFechaFin < ultimoUpdateEfectorFin ) )

        WHILE EXISTS ( SELECT   1
                       FROM     #EFECTORES_SYNC )
            BEGIN

                SELECT TOP 1
										@idEfector = #EFECTORES_SYNC.idEfector,
										@tablaEncabezado = #EFECTORES_SYNC.tablaEncabezado,
										@tablaDetalle = #EFECTORES_SYNC.tablaDetalle
                FROM  #EFECTORES_SYNC;

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
									FROM '+ @tablaEncabezado;
					EXEC ( @TSQL );

					-- traigo detalles
					SET @TSQL = 'INSERT INTO #LAB_ResultadoDetalle SELECT * FROM '+ @tablaDetalle;
					EXEC ( @TSQL );

                	-- Marco que finalizo la migracion de este efector
                	SET @TSQL = 'UPDATE LAB_EstadoSyncGeneral set ultimoSyncFechaFin=GETDATE() where idEfector=' + CAST(@idEfector as VARCHAR(10))
                	EXEC ( @TSQL )
				END TRY
				BEGIN CATCH
				  PRINT 'Error en la migracion del efector ';
                  SELECT
                    ERROR_NUMBER() AS ErrorNumber
                    ,ERROR_MESSAGE() AS ErrorMessage;
                END CATCH;
								--if @retval <> 0
								--raiserror(@srvr , 16, 2 );
                DELETE  FROM #EFECTORES_SYNC
                WHERE    idEfector = @idEfector;

        END; -- WHILE

        PRINT 'TRUNCANDO TABLAS TEMPORALES';
        TRUNCATE TABLE LAB_Temp_ResultadoDetalle;
        TRUNCATE TABLE LAB_Temp_ResultadoEncabezado;

        PRINT 'INSERTANDO EN TABLAS TEMPORALES';

        INSERT  INTO LAB_Temp_ResultadoEncabezado
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
                FROM    #LAB_ResultadoEncabezado;

        INSERT  INTO LAB_Temp_ResultadoDetalle
                SELECT  *
             FROM    #LAB_ResultadoDetalle;

        DROP TABLE #EFECTORES_SYNC;
        DROP TABLE #LAB_ResultadoEncabezado;
        DROP TABLE #LAB_ResultadoDetalle;

        PRINT GETDATE();
        PRINT 'INCIO DE SP DE EXPORTACION';
        --EXEC LAB_ExportacionResultados;
		EXEC LAB_ImportaResultados;
        PRINT GETDATE();
        PRINT 'FIN DE SP DE EXPORTACION';
        --DBCC TRACEOFF (610);

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

		DBCC TRACEOFF (610) WITH NO_INFOMSGS;

    END;
