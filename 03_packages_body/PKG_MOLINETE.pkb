CREATE OR REPLACE package body PKG_MOLINETE

as

--=============================================================================
-- Nombre responsabilidad: Implementar el cuerpo del paquete PKG_MOLINETE.
--
-- Autor: JUAN ANDRES SERNA CASTRO
-- Fecha_creacion: 13/Septiembre/2026
--
-- Descripcion responsabilidad:
-- Implementar las operaciones de consulta, actualización, eliminacion e inserción de MOLINETE.
--
--
-- Historial_modificaciones:
--
-- Autor:
-- Fecha: 13/Septiembre/2026
-- Descripcion:
--=============================================================================

/*
Devuelve los datos del molinete por código opcional y coincidencia parcial de nombre.
La búsqueda del nombre ignora mayúsculas; el cursor OUT queda ordenado por código.
*/
PROCEDURE consultaMolinete ( cod_molinete NUMBER, nom_molinete VARCHAR2, cursor OUT SYS_REFCURSOR ) is

begin

    OPEN cursor FOR
        SELECT
            MOLICODI,
            MOLINOMB,
            MOLIRPM,
            MOLIPERI
        FROM MOLINETE
        WHERE (cod_molinete IS NULL OR MOLICODI = cod_molinete)
          AND (nom_molinete IS NULL OR LOWER(MOLINOMB) LIKE '%' || LOWER(nom_molinete) || '%')
        ORDER BY MOLICODI ASC;

end;

/*
Modifica nombre, RPM y perímetro del molinete indicado; valida los valores antes del UPDATE.
*/
PROCEDURE actualizarMolinete ( cod_molinete NUMBER, nom_molinete VARCHAR2, rpm_molinete NUMBER, peri_molinete NUMBER) is

    begin

        /*
        Rechaza RPM menores o iguales a cero o superiores a 999 con el error -20010.
        */
        IF rpm_molinete <= 0 OR rpm_molinete > 999 THEN
            RAISE_APPLICATION_ERROR(
                -20010,
                'El RPM del molinete no es válido.'
            );
        END IF;

        /*
        Rechaza perímetros menores o iguales a cero o superiores a 999 con el error -20011.
        */
        IF peri_molinete <= 0 OR peri_molinete > 999 THEN
            RAISE_APPLICATION_ERROR(
                -20011,
                'El perímetro del molinete no es válido.'
            );
        END IF;

        UPDATE MOLINETE

        SET MOLINOMB =  nom_molinete, MOLIRPM = rpm_molinete, MOLIPERI = peri_molinete

        WHERE MOLICODI = cod_molinete;

        /*
        SQL%ROWCOUNT detecta que el UPDATE no encontró el código; -20009 informa su ausencia.
        */
        IF SQL%ROWCOUNT = 0 THEN
            RAISE_APPLICATION_ERROR(
                -20009,
                'El molinete indicado no existe.'
            );
        END IF;

        /*
        Confirma la actualización de MOLINETE.
        COMMIT confirma la transacción pendiente de la sesión, incluidos estos cambios.
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
Elimina el molinete únicamente si no tiene cálculos asociados en TIGIMOLI.
*/
PROCEDURE eliminarMolinete (cod_molinete number) is
    /*
    Cantidad de cálculos que referencian el molinete mediante TGMOMOLI.
    */
    v_registros_tigimoli NUMBER := 0;

    begin

        /*
        Cuenta las referencias de TIGIMOLI para preservar los molinetes con cálculos registrados.
        El error -20017 impide su eliminación cuando existe al menos una referencia.
        */
        SELECT COUNT(*)
        INTO v_registros_tigimoli
        FROM TIGIMOLI
        WHERE TGMOMOLI = cod_molinete;

        IF v_registros_tigimoli > 0 THEN

            RAISE_APPLICATION_ERROR(
                -20017,
                'No se puede eliminar el molinete porque tiene cálculos de tiempo de giro asociados.'
            );

        END IF;

        DELETE

        FROM MOLINETE

        WHERE MOLICODI = cod_molinete;

        /*
        Un DELETE sin filas afectadas indica código inexistente y genera el error -20009.
        */
        IF SQL%ROWCOUNT = 0 THEN
            RAISE_APPLICATION_ERROR(
                -20009,
                'El molinete indicado no existe.'
            );
        END IF;

        /*
        Confirma la eliminación de MOLINETE.
        COMMIT confirma la transacción pendiente de la sesión, incluidos estos cambios.
        */
        COMMIT;

    end;

/*
Registra código, nombre, RPM y perímetro tras validar los valores de operación.
*/
PROCEDURE insertarMolinete (cod_molinete number, nom_molinete varchar2, rpm_molinete number, peri_molinete number) is
    begin

        /*
        Rechaza RPM menores o iguales a cero o superiores a 999 con el error -20010.
        */
        IF rpm_molinete <= 0 OR rpm_molinete > 999 THEN
            RAISE_APPLICATION_ERROR(
                -20010,
                'El RPM del molinete no es válido, debe estar entre 1 y 999.'
            );
        END IF;

        /*
        Rechaza perímetros menores o iguales a cero o superiores a 999 con el error -20011.
        */
        IF peri_molinete <= 0 OR peri_molinete > 999 THEN
            RAISE_APPLICATION_ERROR(
                -20011,
                'El perímetro del molinete no es válido, debe estar entre 1 y 999.'
            );
        END IF;

        INSERT INTO MOLINETE (MOLICODI, MOLINOMB, MOLIRPM, MOLIPERI)

        VALUES (cod_molinete, nom_molinete, rpm_molinete, peri_molinete);

        /*
        Confirma la creación de MOLINETE.
        COMMIT confirma la transacción pendiente de la sesión, incluidos estos cambios.
        */
        COMMIT;

        /*
        Manejo general de excepciones:
        ROLLBACK revierte la transacción pendiente de la sesión; RAISE conserva el error original.
        */
        EXCEPTION
            WHEN OTHERS THEN
                ROLLBACK;
                RAISE;

    end;

end PKG_MOLINETE;