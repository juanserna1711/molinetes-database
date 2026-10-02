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

-- Procedimiento privado compartido por inserción, actualización y eliminación.
PROCEDURE recalcularPromedio (cod_tipo_hilaza NUMBER) is

    -- Promedio aritmético redondeado a entero que se replica en todas las filas de la hilaza.
    promedio_tihiprom NUMBER;

    begin
        
        -- AVG considera los pesos no nulos de la hilaza; ROUND redondea sin decimales.
        -- Sin pesos, el agregado devuelve NULL y el UPDATE alcanza las filas existentes.
        SELECT ROUND(AVG(TIHPPESO))
        INTO promedio_tihiprom
        FROM TIHIPROM
        WHERE TIHPHILA = cod_tipo_hilaza;

        UPDATE TIHIPROM

        SET TIHPPROM = promedio_tihiprom

        WHERE TIHPHILA = cod_tipo_hilaza;

    end;

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
        
        -- Los INNER JOIN requieren hilaza y talla coincidentes; el LEFT JOIN de usuario conserva la información de promedio aunque no encuentre el nombre del usuario.
        
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


PROCEDURE actualizarTiHiProm (
    cod_tipo_hilaza NUMBER,
    cod_talla NUMBER,
    peso_tihiprom NUMBER,
    ancho_tihiprom NUMBER,
    usuario_tihiprom NUMBER
) is

    begin
        
        --Ancho y peso deben ser positivos y no nulos; -20001 identifica ancho inválido y -20002 peso inválido.
        
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
  
        -- -20021 informa que el UPDATE no encontró la combinación de hilaza y talla.
        IF SQL%ROWCOUNT = 0 THEN
            RAISE_APPLICATION_ERROR(
                -20021,
                'El tipo de hilaza no tiene información asociada para la talla indicada.'
            );
        END IF;

        -- Propaga a todas las filas de la hilaza el promedio que incorpora el peso actualizado. 
        recalcularPromedio(cod_tipo_hilaza);
        
        COMMIT;
        
        --Manejo general de excepciones: ROLLBACK revierte la transacción pendiente de la sesión; RAISE propaga el error original.
        EXCEPTION
            WHEN OTHERS THEN
                ROLLBACK;
                RAISE;

    end;

-- Aplica ancho y promedio de la hilaza al rendimiento vigente de sus tallas.
-- Conserva el peso del rollo y confirma el conjunto de actualizaciones al terminar.

PROCEDURE aplicarTipoHilaza (cod_tipo_hilaza NUMBER, usuario_rendtall NUMBER) is

    -- Resultados derivados que se guardarán en RENDTALL para cada talla recorrida.
    rendimiento_rendtall NUMBER;
    metros_rendtall NUMBER;
    
    -- Peso promedio según la talla; el peso del rollo se toma siempre de RENDTALL.
    peso_rendtall NUMBER;
    rollo_rendtall NUMBER;
    
    -- Conteo de información asociada, usado para validar antes de continuar.
    cantidad_tihiprom NUMBER;

    begin
        
        -- COUNT detecta ausencia de filas en TIHIPROM; -20022 impide aplicar una hilaza sin información.
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

        
          -- Recorre las tallas asociadas al tipo de hilaza y actualiza la información vigente de RENDTALL. El cursor implícito enlaza TALLA para obtener el nombre que determina el tratamiento de RIB y recorre por código.
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
              -- Obtiene el peso del rollo y el peso actualmente almacenado.
              -- El peso del rollo no cambia al aplicar un tipo de hilaza.
              -- NO_DATA_FOUND genera -20005 si la talla carece de rendimiento.
            
            BEGIN

            SELECT
                RETAROLL,
                RETAPESO
            INTO
                rollo_rendtall,
                peso_rendtall
            FROM RENDTALL
            WHERE RETATALL = registro.TIHPTALL
            FOR UPDATE;

            EXCEPTION

                WHEN NO_DATA_FOUND THEN

                    RAISE_APPLICATION_ERROR(
                        -20005,
                        'La talla no tiene información de rendimiento asociada.'
                    );

            END;

            
              -- Para las tallas normales se utiliza el promedio del tipo de hilaza como peso.
              -- RIB conserva el peso que ya tiene registrado en RENDTALL.
            
            IF UPPER(TRIM(registro.TALLNOMB)) <> 'RIB' THEN

                peso_rendtall := registro.TIHPPROM;

            END IF;
            
            -- El ancho duplicado y dividido entre 100 se multiplica por el peso seleccionado.
            -- 1000 dividido entre ese producto obtiene el rendimiento; el peso del rollo por el rendimiento obtiene los metros, conservando el peso original del rollo.
            rendimiento_rendtall := 1000 /((registro.TIHPANCH * 2 / 100) * peso_rendtall);
            metros_rendtall :=rollo_rendtall * rendimiento_rendtall;
            
            -- -20006 rechaza rendimiento superior al límite documentado de 99.9 para RETAREND.
            IF rendimiento_rendtall > 99.9 THEN

                RAISE_APPLICATION_ERROR(
                    -20006,
                    'El rendimiento calculado supera el máximo permitido de 99.9.'
                );

            END IF;

            -- -20007 rechaza metros superiores al límite documentado de 99999.9 para RETAMETR.
            IF metros_rendtall > 99999.9 THEN

                RAISE_APPLICATION_ERROR(
                    -20007,
                    'Los metros por rollo calculados superan el máximo permitido de 99999.9.'
                );

            END IF;

            --Sustituye las medidas y resultados vigentes, con fecha y usuario de aplicación. RETAROLL no se modifica en esta operación.
            
            UPDATE RENDTALL

            SET RETAANCH = registro.TIHPANCH,
                RETAPESO = peso_rendtall,
                RETAREND = rendimiento_rendtall,
                RETAMETR = metros_rendtall,
                RETAFEGE = SYSDATE,
                RETAUSUA = usuario_rendtall

            WHERE RETATALL = registro.TIHPTALL;

            
            -- -20005 informa que el UPDATE no encontró rendimiento para la talla recorrida.
            IF SQL%ROWCOUNT = 0 THEN

                RAISE_APPLICATION_ERROR(
                    -20005,
                    'La talla no tiene información de rendimiento asociada.'
                );

            END IF;

        END LOOP;

    end;

PROCEDURE eliminarTiHiProm (cod_tipo_hilaza NUMBER, cod_talla NUMBER) is

    begin

        DELETE

        FROM TIHIPROM

        WHERE TIHPHILA = cod_tipo_hilaza
          AND TIHPTALL = cod_talla;

        -- -20021 informa que el DELETE no encontró la combinación de hilaza y talla.
        
        IF SQL%ROWCOUNT = 0 THEN
            RAISE_APPLICATION_ERROR(
                -20021,
                'El tipo de hilaza no tiene información asociada para la talla indicada.'
            );
        END IF;

        
        --- Al eliminar un peso cambia el promedio del tipo de hilaza, por lo que se recalcula para los registros restantes.
        
        recalcularPromedio(cod_tipo_hilaza);
        
        COMMIT;
 
        -- Manejo general de excepciones: ROLLBACK revierte la transacción pendiente de la sesión; RAISE propaga el error original.
        EXCEPTION
            WHEN OTHERS THEN
                ROLLBACK;
                RAISE;

    end;

PROCEDURE insertarTiHiProm (
        cod_tipo_hilaza NUMBER,
        cod_talla NUMBER,
        peso_tihiprom NUMBER,
        ancho_tihiprom NUMBER,
        usuario_tihiprom NUMBER
    ) is

        -- Conteo de existencia de la hilaza antes de registrar la relación.
        cantidad_tipo_hilaza NUMBER;

        -- Conteo de información asociada, usado para validar antes de continuar.
        cantidad_tihiprom NUMBER;
        
        -- Nombre utilizado para excluir RIB tras quitar espacios y normalizar mayúsculas.
        nombre_talla VARCHAR2(60);

        begin

            -- Ancho y peso deben ser positivos y no nulos; -20001 identifica ancho inválido y -20002 peso inválido.
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
            
            -- COUNT comprueba la entidad de origen; -20018 informa que la hilaza no existe.
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
            
            -- Obtiene el nombre necesario para validar RIB; NO_DATA_FOUND se traduce en -20004. 
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
            
            -- -20023 impide insertar RIB, identificada por nombre sin espacios extremos y en mayúsculas.
            IF UPPER(TRIM(nombre_talla)) = 'RIB' THEN

                RAISE_APPLICATION_ERROR(
                    -20023,
                    'La talla RIB no puede tener información asociada en TIHIPROM.'
                );

            END IF;
            
            -- Verificar que la combinación tipo de hilaza y talla no tenga información asociada. COUNT detecta duplicados y -20020 informa que la combinación ya está registrada.
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

            
            -- Registra medidas, fecha y usuario con promedio inicialmente NULL; recalcularPromedio lo establece junto con el de las demás filas de la hilaza.
            
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
  
            -- Calcula nuevamente el promedio considerando el nuevo peso y lo almacena en todos los registros del tipo de hilaza.
            recalcularPromedio(cod_tipo_hilaza);
            
            COMMIT;

            -- Manejo general de excepciones: ROLLBACK revierte el registro, el recálculo y la transacción pendiente de la sesión. RAISE propaga el error original al llamador.
            EXCEPTION
                WHEN OTHERS THEN
                    ROLLBACK;
                    RAISE;

        end;

end PKG_TIHIPROM;
/