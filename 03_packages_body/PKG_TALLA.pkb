CREATE OR REPLACE package body PKG_TALLA

as

--=============================================================================
-- Nombre responsabilidad: Implementar el cuerpo del paquete PKG_TALLA.
--
-- Autor: JUAN ANDRES SERNA CASTRO
-- Fecha_creacion: 09/Septiembre/2026
--
-- Descripcion responsabilidad:
-- Implementar las operaciones de consulta, actualización, eliminación, activación,
-- desactivación e inserción de TALLA.
-- Las operaciones de escritura confirman la transacción de la sesión al completarse;
-- no incluyen un manejador local de excepciones.
--
--
-- Historial_modificaciones:
--
-- Autor:
-- Fecha:
-- Descripcion:
--=============================================================================

/*
Devuelve código, nombre y estado en un cursor OUT ordenado por código.
Los filtros son opcionales; el nombre se busca parcialmente sin distinguir mayúsculas.
*/
PROCEDURE consultaTalla ( cod_talla NUMBER, nom_talla VARCHAR2, esta_talla VARCHAR2, cursor OUT SYS_REFCURSOR ) is

begin

    OPEN cursor FOR
        SELECT
            TALLCODI,
            TALLNOMB,
            TALLESTA
        FROM TALLA
        WHERE (cod_talla IS NULL OR TALLCODI = cod_talla)
          AND (nom_talla IS NULL OR LOWER(TALLNOMB) LIKE '%' || LOWER(nom_talla) || '%')
          AND (esta_talla IS NULL OR TALLESTA = esta_talla)
        ORDER BY TALLCODI ASC;

end;

/*
Sustituye nombre y estado de la talla indicada por su código.
*/
PROCEDURE actualizarTalla ( cod_talla NUMBER, nom_talla VARCHAR2, esta_talla VARCHAR2) is

    begin

        UPDATE TALLA

        SET TALLNOMB =  nom_talla, TALLESTA = esta_talla

        WHERE TALLCODI = cod_talla;

        /*
        Valida que la TALLA exista.
        -20004 informa que el UPDATE o DELETE precedente no encontró el código solicitado.
        */
        IF SQL%ROWCOUNT = 0 THEN
            RAISE_APPLICATION_ERROR(
                -20004,
                'La talla indicada no existe.'
            );
        END IF;

        /*
        Confirma la actualización de TALLA.
        */
        COMMIT;
    end;

/*
Establece el estado A para la talla indicada, manteniendo sus datos asociados.
*/
PROCEDURE activarTalla ( cod_talla NUMBER) is

    begin

        UPDATE TALLA

        SET TALLESTA = 'A'

        WHERE TALLCODI = cod_talla;

        /*
        -20004 informa que el UPDATE o DELETE precedente no encontró el código solicitado.
        */
        IF SQL%ROWCOUNT = 0 THEN
            RAISE_APPLICATION_ERROR(
                -20004,
                'La talla indicada no existe.'
            );
        END IF;

        /*
        Confirma el cambio de estado de la TALLA.
        */
        COMMIT;

    end;

/*
Establece el estado I para la talla indicada sin eliminarla.
*/
PROCEDURE desactivarTalla ( cod_talla NUMBER) is

    begin

        UPDATE TALLA

        SET TALLESTA = 'I'

        WHERE TALLCODI = cod_talla;

        /*
        -20004 informa que el UPDATE o DELETE precedente no encontró el código solicitado.
        */
        IF SQL%ROWCOUNT = 0 THEN
            RAISE_APPLICATION_ERROR(
                -20004,
                'La talla indicada no existe.'
            );
        END IF;

        /*
        Confirma el cambio de estado de la TALLA.
        */
        COMMIT;

    end;

/*
Comprueba dependencias en RENDTALL y TIGIMOLI antes de eliminar la talla.
*/
PROCEDURE eliminarTalla (cod_talla number) is
    /*
    Conteos de las referencias que impiden eliminar la entidad de origen.
    */
    v_registros_rend NUMBER := 0;
    v_registros_tigimoli NUMBER := 0;

    begin

        /*
        RETATALL vincula el rendimiento con la talla; -20012 impide borrar tallas referenciadas.
        */
        SELECT COUNT(*)
        INTO v_registros_rend
        FROM RENDTALL
        WHERE RETATALL = cod_talla;

        IF v_registros_rend > 0 THEN
            RAISE_APPLICATION_ERROR(
                -20012,
                'No se puede eliminar la talla porque tiene registros de rendimiento asociados.'
            );

        END IF;

        /*
        TGMOTALL vincula los cálculos con la talla; -20016 preserva la entidad de esos cálculos.
        */
        SELECT COUNT(*)
        INTO v_registros_tigimoli
        FROM TIGIMOLI
        WHERE TGMOTALL = cod_talla;

        IF v_registros_tigimoli > 0 THEN

            RAISE_APPLICATION_ERROR(
                -20016,
                'No se puede eliminar la talla porque tiene cálculos de tiempo de giro asociados.'
            );

        END IF;

        DELETE

        FROM TALLA

        WHERE TALLCODI = cod_talla;

        /*
        Valida que la TALLA haya existido antes de confirmar la eliminación.
        -20004 informa que el UPDATE o DELETE precedente no encontró el código solicitado.
        */
        IF SQL%ROWCOUNT = 0 THEN
            RAISE_APPLICATION_ERROR(
                -20004,
                'La talla indicada no existe.'
            );
        END IF;

        /*
        Confirma la eliminación de TALLA.
        */
        COMMIT;

    end;

/*
Registra el código, nombre y estado recibidos en una nueva fila de TALLA.
*/
PROCEDURE insertarTalla (cod_talla number, nom_talla varchar2, esta_talla varchar2) is
    begin

        INSERT INTO TALLA (TALLCODI, TALLNOMB, TALLESTA)

        VALUES (cod_talla, nom_talla, esta_talla);

        /*
        Confirma la creación de TALLA.
        */
        COMMIT;

    end;

end PKG_TALLA;