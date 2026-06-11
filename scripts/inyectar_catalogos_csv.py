"""
Inyecta datos desde CSV hacia las tablas de catálogos y geografía.

Tablas destino:
  entidad_federativa  ← catalogos/localidades/csv/estados.csv
  asentamiento        ← catalogos/localidades/csv/municipios.csv
  cat_lengua_inali    ← catalogos/lenguas/csv/lenguas_inali.csv
  cat_lengua          ← catalogos/lenguas/csv/lenguas_inali.csv
"""

import sys
from pathlib import Path

import pandas as pd
from sqlalchemy import create_engine, text

sys.path.insert(0, str(Path(__file__).resolve().parent.parent))
from app.config import DATABASE_URL

BASE_DIR = Path(__file__).resolve().parent.parent

MAPA_CATALOGOS: dict = {
    "entidad_federativa": {
        "csv": BASE_DIR / "catalogos/localidades/csv/estados.csv",
        "rename": {"id_estado": "id_ent", "nombre": "nom_ent"},
        "defaults": {},
        "preserve_id_col": "id_ent",
    },
    "asentamiento": {
        "csv": BASE_DIR / "catalogos/localidades/csv/municipios.csv",
        "rename": {"id_municipio": "id_mun", "nombre": "nom_mun", "id_estado": "id_ent"},
        "defaults": {
            "id_col":  None,
            "nom_col": "Sin registro",
            "cp_asen": "00000",
        },
        "preserve_id_col": None,
    },
    "cat_lengua_inali": {
        "csv": BASE_DIR / "catalogos/lenguas/csv/lenguas_inali.csv",
        "rename": {},
        "defaults": {},
        "preserve_id_col": "id_lengua",
    },
    "cat_lengua": {
        "csv": BASE_DIR / "catalogos/lenguas/csv/lenguas_inali.csv",
        "rename": {"id_lengua": "id_len"},
        "defaults": {},
        "preserve_id_col": "id_len",
    },
}


def _normalizar_booleanos(df: pd.DataFrame) -> pd.DataFrame:
    """Convierte cadenas 'true'/'false' a booleanos nativos de Python."""
    for col in df.columns:
        if df[col].dtype == object:
            muestra = df[col].dropna().astype(str).str.lower().unique()
            if set(muestra).issubset({"true", "false"}):
                df[col] = df[col].astype(str).str.lower() == "true"
    return df


def inyectar(tabla: str, config: dict) -> None:
    df = pd.read_csv(config["csv"])
    df = _normalizar_booleanos(df)

    if config.get("rename"):
        df = df.rename(columns=config["rename"])

    for col, val in config.get("defaults", {}).items():
        df[col] = val

    with engine.begin() as conn:
        conteo = conn.execute(text(f"SELECT COUNT(*) FROM {tabla}")).scalar()
        if conteo > 0:
            print(f"  {tabla}: ya contiene {conteo} filas — omitiendo.")
            return

        registros = df.where(pd.notna(df), other=None).to_dict(orient="records")
        for fila in registros:
            cols = ", ".join(fila.keys())
            vals = ", ".join(f":{k}" for k in fila.keys())
            conn.execute(text(f"INSERT INTO {tabla} ({cols}) VALUES ({vals})"), fila)

        pk_col = config.get("preserve_id_col")
        if pk_col and pk_col in df.columns:
            max_id = int(df[pk_col].max())
            seq_name = f"{tabla}_{pk_col}_seq"
            conn.execute(text(f"SELECT setval('{seq_name}', :max_id)"), {"max_id": max_id})

    print(f"  {tabla}: {len(df)} filas insertadas.")


if __name__ == "__main__":
    engine = create_engine(DATABASE_URL)
    for tabla, config in MAPA_CATALOGOS.items():
        print(f"→ Procesando: {tabla}")
        try:
            inyectar(tabla, config)
        except Exception as exc:
            print(f"  ERROR en {tabla}: {exc}")
    print("\nInyección completada.")
