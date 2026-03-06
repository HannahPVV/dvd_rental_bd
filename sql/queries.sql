
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

-- Raquel: Q2 - Top 3 películas más rentadas por tienda (CTE)
WITH RentasPorPelicula AS (
    SELECT 
        i.store_id, 
        f.film_id, 
        f.title, 
        COUNT(r.rental_id) AS rentals_count
    FROM film f
    JOIN inventory i ON f.film_id = i.film_id
    JOIN rental r ON i.inventory_id = r.inventory_id
    GROUP BY i.store_id, f.film_id, f.title
),
RankingPeliculas AS (
    SELECT 
        store_id, 
        film_id, 
        title, 
        rentals_count,
        ROW_NUMBER() OVER (
            PARTITION BY store_id 
            ORDER BY rentals_count DESC
        ) AS rn
    FROM RentasPorPelicula
)
SELECT store_id, film_id, title, rentals_count, rn
FROM RankingPeliculas
WHERE rn <= 3;

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

-- Raquel: Q4 - Auditoría de pagos (CTE)
WITH PagosDuplicados AS (
    
    SELECT 
        customer_id, 
        amount, 
        CAST(payment_date AS DATE) as fecha,
        COUNT(*) as repeticiones
    FROM payment
    GROUP BY customer_id, amount, CAST(payment_date AS DATE)
    HAVING COUNT(*) > 1 
),
Auditoria AS (
    
    SELECT 
        p.payment_id, 
        p.customer_id, 
        p.amount, 
        p.payment_date, 
        'Pago repetido el mismo día' AS flag_reason
    FROM payment p
    JOIN PagosDuplicados d ON p.customer_id = d.customer_id 
        AND p.amount = d.amount 
        AND CAST(p.payment_date AS DATE) = d.fecha

    UNION ALL

    
    SELECT 
        payment_id, 
        customer_id, 
        amount, 
        payment_date, 
        'Monto excede umbral (Mayor a 10)' AS flag_reason
    FROM payment
    WHERE amount > 10.00
)
SELECT payment_id, customer_id, amount, payment_date, flag_reason
FROM Auditoria
ORDER BY payment_date DESC;