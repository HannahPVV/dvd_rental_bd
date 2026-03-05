
-- WINDOW FUNCTION
--Hannah: Q1 -Top 10 clientes por gasto con ranking

SELECT 
    DENSE_RANK() OVER ( ORDER BY SUM(p.amount) DESC ) AS rank,
    c.customer_id, 
    c.first_name, 
    c.last_name, 
    SUM(p.amount) AS total_paid
FROM customer c

JOIN payment p ON c.customer_id = p.customer_id
GROUP BY c.customer_id, c.first_name, c.last_name 
ORDER BY total_paid DESC
LIMIT 10; 



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