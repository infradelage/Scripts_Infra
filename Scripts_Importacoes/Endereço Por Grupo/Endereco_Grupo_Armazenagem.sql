Select * from endereco_grupo

def_tipo_endereco_grupo (id_tipo_endereco_grupo)
endereco (id_endereco)

mig_pulmao.linha = def_tipo_endereco_grupo.descri��o
def_endereco_setor
id_endereco_grupo	id_tipo_endereco_grupo	id_endereco

--INSERT
BEGIN TRAN INSERT_ENDERECO_GRUPO
insert endereco_grupo(id_tipo_endereco_grupo,id_endereco)
select dteg.id_tipo_endereco_grupo,e.id_endereco from mig_pulmao m1
INNER JOIN endereco e on e.endereco_completo = m1.endereco_completo
INNER JOIN def_tipo_endereco_grupo dteg on dteg.descricao = m1.setor
WHERE m1.setor = 'ROMANEIO'

--ROLLBACK TRAN INSERT_ENDERECO_GRUPO
--COMMIT TRAN INSERT_ENDERECO_GRUPO

--UPDATE mig_pulmao SET SETOR = 'ROMANEIO' WHERE SETOR = 'ROMANEIOS'


-- VALIDA��O
select m1.endereco_completo AS END_MIG,m1.setor as SETOR_MIG,e.id_endereco AS ID_END, dteg.id_tipo_endereco_grupo AS ID_DEF_GRUPO from mig_pulmao m1
left join endereco e on e.endereco_completo = m1.endereco_completo
left join def_tipo_endereco_grupo dteg on dteg.descricao = m1.setor
WHERE m1.setor = 'ROMANEIO'

delete from endereco_grupo

SELECT distinct setor, COUNT(setor) FROM mig_pulmao 
WHERE setor = 'ALIMENTOS'
group by setor

SELECT distinct id_tipo_endereco_grupo, COUNT(id_tipo_endereco_grupo) FROM endereco_grupo 
WHERE id_tipo_endereco_grupo = '1'
group by id_tipo_endereco_grupo