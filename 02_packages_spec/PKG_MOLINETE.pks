CREATE OR REPLACE package PKG_MOLINETE

as

 

--=============================================================================
-- Nombre responsabilidad: Crear la especificación (.pks) del paquete `PKG_MOLINETE` para la gestión de los molinetes.
--
-- Autor: JUAN ANDRES SERNA CASTRO
-- Fecha_creacion: 13/Septiembre/2026
--
-- Descripcion responsabilidad:
-- Gestionar las operaciones de consulta, inserción, actualización y eliminación de los molinetes.
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


-- Consultar MOLINETE
PROCEDURE consultaMolinete (
    cod_molinete NUMBER,  
    nom_molinete VARCHAR2,
    cursor out sys_refcursor
);
---------------------------------------------------------------------------
-- UPDATES
---------------------------------------------------------------------------

-- Actualización de MOLINETE
PROCEDURE actualizarMolinete (
    cod_molinete NUMBER,
    nom_molinete VARCHAR2,
    rpm_molinete NUMBER,
    peri_molinete NUMBER
);


---------------------------------------------------------------------------
-- DELETES
---------------------------------------------------------------------------

-- Eliminación de MOLINETE
PROCEDURE eliminarMolinete (
    cod_molinete NUMBER
);

---------------------------------------------------------------------------
-- INSERTS
---------------------------------------------------------------------------

--Insertar MOLINETE
PROCEDURE insertarMolinete (
    cod_molinete NUMBER,
    nom_molinete VARCHAR2,
    rpm_molinete NUMBER,
    peri_molinete NUMBER
);

-----------------------------------------------------------------------------------------------------------------

end PKG_MOLINETE;

/