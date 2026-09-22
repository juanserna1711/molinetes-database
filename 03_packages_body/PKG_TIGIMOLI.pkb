CREATE OR REPLACE PACKAGE BODY PKG_TIGIMOLI

AS


--=============================================================================
-- Nombre responsabilidad: Implementar el cuerpo del paquete PKG_TIGIMOLI.
--
-- Autor: JUAN ANDRES SERNA CASTRO
-- Fecha_creacion: 18/Septiembre/2026
--
-- Descripcion responsabilidad:
-- Implementar las operaciones de consulta e inserción de TIGIMOLI.
--
--
-- Historial_modificaciones:
--
-- Autor:
-- Fecha:
-- Descripcion:
--=============================================================================


---------------------------------------------------------------------------
-- CONSULTA
---------------------------------------------------------------------------

PROCEDURE consultaTigimoli (
    cod_moli NUMBER,
    nom_moli VARCHAR2,
    fecha_generacion DATE,
    pagina NUMBER,
    registros_pagina NUMBER,
    total_registros OUT NUMBER,
    cursor OUT SYS_REFCURSOR
) IS

    v_pagina NUMBER;
    v_registros_pagina NUMBER;

BEGIN


    -- Define valores por defecto para la paginación.
    IF pagina IS NULL OR pagina < 1 THEN
        v_pagina := 1;
    ELSE
        v_pagina := TRUNC(pagina);
    END IF;


    IF registros_pagina IS NULL OR registros_pagina < 1 THEN
        v_registros_pagina := 10;
    ELSE
        v_registros_pagina := TRUNC(registros_pagina);
    END IF;


    -- Consulta la cantidad total de registros.
    SELECT COUNT(*)
    INTO total_registros
    FROM (
        SELECT
            g.TGMOMOLI,
            g.TGMOFEGE
        FROM TIGIMOLI g
        LEFT JOIN MOLINETE m
            ON g.TGMOMOLI = m.MOLICODI
        WHERE (cod_moli IS NULL OR
               g.TGMOMOLI = cod_moli)

          AND (nom_moli IS NULL OR
               LOWER(m.MOLINOMB) LIKE '%' ||
               LOWER(nom_moli) || '%')

          AND (fecha_generacion IS NULL OR
               (
                   g.TGMOFEGE >= TRUNC(fecha_generacion)
                   AND g.TGMOFEGE < TRUNC(fecha_generacion) + 1
               ))

        GROUP BY
            g.TGMOMOLI,
            g.TGMOFEGE
    );


    -- Consulta TIGIMOLI agrupada por molinete
    -- y fecha de generación.
    OPEN cursor FOR

        SELECT
            codigo_moli,
            nombre_molinete,
            fecha_generacion,
            cantidad_tallas,
            cantidad_rollos,
            total_metros,
            tiempo_giro
        FROM (

            SELECT
                g.TGMOMOLI AS codigo_moli,

                m.MOLINOMB AS nombre_molinete,

                g.TGMOFEGE AS fecha_generacion,

                COUNT(DISTINCT g.TGMOTALL)
                    AS cantidad_tallas,

                SUM(g.TGMOCARO)
                    AS cantidad_rollos,

                SUM(g.TGMOCATM)
                    AS total_metros,

                SUM(g.TGMOTIGI)
                    AS tiempo_giro,

                ROW_NUMBER() OVER (
                    ORDER BY
                        g.TGMOFEGE DESC,
                        g.TGMOMOLI ASC
                ) AS numero_fila

            FROM TIGIMOLI g

            LEFT JOIN MOLINETE m
                ON g.TGMOMOLI = m.MOLICODI

            WHERE (cod_moli IS NULL OR
                   g.TGMOMOLI = cod_moli)

              AND (nom_moli IS NULL OR
                   LOWER(m.MOLINOMB) LIKE '%' ||
                   LOWER(nom_moli) || '%')

              AND (fecha_generacion IS NULL OR
                   (
                       g.TGMOFEGE >= TRUNC(fecha_generacion)
                       AND g.TGMOFEGE < TRUNC(fecha_generacion) + 1
                   ))

            GROUP BY
                g.TGMOMOLI,
                m.MOLINOMB,
                g.TGMOFEGE

        )

        WHERE numero_fila BETWEEN
            ((v_pagina - 1) * v_registros_pagina) + 1
            AND
            (v_pagina * v_registros_pagina)

        ORDER BY
            fecha_generacion DESC,
            codigo_moli ASC;


END;

---------------------------------------------------------------------------
-- CONSULTA DETALLE
---------------------------------------------------------------------------

PROCEDURE consultaDetalleTigimoli (
    cod_moli NUMBER,
    fecha_generacion DATE,
    cursor OUT SYS_REFCURSOR
) IS

BEGIN

    -- Consulta las tallas asociadas al molinete
    -- y fecha de generación.
    OPEN cursor FOR

        SELECT
            g.TGMOTALL AS codigo_talla,
            t.TALLNOMB AS nombre_talla,
            g.TGMOCARO AS rollos,
            g.TGMOCAME AS metros_rollo,
            g.TGMOCATM AS total_metros
        FROM TIGIMOLI g
        INNER JOIN TALLA t
            ON g.TGMOTALL = t.TALLCODI
        WHERE g.TGMOMOLI = cod_moli
          AND g.TGMOFEGE = fecha_generacion
        ORDER BY
            g.TGMOTALL ASC;

END;

---------------------------------------------------------------------------
-- INSERTAR
---------------------------------------------------------------------------
PROCEDURE insertarTigimoli (
    cod_moli NUMBER,
    cod_talla NUMBER,
    rollos NUMBER,
    usuario NUMBER,
    fecha_generacion DATE
) IS

    metros_rollo NUMBER;
    total_metros NUMBER;
    tiempo_giro NUMBER;

    rpm NUMBER;
    perimetro NUMBER;

BEGIN

    IF rollos IS NULL OR rollos <= 0 THEN
        RAISE_APPLICATION_ERROR(
            -20013,
            'La cantidad de rollos debe ser mayor a cero.'
        );
    END IF;


    BEGIN

        SELECT RETAMETR
        INTO metros_rollo
        FROM RENDTALL
        WHERE RETATALL = cod_talla;

    EXCEPTION

        WHEN NO_DATA_FOUND THEN
            RAISE_APPLICATION_ERROR(
                -20005,
                'La talla no tiene rendimiento asociado.'
            );

    END;


    SELECT
        MOLIRPM,
        MOLIPERI
    INTO
        rpm,
        perimetro
    FROM MOLINETE
    WHERE MOLICODI = cod_moli;


    total_metros :=
        metros_rollo * rollos;

    tiempo_giro :=
        total_metros /
        ((rpm * perimetro) / 100);


    INSERT INTO TIGIMOLI (
        TGMOMOLI,
        TGMOTALL,
        TGMOCARO,
        TGMOCAME,
        TGMOCATM,
        TGMOTIGI,
        TGMOFEGE,
        TGMOUSUA
    )
    VALUES (
        cod_moli,
        cod_talla,
        rollos,
        metros_rollo,
        total_metros,
        tiempo_giro,
        fecha_generacion,
        usuario
    );

END;

---------------------------------------------------------------------------
-- REGISTRAR CALCULO
---------------------------------------------------------------------------
PROCEDURE registrarCalculoTigimoli (
    codigos_molinetes t_lista_numeros,
    codigos_tallas t_lista_numeros,
    cantidades_rollos t_lista_numeros,
    usuario NUMBER
) IS

    fecha_generacion DATE;

BEGIN

    IF codigos_molinetes.COUNT = 0 THEN
        RAISE_APPLICATION_ERROR(
            -20015,
            'El cálculo debe contener al menos un registro.'
        );
    END IF;


    IF codigos_molinetes.COUNT <> codigos_tallas.COUNT
       OR codigos_molinetes.COUNT <> cantidades_rollos.COUNT
    THEN

        RAISE_APPLICATION_ERROR(
            -20014,
            'Los datos del cálculo no son consistentes.'
        );

    END IF;


    fecha_generacion := SYSDATE;


    FOR i IN 1 .. codigos_molinetes.COUNT
    LOOP

        insertarTigimoli(
            cod_moli => codigos_molinetes(i),
            cod_talla => codigos_tallas(i),
            rollos => cantidades_rollos(i),
            usuario => usuario,
            fecha_generacion => fecha_generacion
        );

    END LOOP;


    COMMIT;


EXCEPTION

    WHEN OTHERS THEN
        ROLLBACK;
        RAISE;

END;

END PKG_TIGIMOLI;