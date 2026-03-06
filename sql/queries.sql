
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


-- Raquel: Q2 - Top 3 películas más rentadas por tienda (CTE)
-- Propósito:El propósito de esta consulta es mostrar las tres 
-- películas más populares en cada sucursal, cada sucursal identificada por su id. Este query se basa en el 
--volumen total de rentas registradas en el sistema, mostrando el id de la sucursal, 
--el id de la película, el título de la película, el total de rentas y el lugar en el top 3 que tiene cada película.
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

-- Hannah: Q4 — Análisis de retrasos: rentas tardías agregadas por categoría (CTE)
WITH late_rentals AS (
    SELECT fc.category_id, r.rental_id,
        EXTRACT(DAY FROM(r.return_date - r.rental_date)) AS total_days,
        f.rental_duration AS allowed_days
    FROM rental r

    JOIN inventory i ON r.inventory_id = i.inventory_id
    JOIN film f ON i.film_id = f.film_id
    JOIN film_category fc ON f.film_id = fc.film_id
    WHERE EXTRACT(DAY FROM(r.return_date - r.rental_date)) > f.rental_duration
)
SELECT c.category_id, c.name AS category_name,
    COUNT(lr.rental_id) AS late_rentals,
    ROUND(AVG(lr.total_days - lr.allowed_days),2) AS avg_days_late
FROM category c
LEFT JOIN late_rentals lr ON c.category_id = lr.category_id
GROUP BY c.category_id, c.name
ORDER BY late_rentals DESC;

-- Raquel: Q5 - Auditoría de pagos (CTE)
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

-- CONSULTAS OPERATIVAS / "DE SISTEMA"

-- Giselle: Q6 - "Clientes con riesgo (mora)"
-- Se muestra a los clientes que han tenido varias devoluciones tardías

SELECT r.customer_id, 
    COUNT(r.rental_id) AS late_returns_count, 
    MAX(r.return_date) AS last_late_return_date
FROM rental r
JOIN inventory i ON r.inventory_id = i.inventory_id
JOIN film f ON i.film_id = f.film_id
WHERE r.return_date > (r.rental_date + (f.rental_duration || ' days')::interval)
GROUP BY r.customer_id
HAVING COUNT(r.rental_id) > 6
ORDER BY late_returns_count DESC;

-- Hannah: Q7 — Integridad/consistencia: inventario con rentas activas duplicadas 
SELECT  inventory_id, 
    COUNT(*) AS active_rentals_count,
    ARRAY_AGG(rental_id) AS rental_ids
FROM rental
WHERE return_date IS NULL
GROUP BY inventory_id
HAVING COUNT(*) > 1;



