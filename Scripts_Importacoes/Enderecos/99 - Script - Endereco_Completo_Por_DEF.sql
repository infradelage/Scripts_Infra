-- PULMAO
SELECT e.id_def,e.nivel,e.endereco_completo,dlc.descricao
from endereco e
inner join def_lote_classificacao dlc on dlc.id_lote_classificacao = e.id_lote_classificacao
where 
e.id_def = 1 
and e.nivel = (select max(nivel) from def_endereco where id_def = 1)

-- FLOWRACK
SELECT e.id_def,e.nivel,e.endereco_completo,dlc.descricao
from endereco e
inner join def_lote_classificacao dlc on dlc.id_lote_classificacao = e.id_lote_classificacao
where 
e.id_def = 2 
and e.nivel = (select max(nivel) from def_endereco where id_def = 2)

-- DOCA
SELECT e.id_def,e.nivel,e.endereco_completo,dlc.descricao
from endereco e
inner join def_lote_classificacao dlc on dlc.id_lote_classificacao = e.id_lote_classificacao
where 
e.id_def = 4 
and e.nivel = (select max(nivel) from def_endereco where id_def = 4)

-- SEGREGADO
SELECT e.id_def,e.nivel,e.endereco_completo,dlc.descricao
from endereco e
inner join def_lote_classificacao dlc on dlc.id_lote_classificacao = e.id_lote_classificacao
where 
e.id_def = 5
and e.nivel = (select max(nivel) from def_endereco where id_def = 5)
