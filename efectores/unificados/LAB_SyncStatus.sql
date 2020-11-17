CREATE TABLE LAB_SyncStatus (
	id int IDENTITY(0,1) NOT NULL,
	fechaInicio datetime NOT NULL,
	fechaFin datetime NULL,
	cantidadRegistrosEncabezado int NULL,
	fechaFinUpload datetime NULL,
	cantidadRegistrosDetalle int NULL,
	CONSTRAINT LAB_SyncStatus_PK PRIMARY KEY (id)
)
