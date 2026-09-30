CREATE OR REPLACE package PKG_MODULO

as

--=============================================================================
-- Nombre responsabilidad: Crear la especificación (.pks) del paquete `PKG_MODULO` para la gestión de los modulos de MoliPlus.
--
-- Autor: JUAN ANDRES SERNA CASTRO
-- Fecha_creacion: 30/Septiembre/2026
--
-- Descripcion responsabilidad:
-- Declarar la interfaz pública de consulta, inserción, actualización y eliminación de los modulos.
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
Consulta de modulos con parámetros de código, nombre y zona; devuelve un cursor de salida.
*/
PROCEDURE consultamodulo (
    cod_modulo NUMBER,
    nom_modulo VARCHAR2,
    zona_modulo VARCHAR2,
    cursor out sys_refcursor
);
/*
-------------------------------------------------------------------------
UPDATES
-------------------------------------------------------------------------
*/

/*
Actualización del archivo, menu, nombre, zona y orden del modulo identificado por su código.
*/
PROCEDURE actualizarModulo (
    cod_modulo NUMBER,
    arch_modulo VARCHAR2, 
    nom_modulo VARCHAR2,
    zona_modulo VARCHAR2,
    orde_modulo NUMBER
);

/*
-------------------------------------------------------------------------
DELETES
-------------------------------------------------------------------------
*/

/*
Eliminación del modulo identificado por cod_modulo.
*/
PROCEDURE eliminarmodulo (
    cod_modulo NUMBER
);

/*
-------------------------------------------------------------------------
INSERTS
-------------------------------------------------------------------------
*/

/*
Inserción de un modulo con su código, nombre, contraseña y estado.
*/
PROCEDURE insertarmodulo (
    cod_modulo NUMBER,
    arch_modulo VARCHAR2,
    nom_modulo VARCHAR2,
    zona_modulo VARCHAR2,
    orde_modulo NUMBER
);

/*
---------------------------------------------------------------------------------------------------------------
*/

end PKG_modulo;

/