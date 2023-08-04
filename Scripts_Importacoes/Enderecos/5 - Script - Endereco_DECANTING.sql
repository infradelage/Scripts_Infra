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


-- REDEFINE NIVEIS DE ENDERE�AMENTO
ALTER TABLE endereco NOCHECK CONSTRAINT ALL

DELETE def_endereco where id_def = 18 and nivel > 1

INSERT def_endereco(id_def, nivel, descricao, id_tipo, divide_volume, validacao, msgerro, separador, compoe_endereco, endereco_movel)
--FLOWRACK
--SELECT 18, 1, 'CLASSIF.', 15, 0, NULL, NULL, NULL, 0, 0 UNION
SELECT 18, 2, 'LINHA', 15, 1, NULL, NULL, '.', 1, 0  UNION
SELECT 18, 3, 'MODULO', 15, 0, NULL, NULL, '.', 1, 0  UNION
SELECT 18, 4, 'NIVEl', 15, 0, NULL, NULL, NULL, 1, 0  UNION
SELECT 18, 5, 'POSICAO', 15, 0, NULL, NULL, NULL, 1, 0 


ALTER TABLE endereco CHECK CONSTRAINT ALL
GO

-- VALIDA def_endereco
SELECT * FROM def_endereco where id_def = 18 and nivel > 1


drop table mig_decanting_trabalho
--TABELA PARA TRABALHAR E NO FIM DELETAR
select * INTO mig_decanting_trabalho  from mig_decanting


/*CURINGA! Se alguma columa estiver como float basta alterar ela para varchar! 
Exemplo abaixo:
alter table mig_decanting_trabalho alter column estacao varchar(30)
*/


--AJUSTES CASO PRECISEM--
--ACESSO--
select * from def_tipo_acesso_endereco where id_tipo_endereco = 15
update def_tipo_acesso_endereco set descricao = 'A PÉ (DECANTING)' where descricao like '%A PÉ%' and id_tipo_endereco = 15 --FLOWRACK
update def_tipo_acesso_endereco set descricao = 'EMPILHADEIRA (DECANTING)' where descricao like '%EMPILHADEIRA%' and id_tipo_endereco = 15 --FLOWRACK
INSERT INTO def_tipo_acesso_endereco values ('A PÉ (DECANTING)','0,00',15)

select DISTINCT tipo_de_acesso from mig_decanting_trabalho
update mig_decanting_trabalho set tipo_de_acesso = 'A PÉ (DECANTING)' where tipo_de_acesso like '%A PÉ%'
update mig_decanting_trabalho set tipo_de_acesso = 'EMPILHADEIRA (DECANTING)' where tipo_de_acesso like '%EMPILHADEIRA%'

SELECT DISTINCT classificacao FROM mig_decanting_trabalho
update mig_pulmao_trabalho set classificacao = 'DECANTING' --where classificacao like '%PULM�O%'

--VOLUME--
SELECT DISTINCT TIPO_VOLUME FROM mig_decanting_trabalho
update mig_decanting_trabalho set tipo_volume = 'PALLET PADRAO'

SELECT DISTINCT classificacao_endereco FROM mig_decanting_trabalho
update mig_pulmao_trabalho set classificacao_endereco = 'SEGREGADO TRANSITORIO' 
--FIM AJUSTES


--ATENCAO AQUI--NAO PODE RETORNAR NENHUMA LINHA AQUI. SE RETORNAR DEVOLVER A PLANILHA
select * from mig_decanting_trabalho where endereco_completo is null


--INSER��ES EM DEFs CASO PRECISE--
--SETOR
insert def_endereco_setor
select distinct setor,15 from mig_decanting_trabalho
where setor not in (select descricao from def_endereco_setor where descricao = setor and id_tipo = 15)

--ACESSO
insert def_tipo_acesso_endereco (descricao, id_tipo_endereco) 
select distinct tipo_de_acesso,3 from mig_decanting_trabalho 
where  tipo_de_acesso not in 
(select tipo_de_acesso from def_tipo_acesso_endereco where descricao = tipo_de_acesso) 


--VOLUME 
-->SOLICITAR REVISAO POSTERIOR NAS QUANTIDADE DE CAIXAS E DIMENSSOES VIA SISTEMA<--
insert def_tipo_volume_endereco
select distinct tipo_volume, 1, 1,1,1,0,null,0,0,0,0 from mig_decanting_trabalho
where  tipo_volume not in 
(select tipo_volume from def_tipo_volume_endereco where descricao = tipo_volume)

--CLASSIFICACAO
insert def_lote_classificacao (descricao, le_estoque_segregado, principal, exporta_esto
select distinct classificacao_endereco,0,0 from mig_decanting_trabalho
where  classificacao_endereco not in 
(select descricao from def_lote_classificacao where descricao = classificacao_endereco)

--FIM INSER��ES


--DELETE ENDERECO DE FLOW PARA COME�AR DO PRIMEIRO NIVEL E ACERTAR O IDENTITY
DELETE endereco
WHERE nivel > 1 and id_def = 18
DECLARE @max_endereco int
set @max_endereco = (select max(id_endereco) from endereco where id_def = 18)
DBCC CHECKIDENT (endereco, RESEED, @max_endereco)
---AQUI INICIA A IMPORTACAO DOS ENDERECOS DE FATO--

--NIVEL 2 -
insert endereco(id_def, nivel, endereco, id_pai, qtd_caixa, endereco_completo, id_lote_classificacao, cod_situacao_endereco)
select distinct 18, 2,  m1.LINHA, m2.id_endereco, null, m1.LINHA, dlc.id_lote_classificacao,1
from mig_decanting_trabalho m1, endereco m2, def_lote_classificacao dlc
where  m2.endereco_completo = m1.classificacao
and m1.classificacao_endereco = dlc.descricao
AND NOT EXISTS (SELECT 1 FROM ENDERECO E WHERE E.endereco_completo = m1.LINHA AND id_def = 18 AND NIVEL = 2)
and m2.id_def = 18
and m2.nivel = 1

--NIVEL 3 - XX
insert endereco(id_def, nivel, endereco, id_pai, qtd_caixa, endereco_completo, id_lote_classificacao, cod_situacao_endereco)
select distinct  18, 3, m1.MODULO, m2.id_endereco, null, m1.MODULO ,dlc.id_lote_classificacao,1
from mig_decanting_trabalho m1, endereco m2, def_lote_classificacao dlc
where m2.endereco_completo = m1.LINHA
and m1.classificacao_endereco = dlc.descricao
AND NOT EXISTS (SELECT 1 FROM ENDERECO E WHERE E.endereco_completo = m1.MODULO AND id_def = 18 AND NIVEL = 3)
and m2.id_def = 18
and m2.nivel = 2


order by 3, 4

--NIVEL 4 - XX.XX
insert endereco(id_def, nivel, endereco, id_pai, qtd_caixa, endereco_completo, id_lote_classificacao, cod_situacao_endereco,
id_tipo_acesso_endereco, id_tipo_Armazenamento, id_tipo_volume)
select distinct 18, 4, m1.NIVEl, m2.id_endereco, null, m1.MODULO + m1.NIVEl, dlc.id_lote_classificacao,1,
NULL, NULL, null
from mig_decanting_trabalho m1, endereco m2, endereco m3, def_lote_classificacao dlc, def_tipo_volume_endereco dtve
where m2.endereco_completo = m1.MODULO
and m2.id_pai = M3.id_endereco
and M3.endereco_completo = m1.LINHA
and m2.id_def = 18 and m2.nivel = 3
and m1.classificacao_endereco = dlc.descricao
and dtve.descricao =  m1.tipo_volume
and not exists(select 1 from endereco m11,  endereco m22, endereco m33, endereco m44
                   where m11.endereco_completo = m1.MODULO+ m1.NIVEl
				   and m11.id_pai = m22.id_endereco
				   and m22.id_pai = m33.id_endereco
				   and M33.ENDERECO_COMPLETO = m1.LINHA
				   and m33.id_pai = m44.id_endereco
				   and m44.endereco_completo = m1.classificacao) 


--NIVEL 5 - XX.XX.XX
insert endereco(id_def, nivel, endereco, id_pai, qtd_caixa, endereco_completo, id_lote_classificacao, cod_situacao_endereco,
id_tipo_acesso_endereco, id_tipo_Armazenamento, id_tipo_volume)
select distinct 18, 5, m1.POSICAO, m2.id_endereco, null, m1.MODULO + m1.NIVEl + m1.POSICAO, 
dlc.id_lote_classificacao,1,dtac.id_tipo_acesso_endereco, dtae.id_tipo_armazenamento_endereco,dtve.id_tipo_volume_endereco
from mig_decanting_trabalho m1, endereco m2, endereco m3, endereco m4, def_lote_classificacao dlc, def_tipo_acesso_endereco dtac, 
def_tipo_volume_endereco dtve, def_tipo_armazenamento_endereco dtae
where m2.endereco_completo = m1.MODULO + m1.NIVEl
and m2.id_pai = m4.id_endereco
and m4.id_pai = M3.id_endereco
and M3.endereco_completo = m1.LINHA
and m2.id_def = 18 and m2.nivel = 4
and m1.classificacao_endereco = dlc.descricao
and DTAC.descricao = M1.tipo_de_acesso 
--and dtac.id_tipo_endereco = 3
and dtve.descricao =  m1.tipo_volume
and dtae.descricao = m1.tipo_de_armazenamento
--and m1.MODULO + m1.modulo + m1.nivel = 'P16020'
and not exists(select 1 from endereco m11, endereco m55, endereco m22, endereco m33, endereco m44
                   where m11.endereco_completo = m1.MODULO + m1.NIVEl + m1.POSICAO
				   and m11.id_pai = m55.id_endereco
				   and m55.id_pai = m22.id_endereco
				   and m22.id_pai = m33.id_endereco
				   and M33.ENDERECO_COMPLETO = m1.LINHA
				   and m33.id_pai = m44.id_endereco
				   and m44.endereco_completo = m1.classificacao)


----NIVEL 6 - XX.XX.XX
--insert endereco(id_def, nivel, endereco, id_pai, qtd_caixa, endereco_completo, id_lote_classificacao, cod_situacao_endereco,
--id_tipo_acesso_endereco, id_tipo_Armazenamento, id_tipo_volume)
--select distinct 2, 6, m1.apartamento, m2.id_endereco, null, m1.MODULO + m1.NIVEl + m1.POSICAO, 
--dlc.id_lote_classificacao,1,dtac.id_tipo_acesso_endereco, dtae.id_tipo_armazenamento_endereco,dtve.id_tipo_volume_endereco
--from mig_decanting_trabalho m1, endereco m2, endereco m3,endereco m5, endereco m4, def_lote_classificacao dlc, def_tipo_acesso_endereco dtac, 
--def_tipo_volume_endereco dtve, def_tipo_armazenamento_endereco dtae
--where m2.endereco_completo = m1.MODULO + m1.modulo + m1.nivel
--and m2.id_pai = m4.id_endereco
--and m4.id_pai = m5.id_endereco
--and m5.id_pai = M3.id_endereco
--and M3.endereco_completo = m1.LINHA
--and m2.id_def = 18 and m2.nivel = 5
--and m1.classificacao_endereco = dlc.descricao
--and DTAC.descricao = M1.tipo_de_acesso  
--and dtac.id_tipo_endereco = 3 
--and dtve.descricao =  m1.tipo_volume
--and dtae.descricao = m1.tipo_de_armazenamento
--and not exists(select 1 from endereco m11,endereco m12, endereco m55, endereco m22, endereco m33, endereco m44
--                   where m11.endereco_completo = m1.MODULO + m1.modulo + m1.nivel + m1.apartamento
--				   and m11.id_pai = m12.id_endereco
--				   and m12.id_pai = m55.id_endereco
--				   and m55.id_pai = m22.id_endereco
--				   and m22.id_pai = m33.id_endereco
--				   and M33.ENDERECO_COMPLETO = m1.LINHA
--				   and m33.id_pai = m44.id_endereco
--				   and m44.endereco_completo = m1.classificacao)
--order by 6 


--FIM IMPORTACAO DOS ENDERECOS 
				   
select endereco_completo, count(1)
from mig_decanting_trabalho
group by endereco_completo
having count(1) > 1

--UPDATES ADICIONAIS DEPOIS DE IMPORTADO OS ENDERECOS--		   
UPDATE endereco
   SET  endereco_completo_3D = dbo.getEnderecoCompleto3D(id_endereco),
	   id_endereco_completo = dbo.getEnderecoCompletoID(id_endereco),
	   id_endereco_div = dbo.GetEnderecoDivID(id_endereco),
	   endereco_completo = dbo.getEnderecoCompleto(id_endereco)
WHERE id_def = 18

UPDATE E
   SET E.endereco_completo_pai = PAI.endereco_completo
  FROM endereco E INNER JOIN
       endereco PAI ON PAI.id_endereco = E.id_pai
Where e.id_def = 18

UPDATE endereco
   SET  GetEnderecoPaiNivel = dbo.GetEnderecoPaiNivel(id_endereco,nivel)   
   WHERE id_def = 18

--UPDATE e
--SET id_endereco_div = dbo.GetEnderecoDivID(id_endereco)
--SELECT *
--FROM endereco e
--WHERE e.id_def = 18
--AND e.nivel > (select nivel from def_endereco where id_def = 18 and divide_volume = 1)

UPDATE e set
e.id_def_endereco_setor = def.id_def_endereco_setor
--SELECT * 
from endereco e
inner join mig_decanting_trabalho m1 on e.endereco_completo = m1.endereco_completo
inner join def_endereco_setor def on def.descricao = m1.setor
where e.id_def = 18 and def.id_tipo = 15

--FIM UPDATES ADICIONAIS


/*
Validacoes

 SELECT count(1) as enderecos_a_migrar from mig_decanting_trabalho
 SELECT count(1) as enderecos_migrados from endereco where id_def = 18 and nivel = (select max(nivel) from def_endereco where id_def = 18)

 SELECT * FROM endereco WHERE id_def = 18 AND nivel =(select max(nivel) from def_endereco where id_def = 18)
 and id_tipo_Armazenamento is  null
 
 SELECT * FROM endereco WHERE id_def = 18 AND nivel =(select max(nivel) from def_endereco where id_def = 18)
 and id_tipo_acesso_endereco is  null
  
 SELECT * FROM endereco WHERE id_def =2 AND nivel =(select max(nivel) from def_endereco where id_def = 18)
 and id_def_endereco_setor is  null
   
 SELECT * FROM endereco WHERE id_def = 18 AND nivel =(select max(nivel) from def_endereco where id_def = 18)
 and id_tipo_volume is  null
  
*/
 

