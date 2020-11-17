USE [SIPS]
GO
/****** Object:  StoredProcedure [dbo].[LAB_ImportaResultados]    Script Date: 06/11/2020 21:50:58 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author: Julio Rojas
-- Create date: 15/09/2016
-- Description: Importa los resultados de laboratorio de las tablas temporales a las definitivas
-- 20180724: Agrego la columna CDA en NULL para que no de errores en el insert
-- 20201106: Agrego temporalmente provincia, localidad, telefono fijo y telefono celular en null
-- =============================================
CREATE PROCEDURE [dbo].[LAB_ImportaResultados]
WITH EXECUTE AS CALLER
AS
BEGIN

SET NOCOUNT ON


DECLARE @TableAux AS TABLE
(
 [idProtocolo] [int] NOT NULL,
 [idEfector] [int] NOT NULL DEFAULT ((0)),
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
 [idSolicitudScreening] int null,
 [fechaRecibeScreening]  [datetime] null ,
 [observacionesResultados]  [nvarchar](4000)  NULL,
 [tipoMuestra]  [nvarchar](500)  NULL ,
 [baja] [bit] NOT NULL DEFAULT (0),
 [idLocalidad] [INT],
 [idProvincia] [INT],
 [telefonoFijo] [nvarchar](20),
 [telefonoCelular] [nvarchar](20)
)

DECLARE @TableAuxDetalle AS TABLE
(
 [idProtocolo] [int] NOT NULL,
 [idEfector] [int] NOT NULL ,
 [idDetalleProtocolo] [int] NOT NULL
)
--------///////////--------------

INSERT INTO @TableAux
SELECT * FROM LAB_Temp_ResultadoEncabezado order by idEfector, idProtocolo

DECLARE @idProtocolo int
DECLARE @idDetalleProtocolo int
DECLARE @idEfector int
DECLARE @idSolicitudScreening int


-- Borro los detalles y encabezados que en el Hospital que hayan borrado
DELETE LAB_ResultadoDetalle
  FROM LAB_ResultadoDetalle RD
inner join @TableAux T
on RD.idEfector=T.idEfector and RD.idProtocolo = T.idProtocolo
where T.baja=1

DELETE LAB_ResultadoEncabezado
  FROM LAB_ResultadoEncabezado R
inner join @TableAux T
on R.idEfector=T.idEfector and R.idProtocolo = T.idProtocolo
where T.baja=1

DELETE FROM @TableAux where baja=1


WHILE EXISTS ( Select 1 from @TableAux)
 BEGIN
  SET @idSolicitudScreening=0
  SELECT top 1 @idProtocolo=idProtocolo, @idEfector=idEfector, @idSolicitudScreening=idSolicitudScreening FROM @TableAux

  IF EXISTS ( SELECT  1 FROM LAB_ResultadoEncabezado WHERE idProtocolo = @idProtocolo and idEfector=@idEfector  )
  begin
   delete from LAB_ResultadoEncabezado WHERE idProtocolo = @idProtocolo and idEfector=@idEfector
   ---no borra detalles existentes por que es posible que se vaya subiendo parcialmente los detalles.
   --delete from LAB_ResultadoDetalle WHERE idProtocolo = @idProtocolo and idEfector=@idEfector
  end

  -----Bucle @TableAuxDetalle: Por cada encabezado se fija si tiene detalles anteriores ya subidos en otra fecha
  -----si ya tiene y los temporales de hoy coinciden es por que hubo correccion y se sobreescribiran;
  -----sino no se borran.

  INSERT INTO @TableAuxDetalle
  SELECT [idProtocolo], [idEfector], [idDetalleProtocolo] FROM LAB_Temp_ResultadoDetalle  WHERE idProtocolo = @idProtocolo and idEfector=@idEfector  order by idEfector, idProtocolo , iddetalleprotocolo

  WHILE EXISTS (Select 1 from @TableAuxDetalle)
  BEGIN
   SELECT top 1 @idProtocolo=idProtocolo, @idEfector=idEfector, @idDetalleProtocolo=idDetalleProtocolo FROM @TableAuxDetalle
   -- print @idDetalleProtocolo
   IF EXISTS ( SELECT  1 FROM LAB_ResultadoDetalle WHERE idProtocolo = @idProtocolo and idEfector=@idEfector and idDetalleProtocolo=@idDetalleProtocolo  )
   begin
    -- borra solo los detalles que ya existen por si se modificó.
    delete from LAB_ResultadoDetalle WHERE idProtocolo = @idProtocolo and idEfector=@idEfector and idDetalleProtocolo=@idDetalleProtocolo
   end
   delete from @TableAuxDetalle where idProtocolo = @idProtocolo and idEfector=@idEfector and idDetalleProtocolo=@idDetalleProtocolo
  end

  --------------------------------------------------------------------------------------------------------------------------------------------
  ---Despues de haber verificado la existencia de datos anteriores para el protcolo actual; ingresa los datos traidos.
  --------------------------------------------------------------------------------------------------------------------------------------------
  INSERT INTO LAB_ResultadoEncabezado
  select idProtocolo, idEfector, apellido, nombre, edad, unidadEdad, fechaNacimiento, sexo, numeroDocumento, fecha, fecha1, domicilio,
 HC,  prioridad, origen, numero, hiv, solicitante, sector, sala, cama, embarazo, EfectorSolicitante, idSolicitudScreening, fechaRecibeScreening,
 observacionesResultados, tipoMuestra, NULL AS cda
  , idLocalidad, idProvincia, telefonoFijo, telefonoCelular -- Agregado 2020-11-09
  from LAB_Temp_ResultadoEncabezado WHERE idProtocolo = @idProtocolo and idEfector=@idEfector

  INSERT INTO LAB_ResultadoDetalle
           ([idProtocolo] ,[idEfector],[idDetalleProtocolo] ,[codigo] ,[ordenArea],[orden] ,[area] ,[grupo] ,[item] ,[observaciones]
           ,[esTitulo]  ,[derivado] ,[unidad],[hiv] ,[metodo] ,[valorReferencia] ,[orden1] ,[muestra] ,[conresultado] ,[resultado]
           ,[codigo2]   ,[codigoNomenclador],[profesional_val] )
  SELECT [idProtocolo]  ,[idEfector] ,[idDetalleProtocolo] ,[codigo] ,[ordenArea],[orden],[area],[grupo],[item],[observaciones]
   ,[esTitulo] ,[derivado] ,[unidad] ,[hiv],[metodo] ,[valorReferencia],[orden1] ,[muestra]  ,[conresultado] ,[resultado]
   ,[codigo2],[codigoNomenclador],[profesional_val]
  FROM LAB_Temp_ResultadoDetalle WHERE idProtocolo = @idProtocolo and idEfector=@idEfector


 ----actualiza el estado de la tarjeta de screening
  if (@idSolicitudScreening>0)
   begin
    UPDATE LAB_SolicitudScreening set estado=3, fechaValida= GETDATE() where idSolicitudScreening=@idSolicitudScreening

    UPDATE LAB_DetalleSolicitudScreening  set  resultado=T.resultado, metodo=T.metodo, valorReferencia= T.valorReferencia, idUsuarioValida=802, fechaValida= GETDATE()
    from LAB_DetalleSolicitudScreening  as D
    inner join LAB_ItemScreening as I on D.idItem= I.idItemScreening
    inner join LAB_ResultadoDetalle as T on T.codigo=I.abreviatura
    where D.idSolicitudScreening=@idSolicitudScreening and idEfector= @idEfector and idProtocolo=@idProtocolo

   end

  delete from @TableAux where idProtocolo = @idProtocolo and idEfector=@idEfector

  delete from LAB_Temp_ResultadoEncabezado WHERE idProtocolo = @idProtocolo and idEfector=@idEfector
  delete from LAB_Temp_ResultadoDetalle WHERE idProtocolo = @idProtocolo and idEfector=@idEfector
 END

END
