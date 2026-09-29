CREATE OR REPLACE PACKAGE BODY PKG_TIGIMOLI

AS


--=============================================================================
-- Nombre responsabilidad: Implementar el cuerpo del paquete PKG_TIGIMOLI.
--
-- Autor: JUAN ANDRES SERNA CASTRO
-- Fecha_creacion: 18/Septiembre/2026
--
-- Descripcion responsabilidad:
-- Implementar el registro de los cálculos de giro por molinete y talla,
-- almacenando la información técnica en TIGIMOLI y generando la respectiva
-- Orden de Trabajo en ORDEPROD.
--
--
-- Historial_modificaciones:
--
-- Autor: JUAN ANDRES SERNA CASTRO
-- Fecha: 25/Septiembre/2026
-- Descripcion:
-- Se ajusta el registro del cálculo para almacenar RPM, tipo de hilaza
-- y generar la Orden de Trabajo asociada en ORDEPROD.
--=============================================================================


---------------------------------------------------------------------------
-- INSERTAR TIGIMOLI
---------------------------------------------------------------------------

PROCEDURE insertarTigimoli (cod_moli NUMBER, cod_talla NUMBER, rollos NUMBER, rpm_calculo NUMBER, cod_tipo_hilaza NUMBER, usuario NUMBER, fecha_generacion DATE, metros_rollo OUT NUMBER, total_metros OUT NUMBER, tiempo_giro OUT NUMBER) is

    perimetro NUMBER;

begin

    /*
      Valida la cantidad de rollos utilizada en el cálculo.
    */
    IF rollos IS NULL OR rollos <= 0 THEN
        RAISE_APPLICATION_ERROR(
            -20013,
            'La cantidad de rollos debe ser mayor a cero.'
        );
    END IF;


    /*
      Valida el RPM utilizado para el molinete.
    */
    IF rpm_calculo IS NULL OR rpm_calculo <= 0 THEN
        RAISE_APPLICATION_ERROR(
            -20010,
            'El RPM del molinete debe ser mayor a cero.'
        );
    END IF;


    /*
      Consulta los metros correspondientes a la talla.
    */
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


    /*
      Consulta el perímetro configurado para el molinete.
      El RPM es recibido porque corresponde al utilizado
      específicamente para el cálculo.
    */
    BEGIN

        SELECT MOLIPERI
        INTO perimetro
        FROM MOLINETE
        WHERE MOLICODI = cod_moli;

    EXCEPTION

        WHEN NO_DATA_FOUND THEN
            RAISE_APPLICATION_ERROR(
                -20009,
                'El molinete indicado no existe.'
            );

    END;


    IF perimetro IS NULL OR perimetro <= 0 THEN
        RAISE_APPLICATION_ERROR(
            -20011,
            'El perímetro del molinete debe ser mayor a cero.'
        );
    END IF;


    /*
      Calcula los metros y el tiempo de giro correspondientes
      al detalle molinete-talla.
    */
    total_metros := metros_rollo * rollos;

    tiempo_giro :=
        total_metros / ((rpm_calculo * perimetro) / 100);


    /*
      Registra el detalle técnico del cálculo.
    */
    INSERT INTO TIGIMOLI (
        TGMOMOLI,
        TGMOTALL,
        TGMOCARO,
        TGMOCAME,
        TGMOCATM,
        TGMOTIGI,
        TGMOFEGE,
        TGMOUSUA,
        TGMORPM,
        TGMOTIHI
    )
    VALUES (
        cod_moli,
        cod_talla,
        rollos,
        metros_rollo,
        total_metros,
        tiempo_giro,
        fecha_generacion,
        usuario,
        rpm_calculo,
        cod_tipo_hilaza
    );

end;


---------------------------------------------------------------------------
-- INSERTAR ORDEN DE PRODUCCIÓN
---------------------------------------------------------------------------

PROCEDURE insertarOrdeProd (codigo_orden NUMBER, cod_tipo_hilaza NUMBER, cod_moli NUMBER, cod_talla NUMBER, rollos NUMBER, metros_rollo NUMBER, total_metros NUMBER, tiempo_giro NUMBER, usuario NUMBER, fecha_generacion DATE) is

begin

    /*
      Registra el detalle del cálculo dentro de la Orden de Trabajo generada.
    */
    INSERT INTO ORDEPROD (
        ORPRCODI,
        ORPRTIHI,
        ORPRMOLI,
        ORPRTALL,
        ORPRCARO,
        ORPRCAME,
        ORPRCATO,
        ORPRTIGI,
        ORPRFEGE,
        ORPRUSUA
    )
    VALUES (
        codigo_orden,
        cod_tipo_hilaza,
        cod_moli,
        cod_talla,
        rollos,
        metros_rollo,
        total_metros,
        tiempo_giro,
        fecha_generacion,
        usuario
    );

end;


---------------------------------------------------------------------------
-- REGISTRAR CALCULO
---------------------------------------------------------------------------

PROCEDURE registrarCalculoTigimoli (codigos_molinetes t_lista_numeros, codigos_tallas t_lista_numeros, cantidades_rollos t_lista_numeros, rpms_molinetes t_lista_numeros, cod_tipo_hilaza NUMBER, usuario NUMBER, codigo_orden OUT NUMBER) is

    fecha_generacion DATE;

    metros_rollo NUMBER;
    total_metros NUMBER;
    tiempo_giro NUMBER;

    cantidad_tipo_hilaza NUMBER;
    cantidad_usuario NUMBER;

begin

    /*
      Valida que el cálculo contenga al menos un detalle.
    */
    IF codigos_molinetes.COUNT = 0 THEN
        RAISE_APPLICATION_ERROR(
            -20015,
            'El cálculo debe contener al menos un registro.'
        );
    END IF;


    /*
      Valida que todas las listas recibidas correspondan a la misma cantidad de detalles.
    */
    IF codigos_molinetes.COUNT <> codigos_tallas.COUNT
       OR codigos_molinetes.COUNT <> cantidades_rollos.COUNT
       OR codigos_molinetes.COUNT <> rpms_molinetes.COUNT
    THEN

        RAISE_APPLICATION_ERROR(
            -20014,
            'Los datos del cálculo no son consistentes.'
        );

    END IF;


    /*
      Valida la existencia del tipo de hilaza utilizado.
    */
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


    /*
      Valida la existencia del usuario.
    */
    SELECT COUNT(*)
    INTO cantidad_usuario
    FROM USUARIO
    WHERE USUACODI = usuario;

    IF cantidad_usuario = 0 THEN
        RAISE_APPLICATION_ERROR(
            -20008,
            'El usuario indicado no existe.'
        );
    END IF;


    /*
      Mantiene una única fecha de generación para todos los registros pertenecientes al mismo cálculo.
    */
    fecha_generacion := SYSDATE;


    /*
      Genera el consecutivo de la nueva Orden de Trabajo.

      El bloqueo evita que dos sesiones generen el mismo consecutivo simultáneamente.
    */
    LOCK TABLE ORDEPROD IN EXCLUSIVE MODE;


    SELECT NVL(MAX(ORPRCODI), 0) + 1
    INTO codigo_orden
    FROM ORDEPROD;


    /*
      Registra cada combinación molinete-talla tanto en TIGIMOLI como en la Orden de Trabajo.
    */
    FOR i IN 1 .. codigos_molinetes.COUNT
    LOOP

        insertarTigimoli(
            cod_moli => codigos_molinetes(i),
            cod_talla => codigos_tallas(i),
            rollos => cantidades_rollos(i),
            rpm_calculo => rpms_molinetes(i),
            cod_tipo_hilaza => cod_tipo_hilaza,
            usuario => usuario,
            fecha_generacion => fecha_generacion,
            metros_rollo => metros_rollo,
            total_metros => total_metros,
            tiempo_giro => tiempo_giro
        );


        insertarOrdeProd(
            codigo_orden => codigo_orden,
            cod_tipo_hilaza => cod_tipo_hilaza,
            cod_moli => codigos_molinetes(i),
            cod_talla => codigos_tallas(i),
            rollos => cantidades_rollos(i),
            metros_rollo => metros_rollo,
            total_metros => total_metros,
            tiempo_giro => tiempo_giro,
            usuario => usuario,
            fecha_generacion => fecha_generacion
        );

    END LOOP;


    COMMIT;


EXCEPTION

    WHEN OTHERS THEN
        ROLLBACK;
        RAISE;

end;


END PKG_TIGIMOLI;
/