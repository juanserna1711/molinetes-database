CREATE OR REPLACE package body PKG_RENDTALLA 
 
as 
 
  
--=============================================================================
-- Nombre responsabilidad: Implementar el cuerpo del paquete PKG_RENDTALLA.
--
-- Autor: JUAN ANDRES SERNA CASTRO
-- Fecha_creacion: 09/Septiembre/2026
--
-- Descripcion responsabilidad:
-- Implementar las operaciones de consulta, actualización, eliminación
-- e inserción de la información de RENDTALL asociada a las TALLA.
--
-- Historial_modificaciones:
--
-- Autor:
-- Fecha:
-- Descripcion:
--=============================================================================
 
PROCEDURE consultaRendTalla ( cod_talla NUMBER, nom_talla VARCHAR2, esta_talla VARCHAR2, cursor OUT SYS_REFCURSOR ) is 
 
begin 
 
    OPEN cursor FOR 
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
            u.USUANOMB AS NOMBRE_USUARIO 
        FROM TALLA t 
        LEFT JOIN RENDTALL r 
            ON t.TALLCODI = r.RETATALL 
        LEFT JOIN USUARIO u 
            ON r.RETAUSUA = u.USUACODI 
        WHERE (cod_talla IS NULL OR t.TALLCODI = cod_talla) 
          AND (nom_talla IS NULL OR 
               LOWER(t.TALLNOMB) LIKE '%' || LOWER(nom_talla) || '%') 
          AND (esta_talla IS NULL OR t.TALLESTA = esta_talla) 
        ORDER BY t.TALLCODI ASC; 
 
end; 
 
 
PROCEDURE actualizarRendTalla ( cod_talla NUMBER, ancho_rendtall NUMBER, peso_rendtall NUMBER, rollo_rendtall NUMBER, usuario_rendtall NUMBER ) is 
 
    rendimiento_rendtall NUMBER;
    metros_rendtall      NUMBER;
    begin 
 
        -- Validaciones 
        IF ancho_rendtall <= 0 OR ancho_rendtall IS NULL THEN 
            RAISE_APPLICATION_ERROR( 
                -20001, 
                'El ancho de la talla debe ser mayor que cero.' 
            ); 
        END IF; 
 
        IF peso_rendtall <= 0 OR peso_rendtall IS NULL THEN 
            RAISE_APPLICATION_ERROR( 
                -20002, 
                'El peso debe ser mayor que cero.' 
            ); 
        END IF; 
 
        IF rollo_rendtall <= 0 OR rollo_rendtall IS NULL THEN 
            RAISE_APPLICATION_ERROR( 
                -20003, 
                'El peso del rollo debe ser mayor que cero.' 
            ); 
        END IF;

         -- Cálculos de rendimiento
        rendimiento_rendtall := 1000 / ((ancho_rendtall * 2 / 100) * peso_rendtall);
        metros_rendtall := rollo_rendtall * rendimiento_rendtall;
 

        -- Validación según precisión de RETAREND NUMBER(3,1)
        IF rendimiento_rendtall > 99.9 THEN
            RAISE_APPLICATION_ERROR(
                -20006,
                'El rendimiento calculado supera el máximo permitido de 99.9.'
            );
        END IF;

        -- Validación según precisión de RETAMETR NUMBER(6,1)
        IF metros_rendtall > 99999.9 THEN
            RAISE_APPLICATION_ERROR(
                -20007,
                'Los metros por rollo calculados superan el máximo permitido de 99999.9.'
            );
        END IF;
 
        UPDATE RENDTALL 
 
        SET RETAANCH = ancho_rendtall, RETAPESO = peso_rendtall, RETAROLL = rollo_rendtall, RETAREND = rendimiento_rendtall, RETAMETR = metros_rendtall,  RETAFEGE = SYSDATE, RETAUSUA = usuario_rendtall 
 
        WHERE RETATALL = cod_talla; 
 
        IF SQL%ROWCOUNT = 0 THEN
            RAISE_APPLICATION_ERROR(
                -20005,
                'La talla no tiene información de rendimiento asociada.'
            );
        END IF;
 
        -- Confirma la actualización de RENDTALL.
        COMMIT; 
        
        -- Manejo general de excepciones:
        -- Ante cualquier error durante la operación se revierten los cambios realizados.
        EXCEPTION 
            WHEN OTHERS THEN 
                ROLLBACK; 
                RAISE; 
    end; 

 
PROCEDURE eliminarRendTalla (cod_talla number) is 
 
    begin
 
        DELETE 
 
        FROM RENDTALL 
 
        WHERE RETATALL = cod_talla;
 
        -- Valida que la TALLA tenga un RENDTALL asociado antes de confirmar la eliminación.
        IF SQL%ROWCOUNT = 0 THEN 
            RAISE_APPLICATION_ERROR( 
                -20005, 
                'La talla no tiene información de rendimiento asociada.' 
            ); 
        END IF; 
 
        -- Confirma la eliminación de RENDTALL.
        COMMIT; 
 
    end; 
 
  
 
PROCEDURE insertarRendTalla (cod_talla number, ancho_rendtall number, peso_rendtall number, rollo_rendtall number, usuario_rendtall number) is 
    rendimiento_rendtall NUMBER;
    metros_rendtall      NUMBER;
    cantidad_talla NUMBER;
    cantidad_rendtall NUMBER;
    begin
        
        -- Validaciones
        IF ancho_rendtall <= 0 OR ancho_rendtall IS NULL THEN 
            RAISE_APPLICATION_ERROR( 
                -20001, 
                'El ancho de la talla debe ser mayor que cero.' 
            ); 
        END IF; 
 
        IF peso_rendtall <= 0 OR peso_rendtall IS NULL THEN 
            RAISE_APPLICATION_ERROR( 
                -20002, 
                'El peso por metro cuadrado debe ser mayor que cero.' 
            ); 
        END IF; 
 
        IF rollo_rendtall <= 0 OR rollo_rendtall IS NULL THEN 
            RAISE_APPLICATION_ERROR( 
                -20003, 
                'El peso del rollo debe ser mayor que cero.' 
            ); 
        END IF;

         
        -- Verificar que la talla exista
            SELECT COUNT(*)
            INTO cantidad_talla
            FROM TALLA
            WHERE TALLCODI = cod_talla;

            IF cantidad_talla = 0 THEN
                RAISE_APPLICATION_ERROR(
                    -20004,
                    'La talla indicada no existe.'
                );
            END IF;

            -- Verificar que no tenga rendimiento
            SELECT COUNT(*)
            INTO cantidad_rendtall
            FROM RENDTALL
            WHERE RETATALL = cod_talla;

            IF cantidad_rendtall > 0 THEN
                RAISE_APPLICATION_ERROR(
                    -20012,
                    'La talla ya tiene información de rendimiento asociada.'
                );
            END IF;

        -- Cálculos de rendimiento
        rendimiento_rendtall := 1000 / ((ancho_rendtall * 2 / 100) * peso_rendtall);
        metros_rendtall := rollo_rendtall * rendimiento_rendtall;

        
        -- Validación según precisión de RETAREND NUMBER(3,1)
        IF rendimiento_rendtall > 99.9 THEN
            RAISE_APPLICATION_ERROR(
                -20006,
                'El rendimiento calculado supera el máximo permitido de 99.9.'
            );
        END IF;

        -- Validación según precisión de RETAMETR NUMBER(6,1)
        IF metros_rendtall > 99999.9 THEN
            RAISE_APPLICATION_ERROR(
                -20007,
                'Los metros por rollo calculados superan el máximo permitido de 99999.9.'
            );
        END IF;

        INSERT INTO RENDTALL (RETATALL, RETAANCH, RETAPESO, RETAROLL, RETAREND, RETAMETR, RETAFEGE, RETAUSUA) 
 
        VALUES (cod_talla, ancho_rendtall, peso_rendtall, rollo_rendtall, rendimiento_rendtall, metros_rendtall, SYSDATE, usuario_rendtall); 
 
        -- Confirma la creación RENDTALL.
        COMMIT; 
 
        -- Manejo general de excepciones:
        -- Si cualquiera de los INSERT genera un error, se revierten
        -- las operaciones realizadas.
        EXCEPTION 
            WHEN OTHERS THEN 
                ROLLBACK; 
                RAISE; 
    end; 
 
end PKG_RENDTALLA;