/*-------------------------------------------------------------------
-												 -
-- Cria��o da �rvore de endere�o - FLOWRACK - COM 2 NIVEIS FINAIS	-
-																	-
--					XX.XXX											-	
--                  11.011											-
-- 11	- ESTACAO													-
-- 0	- NIVEL														-
-- 11	- POSICAO													-
--																	-
-------------------------------------------------------------------*/
USE XXXXXX
GO


-- REDEFINE NIVEIS DE ENDERE�AMENTO
ALTER TABLE endereco NOCHECK CONSTRAINT ALL

DELETE def_endereco where id_def = 2 and nivel > 1

INSERT def_endereco(id_def, nivel, descricao, id_tipo, divide_volume, validacao, msgerro, separador, compoe_endereco, endereco_movel)
--FLOWRACK
--SELECT 1, 1, 'CLASSIF.', 3, 0, NULL, NULL, NULL, 0, 0 UNION
SELECT 2, 2, 'OL',		3, 1, NULL, NULL, null, 0, 0 UNION
SELECT 2, 3, 'SETOR',	3, 1, NULL, NULL, null, 0, 0 UNION
SELECT 2, 4, 'RUA',		3, 0, NULL, NULL, '.',	1, 0 UNION
SELECT 2, 5, 'LADO',	3, 0, NULL, NULL, NULL, 0, 0 UNION
SELECT 2, 6, 'PREDIO',	3, 0, NULL, NULL, '.',	1, 0 UNION
SELECT 2, 7, 'NIVEL',	3, 0, NULL, NULL, NULL, 1, 0 


ALTER TABLE endereco CHECK CONSTRAINT ALL
GO

SELECT * FROM def_endereco where id_def = 2 and nivel > 1

drop table mig_flowrack_trabalho
--TABELA PARA TRABALHAR E NO FIM DELETAR
select * INTO mig_flowrack_trabalho  from mig_flowrack


/*CURINGA! Se alguma columa estiver como float basta alterar ela para varchar! 
Exemplo abaixo:
alter table mig_flowrack_trabalho alter column estacao varchar(30)
*/


--AJUSTES CASO PRECISEM--
--ACESSO--
select * from def_tipo_acesso_endereco where id_tipo_endereco = 3
update def_tipo_acesso_endereco set descricao = 'A PÉ (FLOWRACK)' where descricao like '%A PÉ%' and id_tipo_endereco = 3 --FLOWRACK
update def_tipo_acesso_endereco set descricao = 'EMPILHADEIRA (FLOWRACK)' where descricao like '%EMPILHADEIRA%' and id_tipo_endereco = 3 --FLOWRACK

select DISTINCT tipo_de_acesso from mig_flowrack_trabalho
update mig_flowrack_trabalho set tipo_de_acesso = 'A PÉ (FLOWRACK)' where tipo_de_acesso like '%A PÉ%'
update mig_flowrack_trabalho set tipo_de_acesso = 'EMPILHADEIRA (FLOWRACK)' where tipo_de_acesso like '%EMPILHADEIRA%'

--VOLUME--
SELECT  DISTINCT tipo_volume from mig_flowrack_trabalho
update mig_flowrack_trabalho set tipo_volume = 'PALLET PADRAO'

SELECT DISTINCT OL  FROM mig_flowrack_trabalho
--update mig_flowrack_trabalho set OL = 'CENTRO DE DISTRIBUICAO' where OL like '%CENTRO DE DISTRIBUIÇÃO%'


--FIM AJUSTES


--ATENCAO AQUI--NAO PODE RETORNAR NENHUMA LINHA AQUI. SE RETORNAR DEVOLVER A PLANILHA
select * from mig_flowrack_trabalho where endereco_completo is null


--INSER��ES EM DEFs CASO PRECISE--
--SETOR
insert def_endereco_setor
select distinct setor,3 from mig_flowrack_trabalho
where setor not in (select descricao from def_endereco_setor where descricao = setor and id_tipo = 3)

--delete def_endereco_setor where id_tipo = 3

--ACESSO
insert def_tipo_acesso_endereco (descricao, id_tipo_endereco) 
select distinct tipo_de_acesso,3 from mig_flowrack_trabalho 
where  tipo_de_acesso not in 
(select tipo_de_acesso from def_tipo_acesso_endereco where descricao = tipo_de_acesso) 


--VOLUME 
-->SOLICITAR REVISAO POSTERIOR NAS QUANTIDADE DE CAIXAS E DIMENSSOES VIA SISTEMA<--
insert def_tipo_volume_endereco
select distinct tipo_volume, 1, 1,1,1,0,null,0,0,0,0 from mig_flowrack_trabalho
where  tipo_volume not in 
(select tipo_volume from def_tipo_volume_endereco where descricao = tipo_volume)

--FIM INSER��ES


--DELETE ENDERECO DE FLOW PARA COME�AR DO PRIMEIRO NIVEL E ACERTAR O IDENTITY
DELETE endereco
WHERE nivel > 1 and id_def = 2
DECLARE @max_endereco int
set @max_endereco = (select max(id_endereco) from endereco where id_def = 1)
DBCC CHECKIDENT (endereco, RESEED, @max_endereco)

---AQUI INICIA A IMPORTACAO DOS ENDERECOS DE FATO--

--NIVEL 2 -
insert endereco(id_def, nivel, endereco, id_pai, qtd_caixa, endereco_completo, id_lote_classificacao, cod_situacao_endereco)
select distinct 2, 2,m1.OL, m2.id_endereco, null, m1.OL, dlc.id_lote_classificacao,1
from mig_flowrack_trabalho m1, endereco m2, def_lote_classificacao dlc
where  m2.endereco = m1.classificacao
and m1.classificacao = dlc.descricao
AND NOT EXISTS (SELECT 1 FROM ENDERECO E WHERE E.endereco_completo = m1.OL AND ID_DEF = 2 AND NIVEL = 2)
and m2.id_def = 2
and m2.nivel = 1


--NIVEL 3 - XX
insert endereco(id_def, nivel, endereco, id_pai, qtd_caixa, endereco_completo, id_lote_classificacao, cod_situacao_endereco)
select distinct  2, 3, m1.SETOR, m2.id_endereco, null, m1.OL+m1.SETOR ,dlc.id_lote_classificacao,1
from mig_flowrack_trabalho m1, endereco m2, def_lote_classificacao dlc
where m2.endereco_completo = m1.OL
and m1.classificacao = dlc.descricao
AND NOT EXISTS (SELECT 1 FROM ENDERECO E WHERE E.endereco_completo = m1.OL+m1.SETOR AND ID_DEF = 2 AND NIVEL = 3)
and m2.id_def = 2
and m2.nivel = 2


--NIVEL 4 - XX.XX

insert endereco(id_def, nivel, endereco, id_pai, qtd_caixa, endereco_completo, id_lote_classificacao, cod_situacao_endereco,
id_tipo_acesso_endereco, id_tipo_Armazenamento, id_tipo_volume)
select distinct 2, 4, m1.RUA, m2.id_endereco, null, m1.RUA , dlc.id_lote_classificacao,1,
NULL, NULL, null
from mig_flowrack_trabalho m1, endereco m2, endereco m3, def_lote_classificacao dlc 
where m2.endereco_completo = m1.OL+m1.SETOR
and m2.id_pai = M3.id_endereco
and M3.endereco = m1.OL
and m2.id_def = 2 and m2.nivel = 3
and m1.classificacao_endereco = dlc.descricao

--and dtve.descricao =  m1.tipo_volume
--and not exists(select 1 from endereco m11,  endereco m22, endereco m33, endereco m44
--                   where m11.endereco_completo = m1.SETOR + '.' + m1.RUA + '.' + m1.PREDIO
--				   and m11.id_pai = m22.id_endereco
--				   and m22.id_pai = m33.id_endereco
--				   and M33.ENDERECO_COMPLETO = m1.SETOR
--				   and m33.id_pai = m44.id_endereco
--				   and m44.endereco_completo = m1.classificacao) 
and not exists(select 1 from endereco m11
				where id_def = 2 and nivel = 4
				and endereco_completo = m1.RUA ) 


--NIVEL 5 - XX.XX.XX
insert endereco(id_def, nivel, endereco, id_pai, qtd_caixa, endereco_completo, id_lote_classificacao, cod_situacao_endereco,
id_tipo_acesso_endereco, id_tipo_Armazenamento, id_tipo_volume)
select distinct 2, 5, m1.LADO, m2.id_endereco, null, m1.RUA + '.' + m1.LADO, 
dlc.id_lote_classificacao,1,dtac.id_tipo_acesso_endereco, dtae.id_tipo_armazenamento_endereco,null--dtve.id_tipo_volume_endereco
from mig_flowrack_trabalho m1, endereco m2, endereco m3, endereco m4, def_lote_classificacao dlc, def_tipo_acesso_endereco dtac, 
def_tipo_volume_endereco dtve, def_tipo_armazenamento_endereco dtae
where m2.endereco_completo = m1.RUA
and m2.id_pai = m4.id_endereco
and m4.id_pai = M3.id_endereco
and M3.endereco = m1.OL
and m2.id_def = 2 and m2.nivel = 4
and m1.classificacao = dlc.descricao
and DTAC.descricao = M1.tipo_de_acesso 
and dtac.id_tipo_endereco = 3
--and dtve.descricao =  m1.tipo_volume
and dtae.descricao = m1.tipo_de_armazenamento
and not exists(select 1 from endereco m11, endereco m55, endereco m22, endereco m33, endereco m44
                   where m11.endereco_completo = m1.RUA + '.' + m1.LADO
				   and m11.id_pai = m55.id_endereco
				   and m55.id_pai = m22.id_endereco
				   and m22.id_pai = m33.id_endereco
				   and M33.ENDERECO_COMPLETO = m1.SETOR
				   and m33.id_pai = m44.id_endereco
				   and m44.endereco_completo = m1.CLASSIFICACAO)



--NIVEL 6 - XX.XX.XX
insert endereco(id_def, nivel, endereco, id_pai, qtd_caixa, endereco_completo, id_lote_classificacao, cod_situacao_endereco,
id_tipo_acesso_endereco, id_tipo_Armazenamento, id_tipo_volume)
select distinct 2, 6, m1.PREDIO, m2.id_endereco, null, m1.RUA + '.' + m1.LADO + m1.PREDIO, 
dlc.id_lote_classificacao,1,dtac.id_tipo_acesso_endereco, dtae.id_tipo_armazenamento_endereco,null--dtve.id_tipo_volume_endereco
from mig_flowrack_trabalho m1, endereco m2, endereco m3,endereco m5, endereco m4, def_lote_classificacao dlc, def_tipo_acesso_endereco dtac, 
def_tipo_volume_endereco dtve, def_tipo_armazenamento_endereco dtae
where m2.endereco_completo = m1.RUA + '.' + m1.LADO
and m2.id_pai = m4.id_endereco
and m4.id_pai = m5.id_endereco
and m5.id_pai = M3.id_endereco
and M3.endereco_completo = m1.OL
and m2.id_def = 2 and m2.nivel = 5
and m1.classificacao_endereco = dlc.descricao
and DTAC.descricao = M1.tipo_de_acesso  
and dtac.id_tipo_endereco = 3 
--and dtve.descricao =  m1.tipo_volume
and dtae.descricao = m1.tipo_de_armazenamento
and not exists(select 1 from endereco m11,endereco m12, endereco m55, endereco m22, endereco m33, endereco m44
                   where m11.endereco_completo =  m1.RUA + '.' + m1.LADO + m1.PREDIO
				   and m11.id_pai = m12.id_endereco
				   and m12.id_pai = m55.id_endereco
				   and m55.id_pai = m22.id_endereco
				   and m22.id_pai = m33.id_endereco
				   and M33.ENDERECO_COMPLETO = m1.OL
				   and m33.id_pai = m44.id_endereco
				   and m44.endereco_completo = m1.CLASSIFICACAO)
order by 6 


--NIVEL 7 - XX.XX.XX.X
insert endereco(id_def, nivel, endereco, id_pai, qtd_caixa, endereco_completo, id_lote_classificacao, cod_situacao_endereco,
id_tipo_acesso_endereco, id_tipo_Armazenamento, id_tipo_volume)
select distinct 2, 7, m1.NIVEL, m2.id_endereco, null, m1.RUA + '.' + m1.LADO + m1.PREDIO + '.' + m1.NIVEL,
dlc.id_lote_classificacao,1,dtac.id_tipo_acesso_endereco, dtae.id_tipo_armazenamento_endereco,dtve.id_tipo_volume_endereco
from mig_flowrack_trabalho m1, endereco m2, endereco m3, endereco m5, endereco m6, endereco m4, def_lote_classificacao dlc, def_tipo_acesso_endereco dtac, 
def_tipo_volume_endereco dtve, def_tipo_armazenamento_endereco dtae
where m2.endereco_completo = m1.RUA + '.' + m1.LADO + m1.PREDIO
and m2.id_pai = m4.id_endereco
and m4.id_pai = m6.id_endereco
and m6.id_pai = m5.id_endereco
and m5.id_pai = M3.id_endereco
and M3.endereco_completo = m1.OL
and m2.id_def = 2 and m2.nivel = 6
and m1.classificacao_endereco = dlc.descricao
and DTAC.descricao = M1.tipo_de_acesso 
and dtac.id_tipo_endereco = 3 -- PULMAO
and dtve.descricao =  m1.tipo_volume
and dtae.descricao = m1.tipo_de_armazenamento
and not exists(select 1 from endereco m11, endereco m12, endereco m13, endereco m55, endereco m22, endereco m33, endereco m44
                   where m11.endereco_completo = m1.RUA + '.' + m1.LADO + m1.PREDIO + '.' + m1.NIVEL
				   and m11.id_pai = m13.id_endereco
				   and m13.id_pai = m12.id_endereco
				   and m12.id_pai = m55.id_endereco
				   and m55.id_pai = m22.id_endereco
				   and m22.id_pai = m33.id_endereco
				   and M33.ENDERECO_COMPLETO = m1.OL
				   and m33.id_pai = m44.id_endereco
				   and m44.endereco_completo = m1.classificacao)
order by 6



select endereco_completo, count(1)
from mig_flowrack_trabalho
group by endereco_completo
having count(1) > 1
			
--FIM IMPORTACAO DOS ENDERECOS 

--UPDATES ADICIONAIS DEPOIS DE IMPORTADO OS ENDERECOS--		   
UPDATE endereco
   SET  endereco_completo_3D = dbo.getEnderecoCompleto3D(id_endereco),
	   id_endereco_completo = dbo.getEnderecoCompletoID(id_endereco),
	   id_endereco_div = dbo.GetEnderecoDivID(id_endereco),
	   endereco_completo = dbo.getEnderecoCompleto(id_endereco)
	   where id_def = 2 AND id_endereco >= 57291

UPDATE E
   SET E.endereco_completo_pai = PAI.endereco_completo
  FROM endereco E INNER JOIN
       endereco PAI ON PAI.id_endereco = E.id_pai
		where e.id_def = 2 AND e.id_endereco >= 57291

UPDATE endereco
   SET  GetEnderecoPaiNivel = dbo.GetEnderecoPaiNivel(id_endereco,nivel)   
   	   where id_def = 2 AND id_endereco >= 57291

--UPDATE e
--SET id_endereco_div = dbo.GetEnderecoDivID(id_endereco)
--FROM endereco e
--WHERE e.id_def = 2
--AND e.nivel > (select nivel from def_endereco where id_def = 2 and divide_volume = 1)
--and e.endereco_completo in (select endereco_completo from mig_flowrack_trabalho)

UPDATE e set
e.id_def_endereco_setor = def.id_def_endereco_setor
--SELECT * 
from endereco e
inner join mig_flowrack_trabalho m1 on e.endereco_completo = m1.endereco_completo
inner join def_endereco_setor def on def.descricao = m1.setor
where e.id_def = 2 and def.id_tipo = 3 AND id_endereco >= 57291


--update e set e.cod_situacao_endereco = 2
----select e.*
--from endereco e
--inner join mig_flowrack_trabalho ee on e.endereco_completo = ee.endereco_completo
--where e.id_def = 2
--and ee.situacao ='Inativo'



--FIM UPDATES ADICIONAIS


/*
Validacoes

 SELECT count(1) as enderecos_a_migrar from mig_flowrack_trabalho
 SELECT count(1) as enderecos_migrados from endereco where id_def = 2 and nivel = (select max(nivel) from def_endereco where id_def = 2)

 SELECT * FROM endereco WHERE id_def = 2 AND nivel =5
 and id_tipo_Armazenamento is  null
 
 SELECT * FROM endereco WHERE id_def = 2 AND nivel =5
 and id_tipo_acesso_endereco is  null
  
 SELECT * FROM endereco WHERE id_def =2 AND nivel =5
 and id_def_endereco_setor is  null
   
 SELECT * FROM endereco WHERE id_def = 2 AND nivel =5
 and id_tipo_volume is  null
  
*/
 

