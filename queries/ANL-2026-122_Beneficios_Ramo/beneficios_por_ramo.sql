WITH ramo as 
  
(  SELECT 
distinct
        periodo,

  ------ creacion del campo ramo --------------------
        case when ( des_agrupacion_n1='VIDA' and des_agrupacion_n2="VIDA INDIVIDUAL" 
and pol_des_subcanal not in ('WORKSITE','CONVENIOS') and pol_des_canal not in ('CANAL NO TRADICIONAL')
  --
and des_producto not in ('PROTECCION FAMILIAR','SEPELIO INDIVIDUAL (WS)','PROTECCION AHORRO', 'ACCIDENTES - PROTECCION ACCIDENTAL',
' VIDA AHORRO IDEAL', 'SEPELIO PLUS - TLMKT')

) then 'VIDA INDIVIDUAL' 
  when des_agrupacion_n1='VIDA' and pol_des_canal in ('CANAL NO TRADICIONAL') then 'VIDA BANCASEGUROS'
  WHEN des_agrupacion_n1='VIDA' and (pol_des_subcanal in ('WORKSITE','CONVENIOS') or  (des_producto  in ('PROTECCION FAMILIAR','SEPELIO INDIVIDUAL (WS)','PROTECCION AHORRO', 'SEPELIO PLUS - TLMKT'))) then 'VIDA WORKSITE'
    when des_agrupacion_n1='VIDA' then 'VIDA INDIVIDUAL' 
  
  else des_agrupacion_n1 end as des_agrupacion_n1,

-----------------------------------------------
        id_cliente_persona,
        'D' AS tipo
    FROM `rs-shr-al-analyticsz-prj-ebc1.anl_persona.cliente_persona_detalle`
    WHERE periodo >= '2026-01-01'
      AND pol_ind_gestionable = 'SI'
      AND des_agrupacion_n2 NOT IN ('DESGRAVAMEN')
      
      )


select  
a.periodo,
case when lower(des_nombre_evento) LIKE '%beneficio%' then 'Zona de Beneficios'  end trx,
des_agrupacion_n1 ramo,
count(distinct num_documento) clientes_unicos,

from  `rs-shr-al-analyticsz-prj-ebc1.anl_digital.registro_usuario_zp_appnativa` a
join ramo c on a.id_persona=c.id_cliente_persona and a.periodo=c.periodo
where  lower(des_nombre_evento) LIKE '%beneficio%' -- clicks a entry points de beneficios en app
and a.periodo >= '2026-01-01' -- cambiar fecha
group by all
