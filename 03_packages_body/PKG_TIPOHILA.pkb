CREATE OR REPLACE package body PKG_TIPOHILA

as

--=============================================================================
-- Nombre responsabilidad: Implementar el cuerpo del paquete PKG_TIPOHILA.
--
-- Autor: JUAN ANDRES SERNA CASTRO
-- Fecha_creacion: 24/Septiembre/2026
--
-- Descripcion responsabilidad:
-- Implementar las operaciones de consulta, actualización, eliminación e inserción
-- de TIPOHILA.
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

/*
Devuelve código y nombre en un cursor OUT ordenado por código.
Los filtros son opcionales; el nombre admite coincidencia parcial sin distinguir mayúsculas.
*/
PROCEDURE consultaTipoHilaza ( cod_tipo_hilaza NUMBER, nom_tipo_hilaza VARCHAR2, cursor OUT SYS_REFCURSOR ) is

begin

    OPEN cursor FOR
        SELECT
            TIHICODI,
            TIHINOMB
        FROM TIPOHILA
        WHERE (cod_tipo_hilaza IS NULL OR TIHICODI = cod_tipo_hilaza)
          AND (nom_tipo_hilaza IS NULL OR LOWER(TIHINOMB) LIKE '%' || LOWER(nom_tipo_hilaza) || '%')
        ORDER BY TIHICODI ASC;

end;

/*
Actualiza el nombre del tipo de hilaza identificado por su código.
*/
PROCEDURE actualizarTipoHilaza ( cod_tipo_hilaza NUMBER, nom_tipo_hilaza VARCHAR2) is

    begin

        UPDATE TIPOHILA

        SET TIHINOMB =  nom_tipo_hilaza

        WHERE TIHICODI = cod_tipo_hilaza;

        /*
        -20019 informa que el UPDATE no encontró el código solicitado.
        */
        IF SQL%ROWCOUNT = 0 THEN
            RAISE_APPLICATION_ERROR(
                -20019,
                'El tipo de hilaza indicado no existe.'
            );
        END IF;

        /*
        Confirma la actualización de TIPOHILA.
        */
        COMMIT;
    end;

/*
Comprueba la dependencia de TIHIPROM antes de borrar el tipo de hilaza.
*/
PROCEDURE eliminarTipoHilaza (cod_tipo_hilaza number) is
    /*
    Cantidad de filas de promedio que referencian la hilaza mediante TIHPHILA.
    */
    v_registros_tihiprom NUMBER := 0;

    begin

        /*
        COUNT detecta promedios asociados; -20019 bloquea la eliminación para conservar su hilaza.
        Este código también se utiliza más abajo para informar una hilaza inexistente.
        */
        SELECT COUNT(*)
        INTO v_registros_tihiprom
        FROM TIHIPROM
        WHERE TIHPHILA = cod_tipo_hilaza;

        IF v_registros_tihiprom > 0 THEN

            RAISE_APPLICATION_ERROR(
                -20019,
                'No se puede eliminar el tipo de hilaza porque tiene registros de promedio asociados.'
            );

        END IF;

        DELETE

        FROM TIPOHILA

        WHERE TIHICODI = cod_tipo_hilaza;

        /*
        Un DELETE sin filas afectadas genera -20019 con el mensaje de hilaza inexistente.
        */
        IF SQL%ROWCOUNT = 0 THEN
            RAISE_APPLICATION_ERROR(
                -20019,
                'El tipo de hilaza indicado no existe.'
            );
        END IF;

        /*
        Confirma la eliminación de TIPOHILA.
        */
        COMMIT;

    end;

/*
Registra el código y nombre recibidos en el catálogo TIPOHILA.
*/
PROCEDURE insertarTipoHilaza (cod_tipo_hilaza number, nom_tipo_hilaza varchar2) is
    begin

        INSERT INTO TIPOHILA (TIHICODI, TIHINOMB)

        VALUES (cod_tipo_hilaza, nom_tipo_hilaza);

        /*
        Confirma la creación de TIPOHILA.
        */
        COMMIT;

    end;

end PKG_TIPOHILA;
/