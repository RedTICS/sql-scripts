CREATE PROCEDURE [dbo].[LAB_Sync]
WITH EXECUTE AS CALLER
AS
BEGIN

       -- SET NOCOUNT ON;

        PRINT 'INICIO DEL PROCESO';
        PRINT GETDATE();
        DBCC TRACEON (610) WITH NO_INFOMSGS;

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
			  [baja] [bit] NOT NULL default(0)
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

        SELECT *
        INTO    #SERVERS
        FROM    LAB_Efector
        WHERE   Activo = 1 and Online = 1 -- and idEfector=4
                
        WHILE EXISTS ( SELECT   1
                       FROM     #SERVERS )
            BEGIN
                DECLARE @idEfector INT,  @srvr NVARCHAR(128) , @bd varchar(50), @retval INT;

                SELECT TOP 1
				        @idEfector = #SERVERS.idEfector,
                        @srvr = #SERVERS.NombreServidor,
						@bd = #SERVERS.NombreBD
                FROM    #SERVERS; 

                BEGIN TRY
                    PRINT GETDATE();
                    PRINT 'PROCESANDO ' + @srvr + ' '; 
                    EXEC @retval = sys.sp_testlinkedserver @srvr;
                    PRINT GETDATE();
                END TRY
                BEGIN CATCH
                    SET @retval = SIGN(@@error);
					SELECT ERROR_NUMBER(), '|', ERROR_MESSAGE();
                END CATCH;
	
                IF @retval = 0
                    BEGIN TRY
                        DECLARE @OPENQUERY NVARCHAR(4000) ,
                            @TSQL NVARCHAR(4000) ,
                            @LinkedServer NVARCHAR(4000);
		--SELECT @srvr
		-- traigo protocolos
                        SET @OPENQUERY = 'SELECT * FROM OPENQUERY([' + @srvr + '],''';
                        SET @TSQL = 'SELECT * FROM '+ @bd +'.dbo.LAB_Temp_ResultadoEncabezado'')'; 
                        INSERT  INTO #LAB_ResultadoEncabezado
                                EXEC ( @OPENQUERY + @TSQL ); 		
		-- traigo detalles
		--SET @OPENQUERY = 'SELECT * FROM OPENQUERY('+ @srvr + ','''
                        SET @TSQL = 'SELECT * FROM '+ @bd +'.dbo.LAB_Temp_ResultadoDetalle'')'; 
                        INSERT  INTO #LAB_ResultadoDetalle
                                EXEC ( @OPENQUERY + @TSQL ); 
                    END TRY
                    BEGIN CATCH
							  SELECT   
								ERROR_NUMBER() AS ErrorNumber  
								,ERROR_MESSAGE() AS ErrorMessage; 
                    END CATCH;
	--if @retval <> 0
	  --raiserror(@srvr , 16, 2 );
                DELETE  FROM #SERVERS
                WHERE   idEfector = @idEfector;
            END;

        PRINT GETDATE();
        PRINT 'TRUNCANDO TABLAS TEMPORALES';
        TRUNCATE TABLE LAB_Temp_ResultadoDetalle;
        TRUNCATE TABLE LAB_Temp_ResultadoEncabezado;

        PRINT GETDATE();
        PRINT 'INSERTANDO EN TABLAS TEMPORALES';
        INSERT  INTO LAB_Temp_ResultadoEncabezado
                SELECT  *
                FROM    #LAB_ResultadoEncabezado;
        INSERT  INTO LAB_Temp_ResultadoDetalle
                SELECT  *
                FROM    #LAB_ResultadoDetalle;

        DROP TABLE #SERVERS;
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


