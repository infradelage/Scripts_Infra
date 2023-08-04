/*-------------------------------------------------------------------
-												 -
-- Cria��o da �rvore de endere�o - STAGING - COM 2 NIVEIS FINAIS	-
-																	-
--					XX.XXX											-	
--                  11.011											-
-- 11	- palete													-
-- 011	- NIVEL	E POSICAO											-
--																	-
-------------------------------------------------------------------*/

-- REDEFINE NIVEIS DE ENDERE�AMENTO
ALTER TABLE endereco NOCHECK CONSTRAINT ALL

DELETE def_endereco where id_def = 4 and nivel > 1

INSERT def_endereco(id_def, nivel, descricao, id_tipo, divide_volume, validacao, msgerro, separador, compoe_endereco, endereco_movel)
-- PULM�O
--SELECT 1, 1, 'CLASSIF.', 2, 0, NULL, NULL, NULL, 0, 0 UNION
SELECT 4, 2, 'DOCA', 1, 0, NULL, NULL, '.', 1, 0 UNION
SELECT 4, 3, 'POSICAO', 1, 0, NULL, NULL, '.', 1, 0
ALTER TABLE endereco CHECK CONSTRAINT ALL
GO
select * from def_endereco where id_def = 4
update def_endereco set id_tipo = 5 where id_def = 4


--TABELA PARA TRABALHAR E NO FIM DELETAR
select * INTO mig_doca_trabalho  from migra_doca_15042019

alter table mig_doca_trabalho add nivel varchar(10)
update mig_doca_trabalho set nivel = SUBSTRING(doca,3,1)
update mig_doca_trabalho set 

/*CURINGA! Se alguma columa estiver como float basta alterar ela para varchar! 
Exemplo abaixo:
alter table mig_doca_trabalho alter column palete varchar(30)
*/


--AJUSTES CASO PRECISEM--
--ACESSO--
--select * from def_tipo_acesso_endereco where id_tipo_endereco = 2
update def_tipo_acesso_endereco set descricao = 'A P� (STAGING)' where descricao like '%A P�%' and id_tipo_endereco = 5 --STAGING

--select * from mig_doca_trabalho
update mig_doca_trabalho set tipo_de_acesso = 'A P� (STAGING)' where tipo_de_acesso like '%A P�%'
--FIM AJUSTES


--ATENCAO AQUI--NAO PODE RETORNAR NENHUMA LINHA AQUI. SE RETORNAR DEVOLVER A PLANILHA
select * from mig_doca_trabalho where endereco_completo is null


--INSER��ES EM DEFs CASO PRECISE--
--SETOR
insert def_endereco_setor
select distinct setor,5 from mig_doca_trabalho
where setor not in (select descricao from def_endereco_setor where descricao = setor and id_tipo = 5)
def_tipo_endereco
--ACESSO
insert def_tipo_acesso_endereco (descricao, id_tipo_endereco)
select distinct tipo_de_acesso, 5 from mig_doca_trabalho
where  tipo_de_acesso not in 
(select tipo_de_acesso from def_tipo_acesso_endereco where descricao = tipo_de_acesso)

update def_tipo_acesso_endereco set descricao = 'A P� - STAGING' where id_tipo_acesso_endereco = 32

--VOLUME 
-->SOLICITAR REVISAO POSTERIOR NAS QUANTIDADE DE CAIXAS E DIMENSSOES VIA SISTEMA<--
insert def_tipo_volume_endereco
select distinct tipo_volume, 1, 1,1,1,0,null,0,0,0 from mig_doca_trabalho
where  tipo_volume not in 
(select tipo_volume from def_tipo_volume_endereco where descricao = tipo_volume)
--FIM INSER��ES


delete inventario_endereco
update mig_doca_trabalho set 

--DELETE ENDERECO DE FLOW PARA COME�AR DO PRIMEIRO NIVEL E ACERTAR O IDENTITY
DELETE endereco
WHERE nivel > 1 and id_def = 4
DECLARE @max_endereco int
set @max_endereco = (select max(id_endereco) from endereco)
DBCC CHECKIDENT (endereco, RESEED, @max_endereco)

inventario_endereco

---AQUI INICIA A IMPORTACAO DOS ENDERECOS DE FATO--
--NIVEL 2 - XXX
insert endereco(id_def, nivel, endereco, id_pai, qtd_caixa, endereco_completo, id_lote_classificacao, cod_situacao_endereco)
select distinct 4, 2, m1.doca, m2.id_endereco, null, m1.doca, dlc.id_lote_classificacao,1
from mig_doca_trabalho m1, endereco m2, def_lote_classificacao dlc
where  m2.endereco_completo = m1.classificacao
and m1.classificacao_endereco = dlc.descricao
AND NOT EXISTS (SELECT 1 FROM ENDERECO E WHERE E.endereco_completo = m1.doca AND id_def = 4 AND NIVEL = 2)
and m2.id_def = 4
and m2.nivel = 1

--NIVEL 3 - XXX.XXX
insert endereco(id_def, nivel, endereco, id_pai, qtd_caixa, endereco_completo, id_lote_classificacao, cod_situacao_endereco,
id_tipo_acesso_endereco, id_tipo_Armazenamento, id_tipo_volume)
select distinct  4, 3, m1.palete, m2.id_endereco, null, m1.doca + separador1 + m1.palete ,dlc.id_lote_classificacao,1,
dtac.id_tipo_acesso_endereco, dtae.id_tipo_armazenamento_endereco,dtve.id_tipo_volume_endereco
from mig_doca_trabalho m1, endereco m2, def_lote_classificacao dlc, def_tipo_acesso_endereco dtac, def_tipo_volume_endereco dtve, 
def_tipo_armazenamento_endereco dtae
where m2.endereco_completo = m1.doca
and m1.classificacao_endereco = dlc.descricao
and dtac.id_tipo_endereco = 5 -- STAGING
and dtve.descricao =  m1.tipo_volume
and dtae.descricao = m1.tipo_de_armazenamento
AND NOT EXISTS (SELECT 1 FROM ENDERECO E WHERE E.endereco_completo = m1.doca + separador1 + m1.palete AND id_def = 4 AND NIVEL = 3)
and m2.id_def = 4
and m2.nivel = 2

--FIM IMPORTACAO DOS ENDERECOS 
				   

--UPDATES ADICIONAIS DEPOIS DE IMPORTADO OS ENDERECOS--		   
UPDATE endereco
   SET  endereco_completo_3D = dbo.getEnderecoCompleto3D(id_endereco),
	   id_endereco_completo = dbo.getEnderecoCompletoID(id_endereco)

UPDATE E
   SET E.endereco_completo_pai = PAI.endereco_completo
  FROM endereco E INNER JOIN
       endereco PAI ON PAI.id_endereco = E.id_pai

UPDATE endereco
   SET  GetEnderecoPaiNivel = dbo.GetEnderecoPaiNivel(id_endereco,nivel)   

UPDATE e set
e.id_def_endereco_setor = def.id_def_endereco_setor
from endereco e
inner join mig_doca_trabalho m1 on e.endereco_completo = m1.endereco_completo
inner join def_endereco_setor def on def.descricao = m1.setor
where e.id_def = 4 and def.id_tipo = 5--STAGING

--FIM UPDATES ADICIONAIS


/*
Validacoes

 SELECT count(1) as enderecos_a_migrar from mig_doca_trabalho
 SELECT count(1) as enderecos_migrados from endereco where id_def = 4 and nivel = (select max(nivel) from def_endereco where id_def = 4)

 SELECT * FROM endereco WHERE id_def = 4 AND nivel =5
 and id_tipo_Armazenamento is  null
 
 SELECT * FROM endereco WHERE id_def = 4 AND nivel =5
 and id_tipo_acesso_endereco is  null
  
 SELECT * FROM endereco WHERE id_def =1 AND nivel =5
 and id_def_endereco_setor is  null
   
 SELECT * FROM endereco WHERE id_def = 4 AND nivel =5
 and id_tipo_volume is  null
  
*/