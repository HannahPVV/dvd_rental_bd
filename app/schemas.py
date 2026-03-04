from pydantic import BaseModel
from datetime import datetime
from typing import Optional

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