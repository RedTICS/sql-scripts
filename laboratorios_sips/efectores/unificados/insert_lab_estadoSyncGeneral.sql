
insert into LAB_EstadoSyncGeneral 
(tablaEncabezado, tablaDetalle, idEfector, minutosMinimoSyncEfector, minutosMinimoSyncPrincipal, nombreEfector, ultimoSyncFechaFin, ultimoSyncFechaInicio, ultimoUpdateEfectorFin, ultimoUpdateEfectorInicio)
values
('LAB_Temp_<efector>ResultadoEncabezado', 'LAB_Temp_<efector>ResultadoDetalle', <idEfector>, 1, 1, '<efector>', '2001-01-01', '2001-01-01', '2001-01-01', '2001-01-01')
