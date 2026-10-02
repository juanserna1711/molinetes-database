CREATE OR REPLACE package PKG_TIHIPROM

as

--=============================================================================
-- Nombre responsabilidad: Crear la especificación (.pks) del paquete `PKG_TIHIPROM`
-- para la gestión de TIHIPROM.
--
-- Autor: JUAN ANDRES SERNA CASTRO
-- Fecha_creacion: 24/Septiembre/2026
--
-- Descripcion responsabilidad:
-- Declarar la interfaz pública de las operaciones de consulta, inserción, actualización, eliminación
-- y aplicación de la información de promedios por tipo de hilaza.
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

--Consulta de promedios con parámetros de tipo de hilaza y talla.

PROCEDURE consultaTiHiProm (
    cod_tipo_hilaza NUMBER,
    cod_talla NUMBER,
    cursor out sys_refcursor
);

-------------------------------------------------------------------------
--UPDATES
-------------------------------------------------------------------------

--Actualización de peso y ancho para el tipo de hilaza y talla indicados, con usuario_tihiprom como parámetro de usuario.

PROCEDURE actualizarTiHiProm (
    cod_tipo_hilaza NUMBER,
    cod_talla NUMBER,
    peso_tihiprom NUMBER,
    ancho_tihiprom NUMBER,
    usuario_tihiprom NUMBER
);

--Aplicación de la información del tipo de hilaza seleccionado en RENDTALL, con usuario_rendtall como parámetro de usuario.

PROCEDURE aplicarTipoHilaza (
    cod_tipo_hilaza NUMBER,
    usuario_rendtall NUMBER
);

-------------------------------------------------------------------------
--DELETES
-------------------------------------------------------------------------

--Eliminación de la información identificada por cod_tipo_hilaza y cod_talla.

PROCEDURE eliminarTiHiProm (
    cod_tipo_hilaza NUMBER,
    cod_talla NUMBER
);

-------------------------------------------------------------------------
--INSERTS
-------------------------------------------------------------------------

--Inserción de peso y ancho asociados al tipo de hilaza y talla indicados, con usuario_tihiprom como parámetro de usuario.

PROCEDURE insertarTiHiProm (
    cod_tipo_hilaza NUMBER,
    cod_talla NUMBER,
    peso_tihiprom NUMBER,
    ancho_tihiprom NUMBER,
    usuario_tihiprom NUMBER
);

---------------------------------------------------------------------------------------------------------------

end PKG_TIHIPROM;
/