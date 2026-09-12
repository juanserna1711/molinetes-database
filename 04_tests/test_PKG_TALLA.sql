--=============================================================================
-- SCRIPT DE PRUEBAS - PKG_TALLA
--
-- Autor: JUAN ANDRES SERNA CASTRO
-- Fecha: 10/Septiembre/2026
--
-- Objetivo:
-- Probar los procedimientos del paquete PKG_TALLA:
--   - consultaTalla
--   - actualizarTalla
--   - activarTalla
--   - desactivarTalla
--   - eliminarTalla
--   - insertarTalla
--
-- IMPORTANTE:
-- Se utilizará la TALLA 12 como registro de prueba.
--=============================================================================


--=============================================================================
-- 0. VERIFICAR DATOS EXISTENTES
--=============================================================================

SELECT *
FROM TALLA
ORDER BY TALLCODI;


-- Verificar que la talla 12 no exista antes de comenzar las pruebas.

SELECT *
FROM TALLA
WHERE TALLCODI = 12;


--=============================================================================
-- 1. PRUEBA DE INSERTAR TALLA
--=============================================================================

BEGIN

    PKG_TALLA.insertarTalla(
        cod_talla        => 12,
        nom_talla        => 'TALLA PRUEBA',
        esta_talla       => 'A'
    );

END;
/
 
 
-- Verificar que se hayan creado TALLA y RENDTALL.

SELECT
    t.TALLCODI,
    t.TALLNOMB,
    t.TALLESTA
FROM TALLA t
WHERE t.TALLCODI = 12;


--=============================================================================
-- 2. PRUEBA DE CONSULTA - SIN FILTROS
--=============================================================================

VARIABLE v_cursor REFCURSOR;

BEGIN

    PKG_TALLA.consultaTalla(
        cod_talla  => NULL,
        nom_talla  => NULL,
        esta_talla => NULL,
        cursor     => :v_cursor
    );

END;
/

PRINT v_cursor;


--=============================================================================
-- 3. PRUEBA DE CONSULTA - POR CÓDIGO
--=============================================================================

VARIABLE v_cursor REFCURSOR;

BEGIN

    PKG_TALLA.consultaTalla(
        cod_talla  => 12,
        nom_talla  => NULL,
        esta_talla => NULL,
        cursor     => :v_cursor
    );

END;
/

PRINT v_cursor;


--=============================================================================
-- 4. PRUEBA DE CONSULTA - POR NOMBRE
--=============================================================================

VARIABLE v_cursor REFCURSOR;

BEGIN

    PKG_TALLA.consultaTalla(
        cod_talla  => NULL,
        nom_talla  => 'PRUEBA',
        esta_talla => NULL,
        cursor     => :v_cursor
    );

END;
/

PRINT v_cursor;


--=============================================================================
-- 5. PRUEBA DE CONSULTA - POR ESTADO
--=============================================================================

VARIABLE v_cursor REFCURSOR;

BEGIN

    PKG_TALLA.consultaTalla(
        cod_talla  => NULL,
        nom_talla  => NULL,
        esta_talla => 'A',
        cursor     => :v_cursor
    );

END;
/

PRINT v_cursor;


--=============================================================================
-- 6. PRUEBA DE ACTUALIZAR TALLA
--=============================================================================

BEGIN

    PKG_TALLA.actualizarTalla(
        cod_talla        => 12,
        nom_talla        => 'TALLA PRUEBA ACTUALIZADA',
        esta_talla       => 'A'
    );

END;
/


-- Verificar actualización y cálculos.

SELECT
    t.TALLCODI,
    t.TALLNOMB,
    t.TALLESTA
FROM TALLA t
WHERE t.TALLCODI = 12;


--=============================================================================
-- 7. PRUEBA DE DESACTIVAR TALLA
--=============================================================================

BEGIN

    PKG_TALLA.desactivarTalla(
        cod_talla => 12
    );

END;
/


-- Verificar que el estado haya cambiado a I.

SELECT
    TALLCODI,
    TALLNOMB,
    TALLESTA
FROM TALLA
WHERE TALLCODI = 12;


--=============================================================================
-- 8. PRUEBA DE ACTIVAR TALLA
--=============================================================================

BEGIN

    PKG_TALLA.activarTalla(
        cod_talla => 12
    );

END;
/


-- Verificar que el estado haya cambiado nuevamente a A.

SELECT
    TALLCODI,
    TALLNOMB,
    TALLESTA
FROM TALLA
WHERE TALLCODI = 12;

--=============================================================================
-- 10. PRUEBA DE TALLA INEXISTENTE
--=============================================================================

BEGIN

    PKG_TALLA.actualizarTalla(
        cod_talla        => 999,
        nom_talla        => 'NO EXISTE',
        esta_talla       => 'A'
    );

END;
/

-- Se espera:
-- ORA-20004: La talla indicada no existe.


--=============================================================================
-- 13. VERIFICACIÓN FINAL
--=============================================================================

SELECT
    t.TALLCODI,
    t.TALLNOMB,
    t.TALLESTA
FROM TALLA t
ORDER BY t.TALLCODI;


--=============================================================================
-- FIN DEL SCRIPT
--=============================================================================