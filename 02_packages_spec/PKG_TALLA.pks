CREATE OR REPLACE package PKG_TALLA

as

--=============================================================================
-- Nombre responsabilidad: Crear la especificación (.pks) del paquete `PKG_TALLA` para la gestión de TALLA.
--
-- Autor: JUAN ANDRES SERNA CASTRO
-- Fecha_creacion: 09/Septiembre/2026
--
-- Descripcion responsabilidad:
-- Declarar la interfaz pública de consulta, inserción, actualización, eliminación,
-- activación y desactivación de TALLA.
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

--Consulta de tallas con parámetros de código, nombre y estado; devuelve un cursor de salida.

PROCEDURE consultaTalla (
    cod_talla NUMBER,
    nom_talla VARCHAR2,
    esta_talla VARCHAR2,
    cursor out sys_refcursor
);

-------------------------------------------------------------------------
--UPDATES
-------------------------------------------------------------------------

--Actualización del nombre y estado de la talla identificada por su código.

PROCEDURE actualizarTalla (
    cod_talla NUMBER,
    nom_talla VARCHAR2,
    esta_talla VARCHAR2
);

--Activación de la talla identificada por cod_talla.

PROCEDURE activarTalla (
    cod_talla NUMBER
);

--Desactivación de la talla identificada por cod_talla.

PROCEDURE desactivarTalla (
    cod_talla NUMBER
);

-------------------------------------------------------------------------
--DELETES
-------------------------------------------------------------------------

--Eliminación de la talla identificada por cod_talla.

PROCEDURE eliminarTalla (
    cod_talla NUMBER
);

-------------------------------------------------------------------------
--INSERTS
-------------------------------------------------------------------------

--Inserción de una talla con su código, nombre y estado.

PROCEDURE insertarTalla (
    cod_talla NUMBER,
    nom_talla VARCHAR2,
    esta_talla VARCHAR2
);

---------------------------------------------------------------------------------------------------------------

end PKG_TALLA;

/