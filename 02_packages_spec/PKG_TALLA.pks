CREATE OR REPLACE package PKG_TALLA

as

 

--=============================================================================
-- Nombre responsabilidad: Crear la especificación (.pks) del paquete `PKG_TALLA` para la gestión de TALLA y su RENDTALL asociado.
--
-- Autor: JUAN ANDRES SERNA CASTRO
-- Fecha_creacion: 09/Septiembre/2026
--
-- Descripcion responsabilidad:
-- Gestionar las operaciones de consulta, inserción, actualización y eliminación de TALLA y su información de RENDTALL asociada.
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


-- Consultar TALLA y su RENDIMIENTO asociado
PROCEDURE consultaTalla (
    cod_talla NUMBER,  
    nom_talla VARCHAR2, 
    esta_talla VARCHAR2, 
    cursor out sys_refcursor
);
---------------------------------------------------------------------------
-- UPDATES
---------------------------------------------------------------------------

-- Actualización de TALLA y su RENDIMIENTO asociado
PROCEDURE actualizarTalla (
    cod_talla NUMBER,
    nom_talla VARCHAR2,
    esta_talla VARCHAR2,
    ancho_rendtall NUMBER,
    peso_rendtall NUMBER,
    rollo_rendtall NUMBER,
    usuario_rendtall NUMBER
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

-- Eliminación de TALLA y su RENDIMIENTO asociado
PROCEDURE eliminarTalla (
    cod_talla NUMBER
);

---------------------------------------------------------------------------
-- INSERTS
---------------------------------------------------------------------------

--Insertar TALLA y su RENDIMIENTO asociado
PROCEDURE insertarTalla (
    cod_talla NUMBER,
    nom_talla VARCHAR2,
    esta_talla VARCHAR2,
    ancho_rendtall NUMBER,
    peso_rendtall NUMBER,
    rollo_rendtall NUMBER,
    usuario_rendtall NUMBER
);

-----------------------------------------------------------------------------------------------------------------

end PKG_TALLA;

/