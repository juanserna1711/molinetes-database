CREATE OR REPLACE package PKG_RENDTALLA

as

--=============================================================================
-- Nombre responsabilidad: Crear la especificación (.pks) del paquete `PKG_RENDTALLA` para la gestión de RENDTALL.
--
-- Autor: JUAN ANDRES SERNA CASTRO
-- Fecha_creacion: 09/Septiembre/2026
--
-- Descripcion responsabilidad:
-- Declarar la interfaz pública de las operaciones de consulta, inserción, actualización y eliminación de RENDTALL.
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
Consulta de tallas y su rendimiento asociado con parámetros de nombre.
Entrega el resultado mediante el cursor de salida.
*/
PROCEDURE consultaRendTalla (
    nom_talla VARCHAR2,
    cursor out sys_refcursor
);
/*
-------------------------------------------------------------------------
UPDATES
-------------------------------------------------------------------------
*/

/*
Actualización del rendimiento asociado a cod_talla con ancho, peso, rollo y usuario.
*/
PROCEDURE actualizarRendTalla (
    cod_talla NUMBER,
    ancho_rendtall NUMBER,
    peso_rendtall NUMBER,
    rollo_rendtall NUMBER,
    usuario_rendtall NUMBER
);

/*
-------------------------------------------------------------------------
DELETES
-------------------------------------------------------------------------
*/

/*
Operación de eliminación de rendimiento con cod_talla como identificador.
*/
PROCEDURE eliminarRendTalla (
    cod_talla NUMBER
);

/*
-------------------------------------------------------------------------
INSERTS
-------------------------------------------------------------------------
*/

/*
Inserción del rendimiento asociado a cod_talla con ancho, peso, rollo y usuario.
*/
PROCEDURE insertarRendTalla (
    cod_talla NUMBER,
    ancho_rendtall NUMBER,
    peso_rendtall NUMBER,
    rollo_rendtall NUMBER,
    usuario_rendtall NUMBER
);

/*
---------------------------------------------------------------------------------------------------------------
*/

end PKG_RENDTALLA;

/