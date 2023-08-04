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

USE WMSRX_Netsuite;
GO

-- REDEFINE NIVEIS DE ENDERE�AMENTO
ALTER TABLE endereco NOCHECK CONSTRAINT ALL

DELETE def_endereco WHERE id_def = 16 and nivel > 1

INSERT def_endereco(id_def, nivel, descricao, id_tipo, divide_volume, validacao, msgerro, separador, compoe_endereco, endereco_movel)

--SELECT 1, 1, 'CLASSIF.', 2, 0, NULL, NULL, NULL, 0, 0 UNION
SELECT 16, 2, 'ZONA', 17, 0, NULL, NULL, '-', 1, 0 UNION
SELECT 16, 3, 'LOCAL', 17, 0, NULL, NULL, '-', 1, 0 UNION
SELECT 16, 4, 'AREA', 17, 0, NULL, NULL, NULL, 1, 0 

ALTER TABLE endereco CHECK CONSTRAINT ALL
GO

select * from def_endereco WHERE id_def = 16 and nivel > 1

DROP TABLE mig_box_trabalho
--TABELA PARA TRABALHAR E NO FIM DELETAR
select * INTO mig_box_trabalho  from mig_box

/*CURINGA! Se alguma columa estiver como float basta alterar ela para varchar! 
Exemplo abaixo:
alter table mig_box_trabalho alter column palete varchar(30)
*/


--AJUSTES CASO PRECISEM--
--ACESSO--
select * from def_tipo_acesso_endereco where id_tipo_endereco = 5
update def_tipo_acesso_endereco set descricao = 'A PÈ (BOX)' where descricao like '%A PE%' and id_tipo_endereco = 5 --STAGING

select DISTINCT tipo_de_acesso from mig_box_trabalho
update mig_box_trabalho set tipo_de_acesso = 'A PÉ (BOX)' where tipo_de_acesso like '%A PE%'

select DISTINCT tipo_volume from mig_box_trabalho
update mig_box_trabalho set tipo_volume = 'PALLET PADRAO' WHERE tipo_volume like '%PALETE PADRAO%'

select DISTINCT tipo_de_armazenamento from mig_box_trabalho

--update mig_box_trabalho set tipo_volume = 'PALLET PADRAO' where tipo_volume like '%PALATE PADR�O%'
--FIM AJUSTES


--ATENCAO AQUI--NAO PODE RETORNAR NENHUMA LINHA AQUI. SE RETORNAR DEVOLVER A PLANILHA
select * from mig_box_trabalho where endereco_completo is null

--INSER��ES EM DEFs CASO PRECISE--
--SETOR
insert def_endereco_setor
select distinct setor,5 from mig_box_trabalho
where setor not in (select descricao from def_endereco_setor where descricao = setor and id_tipo = 5)


--ACESSO
insert def_tipo_acesso_endereco (descricao, id_tipo_endereco)
select distinct tipo_de_acesso, 2 from mig_box_trabalho
where  tipo_de_acesso not in 
(select tipo_de_acesso from def_tipo_acesso_endereco where descricao = tipo_de_acesso)

--ARMAZENAMENTO
insert def_tipo_armazenamento_endereco (descricao)
select distinct tipo_de_armazenamento from mig_box_trabalho
where  tipo_de_armazenamento not in 
(select descricao from def_tipo_armazenamento_endereco where descricao = tipo_de_armazenamento)

--VOLUME 
-->SOLICITAR REVISAO POSTERIOR NAS QUANTIDADE DE CAIXAS E DIMENSSOES VIA SISTEMA<--
insert def_tipo_volume_endereco
select distinct tipo_volume, 1, 1,1,1,0,null,0,0,0,0 from mig_box_trabalho
where  tipo_volume not in 
(select tipo_volume from def_tipo_volume_endereco where descricao = tipo_volume)
--FIM INSER��ES


--DELETE ENDERECO DE FLOW PARA COME�AR DO PRIMEIRO NIVEL E ACERTAR O IDENTITY
DELETE endereco
WHERE nivel > 1 and id_def = 16
DECLARE @max_endereco int
set @max_endereco = (select max(id_endereco) from endereco)
DBCC CHECKIDENT (endereco, RESEED, @max_endereco)

---AQUI INICIA A IMPORTACAO DOS ENDERECOS DE FATO--
--NIVEL 2 - XXX
insert endereco(id_def, nivel, endereco, id_pai, qtd_caixa, endereco_completo, id_lote_classificacao, cod_situacao_endereco)
select distinct 16, 2, m1.ZONA, m2.id_endereco, null, m1.ZONA, dlc.id_lote_classificacao,1
from mig_box_trabalho m1, endereco m2, def_lote_classificacao dlc
where  m2.endereco = m1.classificacao
and m1.classificacao_endereco = dlc.descricao
AND NOT EXISTS (SELECT 1 FROM ENDERECO E WHERE E.endereco_completo = m1.ZONA AND id_def = 16 AND NIVEL = 2)
and m2.id_def = 16
and m2.nivel = 1

--NIVEL 3 - XXX
insert endereco(id_def, nivel, endereco, id_pai, qtd_caixa, endereco_completo, id_lote_classificacao, cod_situacao_endereco,
id_tipo_acesso_endereco, id_tipo_Armazenamento, id_tipo_volume)
select distinct 16, 3, m1.LOCAL, m2.id_endereco, null, m1.ZONA +'-'+ m1.LOCAL, dlc.id_lote_classificacao,1,null,null,null
--dtac.id_tipo_acesso_endereco, dtae.id_tipo_armazenamento_endereco,dtve.id_tipo_volume_endereco
from mig_box_trabalho m1, endereco m2, def_lote_classificacao dlc,def_tipo_acesso_endereco dtac, 
def_tipo_volume_endereco dtve, def_tipo_armazenamento_endereco dtae
where  m2.endereco_completo = m1.ZONA
and m1.classificacao_endereco = dlc.descricao
--and DTAC.descricao = M1.tipo_de_acesso 
--and dtve.descricao =  m1.tipo_volume
--and dtae.descricao = m1.tipo_de_armazenamento
AND NOT EXISTS (SELECT 1 FROM ENDERECO E WHERE E.endereco_completo = 'BOX' + '.' + m1.ZONA + m1.LOCAL AND id_def = 16 AND NIVEL = 2)
and m2.id_def = 16
and m2.nivel = 2

--NIVEL 4 - XXX
insert endereco(id_def, nivel, endereco, id_pai, qtd_caixa, endereco_completo, id_lote_classificacao, cod_situacao_endereco,
id_tipo_acesso_endereco, id_tipo_Armazenamento, id_tipo_volume)
select distinct 16, 4, m1.AREA, m2.id_endereco, null, m1.ZONA +'-'+ m1.LOCAL+'-'+m1.AREA, dlc.id_lote_classificacao,1,
null,null,null
--dtac.id_tipo_acesso_endereco, dtae.id_tipo_armazenamento_endereco,dtve.id_tipo_volume_endereco
from mig_box_trabalho m1, endereco m2,def_lote_classificacao dlc
,def_tipo_acesso_endereco dtac,def_tipo_volume_endereco dtve, def_tipo_armazenamento_endereco dtae
where  m2.endereco_completo = m1.ZONA +'-'+ m1.LOCAL
and m1.classificacao_endereco = dlc.descricao
and DTAC.descricao = M1.tipo_de_acesso 
and dtve.descricao =  m1.tipo_volume
and dtae.descricao = m1.tipo_de_armazenamento
AND NOT EXISTS (SELECT 1 FROM ENDERECO E WHERE E.endereco_completo = m1.ZONA +'-'+ m1.LOCAL+'-'+m1.AREA AND id_def = 16 AND NIVEL = 2)
and m2.id_def = 16
and m2.nivel = 3

--FIM IMPORTACAO DOS ENDERECOS 
				   

--UPDATES ADICIONAIS DEPOIS DE IMPORTADO OS ENDERECOS--		   
UPDATE endereco
   SET  endereco_completo_3D = dbo.getEnderecoCompleto3D(id_endereco),
	   id_endereco_completo = dbo.getEnderecoCompletoID(id_endereco),
	   id_endereco_div = dbo.GetEnderecoDivID(id_endereco)--,
	   --endereco_completo = dbo.getEnderecoCompleto(id_endereco)
WHERE id_def = 16

UPDATE E
   SET E.endereco_completo_pai = PAI.endereco_completo
  FROM endereco E INNER JOIN
       endereco PAI ON PAI.id_endereco = E.id_pai
WHERE e.id_def = 16

UPDATE endereco
   SET  GetEnderecoPaiNivel = dbo.GetEnderecoPaiNivel(id_endereco,nivel)   
WHERE id_def = 16   

UPDATE e set
e.id_def_endereco_setor = def.id_def_endereco_setor
--SELECT *  
from endereco e
inner join mig_box_trabalho m1 on e.endereco_completo = m1.endereco_completo
inner join def_endereco_setor def on def.descricao = m1.setor
where e.id_def = 16 and def.id_tipo = 5--STAGING

--FIM UPDATES ADICIONAIS


/*
Validacoes

 SELECT count(1) as enderecos_a_migrar from mig_box_trabalho
 SELECT count(1) as enderecos_migrados from endereco WHERE id_def = 16 and nivel = (select max(nivel) from def_endereco WHERE id_def = 16)

 SELECT * FROM endereco WHERE id_def = 4 AND nivel = (select max(nivel) from def_endereco where id_def = 4)
 and id_tipo_Armazenamento is  null
 
 SELECT * FROM endereco WHERE id_def = 4 AND nivel = (select max(nivel) from def_endereco where id_def = 4)
 and id_tipo_acesso_endereco is  null
  
 SELECT * FROM endereco WHERE id_def =4 AND nivel = (select max(nivel) from def_endereco where id_def = 4)
 and id_def_endereco_setor is  null
   
 SELECT * FROM endereco WHERE id_def = 4 AND nivel = (select max(nivel) from def_endereco where id_def = 4)
 and id_tipo_volume is  null
  
*/