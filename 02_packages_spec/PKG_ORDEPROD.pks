CREATE OR REPLACE PACKAGE PKG_ORDEPROD
as

--=============================================================================
-- Nombre responsabilidad: Crear la especificación (.pks) del paquete
-- PKG_ORDEPROD para la gestión de órdenes de trabajo.
--
-- Autor: JUAN ANDRES SERNA CASTRO
-- Fecha_creacion: 25/Septiembre/2026
--
-- Descripcion responsabilidad:
-- Declarar la interfaz pública de consulta de las órdenes de trabajo
-- almacenadas en ORDEPROD.
--
--
-- Historial_modificaciones:
--
-- Autor:
-- Fecha:
-- Descripcion:
--=============================================================================

-------------------------------------------------------------------------
--SELECTS
-------------------------------------------------------------------------

--Consulta de órdenes con parámetros de código, tipo de hilaza, fechas y paginación.
--Devuelve total_registros y el cursor de salida con el resultado de la consulta.

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

--Consulta del detalle de la orden indicada por cod_orden mediante un cursor de salida.

PROCEDURE consultaDetalleOrdeProd (
    cod_orden NUMBER,
    cursor OUT SYS_REFCURSOR
);

end PKG_ORDEPROD;
/