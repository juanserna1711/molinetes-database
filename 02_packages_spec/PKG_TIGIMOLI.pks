CREATE OR REPLACE PACKAGE PKG_TIGIMOLI

AS

--=============================================================================
-- Nombre responsabilidad: Crear la especificación (.pks) del paquete
-- PKG_TIGIMOLI para la gestión de TIGIMOLI.
--
-- Autor: JUAN ANDRES SERNA CASTRO
-- Fecha_creacion: 18/Septiembre/2026
--
-- Descripcion responsabilidad:
-- Declarar la interfaz pública para registrar los cálculos de giro por molinete y talla,
-- almacenando el resultado en TIGIMOLI y generando la respectiva
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

-------------------------------------------------------------------------
--TIPOS
-------------------------------------------------------------------------

--Colección asociativa de números utilizada por los parámetros de listas del registro.

TYPE t_lista_numeros IS TABLE OF NUMBER
    INDEX BY BINARY_INTEGER;

-------------------------------------------------------------------------
--INSERTS
-------------------------------------------------------------------------

--Registro del cálculo con listas de molinetes, tallas, cantidades de rollos y RPM, junto con el tipo de hilaza y el usuario; devuelve el código de la orden generada.

PROCEDURE registrarCalculoTigimoli (
    codigos_molinetes t_lista_numeros,
    codigos_tallas t_lista_numeros,
    cantidades_rollos t_lista_numeros,
    rpms_molinetes t_lista_numeros,
    cod_tipo_hilaza NUMBER,
    usuario NUMBER,
    codigo_orden OUT NUMBER
);

END PKG_TIGIMOLI;
/