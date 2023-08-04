/*---------------------------------------------------------------
-												 -
-- Criação da árvore de endereço - PULMÃO - COM 3 NIVEIS FINAIS	-
-																-
--					X.XX.XX										-
--                  B.44.09										-
-- B	- Rua														-
-- 44	- Predio													-
-- 03	- Nivel													-
--																-
---------------------------------------------------------------*/


-- REDEFINE NIVEIS DE ENDEREÇAMENTO
ALTER TABLE endereco NOCHECK CONSTRAINT ALL

DELETE def_endereco where id_def = 1 and nivel > 1

INSERT def_endereco(id_def, nivel, descricao, id_tipo, divide_volume, validacao, msgerro, separador, compoe_endereco, endereco_movel)
-- PULMÃO
--SELECT 1, 1, 'CLASSIF.', 2, 0, NULL, NULL, NULL, 0, 0 UNION
SELECT 1, 2, 'LINHA', 2, 0, NULL, NULL, NULL, 0, 0 UNION
SELECT 1, 3, 'RUA', 2, 0, NULL, NULL, '-', 1, 0 UNION
SELECT 1, 4, 'LADO', 2, 0, NULL, NULL, null, 0, 0 UNION
SELECT 1, 5, 'PREDIO',   2, 0, NULL, NULL, '-', 1, 0 UNION
SELECT 1, 6, 'NIVEL', 2, 0, NULL, NULL, '-', 1, 0  UNION
SELECT 1, 7, 'POSICAO', 2, 0, NULL, NULL, NULL, 1, 0 

ALTER TABLE endereco CHECK CONSTRAINT ALL
GO


SELECT * FROM def_endereco where id_def = 1 and nivel > 1

--TABELA PARA TRABALHAR E NO FIM DELETAR
drop table mig_pulmao_trabalho
select * INTO mig_pulmao_trabalho  from mig_pulmao

/*CURINGA! Se alguma columa estiver como float basta alterar ela para varchar! 
Exemplo abaixo:
alter table mig_pulmao_trabalho alter column estacao varchar(30)
*/

--AJUSTES CASO PRECISEM--
--VOLUME--
select distinct tipo_volume from mig_pulmao_trabalho
update mig_pulmao_trabalho set tipo_volume = 'PALLET PADRAO'

--ACESSO--
select * from def_tipo_acesso_endereco where id_tipo_endereco = 2
update def_tipo_acesso_endereco set descricao = 'A PÉ (PULMAO)' where descricao like '%A PÉ%' and id_tipo_endereco = 2 --PULMAO
update def_tipo_acesso_endereco set descricao = 'ESCADA (PULMAO)' where descricao like '%ESCADA%' and id_tipo_endereco = 2 --PULMAO
update def_tipo_acesso_endereco set descricao = 'EMPILHADEIRA (PULMAO)' where descricao like '%EMPILHADEIRA%' and id_tipo_endereco = 2 --PULMAO
update def_tipo_acesso_endereco set descricao = 'TRANSPALETEIRA (PULMAO)' where descricao like '%TRANSPALETEIRA%' and id_tipo_endereco = 2 --PULMAO

select distinct tipo_de_acesso from mig_pulmao_trabalho
update mig_pulmao_trabalho set tipo_de_acesso = 'A PÉ (PULMAO)' where tipo_de_acesso like '%A PÉ%'
update mig_pulmao_trabalho set tipo_de_acesso = 'ESCADA (PULMAO)' where tipo_de_acesso like '%ESCADA%'
update mig_pulmao_trabalho set tipo_de_acesso = 'EMPILHADEIRA (PULMAO)' where tipo_de_acesso like '%EMPILHADEIRA%'

--TIPO DE ARMAZENAMENTO--
select distinct tipo_de_armazenamento from mig_pulmao_trabalho
update mig_pulmao_trabalho set tipo_de_armazenamento = 'PULMAO' where tipo_de_armazenamento like 'PULMÃO'
update mig_pulmao_trabalho set tipo_de_armazenamento = 'PULMAO DRIVE-IN' where tipo_de_armazenamento like 'PULMÃO DRIVE-IN'


select distinct SETOR from mig_pulmao_trabalho


select distinct classificacao from mig_pulmao_trabalho
update mig_pulmao_trabalho set classificacao = 'PULMAO' 

--FIM AJUSTES


--ATENCAO NAO PODE RETORNAR NENHUMA LINHA AQUI. SE RETORNAR DEVOLVER A PLANILHA
select * from mig_pulmao_trabalho where endereco_completo is null


--INSERÇÕES EM DEFs CASO PRECISE--
--SETOR
insert def_endereco_setor
select distinct setor,2 from mig_pulmao_trabalho
where  setor not in (select descricao from def_endereco_setor where descricao = setor and id_tipo = 2)

--ACESSO
insert def_tipo_acesso_endereco (descricao, id_tipo_endereco)
select distinct tipo_de_acesso,2 from mig_pulmao_trabalho
where  tipo_de_acesso not in 
(select tipo_de_acesso from def_tipo_acesso_endereco where descricao = tipo_de_acesso)

--ARMAZENAMENTO
insert def_tipo_armazenamento_endereco (descricao, automatizado,permite_n_lotes_mesmo_produto)
select distinct tipo_de_armazenamento,0,1 from mig_pulmao_trabalho
where  tipo_de_armazenamento not in 
(select tipo_de_armazenamento from def_tipo_armazenamento_endereco where descricao = tipo_de_armazenamento)
--FIM INSERÇÕES


ALTER TABLE log_produto_endereco NOCHECK CONSTRAINT ALL

--DELETE ENDERECO DE PULMAO PARA COME�AR DO PRIMEIRO NIVEL E ACERTAR O IDENTITY
DELETE endereco
WHERE nivel > 1 --and id_def = 1
DECLARE @max_endereco int
set @max_endereco = (select max(id_endereco) from endereco)
DBCC CHECKIDENT (endereco, RESEED, @max_endereco)

ALTER TABLE log_produto_endereco CHECK CONSTRAINT ALL
--DELETE log_produto_endereco DBCC CHECKIDENT(log_produto_endereco, RESEED, 1)
--GO
--delete endereco_restricao
---AQUI INICIA A IMPORTACAO DOS ENDERECOS DE FATO--
--NIVEL 2 - XX
insert endereco(id_def, nivel, endereco, id_pai, qtd_caixa, endereco_completo, id_lote_classificacao, cod_situacao_endereco)
select distinct 1, 2,  m1.LINHA, m2.id_endereco, null, m1.LINHA, dlc.id_lote_classificacao,1
from mig_pulmao_trabalho m1, endereco m2, def_lote_classificacao dlc
where  m2.endereco = m1.classificacao
and m1.classificacao_endereco = dlc.descricao
AND NOT EXISTS (SELECT 1 FROM ENDERECO E WHERE E.endereco_completo = m1.LINHA 
						AND ID_DEF = 1 AND NIVEL = 2)
and m2.id_def = 1
and m2.nivel = 1

--NIVEL 3 - XX-XX
insert endereco(id_def, nivel, endereco, id_pai, qtd_caixa, endereco_completo, id_lote_classificacao, cod_situacao_endereco)
select distinct  1, 3, m1.RUA, m2.id_endereco, null, m1.LINHA+m1.RUA ,dlc.id_lote_classificacao,1
from mig_pulmao_trabalho m1, endereco m2, def_lote_classificacao dlc
where m2.endereco_completo = m1.LINHA
and m1.Classificacao_endereco = dlc.descricao
AND NOT EXISTS (SELECT 1 FROM ENDERECO E WHERE E.endereco_completo = m1.RUA 
						AND ID_DEF = 1 AND NIVEL = 3)
and m2.id_def = 1
and m2.nivel = 2


--NIVEL 4 - XX-XX-XX
insert endereco(id_def, nivel, endereco, id_pai, qtd_caixa, endereco_completo, id_lote_classificacao, cod_situacao_endereco)
select distinct  1, 4, m1.LADO, m2.id_endereco, null, m1.LINHA+m1.RUA + '-' + m1.LADO, dlc.id_lote_classificacao,1
from mig_pulmao_trabalho m1, endereco m2, def_lote_classificacao dlc
where m2.endereco_completo = m1.LINHA+m1.RUA
and m1.Classificacao_endereco = dlc.descricao
AND NOT EXISTS (SELECT 1 FROM ENDERECO E 
						WHERE E.endereco_completo = m1.LINHA+m1.RUA + '-' + m1.LADO 
						AND ID_DEF = 1 AND NIVEL = 4)
and m2.id_def = 1
and m2.nivel = 3
ORDER BY 6

--NIVEL 5 - XX-XX-XX-XX
insert endereco(id_def, nivel, endereco, id_pai, qtd_caixa, endereco_completo, id_lote_classificacao, cod_situacao_endereco,
id_tipo_acesso_endereco, id_tipo_Armazenamento, id_tipo_volume)
select distinct  1, 5, m1.PREDIO, m2.id_endereco, null, m1.LINHA+m1.RUA + '-' + m1.LADO + '-' + m1.PREDIO, 
dlc.id_lote_classificacao,1,NULL,NULL,NULL
--dtac.id_tipo_acesso_endereco, dtae.id_tipo_armazenamento_endereco,dtve.id_tipo_volume_endereco
from mig_pulmao_trabalho m1, endereco m2, def_lote_classificacao dlc, def_tipo_acesso_endereco dtac, 
def_tipo_volume_endereco dtve, def_tipo_armazenamento_endereco dtae
where m2.endereco_completo = m1.LINHA+m1.RUA + '-' + m1.LADO
and m1.Classificacao_endereco = dlc.descricao
AND NOT EXISTS (SELECT 1 FROM ENDERECO E 
						WHERE E.endereco_completo = m1.RUA + '-' + m1.LADO + '-'  + m1.PREDIO
						AND ID_DEF = 1 AND NIVEL = 4)
and m2.id_def = 1
and m2.nivel = 4
 and dtac.id_tipo_endereco = 2 -- PULMAO



--NIVEL 6 - XX-XX-XX-XX
insert endereco(id_def, nivel, endereco, id_pai, qtd_caixa, endereco_completo, id_lote_classificacao, cod_situacao_endereco,
id_tipo_acesso_endereco, id_tipo_Armazenamento, id_tipo_volume)
select distinct  1, 6, m1.NIVEL, m2.id_endereco, null, m1.LINHA+m1.RUA + '-' + m1.LADO + '-'  + m1.PREDIO+ '-'  + m1.NIVEL, 
dlc.id_lote_classificacao,1,null,null,null
--dtac.id_tipo_acesso_endereco, dtae.id_tipo_armazenamento_endereco,dtve.id_tipo_volume_endereco
from mig_pulmao_trabalho m1, endereco m2, def_lote_classificacao dlc, def_tipo_acesso_endereco dtac, 
def_tipo_volume_endereco dtve, def_tipo_armazenamento_endereco dtae
where m2.endereco_completo = m1.LINHA+m1.RUA + '-' + m1.LADO + '-'  + m1.PREDIO
and m1.Classificacao_endereco = dlc.descricao
AND NOT EXISTS (SELECT 1 FROM ENDERECO E 
						WHERE E.endereco_completo = m1.LINHA+m1.RUA + '-' + m1.LADO + '-'  + m1.PREDIO+ '-'  + m1.NIVEL
						AND ID_DEF = 1 AND NIVEL = 4)
and m2.id_def = 1
and m2.nivel = 5
--and DTAC.descricao = M1.tipo_de_acesso 
and dtac.id_tipo_endereco = 2 -- PULMAO
--and dtve.descricao =  m1.tipo_volume
--and dtae.descricao = m1.tipo_de_armazenamento

ORDER BY 6


--NIVEL 7 - XX-XX-XX-XX
insert endereco(id_def, nivel, endereco, id_pai, qtd_caixa, endereco_completo, id_lote_classificacao, cod_situacao_endereco,
id_tipo_acesso_endereco, id_tipo_Armazenamento, id_tipo_volume)
select distinct  1, 7, m1.POSICAO, m2.id_endereco, null, m1.LINHA+m1.RUA + '-' + m1.LADO + '-'  + m1.PREDIO+ '-'  + m1.NIVEL+ '-'  + m1.POSICAO, 
dlc.id_lote_classificacao,1,dtac.id_tipo_acesso_endereco, dtae.id_tipo_armazenamento_endereco,dtve.id_tipo_volume_endereco
from mig_pulmao_trabalho m1, endereco m2, def_lote_classificacao dlc, def_tipo_acesso_endereco dtac, 
def_tipo_volume_endereco dtve, def_tipo_armazenamento_endereco dtae
where m2.endereco_completo = m1.LINHA+m1.RUA + '-' + m1.LADO + '-'  + m1.PREDIO+ '-'  + m1.NIVEL
and m1.Classificacao_endereco = dlc.descricao
AND NOT EXISTS (SELECT 1 FROM ENDERECO E 
						WHERE E.endereco_completo = m1.LINHA+m1.RUA + '-' + m1.LADO + '-'  + m1.PREDIO+ '-'  + m1.NIVEL+ '-'  + m1.POSICAO
						AND ID_DEF = 1 AND NIVEL = 4)
and m2.id_def = 1
and m2.nivel = 6
and DTAC.descricao = M1.tipo_de_acesso 
and dtac.id_tipo_endereco = 2 -- PULMAO
and dtve.descricao =  m1.tipo_volume
and dtae.descricao = m1.tipo_de_armazenamento

ORDER BY 6

--VALIDA DUPLICIDADES
select endereco_completo, count(1)
from mig_pulmao_trabalho
group by endereco_completo
having count(1) > 1


--UPDATES ADICIONAIS DEPOIS DE IMPORTADO OS ENDERECOS--		   
UPDATE endereco
   SET  endereco_completo_3D = dbo.getEnderecoCompleto3D(id_endereco),
	   id_endereco_completo = dbo.getEnderecoCompletoID(id_endereco),
	   id_endereco_div = dbo.GetEnderecoDivID(id_endereco),
	   endereco_completo = dbo.getEnderecoCompleto(id_endereco)
WHERE id_def = 1

UPDATE E
   SET E.endereco_completo_pai = PAI.endereco_completo
  FROM endereco E INNER JOIN
       endereco PAI ON PAI.id_endereco = E.id_pai
WHERE e.id_def = 1

UPDATE endereco
   SET  GetEnderecoPaiNivel = dbo.GetEnderecoPaiNivel(id_endereco,nivel)   
WHERE id_def = 1

UPDATE e set
e.id_def_endereco_setor = def.id_def_endereco_setor
from endereco e
inner join mig_pulmao_trabalho m1 on e.endereco_completo = m1.endereco_completo
inner join def_endereco_setor def on def.descricao = m1.setor
where e.id_def = 1 and def.id_tipo = 2

--FIM UPDATES ADICIONAIS


/*
Validacoes

 SELECT count(1) as enderecos_a_migrar from mig_pulmao_trabalho
 SELECT count(1) as enderecos_migrados from endereco where id_def = 1 and nivel = (select max(nivel) from def_endereco where id_def = 1)

 SELECT * FROM endereco WHERE id_def = 1 AND nivel =5
 and id_tipo_Armazenamento is  null
 
 SELECT * FROM endereco WHERE id_def = 1 AND nivel =5
 and id_tipo_acesso_endereco is  null
  
 SELECT * FROM endereco WHERE id_def =1 AND nivel =5
 and id_def_endereco_setor is  null
   
 SELECT * FROM endereco WHERE id_def = 1 AND nivel =5
 and id_tipo_volume is  null
  
*/
 

