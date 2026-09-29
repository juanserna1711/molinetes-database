CREATE OR REPLACE PACKAGE PKG_ORDEPROD

AS


--=============================================================================
-- Nombre responsabilidad: Crear la especificación (.pks) del paquete
-- PKG_ORDEPROD para la gestión de órdenes de trabajo.
--
-- Autor: JUAN ANDRES SERNA CASTRO
-- Fecha_creacion: 25/Septiembre/2026
--
-- Descripcion responsabilidad:
-- Gestionar las operaciones de consulta de las órdenes de trabajo
-- almacenadas en ORDEPROD.
--
--
-- Historial_modificaciones:
--
-- Autor:
-- Fecha:
-- Descripcion:
--=============================================================================


---------------------------------------------------------------------------
-- SELECTS
---------------------------------------------------------------------------

PROCEDURE consultaOrdeProd (
    cod_orden NUMBER,
    cod_tipo_hilaza NUMBER,
    fecha_inicio DATE,
    fecha_fin DATE,
    pagina NUMBER,
    registros_pagina NUMBER,
    total_registros OUT NUMBER,
    cursor OUT SYS_REFCURSOR
);


PROCEDURE consultaDetalleOrdeProd (
    cod_orden NUMBER,
    cursor OUT SYS_REFCURSOR
);


END PKG_ORDEPROD;
/