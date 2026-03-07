
-- Para elegir un ID de inventario sin rentar, se puede usare el siguinte query en la bd:
--SELECT inventory_id
--FROM inventory
--WHERE inventory_id NOT IN (SELECT inventory_id FROM rental WHERE return_date IS NULL);

--Se asigna un inventory_id fijo que llamamos inventory_target
--Se selecciona cliente aleatorio, ese rango es porque la bd tiene 1-599 en customer_id

\set inventory_target 1
\set random_customer random(1, 599)
\set staff_id 1  

BEGIN;

-- Bloqueo pesimista con el for update
SELECT inventory_id 
FROM inventory 
WHERE inventory_id = :inventory_target 
FOR UPDATE;

-- Decalramos un conteo para verificar si el inventory_id seleccionado ya esta rentado y que se asigne el return date como null 
SELECT COUNT(*) AS rentado 
FROM rental 
WHERE inventory_id = :inventory_target AND return_date IS NULL \gset

-- aqui es donde usamos rentado para ver si es mayor a 0 significa que ya esta rentado y no se puede rentar
-- entonces solo se insertan valores de la nueva renta si rentado es igual a 0
\if :rentado = 0
    INSERT INTO rental (rental_date, inventory_id, customer_id, staff_id, last_update)
    VALUES (CURRENT_TIMESTAMP, :inventory_target, :random_customer, :staff_id, CURRENT_TIMESTAMP);
\endif

COMMIT;