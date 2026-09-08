DECLARE fecha_inicio DATE DEFAULT '2026-08-01';   -- ajustar rango
DECLARE fecha_fin    DATE DEFAULT '2026-08-31';   -- ajustar rango

WITH
-- 1) Clicks en el card (appnativa), únicos por usuario-día
clicks AS (
  SELECT DISTINCT
    id_digital,
    fec_visita
  FROM `rs-shr-al-analyticsz-prj-ebc1.anl_digital.registro_usuario_zp_appnativa`
  WHERE des_nombre_evento = 'Seguros:MBOX:Click:Card mbox_misSeguros_veh_260730'
    AND fec_visita BETWEEN fecha_inicio AND fecha_fin
)
,

-- 2) Paso planes, únicos por usuario-día
planes AS (
  SELECT DISTINCT
    id_digital,
    fec_visita
  FROM `rs-shr-al-analyticsz-prj-ebc1.anl_digital.registro_solicitudes`
  WHERE des_pantalla = 'sol:comprar:seguro-vehicular:planes'
    AND fec_visita BETWEEN fecha_inicio AND fecha_fin
    and (lower(des_campania_post) like 'app%' or lower(ind_tracking_campania_post) like 'app%')
)
,
--SELECT * FROM PLANES
-- 3) LEADS = click Y planes el mismo día (único por usuario-día)
leads AS (
  SELECT
    c.fec_visita,
    c.id_digital
  FROM clicks c
  INNER JOIN planes p
    ON c.id_digital = p.id_digital
   AND c.fec_visita = p.fec_visita
),

-- 4) Compras vehiculares con transacción, en el rango
purchases AS (
  SELECT DISTINCT
    id_digital,
    fec_visita,
    id_transaccion_post
  FROM `rs-shr-al-analyticsz-prj-ebc1.anl_digital.registro_solicitudes`
  WHERE tip_visita_imagenes_post = 'Purchase'
    AND des_lista_productos LIKE '%-Seguro Vehicular%'
    AND fec_visita BETWEEN fecha_inicio AND fecha_fin
     and (lower(des_campania_post) like 'app%' or lower(ind_tracking_campania_post) like 'app%')
),

-- 5) PURCHASE como subconjunto de LEADS (mismo usuario y mismo día)
purchases_leads AS (
  SELECT
    pu.fec_visita,
    pu.id_transaccion_post
  FROM purchases pu
  INNER JOIN leads l
    ON pu.id_digital = l.id_digital
   AND pu.fec_visita = l.fec_visita
),

-- 6) Calendario completo del rango
calendario AS (
  SELECT fecha
  FROM UNNEST(GENERATE_DATE_ARRAY(fecha_inicio, fecha_fin)) AS fecha
),

-- 7) Agregados por día
leads_agg AS (
  SELECT fec_visita AS fecha, COUNT(DISTINCT id_digital) AS leads
  FROM leads
  GROUP BY fec_visita
),
purchase_agg AS (
  SELECT fec_visita AS fecha, COUNT(DISTINCT id_transaccion_post) AS purchase
  FROM purchases_leads
  GROUP BY fec_visita
)

-- 8) Resultado final: fecha, leads, purchase (0 en días sin actividad)
SELECT
  cal.fecha,
  COALESCE(la.leads, 0)    AS leads,
  COALESCE(pa.purchase, 0) AS purchase
FROM calendario cal
LEFT JOIN leads_agg    la ON cal.fecha = la.fecha
LEFT JOIN purchase_agg pa ON cal.fecha = pa.fecha
ORDER BY cal.fecha;
