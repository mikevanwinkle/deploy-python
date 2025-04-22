from fastapi import FastAPI
from mangum import Mangum

app = FastAPI()

@app.get("/")
async def root():
    return {"message": "Hello, World!"}

@app.get("/api")
async def api():
    return {"message": "Hello, World!"}

@app.get("/dev")
async def dev():
    return {"message": "Hello, World!"}

handler = Mangum(app, lifespan="off")
