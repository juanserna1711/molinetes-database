CREATE OR REPLACE package body PKG_MODULO

as

--=============================================================================
-- Nombre responsabilidad: Implementar el cuerpo del paquete PKG_MODULO.
--
-- Autor: JUAN ANDRES SERNA CASTRO
-- Fecha_creacion: 13/Septiembre/2026
--
-- Descripcion responsabilidad:
-- Implementar las operaciones de consulta, actualización, eliminación e inserción de MODULO.
-- Las escrituras confirman la transacción pendiente de la sesión al completarse;
-- no incluyen un manejador local de excepciones.
--
--
-- Historial_modificaciones:
--
-- Autor:
-- Fecha:
-- Descripcion:
--=============================================================================

PROCEDURE consultaModulo ( cod_modulo NUMBER, nom_modulo VARCHAR2, zona_modulo VARCHAR2, cursor OUT SYS_REFCURSOR ) is

begin

    OPEN cursor FOR
        SELECT
            MODUCODI,
            MODUARCH,
            MODOMENU,
            MODUNOMB,
            MODUZONA,
            MODUORDE
        FROM MODULO
        WHERE (cod_modulo IS NULL OR MODUCODI = cod_modulo)
          AND (nom_modulo IS NULL OR LOWER(MODUNOMB) LIKE '%' || LOWER(nom_modulo) || '%')
          AND (zona_modulo IS NULL OR LOWER(MODUZONA) LIKE '%' || LOWER(zona_modulo) || '%')
        ORDER BY MODUCODI ASC;

end;

PROCEDURE actualizarModulo (cod_modulo NUMBER, arch_modulo VARCHAR2, menu_modulo NUMBER, nom_modulo VARCHAR2, zona_modulo VARCHAR2, orde_modulo NUMBER) is

    begin

        UPDATE USUARIO

        SET USUANOMB =  nom_usuario, USUAPASS = pass_usuario, USUAESTA = esta_usuario

        WHERE USUACODI = cod_usuario;
        
        --Valida que el USUARIO exista.
        -- -20008 informa que la operación precedente no encontró el código de usuario.
        
        IF SQL%ROWCOUNT = 0 THEN
            RAISE_APPLICATION_ERROR(
                -20008,
                'El usuario indicado no existe.'
            );
        END IF;
        
        COMMIT;
    end;

PROCEDURE activarUsuario ( cod_usuario NUMBER) is

    begin

        UPDATE USUARIO

        SET USUAESTA = 'A'

        WHERE USUACODI = cod_usuario;

        
        -- -20008 informa que la operación precedente no encontró el código de usuario.
        
        IF SQL%ROWCOUNT = 0 THEN
            RAISE_APPLICATION_ERROR(
                -20008,
                'El usuario indicado no existe.'
            );
        END IF;
        
        COMMIT;

    end;

PROCEDURE desactivarUsuario ( cod_usuario NUMBER) is

    begin

        UPDATE USUARIO

        SET USUAESTA = 'I'

        WHERE USUACODI = cod_usuario;

        
        -- -20008 informa que la operación precedente no encontró el código de usuario.
        
        IF SQL%ROWCOUNT = 0 THEN
            RAISE_APPLICATION_ERROR(
                -20008,
                'El usuario indicado no existe.'
            );
        END IF;
        
        COMMIT;

    end;

PROCEDURE eliminarUsuario (cod_usuario number) is

    begin

        DELETE

        FROM USUARIO

        WHERE USUACODI = cod_usuario;

        
        --Comprueba la existencia del usuario a partir de las filas afectadas por el DELETE.
        -- -20008 informa que la operación precedente no encontró el código de usuario.
        
        IF SQL%ROWCOUNT = 0 THEN
            RAISE_APPLICATION_ERROR(
                -20008,
                'El usuario indicado no existe.'
            );
        END IF;

        COMMIT;

    end;


PROCEDURE insertarUsuario (cod_usuario number, nom_usuario varchar2, pass_usuario varchar2, esta_usuario varchar2) is

    begin

        INSERT INTO USUARIO (USUACODI, USUANOMB, USUAPASS, USUAESTA)

        VALUES (cod_usuario, nom_usuario, pass_usuario, esta_usuario);

        COMMIT;

    end;

end PKG_USUARIO;