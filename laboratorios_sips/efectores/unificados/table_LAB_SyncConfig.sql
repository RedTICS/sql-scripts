CREATE TABLE LAB_SyncConfig (
	servidorUpstream varchar(100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	idEfector int NOT NULL,
	dbUpstream varchar(100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	diasASincronizar int NOT NULL
)
