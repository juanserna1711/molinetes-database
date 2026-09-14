CREATE OR REPLACE package PKG_USUARIO

as

 

--=============================================================================
-- Nombre responsabilidad: Crear la especificación (.pks) del paquete `PKG_USUARIO` para la gestión del usuario.
--
-- Autor: JUAN ANDRES SERNA CASTRO
-- Fecha_creacion: 13/Septiembre/2026
--
-- Descripcion responsabilidad:
-- Gestionar las operaciones de consulta, inserción, actualización, activación, desactivación y eliminación del usuario.
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


-- Consultar USUARIO
PROCEDURE consultaUsuario (
    cod_usuario NUMBER,  
    nom_usuario VARCHAR2, 
    esta_usuario VARCHAR2, 
    cursor out sys_refcursor
);
---------------------------------------------------------------------------
-- UPDATES
---------------------------------------------------------------------------

-- Actualización de USUARIO
PROCEDURE actualizarUsuario (
    cod_usuario NUMBER,
    nom_usuario VARCHAR2,
    pass_usuario VARCHAR2,
    esta_usuario VARCHAR2
);


-- Activar USUARIO
PROCEDURE activarUsuario (
    cod_usuario NUMBER
);


-- Desactivar USUARIO
PROCEDURE desactivarUsuario (
    cod_usuario NUMBER
);

---------------------------------------------------------------------------
-- DELETES
---------------------------------------------------------------------------

-- Eliminación de USUARIO
PROCEDURE eliminarUsuario (
    cod_usuario NUMBER
);

---------------------------------------------------------------------------
-- INSERTS
---------------------------------------------------------------------------

--Insertar USUARIO
PROCEDURE insertarUsuario (
    cod_usuario NUMBER,
    nom_usuario VARCHAR2,
    pass_usuario VARCHAR2,
    esta_usuario VARCHAR2
);

-----------------------------------------------------------------------------------------------------------------

end PKG_USUARIO;

/