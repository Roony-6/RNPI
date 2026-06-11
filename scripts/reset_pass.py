import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent.parent))

from app.auth.security import hash_password
from app.database import SessionLocal
from app.models.core import Personal


def resetear_password() -> None:
    db = SessionLocal()

    admin = db.query(Personal).filter(Personal.correo == "director@rnpi.gob.mx").first()
    if admin:
        admin.contrasena = hash_password("rnpi_secreto_123")
        db.commit()
        print("Contraseña actualizada y encriptada correctamente.")
    else:
        print("El usuario no existe. Asegúrate de haber ejecutado crear_admin.py")

    db.close()


if __name__ == "__main__":
    resetear_password()
