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

/*
Consulta tallas con filtros opcionales de nombre parcial.
El cursor OUT incluye rendimiento, metros por rollo, fecha y nombre del usuario.
*/
PROCEDURE consultaRendTalla ( nom_talla VARCHAR2, cursor OUT SYS_REFCURSOR ) is

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
        /*
        Conserva las tallas sin rendimiento y los rendimientos sin usuario coincidente.
        */
        LEFT JOIN RENDTALL r
            ON t.TALLCODI = r.RETATALL
        LEFT JOIN USUARIO u
            ON r.RETAUSUA = u.USUACODI
          WHERE (nom_talla IS NULL OR LOWER(t.TALLNOMB) LIKE '%' || LOWER(nom_talla) || '%')
        ORDER BY t.TALLCODI ASC;

end;

/*
Recalcula el rendimiento y los metros de una talla con información ya registrada.
*/
PROCEDURE actualizarRendTalla ( cod_talla NUMBER, ancho_rendtall NUMBER, peso_rendtall NUMBER, rollo_rendtall NUMBER, usuario_rendtall NUMBER ) is

    /*
    Resultados derivados: rendimiento por unidad de peso y metros correspondientes al rollo.
    */
    rendimiento_rendtall NUMBER;
    metros_rendtall      NUMBER;
    begin

        /*
        Exige ancho, peso y peso del rollo positivos y no nulos antes de calcular.
        Los errores -20001, -20002 y -20003 identifican respectivamente cada dato inválido.
        */
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

        /*
        El ancho duplicado y dividido entre 100 interviene junto con el peso en el denominador.
        1000 dividido entre ese producto obtiene el rendimiento; multiplicarlo por el peso
        del rollo obtiene sus metros. Se conserva la precisión de la expresión original.
        */
        rendimiento_rendtall := 1000 / ((ancho_rendtall * 2 / 100) * peso_rendtall);
        metros_rendtall := rollo_rendtall * rendimiento_rendtall;

        /*
        -20006 rechaza rendimiento superior a 99.9, límite documentado para RETAREND NUMBER(3,1).
        */
        IF rendimiento_rendtall > 99.9 THEN
            RAISE_APPLICATION_ERROR(
                -20006,
                'El rendimiento calculado supera el máximo permitido de 99.9.'
            );
        END IF;

        /*
        -20007 rechaza metros superiores a 99999.9, límite documentado para RETAMETR NUMBER(6,1).
        */
        IF metros_rendtall > 99999.9 THEN
            RAISE_APPLICATION_ERROR(
                -20007,
                'Los metros por rollo calculados superan el máximo permitido de 99999.9.'
            );
        END IF;

        /*
        Sustituye datos y resultados de la talla y registra fecha y usuario de esta actualización.
        */
        UPDATE RENDTALL

        SET RETAANCH = ancho_rendtall, RETAPESO = peso_rendtall, RETAROLL = rollo_rendtall, RETAREND = rendimiento_rendtall, RETAMETR = metros_rendtall,  RETAFEGE = SYSDATE, RETAUSUA = usuario_rendtall

        WHERE RETATALL = cod_talla;

        /*
        -20005 señala que no se afectó ningún rendimiento asociado a la talla.
        */
        IF SQL%ROWCOUNT = 0 THEN
            RAISE_APPLICATION_ERROR(
                -20005,
                'La talla no tiene información de rendimiento asociada.'
            );
        END IF;

        /*
        Confirma la actualización de RENDTALL.
        Confirma la transacción pendiente de la sesión, incluida la operación sobre RENDTALL.
        */
        COMMIT;

        /*
        Manejo general de excepciones:
        ROLLBACK revierte la transacción pendiente de la sesión y RAISE propaga el error original.
        */
        EXCEPTION
            WHEN OTHERS THEN
                ROLLBACK;
                RAISE;
    end;

/*
Elimina únicamente la información de RENDTALL asociada al código; conserva la fila de TALLA.
*/
PROCEDURE eliminarRendTalla (cod_talla number) is

    begin

        DELETE

        FROM RENDTALL

        WHERE RETATALL = cod_talla;

        /*
        Valida que la TALLA tenga un RENDTALL asociado antes de confirmar la eliminación.
        -20005 señala que no se afectó ningún rendimiento asociado a la talla.
        */
        IF SQL%ROWCOUNT = 0 THEN
            RAISE_APPLICATION_ERROR(
                -20005,
                'La talla no tiene información de rendimiento asociada.'
            );
        END IF;

        /*
        Confirma la eliminación de RENDTALL.
        Confirma la transacción pendiente de la sesión, incluida la operación sobre RENDTALL.
        */
        COMMIT;

    end;

/*
Crea el rendimiento de una talla existente que aún no tiene información en RENDTALL.
*/
PROCEDURE insertarRendTalla (cod_talla number, ancho_rendtall number, peso_rendtall number, rollo_rendtall number, usuario_rendtall number) is
    /*
    Resultados derivados: rendimiento por unidad de peso y metros correspondientes al rollo.
    */
    rendimiento_rendtall NUMBER;
    metros_rendtall      NUMBER;
    /*
    Conteos para comprobar existencia de la talla y ausencia de rendimiento previo.
    */
    cantidad_talla NUMBER;
    cantidad_rendtall NUMBER;
    begin

        /*
        Exige ancho, peso y peso del rollo positivos y no nulos antes de calcular.
        Los errores -20001, -20002 y -20003 identifican respectivamente cada dato inválido.
        */
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

        /*
        COUNT verifica la entidad de origen; -20004 informa que no existe la talla.
        */
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

            /*
            COUNT detecta rendimiento previo; -20012 evita registrar otra información para la talla.
            */
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

        /*
        El ancho duplicado y dividido entre 100 interviene junto con el peso en el denominador.
        1000 dividido entre ese producto obtiene el rendimiento; multiplicarlo por el peso
        del rollo obtiene sus metros. Se conserva la precisión de la expresión original.
        */
        rendimiento_rendtall := 1000 / ((ancho_rendtall * 2 / 100) * peso_rendtall);
        metros_rendtall := rollo_rendtall * rendimiento_rendtall;

        /*
        -20006 rechaza rendimiento superior a 99.9, límite documentado para RETAREND NUMBER(3,1).
        */
        IF rendimiento_rendtall > 99.9 THEN
            RAISE_APPLICATION_ERROR(
                -20006,
                'El rendimiento calculado supera el máximo permitido de 99.9.'
            );
        END IF;

        /*
        -20007 rechaza metros superiores a 99999.9, límite documentado para RETAMETR NUMBER(6,1).
        */
        IF metros_rendtall > 99999.9 THEN
            RAISE_APPLICATION_ERROR(
                -20007,
                'Los metros por rollo calculados superan el máximo permitido de 99999.9.'
            );
        END IF;

        /*
        Almacena medidas, resultados calculados y datos de usuario y fecha del registro.
        */
        INSERT INTO RENDTALL (RETATALL, RETAANCH, RETAPESO, RETAROLL, RETAREND, RETAMETR, RETAFEGE, RETAUSUA)

        VALUES (cod_talla, ancho_rendtall, peso_rendtall, rollo_rendtall, rendimiento_rendtall, metros_rendtall, SYSDATE, usuario_rendtall);

        /*
        Confirma la creación RENDTALL.
        Confirma la transacción pendiente de la sesión, incluida la operación sobre RENDTALL.
        */
        COMMIT;

        /*
        Manejo general de excepciones:
        ROLLBACK revierte la transacción pendiente de la sesión y RAISE propaga el error original.
        */
        EXCEPTION
            WHEN OTHERS THEN
                ROLLBACK;
                RAISE;
    end;

end PKG_RENDTALLA;