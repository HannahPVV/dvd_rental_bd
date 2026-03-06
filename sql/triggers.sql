-- Trigger 7.1 - Auditoría
-- Giselle: Creación de la tabla audit_log
CREATE TABLE audit_log (
    log_id SERIAL PRIMARY KEY,
    event_ts TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    table_name TEXT,
    op TEXT,
    pk TEXT,
    old_row JSONB,
    new_row JSONB
);
-- Giselle: Trigger
CREATE OR REPLACE FUNCTION audit_ryp()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
    IF TG_OP = 'INSERT' THEN
        INSERT INTO audit_log (table_name, op, pk, new_row)
        VALUES (TG_TABLE_NAME, TG_OP, row_to_json(NEW)::text, to_jsonb(NEW));
    ELSIF TG_OP = 'UPDATE' THEN
        INSERT INTO audit_log (table_name, op, pk, old_row, new_row)
        VALUES (TG_TABLE_NAME, TG_OP, row_to_json(NEW)::text, to_jsonb(OLD), to_jsonb(NEW));
    ELSIF TG_OP = 'DELETE' THEN
        INSERT INTO audit_log (table_name, op, pk, old_row)
        VALUES (TG_TABLE_NAME, TG_OP, row_to_json(OLD)::text, to_jsonb(OLD));
    END IF;
    RETURN NULL;
END;
$$;
-- Giselle: Trigger para rental
CREATE TRIGGER trg_audit_rental
AFTER INSERT OR UPDATE OR DELETE ON rental
FOR EACH ROW 
EXECUTE FUNCTION audit_ryp();
-- Giselle: Trigger para payment
CREATE TRIGGER trg_audit_payment
AFTER INSERT OR UPDATE OR DELETE ON payment
FOR EACH ROW 
EXECUTE FUNCTION audit_ryp();

-- Giselle: Ejemplos: de Insert, Update y Delete en la tabla rental
INSERT INTO rental (rental_date, inventory_id, customer_id, return_date, staff_id)
VALUES ('2022-08-27', 1, 1, NULL, 1);

UPDATE rental SET return_date = '2022-05-26'
WHERE rental_id = 1;

-- Giselle: Para poder eliminar el registro de rental, primero se elimina el registro relacionado en payment
-- debido a la restricción de llave foránea
DELETE FROM payment
WHERE rental_id = 1;

DELETE FROM rental
WHERE rental_id = 1;

-- Giselle: Ejemplos: de Insert, Update y Delete en la tabla payment
INSERT INTO payment (customer_id, staff_id, rental_id, amount, payment_date)
VALUES (1, 1, 1, 5.99, '2022-05-25');

UPDATE payment SET amount = 6.99
WHERE payment_id = 1;

DELETE FROM payment
WHERE payment_id = 1;


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
        RAISE EXCEPTION 'Error: El monto del pago (%) debe ser mayor a cero.', NEW.amount; --Raquel:Aprendí que era necesario el % para que me aparezca el monto del mensaje y no surja un error
    END IF;

    RETURN NEW;
END;
$$;
CREATE TRIGGER trg_check_pago_rango
BEFORE INSERT ON payment
FOR EACH ROW
EXECUTE FUNCTION fn_validar_pago_positivo();

-- Raquel: Insertamos datos a la tabla payment para probar el trigger y que rechace el pago con monto inválido
INSERT INTO payment (customer_id, staff_id, rental_id, amount, payment_date)
VALUES (1, 1, 1, -10.50, '2022-05-15'); --Raquel: Aprendí que es necesario poner la fecha porque la tabla payments está particionada en pagila por fecha

-- Raquel: Insertamos datos a la tabla payment para probar el trigger y que acepte el pago cuando el monto es válido
INSERT INTO payment (customer_id, staff_id, rental_id, amount, payment_date)
VALUES (1, 1, 1, 4.99, '2022-05-15 12:00:00');