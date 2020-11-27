/*
 * Trigger a ejecutar luego de actualizar la fecha de ultimoUpdateEfectorFin (cuando el efector termina de subir sus cambios)
 * Ultima fecha de actualización: 2020-11-25
 */
CREATE TRIGGER [dbo].[onUpdateUltimoUpdateSyncEfector] ON [dbo].[LAB_EstadoSyncGeneral]
   AFTER UPDATE
AS
BEGIN
	SET NOCOUNT ON;
	SET XACT_ABORT OFF; -- No abortar la TX ante un error
	declare @fechaPrevia Datetime;
	declare @fechaNueva Datetime;
	declare @efector int;

	select @fechaPrevia=ultimoUpdateEfectorFin from deleted;

	select @fechaNueva=ultimoUpdateEfectorFin, @efector=idEfector from inserted;
    -- Log de migraciones realizadas (se puede eliminar)
	if (@fechaPrevia is NULL AND @fechaNueva is not NULL)
	begin
		insert into LAB_TestTrigger_Borrar (idEfector, fecha, mensaje) values (@efector, @fechaNueva, 'Se finalizo la migracion')
	end;
    -- Ejecutar stored para la inyección de los datos en las tablas principales
	BEGIN TRY
		EXEC LAB_SyncNewById @efector
	END TRY
	BEGIN CATCH
		insert into LAB_SyncErrors (fecha, idEfector, errorNumber, errorMessage, errorLine)
		SELECT GETDATE(), @efector, ERROR_NUMBER() AS ErrorNumber, ERROR_MESSAGE() AS ErrorMessage, ERROR_LINE() AS ErrorLine;
	END CATCH

END
