-- CTES
-- Giselle: Q3 - Inventario disponible por tienda (CTE)
-- Giselle: CTE con los inventory_id que tienen renta activa
WITH renta_activa AS (
    SELECT inventory_id
    FROM rental
    WHERE return_date IS NULL
)

-- Giselle:Contar el inventario disponible por tienda
SELECT i.store_id, 
COUNT(i.inventory_id) AS available_inventory_count
FROM inventory i
LEFT JOIN renta_activa rta ON i.inventory_id = rta.inventory_id
WHERE rta.inventory_id IS NULL  
GROUP BY i.store_id
ORDER BY i.store_id;