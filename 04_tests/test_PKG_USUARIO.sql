--=============================================================================
-- SCRIPT DE PRUEBAS - PKG_USUARIO
--
-- Autor: JUAN ANDRES SERNA CASTRO
-- Fecha: 10/Septiembre/2026
--
-- Objetivo:
-- Probar los procedimientos del paquete PKG_USUARIO:
--   - consultaUsuario
--   - actualizarUsuario
--   - activarUsuario
--   - desactivarUsuario
--   - eliminarUsuario
--   - insertarUsuario
--
-- IMPORTANTE:
-- Se utilizará el USUARIO 99 como registro de prueba.
--=============================================================================


--=============================================================================
-- 0. VERIFICAR DATOS EXISTENTES
--=============================================================================

SELECT *
FROM USUARIO
ORDER BY USUCCODI;


-- Verificar que el usuario 99 no exista antes de comenzar las pruebas.

SELECT *
FROM USUARIO
WHERE USUCCODI = 99;


--=============================================================================
-- 1. PRUEBA DE INSERTAR USUARIO
--=============================================================================

BEGIN

    PKG_USUARIO.insertarUsuario(
        cod_usuario      => 99,
        nom_usuario      => 'USUARIO PRUEBA',
        esta_usuario     => 'A'
    );

END;
/
 
 
-- Verificar que se haya creado el usuario.

SELECT
    u.USUACCODI,
    u.USUANOMB,
    u.USUAESTA
FROM USUARIO u
WHERE u.USUACCODI = 99;


--=============================================================================
-- 2. PRUEBA DE CONSULTA - SIN FILTROS
--=============================================================================

VARIABLE v_cursor REFCURSOR;

BEGIN

    PKG_USUARIO.consultaUsuario(
        cod_usuario  => NULL,
        nom_usuario  => NULL,
        esta_usuario => NULL,
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

    PKG_USUARIO.consultaUsuario(
        cod_usuario  => 99,
        nom_usuario  => NULL,
        esta_usuario => NULL,
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

    PKG_USUARIO.consultaUsuario(
        cod_usuario  => NULL,
        nom_usuario  => 'PRUEBA',
        esta_usuario => NULL,
        cursor         => :v_cursor
    );

END;
/

PRINT v_cursor;


--=============================================================================
-- 5. PRUEBA DE CONSULTA - POR ESTADO
--=============================================================================

VARIABLE v_cursor REFCURSOR;

BEGIN

    PKG_USUARIO.consultaUsuario(
        cod_usuario  => NULL,
        nom_usuario  => NULL,
        esta_usuario => 'A',
        cursor         => :v_cursor
    );

END;
/

PRINT v_cursor;


--=============================================================================
-- 6. PRUEBA DE ACTUALIZAR USUARIO
--=============================================================================

BEGIN

    PKG_USUARIO.actualizarUsuario(
        cod_usuario      => 99,
        nom_usuario      => 'USUARIO PRUEBA ACTUALIZADO',
        esta_usuario     => 'A'
    );

END;
/


-- Verificar actualización y cálculos.

SELECT
    u.USUACCODI,
    u.USUANOMB,
    u.USUAESTA
FROM USUARIO u
WHERE u.USUACCODI = 99;


--=============================================================================
-- 7. PRUEBA DE DESACTIVAR USUARIO
--=============================================================================

BEGIN

    PKG_USUARIO.desactivarUsuario(
        cod_usuario => 99
    );

END;
/


-- Verificar que el estado haya cambiado a I.

SELECT
    u.USUACCODI,
    u.USUANOMB,
    u.USUAESTA
FROM USUARIO u
WHERE u.USUACCODI = 99;


--=============================================================================
-- 8. PRUEBA DE ACTIVAR USUARIO
--=============================================================================

BEGIN

    PKG_USUARIO.activarUsuario(
        cod_usuario => 99
    );

END;
/


-- Verificar que el estado haya cambiado nuevamente a A.

SELECT
    u.USUACCODI,
    u.USUANOMB,
    u.USUAESTA
FROM USUARIO u
WHERE u.USUACCODI = 99;

--=============================================================================
-- 9. PRUEBA DE ELIMINAR USUARIO DE PRUEBA
--=============================================================================

BEGIN

    PKG_USUARIO.eliminarUsuario(
        cod_usuario => 99
    );

END;
/

--=============================================================================
-- 10. PRUEBA DE USUARIO INEXISTENTE
--=============================================================================

BEGIN

    PKG_USUARIO.actualizarUsuario(
        cod_usuario      => 999,
        nom_usuario      => 'NO EXISTE',
        esta_usuario     => 'A'
    );

END;
/

-- Se espera:
-- ORA-20008: El usuario indicado no existe.


--=============================================================================
-- 13. VERIFICACIÓN FINAL
--=============================================================================

SELECT
    u.USUACCODI,
    u.USUANOMB,
    u.USUAESTA
FROM USUARIO u
ORDER BY u.USUACCODI;


--=============================================================================
-- FIN DEL SCRIPT
--=============================================================================