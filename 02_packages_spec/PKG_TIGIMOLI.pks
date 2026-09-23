CREATE OR REPLACE PACKAGE PKG_TIGIMOLI

AS


--=============================================================================
-- Nombre responsabilidad: Crear la especificación (.pks) del paquete
-- PKG_TIGIMOLI para la gestión de TIGIMOLI.
--
-- Autor: JUAN ANDRES SERNA CASTRO
-- Fecha_creacion: 18/Septiembre/2026
--
-- Descripcion responsabilidad:
-- Gestionar las operaciones de consulta e inserción de TIGIMOLI.
--
--
-- Historial_modificaciones:
--
-- Autor:
-- Fecha:
-- Descripcion:
--=============================================================================
---------------------------------------------------------------------------
-- TIPOS
---------------------------------------------------------------------------

TYPE t_lista_numeros IS TABLE OF NUMBER
    INDEX BY BINARY_INTEGER;

---------------------------------------------------------------------------
-- SELECTS
---------------------------------------------------------------------------


PROCEDURE consultaTigimoli (
    codigos_molinetes VARCHAR2,
    fecha_inicio DATE,
    fecha_fin DATE,
    pagina NUMBER,
    registros_pagina NUMBER,
    total_registros OUT NUMBER,
    cursor OUT SYS_REFCURSOR
);

PROCEDURE consultaDetalleTigimoli (
    cod_moli NUMBER,
    fecha_generacion DATE,
    cursor OUT SYS_REFCURSOR
);

---------------------------------------------------------------------------
-- INSERTS
---------------------------------------------------------------------------


PROCEDURE registrarCalculoTigimoli (
    codigos_molinetes t_lista_numeros,
    codigos_tallas t_lista_numeros,
    cantidades_rollos t_lista_numeros,
    usuario NUMBER
);


END PKG_TIGIMOLI;