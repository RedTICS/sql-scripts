# SQL de subsecretaria

## Listado de efectores

| Efector | idEfector | Servidor | DB | Version de scripts de migración |
|---------|-----------|----------|----|---------------------------------|
| Centenario | 1 |	SQLCENTENARIO - 10.3.72.18	| SIntegralH | 1.5(A) ✓|
| Plottier | 2|SQLPLOTTIER - 10.2.8.17 |SIntegralH| 1.5(B) ✓|
| Senillosa | 3	|SQLSENILLOSA	- 10.4.8.8 |SIntegralH | 1.5(B) ✓ |
| Rincon | 4|	RINCON - 10.6.8.16	|SIntegralH | 1.5(B) ✓|
| Chañar | 5|	SQLCHANAR - 10.12.8.9	|SIntegralH| 1.5(B) ✓|
| Añelo | 6	|10.1.62.53	|SIPSAnelo| ✓|
| Chocon |7	|10.1.62.53	|SIPSChocon| |
| Zapala | 33	|SRVZAPALA	- 10.8.8.15 |SIntegralH| 1.5(A) ✓|
| Loncopue | 37	|SQLLONCOPUE - 10.14.8.10	|SIntegralH | |
| Alumine | 40|	SQLALUMINE	- 10.1.65.253 |SIntegralH| |
| Chosmalal | 51|	CHOSMA - 10.5.72.7	|SIntegralH | |
| Buta | 53	|HTALBUTA	- 10.25.72.110 |SIntegralH | |
| Andacollo | 55|	SRVANDACOLLO	- 10.13.72.8 |SIntegralH ||
| San Martín | 70	|SANMARTIN - 10.10.8.21	| SIntegralH | 1.5(A) ✓|
| Junin | 71|	SQLJUNIN - 10.9.72.25 |SIntegralH | 1.5(A) ✓|
| Villa | 73|	VILLA	- 10.20.8.19 |SIntegralH | 1.5(A) ✓|
| Piedra | 185	| SQLPIEDRA	- 10.19.8.8 |SIntegralH | 1.5(A) ✓|
| Picun | 187	|HTAL_PICUN	- 10.18.8.10 |SIntegralH ||
| Cutral Co | 188	|CUTRALCO	- 10.7.8.21|SIntegralH | 1.5 ✓|
| General | 205	|SQLAGL	|SIntegralHLab ||
| Bouquet | 216	|BOUQUET	- 10.1.46.7 |SIntegralH | 1.5(B) ✓|
| Heller | 221	|SQLHELLER - No tiene sistema de lab |SIntegralH ||

Pasos:

- Crear Lab_SyncStep
- Crear LAB_SyncConfig
- Crear LAB_SyncStatus


## Sincronización de laboratorio con efectores

Ver la documentación de [sp_LAB_SyncStep.md](sp_LAB_SyncStep.md)
