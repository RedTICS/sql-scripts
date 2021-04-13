
CREATE TABLE [dbo].[LAB_Temp_<Efector>ResultadoDetalle](
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
 CONSTRAINT [PK_LAB_Tmp_<Efector>ResultadoDetalle_1] PRIMARY KEY CLUSTERED 
(
	[idProtocolo] ASC,
	[idEfector] ASC,
	[idDetalleProtocolo] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
