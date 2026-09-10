# Módulo Molinetes - Scripts de Base de Datos (Oracle)

Repositorio para el control de versiones de objetos PL/SQL y estructuras DDL.

## ⚠️ Orden Estricto de Compilación

1. **Tablas y Tablas de Catálogo:** `/01_tables/`
2. **Especificaciones de Paquetes (`.pks`):** `/02_packages_spec/`
3. **Cuerpos de Paquetes (`.pkb`):** `/03_packages_body/`

## Convenciones
- Los nombres de paquetes usan el prefijo `PKG_` en mayúsculas.
- Todo script utiliza la cláusula `CREATE OR REPLACE`.