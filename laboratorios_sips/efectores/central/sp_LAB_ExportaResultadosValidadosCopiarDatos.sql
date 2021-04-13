
-- =============================================
-- Author:		jrojas
-- Create date: 2016-07-19
-- Description: Copia los datos de la BD LaboratorioCentral al SIPS para su posterior procesamiento
-- =============================================
CREATE PROCEDURE [dbo].[LAB_ExportaResultadosValidados_CopiarDatos]
AS
BEGIN
	SET NOCOUNT ON

	-- Borro todos los datos en SIPS del laboratorio central (id 228)
	DELETE FROM SIPS.dbo.LAB_Temp_ResultadoEncabezado where idEfector=228
	DELETE FROM SIPS.dbo.LAB_Temp_ResultadoDetalle where idEfector=228

	INSERT INTO SIPS.dbo.LAB_Temp_ResultadoEncabezado
	SELECT *, 0 as baja  FROM LaboratorioCentral.dbo.LAB_Temp_ResultadoEncabezado

	INSERT INTO SIPS.dbo.LAB_Temp_ResultadoDetalle
	SELECT * FROM LaboratorioCentral.dbo.LAB_Temp_ResultadoDetalle

END
