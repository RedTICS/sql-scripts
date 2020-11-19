USE [SIntegralHLab]
GO
/****** Object:  StoredProcedure [dbo].[LAB_ExportaResultadosValidados]    Script Date: 09/11/2020 12:03:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Carolina Pintos
-- Description:	Pone en las tablas temporales los resultados validados a exportar al servidor de la SSS
-- Update: 2016-09-27 - Julio: Agrego columna de baja en los encabezados y modifico select de protocolos
-- Update: 2018-12-10 - Julio: Se hizo un hotfix para que no reasigne pacientes si el tipo_servicio <> 4, se agrego ese filtro en el union all de "Reasignacion de pacientes"
-- =============================================
CREATE PROCEDURE [dbo].[LAB_ExportaResultadosValidados]
AS
BEGIN

TRUNCATE TABLE LAB_Temp_ResultadoEncabezado
TRUNCATE TABLE LAB_Temp_ResultadoDetalle

DECLARE  @dias INT
set @dias=30 --CAMBIAR ACA LOS DIAS A RESTAR DESDE EL DIA DE HOY


CREATE TABLE #TableFinal (idProtocolo int)

INSERT INTO #TableFinal
SELECT DISTINCT idProtocolo FROM (
SELECT DISTINCT P.idProtocolo FROM dbo.LAB_DetalleProtocolo as  DP
inner join LAB_Protocolo as P on P.idProtocolo=DP.idProtocolo
WHERE
(P.baja = 0) and (P.idTipoServicio<4)
and (CONVERT(varchar(8), fechaValida, 112) >=  CONVERT(varchar(8),GETDATE()-@dias, 112)
or  CONVERT(varchar(8), fechaValidaObservacion, 112) >= CONVERT(varchar(8),GETDATE()-@dias, 112))

--and ((CONVERT(varchar, fechaValida, 112) between '20160407' and '20160415' ) or  CONVERT(varchar, fechaValidaObservacion, 112) between '20160407' and '20160415' )

--and ((CONVERT(varchar, fechaValida, 112) <> '19000101' ) or  CONVERT(varchar, fechaValidaObservacion, 112) <> '19000101')
--and P.idPaciente = 1840234

--and ( CONVERT(varchar(6), fechaValida, 112) = '201507' or CONVERT(varchar(6), fechaValidaObservacion, 112) = '201507' )

UNION ALL
-- Eliminacion de protocolos
select distinct  A.idProtocolo from LAB_AuditoriaProtocolo A
inner join LAB_Protocolo P on A.idProtocolo = P.idProtocolo
where CONVERT(varchar, A.fecha, 112) >=  CONVERT(varchar,GETDATE()-@dias, 112)
and A.idProtocolo>0
and (accion = 'Elimina Protocolo')
and P.idTipoServicio <> 4

UNION ALL
-- Reasignacion de paciente
select distinct  A.idProtocolo from LAB_AuditoriaProtocolo A
inner join LAB_DetalleProtocolo as  DP on A.idProtocolo=DP.idProtocolo
inner join LAB_Protocolo P on A.idProtocolo = P.idProtocolo
where CONVERT(varchar, A.fecha, 112) >=  CONVERT(varchar,GETDATE()-@dias, 112)
and A.idProtocolo>0
and (accion like 'Reasigna%')
and ( CONVERT(varchar, fechaValida, 112) <> '19000101' or  CONVERT(varchar, fechaValidaObservacion, 112) <> '19000101')
and P.idTipoServicio <> 4

UNION ALL
-- Modificacion de pacientes, interesa el cambio de estado
select distinct P.idProtocolo
from LAB_Protocolo P inner join Sys_Paciente Pac on P.idPaciente = Pac.idPaciente
inner join LAB_DetalleProtocolo as  DP on P.idProtocolo=DP.idProtocolo
where Pac.idEstado <> 2 and P.idTipoServicio < 4
 and CONVERT(varchar, pac.fechaUltimaActualizacion , 112) >= CONVERT(varchar,GETDATE()-@dias, 112)
 and CONVERT(varchar, p.fecha, 112) >= CONVERT(varchar,GETDATE()-@dias*5, 112)
 and ( CONVERT(varchar, fechaValida, 112) <> '19000101' or  CONVERT(varchar, fechaValidaObservacion, 112) <> '19000101')
  ) as PP

INSERT INTO LAB_Temp_ResultadoEncabezado
SELECT DISTINCT P.idProtocolo, P.idEfector, Pac.apellido, Pac.nombre, P.edad,
			 CASE P.unidadEdad WHEN 0 THEN 'Años' WHEN 1 THEN 'Meses' WHEN 2 THEN 'Dias' END AS unidadEdad, CONVERT(varchar(10),
             Pac.fechaNacimiento, 103) AS fechaNacimiento, P.sexo, Pac.numeroDocumento, CONVERT(varchar(10), P.fecha, 103) AS fecha, P.fecha AS fecha1,
             Pac.referencia  AS domicilio, Pac.historiaClinica AS HC, Pri.nombre AS prioridad, O.nombre AS origen, dbo.NumeroProtocolo(P.idProtocolo) AS numero,
             dbo.ImprimeHiv(P.idProtocolo) AS hiv, UPPER(Prof.solicitante) AS solicitante, SS.nombre AS sector, P.sala, P.cama,
			 CASE WHEN PD.iddiagnostico IS NULL THEN '' ELSE 'E' END AS embarazo, ES.nombre AS EfectorSolicitante, 
       null as idSolicitudScreening, null as fechaRecibeScreening,
      LTRIM(RTRIM(replace(replace(REPLACE( replace(replace(replace(P.observacionesResultados, CHAR(10),' '), CHAR(13), ''), char(9),' '), ' ','<>'),'><',''),'<>',' ')))  as observacionesResultados,
			-- P.observacionesResultados,  -- Reemplazado el 2020-11-11 por la linea de arriba utilizada en Cultralco
       M.nombre as tipoMuestra, P.baja,
       Pac.idLocalidad, Pac.idProvincia, Pac.telefonoFijo, Pac.telefonoCelular
FROM         dbo.LAB_Protocolo AS P INNER JOIN
                      dbo.Sys_Paciente AS Pac ON P.idPaciente = Pac.idPaciente INNER JOIN
                      dbo.LAB_Origen AS O ON P.idOrigen = O.idOrigen INNER JOIN
                      dbo.LAB_Prioridad AS Pri ON P.idPrioridad = Pri.idPrioridad LEFT OUTER JOIN
                      dbo.vta_LAB_SolicitanteProtocolo AS Prof ON P.idProtocolo = Prof.idProtocolo LEFT OUTER JOIN
                      dbo.vta_LAB_Embarazadas AS PD ON PD.idProtocolo = P.idProtocolo INNER JOIN
                      dbo.LAB_SectorServicio AS SS ON SS.idSectorServicio = P.idSector INNER JOIN
                      dbo.Sys_Efector AS ES ON ES.idEfector = P.idEfectorSolicitante left join
					LAB_Muestra as M on M.idMuestra= P.idMuestra
WHERE    P.idProtocolo IN
                          (SELECT  idProtocolo
                            FROM        #TableFinal ) --AND (P.baja = 0) interesa actualizar los que estan dados de baja
AND                       (Pac.idEstado <>2)


---------------------------------------------------------------------------------------
INSERT INTO LAB_Temp_ResultadoDetalle
           ([idProtocolo] ,[idEfector] ,[idDetalleProtocolo]
           ,[codigoNomenclador] ,[codigo] ,[ordenArea] ,[orden]
           ,[area] ,[grupo] ,[item] ,[observaciones]
           ,[esTitulo] ,[derivado] ,[unidad] ,[hiv]
           ,[metodo] ,[valorReferencia] ,[orden1] ,[muestra]
           ,[conresultado] ,[resultado] ,[codigo2] ,[profesional_val])

SELECT DISTINCT       P.idProtocolo, P.idEfector, DP.idDetalleProtocolo, I.codigoNomenclador as codigoNomenclador, I.codigo,
A.ordenImpresion AS ordenArea, I.ordenImpresion AS orden, A.nombre AS area, I.descripcion AS grupo,
                   CASE WHEN I1.idCategoria = 1 THEN I1.descripcion ELSE CASE WHEN I.idcategoria = 1 THEN I1.descripcion ELSE I.descripcion END END AS item, DP.observaciones,
                      CASE WHEN I1.idCategoria = 1 THEN 'Si' ELSE 'No' END AS esTitulo, CASE WHEN I.idEfectorDerivacion <> i.idefector THEN ED.nombre ELSE '' END AS derivado,
                      DP.unidadMedida AS unidad, dbo.ImprimeHiv(P.idProtocolo) AS hiv, DP.metodo, DP.valorReferencia, DP.idDetalleProtocolo AS orden1, DP.trajoMuestra AS muestra,
                      CASE WHEN DP.trajomuestra = 'No' THEN 1 ELSE CASE WHEN I.idEfectorDerivacion <> i.idefector THEN 1 ELSE conResultado END END AS conresultado,
                      CASE WHEN I1.idTipoResultado <> 1 THEN DP.resultadoCar ELSE CASE I1.formatoDecimal WHEN 0 THEN CAST(CAST(resultadonum AS int) AS varchar(50))
                      WHEN 1 THEN CAST(CAST(resultadonum AS decimal(18, 1)) AS varchar(50)) WHEN 2 THEN CAST(CAST(resultadonum AS decimal(18, 2)) AS varchar(50))
                      WHEN 3 THEN CAST(CAST(resultadonum AS decimal(18, 3)) AS varchar(50)) WHEN 4 THEN CAST(CAST(resultadonum AS decimal(18, 4)) AS varchar(50))
                      END END AS resultado, I1.codigo AS codigo2,  U.firmaValidacion as profesional_val
FROM         LAB_Temp_ResultadoEncabezado AS P INNER JOIN
                      LAB_DetalleProtocolo AS DP ON DP.idProtocolo = P.idProtocolo INNER JOIN
                      LAB_Item AS I ON DP.idItem = I.idItem AND DP.idEfector = I.idEfector INNER JOIN
                      LAB_Item AS I1 ON DP.idSubItem = I1.idItem AND DP.idEfector = I1.idEfector INNER JOIN
                      LAB_Area AS A ON I.idArea = A.idArea INNER JOIN
                      Sys_Efector AS ED ON I.idEfectorDerivacion = ED.idEfector inner JOIN
                      Sys_Usuario AS U ON DP.idUsuarioValida = U.idUsuario

 ------------------------------------------------------------------------------

INSERT INTO LAB_Temp_ResultadoDetalle
           ([idProtocolo],[idEfector],[idDetalleProtocolo]
           ,[codigoNomenclador],[codigo],[ordenArea],[orden]
           ,[area] ,[grupo] ,[item] ,[observaciones]
           ,[esTitulo] ,[derivado] ,[unidad] ,[hiv]
           ,[metodo] ,[valorReferencia] ,[orden1],[muestra]
           ,[conresultado] ,[resultado] ,[codigo2] ,[profesional_val])

SELECT DISTINCT       DP.idProtocolo, DP.idEfector, DP.idDetalleProtocolo,
					I.codigoNomenclador as codigoNomenclador, I.codigo, A.ordenImpresion AS ordenArea, I.ordenImpresion AS orden, A.nombre AS area, I.descripcion AS grupo,
                      CASE WHEN I1.idCategoria = 1 THEN I1.descripcion ELSE CASE WHEN I.idcategoria = 1 THEN I1.descripcion ELSE I.descripcion END END AS item, DP.observaciones,
                       CASE WHEN I1.idCategoria = 1 THEN 'Si' ELSE 'No' END AS esTitulo, CASE WHEN I.idEfectorDerivacion <> i.idefector THEN ED.nombre ELSE '' END AS derivado,
                      DP.unidadMedida AS unidad, dbo.ImprimeHiv(DP.idProtocolo) AS hiv, DP.metodo, DP.valorReferencia, DP.idDetalleProtocolo AS orden1, DP.trajoMuestra AS muestra,
                      CASE WHEN DP.trajomuestra = 'No' THEN 1 ELSE CASE WHEN I.idEfectorDerivacion <> i.idefector THEN 1 ELSE conResultado END END AS conresultado,
                      CASE WHEN I1.idTipoResultado <> 1 THEN DP.resultadoCar ELSE CASE I1.formatoDecimal WHEN 0 THEN CAST(CAST(resultadonum AS int) AS varchar(50))
                      WHEN 1 THEN CAST(CAST(resultadonum AS decimal(18, 1)) AS varchar(50)) WHEN 2 THEN CAST(CAST(resultadonum AS decimal(18, 2)) AS varchar(50))
                      WHEN 3 THEN CAST(CAST(resultadonum AS decimal(18, 3)) AS varchar(50)) WHEN 4 THEN CAST(CAST(resultadonum AS decimal(18, 4)) AS varchar(50))
                      END END AS resultado,  I1.codigo AS codigo2, U1.firmaValidacion as profesional_val
FROM                 LAB_Temp_ResultadoEncabezado as P inner join
					 LAB_DetalleProtocolo AS DP on P.idProtocolo= DP.idProtocolo INNER JOIN
                     LAB_Item AS I ON DP.idItem = I.idItem AND DP.idEfector = I.idEfector INNER JOIN
                     LAB_Item AS I1 ON DP.idSubItem = I1.idItem AND DP.idEfector = I1.idEfector INNER JOIN
                     LAB_Area AS A ON I.idArea = A.idArea INNER JOIN
                     Sys_Efector AS ED ON I.idEfectorDerivacion = ED.idEfector inner JOIN
                     Sys_Usuario AS U1 ON DP.idUsuarioValidaObservacion = U1.idUsuario
WHERE idUsuarioValida=0
--and DP.idProtocolo IN  (SELECT  idProtocolo   FROM        LAB_Temp_ResultadoEncabezado )

---------------------------------------------------------------------------------------------
--inserta los aislamientos
INSERT INTO LAB_Temp_ResultadoDetalle
           ([idProtocolo] ,[idEfector] ,[idDetalleProtocolo]
           ,[codigoNomenclador] ,[codigo] ,[ordenArea] ,[orden]
           ,[area] ,[grupo] ,[item] ,[observaciones]
           ,[esTitulo] ,[derivado] ,[unidad] ,[hiv]
           ,[metodo] ,[valorReferencia] ,[orden1] ,[muestra]
           ,[conresultado] ,[resultado] ,[codigo2] ,[profesional_val])

select  A.idProtocolo, P.idEfector as idEfector, A.idProtocoloGermen  *(-1) as idDetalleProtocolo,
'' as codigoNomenclador, '0' as codigo, 9999 AS ordenArea,9999 AS orden,
Ar.nombre as area, I.nombre  AS grupo, 'Aislamiento'  AS item, '' as observaciones, 'No' AS esTitulo,  ''  AS derivado,
'' AS unidad, 0 AS hiv, '' as metodo, '' as valorReferencia, 9999 AS orden1, 'Si' AS muestra,
1 AS conresultado, G.nombre   AS resultado,  '' AS codigo2, U.firmaValidacion as profesional_val

from lab_protocologermen as A
inner join LAB_Temp_ResultadoEncabezado as P on P.idProtocolo= A.idProtocolo
inner join lab_item as I on I.idItem= a.idItem
inner join LAB_Area as Ar on Ar.idArea= I.idArea
inner join lab_germen as G on G.idgermen= A.idGermen
inner join Sys_Usuario as U on U.idUsuario= A.idusuariovalida

---------------------------------------------------------------------------------------------

----inserta los antibiograma
INSERT INTO LAB_Temp_ResultadoDetalle
           ([idProtocolo] ,[idEfector] ,[idDetalleProtocolo]
           ,[codigoNomenclador] ,[codigo] ,[ordenArea] ,[orden]
           ,[area] ,[grupo] ,[item] ,[observaciones]
           ,[esTitulo] ,[derivado] ,[unidad] ,[hiv]
           ,[metodo] ,[valorReferencia] ,[orden1] ,[muestra]
           ,[conresultado] ,[resultado] ,[codigo2] ,[profesional_val])

select  A.idProtocolo, P.idEfector as idEfector, A.idAntibiograma  *(-1) as idDetalleProtocolo,'' as codigoNomenclador, '0' as codigo, 9999 AS ordenArea,9999 AS orden,
area, item AS grupo,'ATB ' + germen  AS item, '' as observaciones, 'No' AS esTitulo,  ''  AS derivado,
'' AS unidad, 0 AS hiv, metodologia as metodo, '' as valorReferencia, 9999 AS orden1, 'Si' AS muestra,
1 AS conresultado, antibiotico + ': '+ resultado AS resultado,  '' AS codigo2, A.userValida as profesional_val
from [vta_LAB_Antibiograma] as A
inner join LAB_Temp_ResultadoEncabezado as P on P.idProtocolo= A.idProtocolo
order by a.numeroaislamiento, a.idGermen
--where P.estado=2  AND P.baja=0
--and A.idProtocolo IN  (SELECT  idProtocolo    FROM        LAB_Temp_ResultadoEncabezado)

----------------------------------------------------------------------
end
