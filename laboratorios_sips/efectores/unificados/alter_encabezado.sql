-- Script para modificar las tablas temporales de encabezado en los efectores
-- para agregar los nuevos campos idLocalidad, idProvincia, telefonoFijo, telefonoCelular

ALTER TABLE LAB_Temp_ResultadoEncabezado add idLocalidad INT;
ALTER TABLE LAB_Temp_ResultadoEncabezado add idProvincia INT;
ALTER TABLE LAB_Temp_ResultadoEncabezado add telefonoFijo nvarchar(20);
ALTER TABLE LAB_Temp_ResultadoEncabezado add telefonoCelular nvarchar(20);
