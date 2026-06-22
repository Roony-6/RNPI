-- Migración 5NF: divide personal.nombre_completo en campos atómicos
-- nom_personal / prim_ap_personal / seg_ap_personal (mismo estándar que tutor y nna).
-- Heurística de reparto: las últimas 2 palabras se toman como apellidos;
-- revisar manualmente los registros con nombres atípicos antes de ejecutar.

BEGIN;

ALTER TABLE personal
    ADD COLUMN nom_personal     character varying(200),
    ADD COLUMN prim_ap_personal character varying(200),
    ADD COLUMN seg_ap_personal  character varying(200);

UPDATE personal p
SET nom_personal     = s.nom,
    prim_ap_personal = s.prim,
    seg_ap_personal  = s.seg
FROM (
    SELECT id_personal,
           CASE WHEN n <= 2 THEN partes[1]
                ELSE array_to_string(partes[1:n-2], ' ')
           END AS nom,
           CASE WHEN n = 1 THEN partes[1]
                WHEN n = 2 THEN partes[2]
                ELSE partes[n-1]
           END AS prim,
           CASE WHEN n >= 3 THEN partes[n] END AS seg
    FROM (
        SELECT id_personal,
               regexp_split_to_array(btrim(nombre_completo), '\s+') AS partes,
               array_length(regexp_split_to_array(btrim(nombre_completo), '\s+'), 1) AS n
        FROM personal
    ) t
) s
WHERE p.id_personal = s.id_personal;

ALTER TABLE personal
    ALTER COLUMN nom_personal     SET NOT NULL,
    ALTER COLUMN prim_ap_personal SET NOT NULL;

ALTER TABLE personal DROP COLUMN nombre_completo;

COMMIT;
