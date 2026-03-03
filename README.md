# DVD Rental API 

Este proyecto consiste en el desarrollo de una API REST profesional para la gestión de una tienda de películas, utilizando la base de datos **Pagila**. El sistema está diseñado para manejar operaciones críticas como el registro de rentas y control de inventario mediante una arquitectura de contenedores.


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
git clone [https://github.com/hpval/dvd_rental_bd.git](https://github.com/hpval/dvd_rental_bd.git)
cd dvd_rental_bd
```

### 2. Agregar archivo .env
Dar click en create new file en dvd_rental_bd, nombrarlo ".env" y pegar en el lo siguiente:
DATABASE_URL=postgresql://postgres:password123@db:5432/pagila 

### 3. Levantar entorno
Este comando construye los contenedores, crea el servicio PostgreSQL, inicializa la base pagila y ejecuta automáticamente el script pagila.sql:

```bash
docker-compose up --build
```

### 3.1 Verificación de la Base de Datos
Para confirmar que la base de datos se cargó correctamente y las tablas están listas, ejecuta:

```bash
docker exec -it pagila_db psql -U postgres -d pagila -c "\dt"
```

Se deberías ver una lista de 21 tablas.