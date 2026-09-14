--=============================================================================
-- SCRIPT DE PRUEBAS - PKG_MOLINETE
--
-- Autor: JUAN ANDRES SERNA CASTRO
-- Fecha: 10/Septiembre/2026
--
-- Objetivo:
-- Probar los procedimientos del paquete PKG_MOLINETE:
--   - consultaMolinete
--   - actualizarMolinete
--   - eliminarMolinete
--   - insertarMolinete
--
-- IMPORTANTE:
-- Se utilizará el MOLINETE 99 como registro de prueba.
--=============================================================================


--=============================================================================
-- 0. VERIFICAR DATOS EXISTENTES
--=============================================================================

SELECT *
FROM MOLINETE
ORDER BY MOLICODI;


-- Verificar que el molinete 99 no exista antes de comenzar las pruebas.

SELECT *
FROM MOLINETE
WHERE MOLICODI = 99;


--=============================================================================
-- 1. PRUEBA DE INSERTAR MOLINETE
--=============================================================================

BEGIN

    PKG_MOLINETE.insertarMolinete(
        cod_molinete      => 99,
        nom_molinete      => 'MOLINETE PRUEBA',
        rpm_molinete      => 250,
        peri_molinete     => 78
    );

END;
/
 
 
-- Verificar que se haya creado el molinete.

SELECT
    m.MOLICODI,
    m.MOLINOMB,
    m.MOLIRPM,
    m.MOLIPERI
FROM MOLINETE m
WHERE m.MOLICODI = 99;


--=============================================================================
-- 2. PRUEBA DE CONSULTA - SIN FILTROS
--=============================================================================

VARIABLE v_cursor REFCURSOR;

BEGIN

    PKG_MOLINETE.consultaMolinete(
        cod_molinete  => NULL,
        nom_molinete  => NULL,
        cursor         => :v_cursor
    );

END;
/

PRINT v_cursor;


--=============================================================================
-- 3. PRUEBA DE CONSULTA - POR CÓDIGO
--=============================================================================

VARIABLE v_cursor REFCURSOR;

BEGIN

    PKG_MOLINETE.consultaMolinete(
        cod_molinete  => 99,
        nom_molinete  => NULL,
        cursor         => :v_cursor
    );

END;
/

PRINT v_cursor;


--=============================================================================
-- 4. PRUEBA DE CONSULTA - POR NOMBRE
--=============================================================================

VARIABLE v_cursor REFCURSOR;

BEGIN

    PKG_MOLINETE.consultaMolinete(
        cod_molinete  => NULL,
        nom_molinete  => 'PRUEBA',
        cursor         => :v_cursor
    );

END;
/

PRINT v_cursor;



--=============================================================================
-- 5. PRUEBA DE ACTUALIZAR MOLINETE
--=============================================================================

BEGIN

    PKG_MOLINETE.actualizarMolinete(
        cod_molinete      => 99,
        nom_molinete      => 'MOLINETE PRUEBA ACTUALIZADO',
        rpm_molinete      => 300,
        peri_molinete     => 80
    );

END;
/


-- Verificar actualización y cálculos.


SELECT
    m.MOLICODI,
    m.MOLINOMB,
    m.MOLIRPM,
    m.MOLIPERI
FROM MOLINETE m
WHERE m.MOLICODI = 99;


--=============================================================================
-- 9. PRUEBA DE ELIMINAR MOLINETE DE PRUEBA
--=============================================================================

BEGIN

    PKG_MOLINETE.eliminarMolinete(
        cod_molinete => 99
    );

END;
/

--=============================================================================
-- 10. PRUEBA DE MOLINETE INEXISTENTE
--=============================================================================

BEGIN

    PKG_MOLINETE.actualizarMolinete(
        cod_molinete      => 999,
        nom_molinete      => 'NO EXISTE',
        rpm_molinete      => 300,
        peri_molinete     => 80
    );

END;
/

-- Se espera:
-- ORA-20009: El molinete indicado no existe.


--=============================================================================
-- 13. VERIFICACIÓN FINAL
--=============================================================================

SELECT
    m.MOLICODI,
    m.MOLINOMB,
    m.MOLIRPM,
    m.MOLIPERI
FROM MOLINETE m
ORDER BY m.MOLICODI;


--=============================================================================
-- FIN DEL SCRIPT
--=============================================================================