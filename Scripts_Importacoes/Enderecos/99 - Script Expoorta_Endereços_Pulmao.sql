select 'PULMAO' as classificacao, e.endereco_completo, dtve.descricao as tipo_volume, dtae.descricao as acesso_endereco,
dtaen.descricao as armazenamento_endereco 
from endereco e (nolock) 
inner join def_tipo_volume_endereco dtve (nolock) on e.id_tipo_volume = dtve.id_tipo_volume_endereco 
inner join def_tipo_acesso_endereco dtae (nolock) on e.id_tipo_acesso_endereco = dtae.id_tipo_acesso_endereco 
inner join def_tipo_armazenamento_endereco dtaen (nolock) on e.id_tipo_Armazenamento = dtaen.id_tipo_armazenamento_endereco 
where e.id_def = 1 
and e.nivel = (select max (nivel) from def_endereco where id_def = 1)

select 'FLOWRACK' as classificacao, e.endereco_completo, dtve.descricao as tipo_volume, dtae.descricao as acesso_endereco,
dtaen.descricao as armazenamento_endereco 
from endereco e (nolock) 
inner join def_tipo_volume_endereco dtve (nolock) on e.id_tipo_volume = dtve.id_tipo_volume_endereco 
inner join def_tipo_acesso_endereco dtae (nolock) on e.id_tipo_acesso_endereco = dtae.id_tipo_acesso_endereco 
inner join def_tipo_armazenamento_endereco dtaen (nolock) on e.id_tipo_Armazenamento = dtaen.id_tipo_armazenamento_endereco 
where e.id_def = 2 
and e.nivel = (select max (nivel) from def_endereco where id_def = 2)


select 'DOCA' as classificacao, e.endereco_completo, dtve.descricao as tipo_volume, dtae.descricao as acesso_endereco,
dtaen.descricao as armazenamento_endereco 
from endereco e (nolock) 
inner join def_tipo_volume_endereco dtve (nolock) on e.id_tipo_volume = dtve.id_tipo_volume_endereco 
inner join def_tipo_acesso_endereco dtae (nolock) on e.id_tipo_acesso_endereco = dtae.id_tipo_acesso_endereco 
inner join def_tipo_armazenamento_endereco dtaen (nolock) on e.id_tipo_Armazenamento = dtaen.id_tipo_armazenamento_endereco 
where e.id_def = 4 
and e.nivel = (select max (nivel) from def_endereco where id_def = 4)

select 'SEGREGADO' as classificacao, e.endereco_completo, dtve.descricao as tipo_volume, dtae.descricao as acesso_endereco,
dtaen.descricao as armazenamento_endereco 
from endereco e (nolock) 
inner join def_tipo_volume_endereco dtve (nolock) on e.id_tipo_volume = dtve.id_tipo_volume_endereco 
inner join def_tipo_acesso_endereco dtae (nolock) on e.id_tipo_acesso_endereco = dtae.id_tipo_acesso_endereco 
inner join def_tipo_armazenamento_endereco dtaen (nolock) on e.id_tipo_Armazenamento = dtaen.id_tipo_armazenamento_endereco 
where e.id_def = 5
and e.nivel = (select max (nivel) from def_endereco where id_def = 5)