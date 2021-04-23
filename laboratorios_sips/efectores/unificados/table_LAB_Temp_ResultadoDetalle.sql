-- Tabla utilizada en los efectores (esta script es útil para agregar un efector que no tiene el sistema de sincronización aún)

USE [SIntegralH]
GO

/****** Object:  Table [dbo].[LAB_Temp_ResultadoDetalle]    Script Date: 23/04/2021 11:05:37 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [dbo].[LAB_Temp_ResultadoDetalle](
	[idProtocolo] [int] NOT NULL,
	[idEfector] [int] NOT NULL,
	[idDetalleProtocolo] [int] NOT NULL,
	[codigoNomenclador] [varchar](50) NULL,
	[codigo] [nvarchar](50) NOT NULL,
	[ordenArea] [int] NOT NULL,
	[orden] [int] NOT NULL,
	[area] [nvarchar](50) NOT NULL,
	[grupo] [nvarchar](500) NOT NULL,
	[item] [nvarchar](500) NOT NULL,
	[observaciones] [nvarchar](500) NOT NULL,
	[esTitulo] [varchar](2) NOT NULL,
	[derivado] [nvarchar](100) NOT NULL,
	[unidad] [nvarchar](500) NOT NULL,
	[hiv] [bit] NULL,
	[metodo] [nvarchar](500) NOT NULL,
	[valorReferencia] [nvarchar](500) NOT NULL,
	[orden1] [int] NOT NULL,
	[muestra] [nvarchar](2) NOT NULL,
	[conresultado] [int] NOT NULL,
	[resultado] [nvarchar](4000) NULL,
	[codigo2] [nvarchar](50) NOT NULL,
	[profesional_val] [nvarchar](500) NOT NULL,
 CONSTRAINT [PK_LAB_Temp_ResultadoDetalle_1] PRIMARY KEY CLUSTERED 
(
	[idProtocolo] ASC,
	[idEfector] ASC,
	[idDetalleProtocolo] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO

ALTER TABLE [dbo].[LAB_Temp_ResultadoDetalle] ADD  CONSTRAINT [DF_LAB_Temp_ResultadoDetalle_codigoNomenclador]  DEFAULT ('') FOR [codigoNomenclador]
GO

ALTER TABLE [dbo].[LAB_Temp_ResultadoDetalle] ADD  CONSTRAINT [DF_LAB_Temp_ResultadoDetalle_profesional_val]  DEFAULT ('') FOR [profesional_val]
GO



