/*-------------------------------------------------------------------
-												 -
-- Criação da árvore de endereço - STAGING - COM 3 NIVEIS FINAIS	-
-																	-
--					XX.XXX.X											-	
--             11.011.1											-
-- 11	 - DOCA													-
-- 011 - PALETE
-- 1	 - NIVEL																	-
-------------------------------------------------------------------*/

-- REDEFINE NIVEIS DE ENDEREÇAMENTO
ALTER TABLE endereco NOCHECK CONSTRAINT ALL

DELETE def_endereco where id_def = 4 and nivel > 1

INSERT def_endereco(id_def, nivel, descricao, id_tipo, divide_volume, validacao, msgerro, separador, compoe_endereco, endereco_movel)
-- PULM�O
--SELECT 1, 1, 'CLASSIF.', 2, 0, NULL, NULL, NULL, 0, 0 UNION
SELECT 4, 2, 'DOCA', 5, 0, NULL, NULL, '.', 1, 0 UNION
SELECT 4, 3, 'PALETE', 5, 0, NULL, NULL, '.', 1, 0 UNION
SELECT 4, 4, 'NIVEL', 5, 0, NULL, NULL, NULL, 1, 0

ALTER TABLE endereco CHECK CONSTRAINT ALL
GO

drop table mig_doca_trabalho
--TABELA PARA TRABALHAR E NO FIM DELETAR
select * INTO mig_doca_trabalho  from mig_doca

/*CURINGA! Se alguma columa estiver como float basta alterar ela para varchar! 
Exemplo abaixo:
alter table mig_doca_trabalho alter column palete varchar(30)
*/


--AJUSTES CASO PRECISEM--
--ACESSO--
Select * from def_tipo_acesso_endereco where id_tipo_endereco = 5
update def_tipo_acesso_endereco set descricao = 'A PÉ (STAGING)' where descricao like '%A PÉ%' and id_tipo_endereco = 5 --STAGING

select * from mig_doca_trabalho
update mig_doca_trabalho set tipo_de_acesso = 'A PÉ (STAGING)' where tipo_de_acesso like '%A PÉ%'

select distinct classificacao_endereco from mig_doca_trabalho
update mig_doca_trabalho set classificacao_endereco = 'SEGREGADO TRANSITORIO' where classificacao_endereco LIKE '%SEGREGADO%'

--FIM AJUSTES


--ATENCAO AQUI--NAO PODE RETORNAR NENHUMA LINHA AQUI. SE RETORNAR DEVOLVER A PLANILHA
select * from mig_doca_trabalho where endereco_completo is null


--INSERÇÕES EM DEFs CASO PRECISE--
--SETOR
insert def_endereco_setor
select distinct setor,2 from mig_doca_trabalho
where setor not in (select descricao from def_endereco_setor where descricao = setor and id_tipo = 5)

--ACESSO
insert def_tipo_acesso_endereco (descricao, id_tipo_endereco)
select distinct tipo_de_acesso, 5 from mig_doca_trabalho
where  tipo_de_acesso not in 
(select tipo_de_acesso from def_tipo_acesso_endereco where descricao = tipo_de_acesso)

--VOLUME 
-->SOLICITAR REVISAO POSTERIOR NAS QUANTIDADE DE CAIXAS E DIMENSSOES VIA SISTEMA<--
insert def_tipo_volume_endereco
select distinct tipo_volume, 1, 1,1,1,0,null,0,0,0 from mig_doca_trabalho
where  tipo_volume not in 
(select tipo_volume from def_tipo_volume_endereco where descricao = tipo_volume)
--FIM INSERÇÕES

--AJUTE NA ENDERECO
UPDATE ENDERECO SET endereco_completo = endereco WHERE id_endereco = 1 AND NIVEL = 1
UPDATE ENDERECO SET endereco_completo = endereco WHERE id_endereco = 2 AND NIVEL = 1
UPDATE ENDERECO SET endereco_completo = endereco WHERE id_endereco = 3 AND NIVEL = 1
UPDATE ENDERECO SET endereco_completo = endereco WHERE id_endereco = 4 AND NIVEL = 1
UPDATE ENDERECO SET endereco_completo = endereco WHERE id_endereco = 5 AND NIVEL = 1

--DELETE ENDERECO DE FLOW PARA COME�AR DO PRIMEIRO NIVEL E ACERTAR O IDENTITY
DELETE endereco
WHERE nivel > 1 and id_def = 4
DECLARE @max_endereco int
set @max_endereco = (select max(id_endereco) from endereco)
DBCC CHECKIDENT (endereco, RESEED, @max_endereco)

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
select distinct  4, 3, m1.palete, m2.id_endereco, null, m1.doca + m1.separador1 + m1.palete ,dlc.id_lote_classificacao,1,
dtac.id_tipo_acesso_endereco, dtae.id_tipo_armazenamento_endereco,dtve.id_tipo_volume_endereco
from mig_doca_trabalho m1, endereco m2, def_lote_classificacao dlc, def_tipo_acesso_endereco dtac, def_tipo_volume_endereco dtve, 
def_tipo_armazenamento_endereco dtae
where m2.endereco_completo = m1.doca
and m1.classificacao_endereco = dlc.descricao
and dtac.id_tipo_endereco = 5 -- STAGING
and dtve.descricao =  m1.tipo_volume
and dtae.descricao = m1.tipo_de_armazenamento
AND NOT EXISTS (SELECT 1 FROM ENDERECO E WHERE E.endereco_completo = m1.doca + m1.separador1 + m1.palete AND id_def = 4 AND NIVEL = 3)
and m2.id_def = 4
and m2.nivel = 2

--NIVEL 4 - XXX.XXX
insert endereco(id_def, nivel, endereco, id_pai, qtd_caixa, endereco_completo, id_lote_classificacao, cod_situacao_endereco,
id_tipo_acesso_endereco, id_tipo_Armazenamento, id_tipo_volume)
select distinct  4, 4, m1.nivel, m2.id_endereco, null, m1.doca + m1.separador1 + m1.palete + separador2 + m1.nivel ,dlc.id_lote_classificacao,1,
dtac.id_tipo_acesso_endereco, dtae.id_tipo_armazenamento_endereco,dtve.id_tipo_volume_endereco
from mig_doca_trabalho m1, endereco m2, def_lote_classificacao dlc, def_tipo_acesso_endereco dtac, def_tipo_volume_endereco dtve, 
def_tipo_armazenamento_endereco dtae
where m2.endereco_completo = m1.doca + m1.separador1 + m1.palete 
and m1.classificacao_endereco = dlc.descricao
and dtac.id_tipo_endereco = 5 -- STAGING
and dtve.descricao =  m1.tipo_volume
and dtae.descricao = m1.tipo_de_armazenamento
AND NOT EXISTS (SELECT 1 FROM ENDERECO E WHERE E.endereco_completo = m1.doca + m1.separador1 + m1.palete + separador2 + m1.nivel AND id_def = 4 AND NIVEL = 4)
and m2.id_def = 4
and m2.nivel = 3


--FIM IMPORTACAO DOS ENDERECOS 
				   

--UPDATES ADICIONAIS DEPOIS DE IMPORTADO OS ENDERECOS--		   
UPDATE endereco
   SET  endereco_completo_3D = dbo.getEnderecoCompleto3D(id_endereco),
	   id_endereco_completo = dbo.getEnderecoCompletoID(id_endereco),
	   id_endereco_div = dbo.GetEnderecoDivID(id_endereco),
	   endereco_completo = dbo.getEnderecoCompleto(id_endereco)

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

 SELECT * FROM endereco WHERE id_def = 4 AND nivel = (select max(nivel) from def_endereco where id_def = 4)
 and id_tipo_Armazenamento is  null
 
 SELECT * FROM endereco WHERE id_def = 4 AND nivel = (select max(nivel) from def_endereco where id_def = 4)
 and id_tipo_acesso_endereco is  null
  
 SELECT * FROM endereco WHERE id_def =4 AND nivel = (select max(nivel) from def_endereco where id_def = 4)
 and id_def_endereco_setor is  null
   
 SELECT * FROM endereco WHERE id_def = 4 AND nivel = (select max(nivel) from def_endereco where id_def = 4)
 and id_tipo_volume is  null
  
*/