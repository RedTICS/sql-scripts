# SQL de subsecretaria

## Listado de efectores

| Efector | idEfector | Servidor | DB | Version de scripts de migración |
|---------|-----------|----------|----|---------------------------------|
| Centenario | 1 |	SQLCENTENARIO - 10.3.72.18	| SIntegralH | 1.5(A) ✓|
| Plottier | 2|SQLPLOTTIER - 10.2.8.17 |SIntegralH| 1.5(B) ✓|
| Senillosa | 3	|SQLSENILLOSA	- 10.4.8.8 |SIntegralH | 1.5(C) ✓ |
| Rincon | 4|	RINCON - 10.6.8.16	|SIntegralH | 1.5(B) ✓|
| Chañar | 5|	SQLCHANAR - 10.12.8.9	|SIntegralH| 1.5(B) ✓|
| Añelo | 6	|10.1.62.53	|SIPSAnelo| 1.5(B) ✓|
| Chocon |7	|10.1.62.53	|SIPSChocon| 1.5(B) ✓|
| Zapala | 33	|SRVZAPALA	- 10.8.8.15 |SIntegralH| 1.5(A) ✓|
| Loncopue | 37	|SQLLONCOPUE - 10.14.8.10	|SIntegralH | 1.5(H) ✓|
| Alumine | 40|	SQLALUMINE	- 10.1.65.253 |SIntegralH| |
| Chosmalal | 51|	CHOSMA - 10.5.72.7	|SIntegralH | 1.5(B) ✓|
| Buta | 53	|HTALBUTA	- 10.25.72.110 |SIntegralH | 1.5(G) ✓|
| Andacollo | 55|	SRVANDACOLLO	- 10.13.72.8 |SIntegralH |1.5(B) ✓|
| San Martín | 70	|SANMARTIN - 10.10.8.21	| SIntegralH | 1.5(A) ✓|
| Junin | 71|	SQLJUNIN - 10.9.72.25 |SIntegralH | 1.5(A) ✓|
| Villa | 73|	VILLA	- 10.20.8.19 |SIntegralH | 1.5(A) ✓|
| Piedra | 185	| SQLPIEDRA	- 10.19.8.8 |SIntegralH | 1.5(A) ✓|
| Picun | 187	|HTAL_PICUN	- 10.18.8.10 |SIntegralH | 1.5(F) ✓|
| Cutral Co | 188	|CUTRALCO	- 10.7.8.21|SIntegralH | 1.5(B) ✓|
| Castro | 205	|SQLAGL	- 10.1.72.7 |SIntegralHLab | 1.5(D) ✓|
| Bouquet | 216	|BOUQUET	- 10.1.46.7 |SIntegralH | 1.5(B) ✓|
| Heller | 221	|SQLHELLER - 10.1.104.37 - No tiene sistema de lab |SIntegralH ||
| Laboratorio Central | 228	| 10.1.62.53 |LaboratorioCentral | 1.5(E)|
| Las Lajas | 35 | 10.15.8.15 | SIntegralH | 1.5(I) ✓| 

Versiones:
- 1.5(A): vta_LAB_Antibiograma NO tiene el usuario que lo valido
- 1.5(B): vta_LAB_Antibiograma tiene el usuario que lo valido
- 1.5(C): vta_LAB_Antibiograma tiene el usuario que lo valido y hace left join con tabla LAB_Muestra
- 1.5(D): script del castro que contiene diferentes validaciones (tiene el usuario que lo valido), no tiene telefono de contacto la tabla de paciente
- 1.5(E): script del laboratorio central que contiene diferencias con los otros scripts en la validacion de los estudios
- 1.5(F): script de Picun que contiene varias diferencias y mucha menos funcionalidad
- 1.5(G): vta_LAB_Antibiograma NO tiene el usuario que lo valido pero no tiene telefono fijo o celular (es similara al 1.5(A))
- 1.5(H): carece de la mayoría de datos (usado en Loncopue)
- 1.5(I): carece de la mayoría de datos (usado en Loncopue)


## Sincronización de laboratorio con efectores

Ver la documentación de [sp_LAB_SyncStep.md](sp_LAB_SyncStep.md)
