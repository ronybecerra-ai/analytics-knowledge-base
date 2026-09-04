---------- TRAFICO WEB PUBLICA (NO INCLUYE COTIZADORES)  ----------
    select
      periodo,
      count(distinct ind_visitante_high_post||ind_visitante_low_post||num_visita||ind_primera_visita_tiempo_gmt) visitas
 
    from `rs-shr-al-analyticsz-prj-ebc1.anl_digital.registro_global` --se usa global porque consulta soat esta en solicitudes
    where (des_pagina_visitada like 'web:%')  -- se filtra lo que incluye web
    or (des_pagina_visitada like 'sol:consulta-soat%') -- se considera consulta soat
    and periodo between '2021-01-01' and '2025-11-01' -- cambiar periodo
    and des_flujo_usuario = 'External' -- filtro external de adobe
    group by all
