from pydantic import BaseModel
from datetime import datetime

class RespuestaDevolucion(BaseModel):
    rental_id: int
    return_date: datetime
    estado: str  

    class Config:
        from_attributes = True