CREATE OR REPLACE PACKAGE BODY PKG_ORDEPROD

AS


--=============================================================================
-- Nombre responsabilidad: Implementar el cuerpo del paquete PKG_ORDEPROD.
--
-- Autor: JUAN ANDRES SERNA CASTRO
-- Fecha_creacion: 25/Septiembre/2026
--
-- Descripcion responsabilidad:
-- Implementar las operaciones de consulta de las órdenes de trabajo
-- almacenadas en ORDEPROD, permitiendo consultar el historial y el
-- detalle de cada orden agrupado por molinete.
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

PROCEDURE consultaOrdeProd (cod_orden NUMBER, cod_tipo_hilaza NUMBER, fecha_inicio DATE, fecha_fin DATE, pagina NUMBER, registros_pagina NUMBER, total_registros OUT NUMBER, cursor OUT SYS_REFCURSOR) is

    v_pagina NUMBER;
    v_registros_pagina NUMBER;

begin

    /*
      Define los valores utilizados para la paginación.
    */
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


    /*
      Consulta la cantidad total de órdenes que cumplen con los filtros seleccionados.
    */
    SELECT COUNT(*)
    INTO total_registros
    FROM (
        SELECT
            o.ORPRCODI
        FROM ORDEPROD o
        WHERE (cod_orden IS NULL OR o.ORPRCODI = cod_orden)
        AND (cod_tipo_hilaza IS NULL OR o.ORPRTIHI = cod_tipo_hilaza )
        AND (fecha_inicio IS NULL OR o.ORPRFEGE >= TRUNC(fecha_inicio) )
        AND (fecha_fin IS NULL OR o.ORPRFEGE < TRUNC(fecha_fin) + 1 )
        GROUP BY o.ORPRCODI
    );


    /*
      Consulta el historial de órdenes de trabajo.
    */
    OPEN cursor FOR

        SELECT
            codigo_orden,
            codigo_tipo_hilaza,
            nombre_tipo_hilaza,
            fecha_generacion,
            codigo_usuario,
            nombre_usuario,
            cantidad_molinetes
        FROM (
            SELECT
                o.ORPRCODI AS codigo_orden,
                o.ORPRTIHI AS codigo_tipo_hilaza,
                h.TIHINOMB AS nombre_tipo_hilaza,
                o.ORPRFEGE AS fecha_generacion,
                o.ORPRUSUA AS codigo_usuario,
                u.USUANOMB AS nombre_usuario,
                COUNT(DISTINCT o.ORPRMOLI) AS cantidad_molinetes,

                ROW_NUMBER() OVER (
                    ORDER BY
                        o.ORPRFEGE DESC,
                        o.ORPRCODI DESC
                ) AS numero_fila

            FROM ORDEPROD o
            LEFT JOIN TIPOHILA h ON o.ORPRTIHI = h.TIHICODI
            LEFT JOIN USUARIO u ON o.ORPRUSUA = u.USUACODI
            WHERE (cod_orden IS NULL OR o.ORPRCODI = cod_orden)
            AND (cod_tipo_hilaza IS NULL OR o.ORPRTIHI = cod_tipo_hilaza)
            AND (fecha_inicio IS NULL OR o.ORPRFEGE >= TRUNC(fecha_inicio))
            AND (fecha_fin IS NULL OR o.ORPRFEGE < TRUNC(fecha_fin) + 1)

            GROUP BY
                o.ORPRCODI,
                o.ORPRTIHI,
                h.TIHINOMB,
                o.ORPRFEGE,
                o.ORPRUSUA,
                u.USUANOMB
        )

        WHERE numero_fila BETWEEN
            ((v_pagina - 1) * v_registros_pagina) + 1
            AND
            (v_pagina * v_registros_pagina)

        ORDER BY
            fecha_generacion DESC,
            codigo_orden DESC;

end;


---------------------------------------------------------------------------
-- CONSULTA DETALLE
---------------------------------------------------------------------------

PROCEDURE consultaDetalleOrdeProd (cod_orden NUMBER, cursor OUT SYS_REFCURSOR) is

begin

    /*
      Consulta todos los detalles asociados a una Orden de Trabajo.
      Los totales de rollos, metros y tiempo de giro se calculan independientemente para cada molinete.
      El RPM utilizado se obtiene desde TIGIMOLI utilizando los datos compartidos por ambas tablas durante la generación del cálculo.
    */
    OPEN cursor FOR

        SELECT
            o.ORPRCODI AS codigo_orden,
            o.ORPRTIHI AS codigo_tipo_hilaza,
            h.TIHINOMB AS nombre_tipo_hilaza,
            o.ORPRMOLI AS codigo_molinete,
            m.MOLINOMB AS nombre_molinete,
            m.MOLIPERI AS perimetro,
            o.ORPRTALL AS codigo_talla,
            t.TALLNOMB AS nombre_talla,
            o.ORPRCARO AS rollos,
            o.ORPRCAME AS metros_rollo,
            o.ORPRCATO AS total_metros_talla,

            SUM(o.ORPRCARO) OVER (
                PARTITION BY
                    o.ORPRCODI,
                    o.ORPRMOLI
            ) AS total_rollos_molinete,

            SUM(o.ORPRCATO) OVER (
                PARTITION BY
                    o.ORPRCODI,
                    o.ORPRMOLI
            ) AS total_metros_molinete,

            SUM(o.ORPRTIGI) OVER (
                PARTITION BY
                    o.ORPRCODI,
                    o.ORPRMOLI
            ) AS tiempo_giro_molinete,

            g.TGMORPM AS rpm,
            o.ORPRFEGE AS fecha_generacion,
            o.ORPRUSUA AS codigo_usuario,
            u.USUANOMB AS nombre_usuario

        FROM ORDEPROD o
        INNER JOIN MOLINETE m ON o.ORPRMOLI = m.MOLICODI
        INNER JOIN TALLA t ON o.ORPRTALL = t.TALLCODI
        LEFT JOIN TIPOHILA h ON o.ORPRTIHI = h.TIHICODI
        LEFT JOIN USUARIO u ON o.ORPRUSUA = u.USUACODI
        LEFT JOIN (
            SELECT
                TGMOMOLI,
                TGMOTALL,
                TGMOFEGE,
                TGMOUSUA,
                TGMOTIHI,
                MAX(TGMORPM) AS TGMORPM

            FROM TIGIMOLI

            GROUP BY
                TGMOMOLI,
                TGMOTALL,
                TGMOFEGE,
                TGMOUSUA,
                TGMOTIHI
        ) g

            ON g.TGMOMOLI = o.ORPRMOLI
            AND g.TGMOTALL = o.ORPRTALL
            AND g.TGMOFEGE = o.ORPRFEGE
            AND g.TGMOUSUA = o.ORPRUSUA
            AND g.TGMOTIHI = o.ORPRTIHI

        WHERE o.ORPRCODI = cod_orden

        ORDER BY
            o.ORPRMOLI ASC,
            o.ORPRTALL ASC;

end;


END PKG_ORDEPROD;
/