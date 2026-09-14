CREATE OR REPLACE package body PKG_USUARIO 
 
as 
 
  
--=============================================================================
-- Nombre responsabilidad: Implementar el cuerpo del paquete PKG_USUARIO.
--
-- Autor: JUAN ANDRES SERNA CASTRO
-- Fecha_creacion: 13/Septiembre/2026
--
-- Descripcion responsabilidad:
-- Implementar las operaciones de consulta, actualización, activación, desactivación, eliminacion e inserción de USUARIO.
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
          AND (nom_usuario IS NULL OR 
               LOWER(USUANOMB) LIKE '%' || LOWER(nom_usuario) || '%') 
          AND (esta_usuario IS NULL OR USUAESTA = esta_usuario) 
        ORDER BY USUACODI ASC; 
 
end;
 
 
PROCEDURE actualizarUsuario ( cod_usuario NUMBER, nom_usuario VARCHAR2, pass_usuario VARCHAR2, esta_usuario VARCHAR2) is 

    begin

 
        UPDATE USUARIO 
 
        SET USUANOMB =  nom_usuario, USUAPASS = pass_usuario, USUAESTA = esta_usuario 
 
        WHERE USUACODI = cod_usuario; 
 
        -- Valida que el USUARIO exista.
        IF SQL%ROWCOUNT = 0 THEN 
            RAISE_APPLICATION_ERROR( 
                -20008, 
                'El usuario indicado no existe.' 
            ); 
        END IF;
 
        -- Confirma la actualización de USUARIO.
        COMMIT;
    end; 
 

PROCEDURE activarUsuario ( cod_usuario NUMBER) is 
 
    begin
 
        UPDATE USUARIO 
 
        SET USUAESTA = 'A' 
 
        WHERE USUACODI = cod_usuario; 
 
        IF SQL%ROWCOUNT = 0 THEN 
            RAISE_APPLICATION_ERROR( 
                -20008, 
                'El usuario indicado no existe.' 
            ); 
        END IF; 
 
        -- Confirma el cambio de estado de la USUARIO.
        COMMIT; 
 
    end; 
 
  
 
PROCEDURE desactivarUsuario ( cod_usuario NUMBER) is 
     
    begin
 
        UPDATE USUARIO 
 
        SET USUAESTA = 'I' 
 
        WHERE USUACODI = cod_usuario; 
 
        IF SQL%ROWCOUNT = 0 THEN 
            RAISE_APPLICATION_ERROR( 
                -20008, 
                'El usuario indicado no existe.' 
            ); 
        END IF; 
 
        -- Confirma el cambio de estado de la USUARIO.
        COMMIT; 
 
    end; 


 
PROCEDURE eliminarUsuario (cod_usuario number) is 
 
    begin
 
        DELETE 
 
        FROM USUARIO 
 
        WHERE USUACODI = cod_usuario; 
 
        -- Valida que la USUARIO haya existido antes de confirmar la eliminación.
        IF SQL%ROWCOUNT = 0 THEN 
            RAISE_APPLICATION_ERROR( 
                -20008, 
                'El usuario indicado no existe.' 
            ); 
        END IF; 
 
        -- Confirma la eliminación de USUARIO.
        COMMIT; 
 
    end;
  
 
PROCEDURE insertarUsuario (cod_usuario number, nom_usuario varchar2, pass_usuario varchar2, esta_usuario varchar2) is 
    begin

 
        INSERT INTO USUARIO (USUACODI, USUANOMB, USUAPASS, USUAESTA) 
 
        VALUES (cod_usuario, nom_usuario, pass_usuario, esta_usuario); 
 
        -- Confirma la creación de USUARIO.
        COMMIT;

    end; 
 
end PKG_USUARIO;