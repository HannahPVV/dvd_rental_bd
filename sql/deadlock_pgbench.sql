--SCRIPT B CON PGBENCH
-- RAQUEL: Primero cree una tabla para solo usarla con este script, me daba cosa afectar algo más de la base de datos que si usamos
-- en caso de que esto no funcione


---Prueba de Deadlock en pgbench

--BEGIN;

--\set orden random(1,2)

--\if :orden = 1
--UPDATE prueba_deadlock SET valor = valor + 1 WHERE id = 1;
--SELECT pg_sleep(0.2);
--UPDATE prueba_deadlock SET valor = valor + 1 WHERE id = 2;
--\else
--UPDATE prueba_deadlock SET valor = valor + 1 WHERE id = 2;
--SELECT pg_sleep(0.2);
--UPDATE prueba_deadlock SET valor = valor + 1 WHERE id = 1;
--\endif

--COMMIT;

-- Solución: mantener el orden de filas en ambos procesos
-- (Descomentar esta parte para eliminar el deadlock)


BEGIN;

UPDATE prueba_deadlock
SET valor = valor + 1
WHERE id = 1;

SELECT pg_sleep(0.05);

UPDATE prueba_deadlock
SET valor = valor + 1
WHERE id = 2;

COMMIT;

