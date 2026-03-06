import time
from fastapi import FastAPI, Depends, HTTPException
from sqlalchemy.orm import Session
from sqlalchemy import text
from datetime import datetime
from app import model_orm, schemas
from app.database import get_db

app = FastAPI()


"""Estrategia de endpoint /rentals: Bloqueo Pesimista 
Se usa 'with_for_update' para cumplir con el requisito de "Bajo dos requests simultáneos por el mismo inventory_id, 
solo uno debe concretarse". Lo que hace la base de datos es bloquear la fila y solo una procesa la renta.
Considero que es más práctico que el optimista porque no se requieren columnas de versión ni reintentos, y al ser bloqueo por 
fila, no afecta el rendimiento de otras rentas simultáneas de otros dvd's."""

#decorador llama el modelo de datos de salida que es el schemas.RentaCreada
#funcion llama al schema de CrearRenta que es el modelo de datos los de entrada
@app.post("/rentals", response_model=schemas.RentaCreada, status_code=201)
def crear_renta(entrada: schemas.CrearRenta, db: Session = Depends(get_db)): 
    inventory_id = entrada.inventory_id
    customer_id = entrada.customer_id
    staff_id = entrada.staff_id
    
    #se selecciona a la fila del inventario que se solicta rentar y tiene el bloqueo pesimista con with_for_update
    fila_bloqueada = db.query(model_orm.Inventory).filter(model_orm.Inventory.inventory_id == inventory_id).with_for_update().first()
    
    #validación de si existe id que se quiere rentar
    if not fila_bloqueada:
        raise HTTPException(status_code=404, detail="No se encontro ID en el inventario")
    
    #validación de si el dvd ya está rentado
    #si la fecha de return_date en None significa que ya esta rentado, porque no han regresado el dvd
    rentado = db.query(model_orm.Rental).filter(model_orm.Rental.inventory_id == inventory_id, model_orm.Rental.return_date == None).first()
    if rentado:
        raise HTTPException(status_code=400, detail="El DVD ya está rentado")

    # se crea variable de nueva renta que le pasa los datos que vamos a ingresar si pasa las validaciones
    nueva_renta = model_orm.Rental(
        inventory_id=inventory_id,
        customer_id=customer_id,
        staff_id=staff_id,
        rental_date=datetime.now(),
        last_update=datetime.now(),)
    

    # en el try se agregan las valores de la nueva renta, se hace commit para guardar
    try:
        db.add(nueva_renta)
        db.commit()  #se desbloquea el with_for_update al hacer commit
        db.refresh(nueva_renta) 
        return nueva_renta 
    
    except Exception as e:
        db.rollback() #si hay un error para liberar el with_for_update se hace rollback
        raise HTTPException(status_code=500, detail=f"Error: {str(e)}") 
    


@app.post("/returns/{rental_id}", response_model=schemas.RespuestaDevolucion)
def registrar_devolucion(rental_id: int, db: Session = Depends(get_db)):

    intentos = 0

    while intentos < 3:
        try:
            #Raquel:Tiempo de espera y se configura en CADA intento, porque si no me aparecia errores de serialización
            db.execute(text("SET TRANSACTION ISOLATION LEVEL SERIALIZABLE"))
            db.execute(text("SET statement_timeout = '2s'"))

            renta = (
                db.query(model_orm.Rental)
                .filter(model_orm.Rental.rental_id == rental_id)
                .with_for_update()   #Raquel: Bloquea la fila para evitar conflictos
                .first()
            )

            if not renta:
                raise HTTPException(status_code=404, detail="ID de renta no encontrado")

            if renta.return_date:
                return {
                    "rental_id": renta.rental_id,
                    "return_date": renta.return_date,
                    "estado": "ya estaba devuelto"
                }

            renta.return_date = datetime.now()
            renta.last_update = datetime.now()

            db.commit()

            return {
                "rental_id": renta.rental_id,
                "return_date": renta.return_date,
                "estado": "completado"
            }

        except Exception as e:
            db.rollback()
            error_str = str(e).lower()

            if "serialization" in error_str or "deadlock" in error_str or "timeout" in error_str:
                intentos += 1
                time.sleep(0.2* (2 ** intentos)) #Raquel: Esto es para lo del backoff
                continue

            raise HTTPException(status_code=500, detail=f"Error de base de datos: {error_str}")

    raise HTTPException(status_code=503, detail="La fila está bloqueada por otra transacción.")


@app.post("/payments")
def crear_pago(pago: schemas.CreacionPagos, db: Session = Depends(get_db)):
    
    max_intentos = 3
    intento = 0

    while intento < max_intentos:
        try:
            # Giselle: nivel de aislamiento de la transacción (REPEATABLE READ)
            db.execute(text("SET TRANSACTION ISOLATION LEVEL REPEATABLE READ"))

            #Giselle: Validar que el rental_id exista y corresponda al cliente.
            if pago.rental_id:
                renta_check = db.query(model_orm.Rental).filter(model_orm.Rental.rental_id == pago.rental_id, model_orm.Rental.customer_id == pago.customer_id).first()
                if not renta_check:
                    raise HTTPException(status_code=400, detail="La renta no existe o no pertenece a este cliente")

            fecha_valida = datetime(2022, 1, 1, 10, 0, 0)

            #Giselle: Creamos el pago que se va a guardar en la base de datos
            nuevo_pago = model_orm.Payment(
                customer_id=pago.customer_id,
                staff_id=pago.staff_id,
                amount=pago.amount,
                rental_id=pago.rental_id,
                payment_date=fecha_valida
            )
    
    
            db.add(nuevo_pago)
            db.commit()
            db.refresh(nuevo_pago)
            return {"mensaje": "pago registrado", "id": nuevo_pago.payment_id}
        except Exception as e:
            db.rollback()
            error_texto = str(e).lower()

            # Giselle: manejo de posibles errores de concurrencia
            if "deadlock" in error_texto or "serialization" in error_texto:

                intento += 1
                tiempo_espera = 0.3 * (2 ** intento)
                time.sleep(tiempo_espera)
                continue

            raise HTTPException(status_code=500, detail="No se pudo registrar el pago") 
    
    raise HTTPException(status_code=503, detail="No se pudo completar el pago debido a conflictos de concurrencia.")