from fastapi import FastAPI

app = FastAPI(title="DVD Rental API")

@app.get("/")
def read_root():
    return {"API de Renta de DVDs conectada en Docker"}