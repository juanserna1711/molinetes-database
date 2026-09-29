CREATE OR REPLACE package body PKG_TIHIPROM
 
as
 
  
--=============================================================================
-- Nombre responsabilidad: Implementar el cuerpo del paquete PKG_TIHIPROM.
--
-- Autor: JUAN ANDRES SERNA CASTRO
-- Fecha_creacion: 24/Septiembre/2026
--
-- Descripcion responsabilidad:
-- Implementar las operaciones de consulta, actualización, eliminación,
-- inserción y aplicación de la información de TIHIPROM asociada a TIPOHILA
-- y TALLA.
--
-- Historial_modificaciones:
--
-- Autor:
-- Fecha:
-- Descripcion:
--=============================================================================


---------------------------------------------------------------------------
-- PROCEDIMIENTOS PRIVADOS
---------------------------------------------------------------------------

-- Recalcula el promedio de los pesos asociados a un tipo de hilaza.
PROCEDURE recalcularPromedio (cod_tipo_hilaza NUMBER) is

    promedio_tihiprom NUMBER;

    begin

        SELECT ROUND(AVG(TIHPPESO))
        INTO promedio_tihiprom
        FROM TIHIPROM
        WHERE TIHPHILA = cod_tipo_hilaza;


        UPDATE TIHIPROM

        SET TIHPPROM = promedio_tihiprom

        WHERE TIHPHILA = cod_tipo_hilaza;

    end;


---------------------------------------------------------------------------
-- SELECTS
---------------------------------------------------------------------------

PROCEDURE consultaTiHiProm ( cod_tipo_hilaza NUMBER, cod_talla NUMBER, cursor OUT SYS_REFCURSOR ) is
 
begin
 
    OPEN cursor FOR
        SELECT
            h.TIHICODI,
            h.TIHINOMB,
            t.TALLCODI,
            t.TALLNOMB,
            p.TIHPPESO,
            p.TIHPANCH,
            p.TIHPPROM,
            p.TIHPFEGE,
            u.USUANOMB AS NOMBRE_USUARIO
        FROM TIHIPROM p
        INNER JOIN TIPOHILA h
            ON p.TIHPHILA = h.TIHICODI
        INNER JOIN TALLA t
            ON p.TIHPTALL = t.TALLCODI
        LEFT JOIN USUARIO u
            ON p.TIHPUSUA = u.USUACODI
        WHERE (cod_tipo_hilaza IS NULL OR p.TIHPHILA = cod_tipo_hilaza)
          AND (cod_talla IS NULL OR p.TIHPTALL = cod_talla)
        ORDER BY h.TIHICODI ASC, t.TALLCODI ASC;
 
end;


---------------------------------------------------------------------------
-- UPDATES
---------------------------------------------------------------------------

PROCEDURE actualizarTiHiProm (
    cod_tipo_hilaza NUMBER,
    cod_talla NUMBER,
    peso_tihiprom NUMBER,
    ancho_tihiprom NUMBER,
    usuario_tihiprom NUMBER
) is

    begin

        -- Validaciones
        IF ancho_tihiprom <= 0 OR ancho_tihiprom IS NULL THEN
            RAISE_APPLICATION_ERROR(
                -20001,
                'El ancho de la talla debe ser mayor que cero.'
            );
        END IF;

        IF peso_tihiprom <= 0 OR peso_tihiprom IS NULL THEN
            RAISE_APPLICATION_ERROR(
                -20002,
                'El peso por metro cuadrado debe ser mayor que cero.'
            );
        END IF;


        UPDATE TIHIPROM

        SET TIHPPESO = peso_tihiprom,
            TIHPANCH = ancho_tihiprom,
            TIHPFEGE = SYSDATE,
            TIHPUSUA = usuario_tihiprom

        WHERE TIHPHILA = cod_tipo_hilaza
          AND TIHPTALL = cod_talla;


        -- Valida que la información asociada exista.
        IF SQL%ROWCOUNT = 0 THEN
            RAISE_APPLICATION_ERROR(
                -20021,
                'El tipo de hilaza no tiene información asociada para la talla indicada.'
            );
        END IF;


        -- Recalcula el promedio del tipo de hilaza.
        recalcularPromedio(cod_tipo_hilaza);


        -- Confirma la actualización de TIHIPROM.
        COMMIT;

        -- Manejo general de excepciones:
        -- Ante cualquier error durante la operación se revierten los cambios realizados.
        EXCEPTION
            WHEN OTHERS THEN
                ROLLBACK;
                RAISE;

    end;


---------------------------------------------------------------------------
-- APLICAR TIPO DE HILAZA
---------------------------------------------------------------------------

PROCEDURE aplicarTipoHilaza (
    cod_tipo_hilaza NUMBER,
    usuario_rendtall NUMBER
) is

    rendimiento_rendtall NUMBER;
    metros_rendtall NUMBER;
    peso_rendtall NUMBER;
    rollo_rendtall NUMBER;
    cantidad_tihiprom NUMBER;

    begin

        -- Verifica que el tipo de hilaza tenga información asociada.
        SELECT COUNT(*)
        INTO cantidad_tihiprom
        FROM TIHIPROM
        WHERE TIHPHILA = cod_tipo_hilaza;


        IF cantidad_tihiprom = 0 THEN
            RAISE_APPLICATION_ERROR(
                -20022,
                'El tipo de hilaza no tiene información de promedio asociada.'
            );
        END IF;


        /*
          Recorre las tallas asociadas al tipo de hilaza y actualiza
          la información vigente de RENDTALL.
        */
        FOR registro IN (

            SELECT
                p.TIHPTALL,
                p.TIHPANCH,
                p.TIHPPROM,
                t.TALLNOMB
            FROM TIHIPROM p
            INNER JOIN TALLA t
                ON p.TIHPTALL = t.TALLCODI
            WHERE p.TIHPHILA = cod_tipo_hilaza
            ORDER BY p.TIHPTALL ASC

        ) LOOP


            /*
              Obtiene el peso del rollo y el peso actualmente almacenado.
              El peso del rollo no cambia al aplicar un tipo de hilaza.
            */
            BEGIN

                SELECT
                    RETAROLL,
                    RETAPESO
                INTO
                    rollo_rendtall,
                    peso_rendtall
                FROM RENDTALL
                WHERE RETATALL = registro.TIHPTALL;

            EXCEPTION

                WHEN NO_DATA_FOUND THEN

                    RAISE_APPLICATION_ERROR(
                        -20005,
                        'La talla no tiene información de rendimiento asociada.'
                    );

            END;


            /*
              Para las tallas normales se utiliza el promedio del tipo
              de hilaza como peso.

              RIB conserva el peso que ya tiene registrado en RENDTALL.
            */
            IF UPPER(TRIM(registro.TALLNOMB)) <> 'RIB' THEN

                peso_rendtall := registro.TIHPPROM;

            END IF;


            -- Cálculos de rendimiento
            rendimiento_rendtall :=
                1000 /
                (
                    (registro.TIHPANCH * 2 / 100) *
                    peso_rendtall
                );

            metros_rendtall :=
                rollo_rendtall *
                rendimiento_rendtall;


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

            SET RETAANCH = registro.TIHPANCH,
                RETAPESO = peso_rendtall,
                RETAREND = rendimiento_rendtall,
                RETAMETR = metros_rendtall,
                RETAFEGE = SYSDATE,
                RETAUSUA = usuario_rendtall

            WHERE RETATALL = registro.TIHPTALL;


            IF SQL%ROWCOUNT = 0 THEN

                RAISE_APPLICATION_ERROR(
                    -20005,
                    'La talla no tiene información de rendimiento asociada.'
                );

            END IF;


        END LOOP;


        -- Confirma la aplicación del tipo de hilaza en RENDTALL.
        COMMIT;


        -- Manejo general de excepciones:
        -- Si alguna talla genera un error se revierten todas las actualizaciones.
        EXCEPTION
            WHEN OTHERS THEN
                ROLLBACK;
                RAISE;

    end;


---------------------------------------------------------------------------
-- DELETES
---------------------------------------------------------------------------

PROCEDURE eliminarTiHiProm (
    cod_tipo_hilaza NUMBER,
    cod_talla NUMBER
) is

    begin

        DELETE

        FROM TIHIPROM

        WHERE TIHPHILA = cod_tipo_hilaza
          AND TIHPTALL = cod_talla;


        -- Valida que la información asociada haya existido.
        IF SQL%ROWCOUNT = 0 THEN
            RAISE_APPLICATION_ERROR(
                -20021,
                'El tipo de hilaza no tiene información asociada para la talla indicada.'
            );
        END IF;


        /*
          Al eliminar un peso cambia el promedio del tipo de hilaza,
          por lo que se recalcula para los registros restantes.
        */
        recalcularPromedio(cod_tipo_hilaza);


        -- Confirma la eliminación de TIHIPROM.
        COMMIT;


        -- Manejo general de excepciones:
        -- Ante cualquier error durante la operación se revierten los cambios realizados.
        EXCEPTION
            WHEN OTHERS THEN
                ROLLBACK;
                RAISE;

    end;


---------------------------------------------------------------------------
-- INSERTS
---------------------------------------------------------------------------
PROCEDURE insertarTiHiProm (
        cod_tipo_hilaza NUMBER,
        cod_talla NUMBER,
        peso_tihiprom NUMBER,
        ancho_tihiprom NUMBER,
        usuario_tihiprom NUMBER
    ) is

        cantidad_tipo_hilaza NUMBER;
        cantidad_tihiprom NUMBER;
        nombre_talla VARCHAR2(60);

        begin

            -- Validaciones
            IF ancho_tihiprom <= 0 OR ancho_tihiprom IS NULL THEN
                RAISE_APPLICATION_ERROR(
                    -20001,
                    'El ancho de la talla debe ser mayor que cero.'
                );
            END IF;

            IF peso_tihiprom <= 0 OR peso_tihiprom IS NULL THEN
                RAISE_APPLICATION_ERROR(
                    -20002,
                    'El peso por metro cuadrado debe ser mayor que cero.'
                );
            END IF;


            -- Verificar que el tipo de hilaza exista
            SELECT COUNT(*)
            INTO cantidad_tipo_hilaza
            FROM TIPOHILA
            WHERE TIHICODI = cod_tipo_hilaza;


            IF cantidad_tipo_hilaza = 0 THEN

                RAISE_APPLICATION_ERROR(
                    -20018,
                    'El tipo de hilaza indicado no existe.'
                );

            END IF;


            -- Verificar que la talla exista
            BEGIN

                SELECT TALLNOMB
                INTO nombre_talla
                FROM TALLA
                WHERE TALLCODI = cod_talla;

            EXCEPTION

                WHEN NO_DATA_FOUND THEN

                    RAISE_APPLICATION_ERROR(
                        -20004,
                        'La talla indicada no existe.'
                    );

            END;


            -- RIB no participa en TIHIPROM
            IF UPPER(TRIM(nombre_talla)) = 'RIB' THEN

                RAISE_APPLICATION_ERROR(
                    -20023,
                    'La talla RIB no puede tener información asociada en TIHIPROM.'
                );

            END IF;


            /*
            Verificar que la combinación tipo de hilaza y talla
            no tenga información asociada.
            */
            SELECT COUNT(*)
            INTO cantidad_tihiprom
            FROM TIHIPROM
            WHERE TIHPHILA = cod_tipo_hilaza
            AND TIHPTALL = cod_talla;


            IF cantidad_tihiprom > 0 THEN

                RAISE_APPLICATION_ERROR(
                    -20020,
                    'El tipo de hilaza ya tiene información asociada para la talla indicada.'
                );

            END IF;


            INSERT INTO TIHIPROM (
                TIHPHILA,
                TIHPTALL,
                TIHPPESO,
                TIHPANCH,
                TIHPPROM,
                TIHPFEGE,
                TIHPUSUA
            )

            VALUES (
                cod_tipo_hilaza,
                cod_talla,
                peso_tihiprom,
                ancho_tihiprom,
                NULL,
                SYSDATE,
                usuario_tihiprom
            );


            /*
            Calcula nuevamente el promedio considerando el nuevo peso
            y lo almacena en todos los registros del tipo de hilaza.
            */
            recalcularPromedio(cod_tipo_hilaza);


            -- Confirma la creación de TIHIPROM.
            COMMIT;


            -- Manejo general de excepciones:
            -- Si cualquiera de las operaciones genera un error, se revierten
            -- los cambios realizados.
            EXCEPTION
                WHEN OTHERS THEN
                    ROLLBACK;
                    RAISE;

        end;


end PKG_TIHIPROM;
/