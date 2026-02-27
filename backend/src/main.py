from fastapi import FastAPI
from src.routers import personal, menores, celulas, catalogos
from fastapi.middleware.cors import CORSMiddleware
from fastapi.staticfiles import StaticFiles





app = FastAPI(
    title="RNPI - Sistema de Gestión de Menores",
    version="1.0.0"
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_methods=["*"],
    allow_headers=["*"],
)

app.mount("/static", StaticFiles(directory="src/static"), name="static")
app.include_router(catalogos.router, prefix="/catalogos", tags=["Catálogos"])
app.include_router(celulas.router,   prefix="/celulas",   tags=["Células"])
app.include_router(personal.router,  prefix="/personal",  tags=["Personal"])
app.include_router(menores.router,   prefix="/menores",   tags=["Menores"])

@app.get("/")
def root():
    return {"mensaje": "API del sistema RNPI activa"}



