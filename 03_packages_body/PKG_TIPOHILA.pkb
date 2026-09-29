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
--
--
-- Historial_modificaciones:
--
-- Autor:
-- Fecha:
-- Descripcion:
--=============================================================================
 
PROCEDURE consultaTipoHilaza ( cod_tipo_hilaza NUMBER, nom_tipo_hilaza VARCHAR2, cursor OUT SYS_REFCURSOR ) is 
 
begin 
 
    OPEN cursor FOR 
        SELECT 
            TIHICODI, 
            TIHINOMB
        FROM TIPOHILA
        WHERE (cod_tipo_hilaza IS NULL OR TIHICODI = cod_tipo_hilaza) 
          AND (nom_tipo_hilaza IS NULL OR 
               LOWER(TIHINOMB) LIKE '%' || LOWER(nom_tipo_hilaza) || '%') 
        ORDER BY TIHICODI ASC; 
 
end;
 
 
PROCEDURE actualizarTipoHilaza ( cod_tipo_hilaza NUMBER, nom_tipo_hilaza VARCHAR2) is 

    begin

 
        UPDATE TIPOHILA 
 
        SET TIHINOMB =  nom_tipo_hilaza 
 
        WHERE TIHICODI = cod_tipo_hilaza; 
 
        -- Valida que el TIPO DE HILAZA exista.
        IF SQL%ROWCOUNT = 0 THEN 
            RAISE_APPLICATION_ERROR( 
                -20019, 
                'El tipo de hilaza indicado no existe.' 
            ); 
        END IF;
 
        -- Confirma la actualización de TIPOHILA.
        COMMIT;
    end; 
 
 
PROCEDURE eliminarTipoHilaza (cod_tipo_hilaza number) is 
    v_registros_tihiprom NUMBER := 0;
 
    begin

        -- Validar si existen registros de promedio asociados al tipo de hilaza
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
 
        -- Valida que el TIPO DE HILAZA haya existido antes de confirmar la eliminación.
        IF SQL%ROWCOUNT = 0 THEN 
            RAISE_APPLICATION_ERROR( 
                -20019, 
                'El tipo de hilaza indicado no existe.' 
            ); 
        END IF; 
 
        -- Confirma la eliminación de TIPOHILA.
        COMMIT; 
 
    end; 
  
  
PROCEDURE insertarTipoHilaza (cod_tipo_hilaza number, nom_tipo_hilaza varchar2) is 
    begin

 
        INSERT INTO TIPOHILA (TIHICODI, TIHINOMB) 
 
        VALUES (cod_tipo_hilaza, nom_tipo_hilaza); 
 
        -- Confirma la creación de TIPOHILA.
        COMMIT;

    end; 
 
end PKG_TIPOHILA;
/