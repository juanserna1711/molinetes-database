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
          AND (nom_molinete IS NULL OR 
               LOWER(MOLINOMB) LIKE '%' || LOWER(nom_molinete) || '%')
        ORDER BY MOLICODI ASC; 
 
end;
 
 
PROCEDURE actualizarMolinete ( cod_molinete NUMBER, nom_molinete VARCHAR2, rpm_molinete NUMBER, peri_molinete NUMBER) is 

    begin

        -- Valida que el RPM sea válido.
        IF rpm_molinete <= 0 OR rpm_molinete > 999 THEN 
            RAISE_APPLICATION_ERROR( 
                -20010, 
                'El RPM del molinete no es válido.' 
            ); 
        END IF;

        -- Valida que el perimetro sea válido.
        IF peri_molinete <= 0 OR peri_molinete > 999 THEN 
            RAISE_APPLICATION_ERROR( 
                -20011, 
                'El perímetro del molinete no es válido.' 
            ); 
        END IF;
 
        UPDATE MOLINETE 
 
        SET MOLINOMB =  nom_molinete, MOLIRPM = rpm_molinete, MOLIPERI = peri_molinete 
 
        WHERE MOLICODI = cod_molinete; 

        -- Valida que el MOLINETE exista.
        IF SQL%ROWCOUNT = 0 THEN 
            RAISE_APPLICATION_ERROR( 
                -20009, 
                'El molinete indicado no existe.' 
            ); 
        END IF;
 
        -- Confirma la actualización de MOLINETE.
        COMMIT;

        -- Manejo general de excepciones:
        -- Ante cualquier error durante la operación se revierten los cambios realizados.
        EXCEPTION 
            WHEN OTHERS THEN 
                ROLLBACK; 
                RAISE; 
    end; 
 
 
PROCEDURE eliminarMolinete (cod_molinete number) is 
 
    begin
 
        DELETE 
 
        FROM MOLINETE 
 
        WHERE MOLICODI = cod_molinete; 
 
        -- Valida que el MOLINETE haya existido antes de confirmar la eliminación.
        IF SQL%ROWCOUNT = 0 THEN 
            RAISE_APPLICATION_ERROR( 
                -20009, 
                'El molinete indicado no existe.' 
            ); 
        END IF;
 
        -- Confirma la eliminación de MOLINETE.
        COMMIT; 
 
    end;
  
 
PROCEDURE insertarMolinete (cod_molinete number, nom_molinete varchar2, rpm_molinete number, peri_molinete number) is 
    begin

        -- Valida que el RPM sea válido.
        IF rpm_molinete <= 0 OR rpm_molinete > 999 THEN 
            RAISE_APPLICATION_ERROR( 
                -20010, 
                'El RPM del molinete no es válido, debe estar entre 1 y 999.' 
            ); 
        END IF;

        -- Valida que el perimetro sea válido.
        IF peri_molinete <= 0 OR peri_molinete > 999 THEN 
            RAISE_APPLICATION_ERROR( 
                -20011, 
                'El perímetro del molinete no es válido, debe estar entre 1 y 999.' 
            ); 
        END IF;

 
        INSERT INTO MOLINETE (MOLICODI, MOLINOMB, MOLIRPM, MOLIPERI) 
 
        VALUES (cod_molinete, nom_molinete, rpm_molinete, peri_molinete);
 
        -- Confirma la creación de MOLINETE.
        COMMIT;

        -- Manejo general de excepciones:
        -- Si cualquiera de los INSERT genera un error, se revierten
        -- las operaciones realizadas.
        EXCEPTION 
            WHEN OTHERS THEN 
                ROLLBACK; 
                RAISE; 

    end; 
 
end PKG_MOLINETE;