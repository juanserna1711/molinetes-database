CREATE OR REPLACE package PKG_TALLA

as

 

--=============================================================================
-- Nombre responsabilidad: Crear la especificación (.pks) del paquete `PKG_TALLA` para la gestión de TALLA.
--
-- Autor: JUAN ANDRES SERNA CASTRO
-- Fecha_creacion: 09/Septiembre/2026
--
-- Descripcion responsabilidad:
-- Gestionar las operaciones de consulta, inserción, actualización, eliminación y activación de TALLA.
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


-- Consultar TALLA
PROCEDURE consultaTalla (
    cod_talla NUMBER,  
    nom_talla VARCHAR2, 
    esta_talla VARCHAR2, 
    cursor out sys_refcursor
);
---------------------------------------------------------------------------
-- UPDATES
---------------------------------------------------------------------------

-- Actualización de TALLA
PROCEDURE actualizarTalla (
    cod_talla NUMBER,
    nom_talla VARCHAR2,
    esta_talla VARCHAR2
);


-- Activar TALLA
PROCEDURE activarTalla (
    cod_talla NUMBER
);


-- Desactivar TALLA
PROCEDURE desactivarTalla (
    cod_talla NUMBER
);

---------------------------------------------------------------------------
-- DELETES
---------------------------------------------------------------------------

-- Eliminación de TALLA
PROCEDURE eliminarTalla (
    cod_talla NUMBER
);

---------------------------------------------------------------------------
-- INSERTS
---------------------------------------------------------------------------

--Insertar TALLA
PROCEDURE insertarTalla (
    cod_talla NUMBER,
    nom_talla VARCHAR2,
    esta_talla VARCHAR2
);

-----------------------------------------------------------------------------------------------------------------

end PKG_TALLA;

/