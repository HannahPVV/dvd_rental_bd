from pydantic import BaseModel
from datetime import datetime


#es la entrada del post de rentals, que cumple con el requisito de entrada mínima de parámetros
class CrearRenta(BaseModel):
    inventory_id: int
    customer_id: int
    staff_id: int

    class Config:
        from_attributes = True

# es la respuesta del post de rentals, que muestra todos los datos de la renta creada
class RentaCreada(BaseModel):
    rental_id: int
    rental_date: datetime
    inventory_id: int
    customer_id: int
    return_date: datetime | None
    staff_id: int
    last_update: datetime

    class Config:
        from_attributes = True

class RespuestaDevolucion(BaseModel):
    rental_id: int
    return_date: datetime
    estado: str  

    class Config:
        from_attributes = True

class CreacionPagos(BaseModel):
    customer_id: int
    staff_id: int
    amount: float
    #Giselle: El rental_id es opcional, ya que el cliente puede pagar sin una renta específica
    rental_id: Optional[int] = None 