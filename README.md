# DVD Rental API 

Este proyecto consiste en el desarrollo de una API REST profesional para la gestión de una tienda de películas, utilizando la base de datos **Pagila**. El sistema está diseñado para manejar operaciones críticas como el registro de rentas y control de inventario mediante una arquitectura de contenedores.

Repositorio: [dvd_rental_bd](https://github.com/HannahPVV/dvd_rental_bd)


## Herramientas
* **Framework:** FastAPI
* **Lenguaje:** Python 3.11
* **Base de Datos:** PostgreSQL 15
* **Infraestructura:** Docker & Docker Compose
* **ORM:** SQLAlchemy 2.0
* **Validación de Datos:** Pydantic


## Instalación y Despliegue

### 1. Clonar el repositorio
```bash
git clone https://github.com/HannahPVV/dvd_rental_bd.git
cd dvd_rental_bd
```

### 2. Levantar entorno
Este comando construye los contenedores, crea el servicio PostgreSQL, inicializa la base pagila y ejecuta automáticamente el script pagila.sql:

```bash
docker-compose up --build
```

### 2.1 Verificación de la Base de Datos
Para confirmar que la base de datos se cargó correctamente y las tablas están listas, ejecuta:

```bash
docker exec -it pagila_db psql -U postgres -d pagila -c "\dt"
```

Se debería ver una lista de 21 tablas.

## Ejecución de queries.sql 
Para ejecutar las queries es necesario abrir una terminal, en la terminal el comando que se debe ingrear es:
```bash
docker exec -it pagila_db psql -U postgres -d pagila
```
Posteriormente en la terminal ya estamos dentro de Pagila por lo que copiamos el query que se quiere probar y damos enter.

## Ejecución de hot_invetory.sql
Para hacer uso de este archivo de pgbench se abre una terminal y se pone e siguiente comando:
```bash
docker exec -it pagila_db bash
```
Posteriomente el comando que se ingresa para ejecutar el script es el siguiente:
```bash
pgbench -U postgres -d pagila -c 20 -j 4 -T 30 -f /scripts/pgbench/hot_inventory.sql
```
## Ejecución de deadlock_pgbench.sql
Primero es necesario asegurarse que solo el problema o la solución estén siendo probadas, una parte debe mantenerse comentada con ("--") para poder
correr el archivo correctamente. 

Para hacer uso de este archivo de pgbench se abre una terminal y se pone e siguiente comando:
```bash
docker cp .\scripts\pgbench\deadlock_pgbench.sql pagila_db:/deadlock_pgbench.sql
```
Posteriomente el comando que se ingresa para ejecutar el script es el siguiente:
```bash
docker exec -it pagila_db pgbench -U postgres -d pagila -c 20 -j 4 -T 30 -f /deadlock_pgbench.sql
```



