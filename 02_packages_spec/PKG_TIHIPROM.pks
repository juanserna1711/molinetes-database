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
-- Gestionar las operaciones de consulta, inserción, actualización, eliminación
-- y aplicación de la información de promedios por tipo de hilaza.
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

-- Consultar TIPOHILA y su información de promedio asociada
PROCEDURE consultaTiHiProm (
    cod_tipo_hilaza NUMBER,
    cod_talla NUMBER,
    cursor out sys_refcursor
);

---------------------------------------------------------------------------
-- UPDATES
---------------------------------------------------------------------------

-- Actualización de la información asociada al tipo de hilaza y talla
PROCEDURE actualizarTiHiProm (
    cod_tipo_hilaza NUMBER,
    cod_talla NUMBER,
    peso_tihiprom NUMBER,
    ancho_tihiprom NUMBER,
    usuario_tihiprom NUMBER
);


-- Aplicar la información del tipo de hilaza seleccionado en RENDTALL
PROCEDURE aplicarTipoHilaza (
    cod_tipo_hilaza NUMBER,
    usuario_rendtall NUMBER
);

---------------------------------------------------------------------------
-- DELETES
---------------------------------------------------------------------------

-- Eliminación de la información asociada al tipo de hilaza y talla
PROCEDURE eliminarTiHiProm (
    cod_tipo_hilaza NUMBER,
    cod_talla NUMBER
);

---------------------------------------------------------------------------
-- INSERTS
---------------------------------------------------------------------------

-- Insertar información asociada al tipo de hilaza y talla
PROCEDURE insertarTiHiProm (
    cod_tipo_hilaza NUMBER,
    cod_talla NUMBER,
    peso_tihiprom NUMBER,
    ancho_tihiprom NUMBER,
    usuario_tihiprom NUMBER
);

-----------------------------------------------------------------------------------------------------------------

end PKG_TIHIPROM;
/