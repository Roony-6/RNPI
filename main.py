"""
RNPI — Red Nacional de Protección Infantil
Backend principal: FastAPI + SQLAlchemy + PostgreSQL
"""

from fastapi import Depends, FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import FileResponse
from fastapi.staticfiles import StaticFiles
from sqlalchemy import text
from sqlalchemy.orm import Session

from app.database import get_db
from app.routers import auth, catalogos, nna, personal

app = FastAPI(
    title="RNPI API",
    description="Red Nacional de Protección Infantil — Backend",
    version="1.0.0",
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=[
        "http://localhost:8000",
        "http://127.0.0.1:8000",
    ],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.mount("/static", StaticFiles(directory="static"), name="static")

app.include_router(auth.router)
app.include_router(personal.router)
app.include_router(catalogos.router)
app.include_router(nna.router)


@app.get("/ui", tags=["Frontend"])
def frontend():
    return FileResponse("static/index.html")


@app.get("/", tags=["Sistema"])
def raiz():
    return {"mensaje": "RNPI API activa"}


@app.get("/health", tags=["Sistema"])
def health(db: Session = Depends(get_db)):
    try:
        db.execute(text("SELECT 1"))
        return {"estado": "ok", "base_de_datos": "conectada"}
    except Exception as e:
        raise HTTPException(status_code=503, detail=f"Base de datos no disponible: {e}")


if __name__ == "__main__":
    import uvicorn
    uvicorn.run("main:app", host="0.0.0.0", port=8000, reload=True)
