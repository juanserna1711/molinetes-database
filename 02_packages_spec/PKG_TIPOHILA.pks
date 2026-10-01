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
-- Declarar la interfaz pública de las operaciones de consulta, inserción, actualización y eliminación
-- de los tipos de hilaza.
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

--Consulta de tipos de hilaza con parámetros de código y nombre.

PROCEDURE consultaTipoHilaza (
    cod_tipo_hilaza NUMBER,
    nom_tipo_hilaza VARCHAR2,
    cursor OUT SYS_REFCURSOR
);

-------------------------------------------------------------------------
--UPDATES
-------------------------------------------------------------------------

--Actualización del nombre del tipo de hilaza identificado por su código.

PROCEDURE actualizarTipoHilaza (
    cod_tipo_hilaza NUMBER,
    nom_tipo_hilaza VARCHAR2
);

-------------------------------------------------------------------------
--DELETES
-------------------------------------------------------------------------

--Eliminación del tipo de hilaza identificado por cod_tipo_hilaza.

PROCEDURE eliminarTipoHilaza (
    cod_tipo_hilaza NUMBER
);

-------------------------------------------------------------------------
--INSERTS
-------------------------------------------------------------------------

--Inserción de un tipo de hilaza con su código y nombre.

PROCEDURE insertarTipoHilaza (
    cod_tipo_hilaza NUMBER,
    nom_tipo_hilaza VARCHAR2
);

---------------------------------------------------------------------------------------------------------------

end PKG_TIPOHILA;
/