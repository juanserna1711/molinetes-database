CREATE OR REPLACE package body PKG_TALLA 
 
as 
 
  
--=============================================================================
-- Nombre responsabilidad: Implementar el cuerpo del paquete PKG_TALLA.
--
-- Autor: JUAN ANDRES SERNA CASTRO
-- Fecha_creacion: 09/Septiembre/2026
--
-- Descripcion responsabilidad:
-- Implementar las operaciones de consulta, actualización, activación,
-- desactivación e inserción de TALLA.
--
--
-- Historial_modificaciones:
--
-- Autor:
-- Fecha:
-- Descripcion:
--=============================================================================
 
PROCEDURE consultaTalla ( cod_talla NUMBER, nom_talla VARCHAR2, esta_talla VARCHAR2, cursor OUT SYS_REFCURSOR ) is 
 
begin 
 
    OPEN cursor FOR 
        SELECT 
            TALLCODI, 
            TALLNOMB, 
            TALLESTA
        FROM TALLA
        WHERE (cod_talla IS NULL OR TALLCODI = cod_talla) 
          AND (nom_talla IS NULL OR 
               LOWER(TALLNOMB) LIKE '%' || LOWER(nom_talla) || '%') 
          AND (esta_talla IS NULL OR TALLESTA = esta_talla) 
        ORDER BY TALLCODI ASC; 
 
end;
 
 
PROCEDURE actualizarTalla ( cod_talla NUMBER, nom_talla VARCHAR2, esta_talla VARCHAR2) is 

    begin

 
        UPDATE TALLA 
 
        SET TALLNOMB =  nom_talla, TALLESTA = esta_talla 
 
        WHERE TALLCODI = cod_talla; 
 
        -- Valida que la TALLA exista.
        IF SQL%ROWCOUNT = 0 THEN 
            RAISE_APPLICATION_ERROR( 
                -20004, 
                'La talla indicada no existe.' 
            ); 
        END IF;
 
        -- Confirma la actualización de TALLA.
        COMMIT;
    end; 
 
PROCEDURE activarTalla ( cod_talla NUMBER) is 
 
    begin
 
        UPDATE TALLA 
 
        SET TALLESTA = 'A' 
 
        WHERE TALLCODI = cod_talla; 
 
        IF SQL%ROWCOUNT = 0 THEN 
            RAISE_APPLICATION_ERROR( 
                -20004, 
                'La talla indicada no existe.' 
            ); 
        END IF; 
 
        -- Confirma el cambio de estado de la TALLA.
        COMMIT; 
 
    end; 
 
  
 
PROCEDURE desactivarTalla ( cod_talla NUMBER) is 
     
    begin
 
        UPDATE TALLA 
 
        SET TALLESTA = 'I' 
 
        WHERE TALLCODI = cod_talla; 
 
        IF SQL%ROWCOUNT = 0 THEN 
            RAISE_APPLICATION_ERROR( 
                -20004, 
                'La talla indicada no existe.' 
            ); 
        END IF; 
 
        -- Confirma el cambio de estado de la TALLA.
        COMMIT; 
 
    end; 
 
  
 
PROCEDURE insertarTalla (cod_talla number, nom_talla varchar2, esta_talla varchar2) is 
    begin

 
        INSERT INTO TALLA (TALLCODI, TALLNOMB, TALLESTA) 
 
        VALUES (cod_talla, nom_talla, esta_talla); 
 
        -- Confirma la creación de TALLA.
        COMMIT;

    end; 
 
end PKG_TALLA;