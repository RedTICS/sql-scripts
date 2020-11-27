/****** Object:  Table [dbo].[LAB_EstadoSyncGeneral]    Script Date: 11/25/2020 11:00:33 AM ******/
CREATE TABLE [dbo].[LAB_EstadoSyncGeneral](
	[ultimoSyncFechaInicio] [datetime] NULL,
	[ultimoSyncFechaFin] [datetime] NULL,
	[ultimoSyncRegistrosEncabezado] [int] NULL,
	[tablaEncabezado] [varchar](100) NULL,
	[tablaDetalle] [varchar](100) NULL,
	[ultimoUpdateEfectorInicio] [datetime] NULL,
	[ultimoUpdateEfectorFin] [datetime] NULL,
	[idEfector] [int] NOT NULL,
	[ultimoSyncRegistrosDetalle] [int] NULL,
	[minutosMinimoSyncEfector] [int] NULL,
	[minutosMinimoSyncPrincipal] [int] NULL,
 CONSTRAINT [LAB_EstadoSyncGeneral_PK] PRIMARY KEY CLUSTERED
(
	[idEfector] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
