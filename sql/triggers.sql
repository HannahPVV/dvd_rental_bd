


--Trigger 7.2
-- Raquel: Elegí el trigger B
-- Propósito: Implementar un trigger que ayude a  validar datos financieros,
-- impidiendo que entren registros de pagos con montos inválidos (menores o iguales a cero)

CREATE OR REPLACE FUNCTION fn_validar_pago_positivo()
RETURNS TRIGGER 
LANGUAGE plpgsql
AS $$
BEGIN
    IF NEW.amount <= 0 THEN
        RAISE EXCEPTION 'Error: El monto del pago (%) debe ser mayor a cero.', NEW.amount; --Aprendí que era necesario el % para que me aparezca el monto del mensaje y no surja un error
    END IF;

    RETURN NEW;
END;
$$;
CREATE TRIGGER trg_check_pago_rango
BEFORE INSERT ON payment
FOR EACH ROW
EXECUTE FUNCTION fn_validar_pago_positivo();

-- Insertamos datos a la tabla payment para probar el trigger y que rechace el pago con monto inválido
INSERT INTO payment (customer_id, staff_id, rental_id, amount, payment_date)
VALUES (1, 1, 1, -10.50, '2022-05-15'); --Aprendí que es necesario poner la fecha porque la tabla payments está particionada en pagila por fecha

-- Insertamos datos a la tabla payment para probar el trigger y que acepte el pago cuando el monto es válido
INSERT INTO payment (customer_id, staff_id, rental_id, amount, payment_date)
VALUES (1, 1, 1, 4.99, '2022-05-15 12:00:00');