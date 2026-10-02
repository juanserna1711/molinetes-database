CREATE OR REPLACE package body PKG_USUARIO

as

--=============================================================================
-- Nombre responsabilidad: Implementar el cuerpo del paquete PKG_USUARIO.
--
-- Autor: JUAN ANDRES SERNA CASTRO
-- Fecha_creacion: 13/Septiembre/2026
--
-- Descripcion responsabilidad:
-- Implementar las operaciones de consulta, actualización, activación, desactivación,
-- eliminación e inserción de USUARIO.
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

PROCEDURE consultaUsuario ( cod_usuario NUMBER, nom_usuario VARCHAR2, esta_usuario VARCHAR2, cursor OUT SYS_REFCURSOR ) is

begin

    OPEN cursor FOR
        SELECT
            USUACODI,
            USUANOMB,
            USUAPASS,
            USUAESTA
        FROM USUARIO
        WHERE (cod_usuario IS NULL OR USUACODI = cod_usuario)
          AND (nom_usuario IS NULL OR LOWER(USUANOMB) LIKE '%' || LOWER(nom_usuario) || '%')
          AND (esta_usuario IS NULL OR USUAESTA = esta_usuario)
        ORDER BY USUACODI ASC;

end;

PROCEDURE actualizarUsuario ( cod_usuario NUMBER, nom_usuario VARCHAR2, pass_usuario VARCHAR2, esta_usuario VARCHAR2) is

    begin

        UPDATE USUARIO

        SET USUANOMB =  nom_usuario, USUAPASS = pass_usuario, USUAESTA = esta_usuario

        WHERE USUACODI = cod_usuario;

        
        -- Valida que el USUARIO exista.
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

        
        -- Comprueba la existencia del usuario a partir de las filas afectadas por el DELETE.
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