import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent.parent))

from app.auth.security import hash_password
from app.database import SessionLocal
from app.models.catalogos import CatRol
from app.models.core import Personal


def crear_primer_admin() -> None:
    db = SessionLocal()

    rol_director = (
        db.query(CatRol).filter(CatRol.nombre_rol.ilike("%director%")).first()
    )
    if not rol_director:
        rol_director = CatRol(nombre_rol="Director General")
        db.add(rol_director)
        db.commit()
        db.refresh(rol_director)

    correo_admin = "director@rnpi.gob.mx"
    if not db.query(Personal).filter(Personal.correo == correo_admin).first():
        admin = Personal(
            nom_personal="Director",
            prim_ap_personal="General",
            seg_ap_personal=None,
            rfc="ADMIN12345678",
            curp="ADMIN1234567890123",
            correo=correo_admin,
            contrasena=hash_password("rnpi_secreto_123"),
            id_rol=rol_director.id_rol,
            activo=True,
        )
        db.add(admin)
        db.commit()
        print(f"Administrador creado. Correo: {correo_admin} | Pass: rnpi_secreto_123")
    else:
        print("El administrador ya existe en la base de datos.")

    db.close()


if __name__ == "__main__":
    crear_primer_admin()
