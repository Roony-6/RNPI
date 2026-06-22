-- ============================================================
-- SEMILLAS DE CATÁLOGOS DE SOPORTE — RNPI
-- Idempotente: solo inserta si la tabla está vacía.
-- ============================================================

INSERT INTO cat_sexo (nombre)
SELECT v FROM (VALUES ('Mujer'), ('Hombre'), ('Intersexual')) AS s(v)
WHERE NOT EXISTS (SELECT 1 FROM cat_sexo);

INSERT INTO cat_nacionalidad (nombre)
SELECT v FROM (VALUES
    ('Mexicana'), ('Guatemalteca'), ('Hondureña'), ('Salvadoreña'),
    ('Venezolana'), ('Estadounidense'), ('Otra')
) AS s(v)
WHERE NOT EXISTS (SELECT 1 FROM cat_nacionalidad);

INSERT INTO cat_tipo_contacto (nombre)
SELECT v FROM (VALUES
    ('Teléfono fijo'), ('Teléfono celular'), ('Correo electrónico'), ('Otro')
) AS s(v)
WHERE NOT EXISTS (SELECT 1 FROM cat_tipo_contacto);

INSERT INTO cat_discapacidad (nombre)
SELECT v FROM (VALUES
    ('Motriz'), ('Visual'), ('Auditiva'), ('Intelectual'),
    ('Psicosocial'), ('Múltiple')
) AS s(v)
WHERE NOT EXISTS (SELECT 1 FROM cat_discapacidad);

INSERT INTO cat_grado_dependencia (descripcion)
SELECT v FROM (VALUES
    ('Sin dependencia'), ('Leve'), ('Moderado'), ('Severo'), ('Total')
) AS s(v)
WHERE NOT EXISTS (SELECT 1 FROM cat_grado_dependencia);

INSERT INTO cat_nivel_competencia_oral (descripcion)
SELECT v FROM (VALUES
    ('No comprende ni habla'), ('Comprende pero no habla'),
    ('Habla con dificultad'), ('Habla con fluidez')
) AS s(v)
WHERE NOT EXISTS (SELECT 1 FROM cat_nivel_competencia_oral);

INSERT INTO cat_modo_adquisicion_lengua (descripcion)
SELECT v FROM (VALUES
    ('Lengua materna'), ('Segunda lengua'),
    ('Aprendida en la escuela'), ('Otra')
) AS s(v)
WHERE NOT EXISTS (SELECT 1 FROM cat_modo_adquisicion_lengua);
