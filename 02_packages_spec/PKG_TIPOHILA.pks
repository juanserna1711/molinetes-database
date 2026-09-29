CREATE OR REPLACE PACKAGE PKG_TIPOHILA

as


--=============================================================================
-- Nombre responsabilidad: Crear la especificación (.pks) del paquete `PKG_TIPOHILA`
-- para la gestión de TIPOHILA.
--
-- Autor: JUAN ANDRES SERNA CASTRO
-- Fecha_creacion: 24/Septiembre/2026
--
-- Descripcion responsabilidad:
-- Gestionar las operaciones de consulta, inserción, actualización y eliminación
-- de los tipos de hilaza.
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

-- Consultar TIPOHILA
PROCEDURE consultaTipoHilaza (
    cod_tipo_hilaza NUMBER,
    nom_tipo_hilaza VARCHAR2,
    cursor OUT SYS_REFCURSOR
);

---------------------------------------------------------------------------
-- UPDATES
---------------------------------------------------------------------------

-- Actualización de TIPOHILA
PROCEDURE actualizarTipoHilaza (
    cod_tipo_hilaza NUMBER,
    nom_tipo_hilaza VARCHAR2
);

---------------------------------------------------------------------------
-- DELETES
---------------------------------------------------------------------------

-- Eliminación de TIPOHILA
PROCEDURE eliminarTipoHilaza (
    cod_tipo_hilaza NUMBER
);

---------------------------------------------------------------------------
-- INSERTS
---------------------------------------------------------------------------

-- Insertar TIPOHILA
PROCEDURE insertarTipoHilaza (
    cod_tipo_hilaza NUMBER,
    nom_tipo_hilaza VARCHAR2
);

-----------------------------------------------------------------------------------------------------------------

end PKG_TIPOHILA;
/