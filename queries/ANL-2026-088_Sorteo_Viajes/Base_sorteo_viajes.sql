with prod_viajes as ( 
  select des_producto,pol_id_contratante,des_producto, num_poliza from
  `rs-shr-al-analyticsz-prj-ebc1.anl_produccion.produccion_resumen` 
where periodo='2026-08-01' -- cambiar periodo
and id_producto='AX-4142' -- producto viajes
) 
, app as ( select  date_trunc(fec_visita, month) as month, fec_visita, num_documento,
  concat('Comprar -',des_producto_post) des_transaccion,
  id_persona
from `rs-shr-al-analyticsz-prj-ebc1.anl_digital.registro_solicitudes` ,
unnest (des_eventos_activados) as e
where fec_visita between '2026-08-01' and '2026-08-31' -- cambiar periodo
 
and  (lower(des_campania_post) like 'app%' or lower(ind_tracking_campania_post) like 'app%')
and tip_visita_imagenes_post = 'Purchase'
and lower(des_producto_post) ='seguro viajes'
group by all
order by 1 asc)
 
select a.*, b.num_poliza from app a join prod_viajes b on a.id_persona=b.pol_id_contratante
QUALIFY ROW_NUMBER() OVER (PARTITION BY num_poliza ORDER BY id_persona) = 1 
