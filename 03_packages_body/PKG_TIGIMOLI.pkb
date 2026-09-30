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

/*
-------------------------------------------------------------------------
INSERTAR TIGIMOLI
-------------------------------------------------------------------------
*/

/*
Procedimiento interno: calcula y registra un detalle técnico sin confirmar la transacción.
Devuelve metros por rollo, metros totales y tiempo para registrar el mismo detalle en ORDEPROD.
*/
PROCEDURE insertarTigimoli (cod_moli NUMBER, cod_talla NUMBER, rollos NUMBER, rpm_calculo NUMBER, cod_tipo_hilaza NUMBER, usuario NUMBER, fecha_generacion DATE, metros_rollo OUT NUMBER, total_metros OUT NUMBER, tiempo_giro OUT NUMBER) is

    /*
    Perímetro leído del catálogo para convertir las RPM en longitud recorrida por minuto.
    */
    perimetro NUMBER;

begin

    /*
      -20013 rechaza una cantidad de rollos nula o no positiva antes de obtener los metros totales.
    */
    IF rollos IS NULL OR rollos <= 0 THEN
        RAISE_APPLICATION_ERROR(
            -20013,
            'La cantidad de rollos debe ser mayor a cero.'
        );
    END IF;

    /*
      -20010 rechaza RPM nulas o no positivas para evitar un divisor inválido en el tiempo de giro.
    */
    IF rpm_calculo IS NULL OR rpm_calculo <= 0 THEN
        RAISE_APPLICATION_ERROR(
            -20010,
            'El RPM del molinete debe ser mayor a cero.'
        );
    END IF;

    /*
      Obtiene de RENDTALL los metros por rollo de la talla y los entrega en metros_rollo.
      NO_DATA_FOUND se traduce en -20005 cuando no existe rendimiento asociado.
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
      específicamente para el cálculo. NO_DATA_FOUND se traduce en -20009
      cuando no existe el molinete solicitado.
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

    /*
    -20011 impide calcular el tiempo con un perímetro nulo o no positivo.
    */
    IF perimetro IS NULL OR perimetro <= 0 THEN
        RAISE_APPLICATION_ERROR(
            -20011,
            'El perímetro del molinete debe ser mayor a cero.'
        );
    END IF;

    /*
      Multiplica los metros de un rollo por la cantidad asignada al detalle.
      RPM por perímetro dividido entre 100 expresa metros recorridos por minuto
      con el perímetro en centímetros; metros totales entre ese avance obtiene minutos.
    */
    total_metros := metros_rollo * rollos;

    tiempo_giro :=
        total_metros / ((rpm_calculo * perimetro) / 100);

    /*
      Conserva los metros, tiempo y RPM utilizados junto con molinete, talla,
      tipo de hilaza, usuario y fecha comunes al registro de la orden.
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

/*
-------------------------------------------------------------------------
INSERTAR ORDEN DE PRODUCCIÓN
-------------------------------------------------------------------------
*/

/*
Procedimiento interno: guarda un detalle de la orden con los resultados ya calculados.
No recalcula ni confirma; participa en la transacción de registrarCalculoTigimoli.
*/
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

/*
-------------------------------------------------------------------------
REGISTRAR CALCULO
-------------------------------------------------------------------------
*/

/*
Coordina los detalles de TIGIMOLI y ORDEPROD en una transacción y devuelve codigo_orden.
*/
PROCEDURE registrarCalculoTigimoli (codigos_molinetes t_lista_numeros, codigos_tallas t_lista_numeros, cantidades_rollos t_lista_numeros, rpms_molinetes t_lista_numeros, cod_tipo_hilaza NUMBER, usuario NUMBER, codigo_orden OUT NUMBER) is

    /*
    Marca temporal compartida por todos los detalles de ambas tablas.
    */
    fecha_generacion DATE;

    /*
    Resultados OUT del detalle técnico que se transfieren a insertarOrdeProd en cada iteración.
    */
    metros_rollo NUMBER;
    total_metros NUMBER;
    tiempo_giro NUMBER;

    /*
    Conteos de existencia para las entidades comunes a todos los detalles.
    */
    cantidad_tipo_hilaza NUMBER;
    cantidad_usuario NUMBER;

begin

    /*
      -20015 rechaza una lista de molinetes vacía para evitar una orden sin detalles.
    */
    IF codigos_molinetes.COUNT = 0 THEN
        RAISE_APPLICATION_ERROR(
            -20015,
            'El cálculo debe contener al menos un registro.'
        );
    END IF;

    /*
      -20014 rechaza listas con cantidades distintas. La iteración posterior usa
      índices de 1 a COUNT en las cuatro listas y asocia los valores del mismo índice.
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
      COUNT comprueba la existencia de la hilaza referenciada; -20018 informa su ausencia.
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
      COUNT comprueba el usuario que se guardará en ambas tablas; -20008 informa su ausencia.
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

      El bloqueo exclusivo serializa las escrituras de ORDEPROD antes de MAX + 1
      y se mantiene hasta COMMIT o ROLLBACK. NVL permite iniciar en 1 si no hay órdenes.
      El consecutivo se entrega por codigo_orden y se comparte entre los detalles.
    */
    LOCK TABLE ORDEPROD IN EXCLUSIVE MODE;

    SELECT NVL(MAX(ORPRCODI), 0) + 1
    INTO codigo_orden
    FROM ORDEPROD;

    /*
      Registra cada combinación molinete-talla en TIGIMOLI; sus tres resultados OUT
      alimentan insertarOrdeProd para conservar los mismos valores en la orden.
      Los procedimientos internos no confirman entre detalles.
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

    /*
    Confirma todos los detalles de ambas tablas y la transacción pendiente de la sesión.
    */
    COMMIT;

EXCEPTION

    /*
    Revierte la transacción pendiente, incluidos detalles previos del ciclo, y propaga el error.
    */
    WHEN OTHERS THEN
        ROLLBACK;
        RAISE;

end;

END PKG_TIGIMOLI;
/