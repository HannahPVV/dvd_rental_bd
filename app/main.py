import time
from fastapi import FastAPI, Depends, HTTPException
from sqlalchemy.orm import Session
from sqlalchemy import text
from datetime import datetime
from app import model_orm, schemas
from app.database import get_db

app = FastAPI()

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
                time.sleep(0.2)
                continue

            raise HTTPException(status_code=500, detail=f"Error de base de datos: {error_str}")

    raise HTTPException(status_code=503, detail="La fila está bloqueada por otra transacción.")


@app.post("/payments")
def crear_pago(pago: schemas.CreacionPagos, db: Session = Depends(get_db)):
    
    #Giselle: Validar que el rental_id exista y corresponda al cliente.
    if pago.rental_id:
        renta_check = db.query(models.Rental).filter(models.Rental.rental_id == pago.rental_id, models.Rental.customer_id == pago.customer_id).first()
        if not renta_check:
            raise HTTPException(status_code=400, detail="La renta no existe o no pertenece a este cliente")

    #Giselle: Creamos el pago que se va a guardar en la base de datos
    nuevo_pago = models.Payment(
        customer_id=pago.customer_id,
        staff_id=pago.staff_id,
        amount=pago.amount,
        rental_id=pago.rental_id,
        payment_date=datetime.now()
    )
    
    try:
        db.add(nuevo_pago)
        db.commit()
        db.refresh(nuevo_pago)
        return {"mensaje": "pago registrado", "id": nuevo_pago.payment_id}
    except Exception:
        db.rollback()
        raise HTTPException(status_code=500, detail="No se pudo registrar el pago") 
