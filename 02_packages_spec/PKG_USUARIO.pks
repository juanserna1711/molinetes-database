CREATE OR REPLACE package PKG_USUARIO

as

--=============================================================================
-- Nombre responsabilidad: Crear la especificación (.pks) del paquete `PKG_USUARIO` para la gestión del usuario.
--
-- Autor: JUAN ANDRES SERNA CASTRO
-- Fecha_creacion: 13/Septiembre/2026
--
-- Descripcion responsabilidad:
-- Declarar la interfaz pública de consulta, inserción, actualización,
-- activación, desactivación y eliminación del usuario.
--
-- Historial_modificaciones:
--
-- Autor:
-- Fecha:
-- Descripcion:
--=============================================================================

/*
-------------------------------------------------------------------------
SELECTS
-------------------------------------------------------------------------
*/

/*
Consulta de usuarios con parámetros de código, nombre y estado; devuelve un cursor de salida.
*/
PROCEDURE consultaUsuario (
    cod_usuario NUMBER,
    nom_usuario VARCHAR2,
    esta_usuario VARCHAR2,
    cursor out sys_refcursor
);
/*
-------------------------------------------------------------------------
UPDATES
-------------------------------------------------------------------------
*/

/*
Actualización del nombre, contraseña y estado del usuario identificado por su código.
*/
PROCEDURE actualizarUsuario (
    cod_usuario NUMBER,
    nom_usuario VARCHAR2,
    pass_usuario VARCHAR2,
    esta_usuario VARCHAR2
);

/*
Activación del usuario identificado por cod_usuario.
*/
PROCEDURE activarUsuario (
    cod_usuario NUMBER
);

/*
Desactivación del usuario identificado por cod_usuario.
*/
PROCEDURE desactivarUsuario (
    cod_usuario NUMBER
);

/*
-------------------------------------------------------------------------
DELETES
-------------------------------------------------------------------------
*/

/*
Eliminación del usuario identificado por cod_usuario.
*/
PROCEDURE eliminarUsuario (
    cod_usuario NUMBER
);

/*
-------------------------------------------------------------------------
INSERTS
-------------------------------------------------------------------------
*/

/*
Inserción de un usuario con su código, nombre, contraseña y estado.
*/
PROCEDURE insertarUsuario (
    cod_usuario NUMBER,
    nom_usuario VARCHAR2,
    pass_usuario VARCHAR2,
    esta_usuario VARCHAR2
);

/*
---------------------------------------------------------------------------------------------------------------
*/

end PKG_USUARIO;

/