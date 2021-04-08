CREATE PROCEDURE [dbo].[LAB_UpdateMigracionesPendientes]
WITH EXECUTE AS CALLER
AS
BEGIN
    DECLARE @idEfector INT

    CREATE TABLE #LAB_PendientesMigracion ( [idEfector] [INT] NOT NULL )
             
             
    insert into #LAB_PendientesMigracion 
        select idEfector from SIPS.dbo.LAB_EstadoSyncGeneral
        where ultimoSyncFechaFin<ultimoUpdateEfectorFin
        and ultimoUpdateEfectorFin is not null
        order by ultimoSyncFechaFin


    WHILE EXISTS ( Select 1 from #LAB_PendientesMigracion )
    BEGIN
        SELECT top 1 @idEfector=idEfector FROM #LAB_PendientesMigracion
        EXEC LAB_SyncNewById @idEfector
        delete from #LAB_PendientesMigracion where idEfector=@idEfector
    END
END
