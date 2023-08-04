--TABELA								CHAVE
--def_lote_classificacao			id_lote_classificacao
--def_tipo_volume_endereco			id_tipo_volume_endereco,
--def_tipo_acesso_endereco			id_tipo_acesso_endereco
--def_tipo_armazenamento_endereco	id_tipo_armazenamento_endereco

SELECT * FROM endereco where id_def = 5

SELECT * FROM def_lote_classificacao
SELECT * FROM def_tipo_acesso_endereco
SELECT * FROM def_tipo_volume_endereco
SELECT * FROM def_tipo_armazenamento_endereco
SELECT * FROM def_endereco_setor

update endereco set id_tipo_armazenamento = 1 where id_def = 5
update endereco set id_tipo_volume = 23 where id_def = 5
update endereco set id_tipo_acesso_endereco = 8 where id_def = 5
--update endereco set id_lote_classificacao = 3 where id_def = 5

UPDATE e set
e.id_def_endereco_setor = def.id_def_endereco_setor
--SELECT * 
from endereco e
inner join mig_segregado_trabalho m1 on e.endereco_completo = m1.endereco_completo
inner join def_endereco_setor def on def.descricao = m1.setor2
where e.id_def = 5 