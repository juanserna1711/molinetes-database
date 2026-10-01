CREATE OR REPLACE package PKG_MOLINETE
as

--=============================================================================
-- Nombre responsabilidad: Crear la especificación (.pks) del paquete `PKG_MOLINETE` para la gestión de los molinetes.
--
-- Autor: JUAN ANDRES SERNA CASTRO
-- Fecha_creacion: 13/Septiembre/2026
--
-- Descripcion responsabilidad:
-- Declarar la interfaz pública de consulta, inserción, actualización y eliminación de los molinetes.
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

--Consulta de molinetes con parámetros de código y nombre.

PROCEDURE consultaMolinete (
    cod_molinete NUMBER,
    nom_molinete VARCHAR2,
    cursor out sys_refcursor
);

-------------------------------------------------------------------------
--UPDATES
-------------------------------------------------------------------------

--Actualización del molinete por código con los valores nom_molinete, rpm_molinete y peri_molinete.

PROCEDURE actualizarMolinete (
    cod_molinete NUMBER,
    nom_molinete VARCHAR2,
    rpm_molinete NUMBER,
    peri_molinete NUMBER
);

-------------------------------------------------------------------------
--DELETES
-------------------------------------------------------------------------

--Eliminación del molinete identificado por su código.

PROCEDURE eliminarMolinete (
    cod_molinete NUMBER
);

-------------------------------------------------------------------------
--INSERTS
-------------------------------------------------------------------------

--Inserción de un molinete con los valores cod_molinete, nom_molinete, rpm_molinete y peri_molinete.

PROCEDURE insertarMolinete (
    cod_molinete NUMBER,
    nom_molinete VARCHAR2,
    rpm_molinete NUMBER,
    peri_molinete NUMBER
);

---------------------------------------------------------------------------------------------------------------

end PKG_MOLINETE;

/