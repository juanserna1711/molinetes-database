--=============================================================================
-- SCRIPT DE PRUEBAS - PKG_RENDTALLA
--
-- Autor: JUAN ANDRES SERNA CASTRO
-- Fecha: 10/Septiembre/2026
--
-- Objetivo:
-- Probar los procedimientos del paquete PKG_RENDTALLA:
--   - consultaRendTalla
--   - actualizarRendTalla
--   - insertarRendTalla
--   - eliminarRendTalla
--   - insertarRendTalla
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

SELECT *
FROM RENDTALL
ORDER BY RETATALL;


-- Verificar que la talla 12 no exista antes de comenzar las pruebas.

SELECT *
FROM TALLA
WHERE TALLCODI = 12;

SELECT *
FROM RENDTALL
WHERE RETATALL = 12;


--=============================================================================
-- 1. PRUEBA DE INSERTAR TALLA
--=============================================================================

BEGIN

    PKG_RENDTALLA.insertarRendTalla(
        cod_talla        => 12,
        nom_talla        => 'TALLA PRUEBA',
        esta_talla       => 'A',
        ancho_rendtall   => 50,
        peso_rendtall    => 200,
        rollo_rendtall   => 100,
        usuario_rendtall => 1
    );

END;
/
 
 
-- Verificar que se hayan creado TALLA y RENDTALL.

SELECT
    t.TALLCODI,
    t.TALLNOMB,
    t.TALLESTA,
    r.RETAANCH,
    r.RETAPESO,
    r.RETAROLL,
    r.RETAREND,
    r.RETAMETR,
    r.RETAFEGE,
    r.RETAUSUA
FROM TALLA t
INNER JOIN RENDTALL r
    ON t.TALLCODI = r.RETATALL
WHERE t.TALLCODI = 12;


--=============================================================================
-- 2. PRUEBA DE CONSULTA - SIN FILTROS
--=============================================================================

VARIABLE v_cursor REFCURSOR;

BEGIN

    PKG_RENDTALLA.consultaRendTalla(
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

    PKG_RENDTALLA.consultaRendTalla(
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

    PKG_RENDTALLA.consultaRendTalla(
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

    PKG_RENDTALLA.consultaRendTalla(
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

    PKG_RENDTALLA.actualizarRendTalla(
        cod_talla        => 12,
        nom_talla        => 'TALLA PRUEBA ACTUALIZADA',
        esta_talla       => 'A',
        ancho_rendtall   => 55,
        peso_rendtall    => 180,
        rollo_rendtall   => 80,
        usuario_rendtall => 1
    );

END;
/


-- Verificar actualización y cálculos.

SELECT
    t.TALLCODI,
    t.TALLNOMB,
    t.TALLESTA,
    r.RETAANCH,
    r.RETAPESO,
    r.RETAROLL,
    r.RETAREND,
    r.RETAMETR
FROM TALLA t
INNER JOIN RENDTALL r
    ON t.TALLCODI = r.RETATALL
WHERE t.TALLCODI = 12;


--=============================================================================
-- 7. PRUEBAS DE VALIDACIONES
--=============================================================================

-------------------------------------------------------------------------------
-- 7.1 Ancho igual a cero
-------------------------------------------------------------------------------

BEGIN

    PKG_RENDTALLA.actualizarRendTalla(
        cod_talla        => 12,
        nom_talla        => 'TALLA PRUEBA',
        esta_talla       => 'A',
        ancho_rendtall   => 0,
        peso_rendtall    => 180,
        rollo_rendtall   => 80,
        usuario_rendtall => 1
    );

END;
/

-- Se espera:
-- ORA-20001: El ancho de la talla debe ser mayor que cero.


-------------------------------------------------------------------------------
-- 7.2 Peso igual a cero
-------------------------------------------------------------------------------

BEGIN

    PKG_RENDTALLA.actualizarRendTalla(
        cod_talla        => 12,
        nom_talla        => 'TALLA PRUEBA',
        esta_talla       => 'A',
        ancho_rendtall   => 55,
        peso_rendtall    => 0,
        rollo_rendtall   => 80,
        usuario_rendtall => 1
    );

END;
/

-- Se espera:
-- ORA-20002: El peso debe ser mayor que cero.


-------------------------------------------------------------------------------
-- 7.3 Peso del rollo igual a cero
-------------------------------------------------------------------------------

BEGIN

    PKG_RENDTALLA.actualizarRendTalla(
        cod_talla        => 12,
        nom_talla        => 'TALLA PRUEBA',
        esta_talla       => 'A',
        ancho_rendtall   => 55,
        peso_rendtall    => 180,
        rollo_rendtall   => 0,
        usuario_rendtall => 1
    );

END;
/

-- Se espera:
-- ORA-20003: El peso del rollo debe ser mayor que cero.


--=============================================================================
-- 8. PRUEBA DE TALLA INEXISTENTE
--=============================================================================

BEGIN

    PKG_RENDTALLA.actualizarRendTalla(
        cod_talla        => 999,
        nom_talla        => 'NO EXISTE',
        esta_talla       => 'A',
        ancho_rendtall   => 50,
        peso_rendtall    => 200,
        rollo_rendtall   => 100,
        usuario_rendtall => 1
    );

END;
/

-- Se espera:
-- ORA-20005: La talla indicada no existe.


--=============================================================================
-- 9. PRUEBA DE ELIMINAR TALLA DE PRUEBA
--=============================================================================

BEGIN

    PKG_RENDTALLA.eliminarRendTalla(
        cod_talla => 12
    );

END;
/


--=============================================================================
-- 10. VERIFICAR QUE LA TALLA Y RENDTALL FUERON ELIMINADOS
--=============================================================================

SELECT *
FROM TALLA
WHERE TALLCODI = 12;

SELECT *
FROM RENDTALL
WHERE RETATALL = 12;


-- Ambos SELECT deberían devolver 0 registros.


--=============================================================================
-- 11. VERIFICACIÓN FINAL
--=============================================================================

SELECT
    t.TALLCODI,
    t.TALLNOMB,
    t.TALLESTA,
    r.RETAANCH,
    r.RETAPESO,
    r.RETAROLL,
    r.RETAREND,
    r.RETAMETR
FROM TALLA t
INNER JOIN RENDTALL r
    ON t.TALLCODI = r.RETATALL
ORDER BY t.TALLCODI;


--=============================================================================
-- FIN DEL SCRIPT
--=============================================================================