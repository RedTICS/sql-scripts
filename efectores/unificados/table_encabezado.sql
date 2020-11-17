/****** Object:  Table [dbo].[LAB_Temp_ResultadoEncabezado]    Script Date: 05/11/2020 12:15:31 ******/
CREATE TABLE [dbo].[LAB_Temp_<Efector>ResultadoEncabezado](
	[idProtocolo] [int] NOT NULL,
	[idEfector] [int] NOT NULL,
	[apellido] [nvarchar](100) NOT NULL,
	[nombre] [nvarchar](100) NOT NULL,
	[edad] [int] NOT NULL,
	[unidadEdad] [varchar](5) NULL,
	[fechaNacimiento] [varchar](10) NULL,
	[sexo] [nvarchar](1) NOT NULL,
	[numeroDocumento] [int] NOT NULL,
	[fecha] [varchar](10) NULL,
	[fecha1] [datetime] NOT NULL,
	[domicilio] [nvarchar](261) NULL,
	[HC] [int] NOT NULL,
	[prioridad] [nvarchar](50) NOT NULL,
	[origen] [nvarchar](50) NOT NULL,
	[numero] [varchar](50) NULL,
	[hiv] [bit] NULL,
	[solicitante] [nvarchar](205) NULL,
	[sector] [varchar](50) NOT NULL,
	[sala] [varchar](50) NOT NULL,
	[cama] [varchar](50) NOT NULL,
	[embarazo] [varchar](1) NOT NULL,
	[EfectorSolicitante] [nvarchar](100) NOT NULL,
	[idSolicitudScreening] [int] NULL,
	[fechaRecibeScreening] [datetime] NULL,
	[observacionesResultados] [nvarchar](4000) NULL,
	[tipoMuestra] [nvarchar](500) NULL,
	[baja] [bit] NOT NULL,
 CONSTRAINT [PK_Tmp_<Efector>ResultadoEncabezado] PRIMARY KEY CLUSTERED
(
	[idProtocolo] ASC,
	[idEfector] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GRANT DELETE ON [dbo].[LAB_Temp_<Efector>ResultadoEncabezado] TO [linked_desde_efector]
GRANT INSERT ON [dbo].[LAB_Temp_<Efector>ResultadoEncabezado] TO [linked_desde_efector]
GRANT SELECT ON [dbo].[LAB_Temp_<Efector>ResultadoEncabezado] TO [linked_desde_efector]
GRANT UPDATE ON [dbo].[LAB_Temp_<Efector>ResultadoEncabezado] TO [linked_desde_efector]
