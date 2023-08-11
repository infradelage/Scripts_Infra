/*---------------------------------------------------------------
-												 -
-- Cria��o da �rvore de endere�o - PULM�O - COM 3 NIVEIS FINAIS	-
-																-
--					X.XX.XX										-
--                  B.44.09										-
-- B	- BLOCO														-
-- 44	- Predio													-
-- 03	- Nivel													-
--																-
---------------------------------------------------------------*/
USE WMSRX_HML
GO


-- REDEFINE NIVEIS DE ENDERE�AMENTO
ALTER TABLE endereco NOCHECK CONSTRAINT ALL

DELETE def_endereco where id_def = 1 and nivel > 1

INSERT def_endereco(id_def, nivel, descricao, id_tipo, divide_volume, validacao, msgerro, separador, compoe_endereco, endereco_movel)
-- PULM�O
--SELECT 1, 1, 'CLASSIF.', 2, 0, NULL, NULL, NULL, 0, 0 UNION
SELECT 1, 2, 'OL', 2, 0, NULL, NULL, NULL, 0, 0 UNION
SELECT 1, 3, 'LINHA', 2, 0, NULL, NULL, null, 0, 0 UNION
SELECT 1, 4, 'RUA',   2, 0, NULL, NULL, 1, 0 UNION
SELECT 1, 5, 'LADO',     2, 0, NULL, NULL,NULL , 0, 0 UNION
SELECT 1, 6, 'PREDIO',     2, 0, NULL, NULL,'.', 1, 0 UNION
SELECT 1, 7, 'NIVEL', 2, 0, NULL, NULL, NULL, 1, 0 

ALTER TABLE endereco CHECK CONSTRAINT ALL
GO

--
SELECT * from def_endereco where id_def = 1 and nivel >= 1

drop table mig_pulmao_trabalho
--TABELA PARA TRABALHAR E NO FIM DELETAR
select * INTO mig_pulmao_trabalho  from mig_pulmao

/*CURINGA! Se alguma columa estiver como float basta alterar ela para varchar! 
Exemplo abaixo:
alter table mig_pulmao_trabalho alter column estacao varchar(30)
*/

--AJUSTES CASO PRECISEM--
--VOLUME--
SELECT  DISTINCT tipo_volume from mig_pulmao_trabalho
update mig_pulmao_trabalho set tipo_volume = 'PALLET PADRAO'

--ACESSO--
select * from def_tipo_acesso_endereco where id_tipo_endereco = 2
update def_tipo_acesso_endereco set descricao = 'A PÉ (PULMAO)' where descricao like '%A PÉ (PULMÃO)%' and id_tipo_endereco = 2 --PULMAO
update def_tipo_acesso_endereco set descricao = 'ESCADA (PULMAO)' where descricao like '%ESCADA (PULMÃO)%' and id_tipo_endereco = 2 --PULMAO
update def_tipo_acesso_endereco set descricao = 'EMPILHADEIRA (PULMAO)' where descricao like '%EMPILHADEIRA (PULMÃO)%' and id_tipo_endereco = 2 --PULMAO

select DISTINCT tipo_de_acesso from mig_pulmao_trabalho
update mig_pulmao_trabalho set tipo_de_acesso = 'A PÉ (PULMAO)' where tipo_de_acesso like '%A PÉ%'
update mig_pulmao_trabalho set tipo_de_acesso = 'ESCADA (PULMAO)' where tipo_de_acesso like '%ESCADA%'
update mig_pulmao_trabalho set tipo_de_acesso = 'EMPILHADEIRA (PULMAO)' where tipo_de_acesso like '%EMPILHADEIRA%'

select DISTINCT tipo_de_armazenamento from mig_pulmao_trabalho
update mig_pulmao_trabalho set tipo_de_armazenamento = 'PULMAO' where tipo_de_armazenamento like '%PULMÃO'

select DISTINCT LINHA from mig_pulmao_trabalho
update mig_pulmao_trabalho set LINHA = 'ALMOXARIFADO' where LINHA like '%Almoxarifado'
update mig_pulmao_trabalho set LINHA = 'PRODUTO ACABADO' where LINHA like '%Produto Acabado'
update mig_pulmao_trabalho set LINHA = 'EMBALAGEM/SEMI ACABADO' where LINHA like '%Embalagem/Semi Acabado'

select DISTINCT SETOR from mig_pulmao_trabalho
update mig_pulmao_trabalho set SETOR = 'ALMOXARIFADO' where SETOR like '%Almoxarifado'
update mig_pulmao_trabalho set SETOR = 'PRODUTO ACABADO' where SETOR like '%Produto Acabado'
update mig_pulmao_trabalho set SETOR = 'EMBALAGEM/SEMI ACABADO' where SETOR like '%Embalagem/Semi Acabado'
update mig_pulmao_trabalho set SETOR = 'RÓTULO E BULA' where SETOR like '%Rótulo e Bula'
--FIM AJUSTES


--ATENCAO NAO PODE RETORNAR NENHUMA LINHA AQUI. SE RETORNAR DEVOLVER A PLANILHA
select * from mig_pulmao_trabalho where endereco_completo is null


--INSER��ES EM DEFs CASO PRECISE--
--SETOR
insert def_endereco_setor
select distinct UPPER(setor),2 from mig_pulmao_trabalho
where  setor not in (select descricao from def_endereco_setor where descricao = setor and id_tipo = 2)

--ACESSO
insert def_tipo_acesso_endereco (descricao, id_tipo_endereco)
select distinct tipo_de_acesso,2 from mig_pulmao_trabalho
where  tipo_de_acesso not in 
(select tipo_de_acesso from def_tipo_acesso_endereco where descricao = tipo_de_acesso)


--ARMAZENAMENTO
insert def_tipo_armazenamento_endereco (descricao)
select distinct tipo_de_armazenamento from mig_pulmao_trabalho
where  tipo_de_armazenamento not in 
(select descricao from def_tipo_armazenamento_endereco where descricao = tipo_de_armazenamento)

--FIM INSER��ES


delete endereco_restricao DBCC CHECKIDENT (endereco_restricao, RESEED, 0)
delete log_produto_endereco DBCC CHECKIDENT (log_produto_endereco, RESEED, 0)

ALTER TABLE log_produto_endereco NOCHECK CONSTRAINT ALL

--DELETE ENDERECO DE PULMAO PARA COME�AR DO PRIMEIRO NIVEL E ACERTAR O IDENTITY
DELETE endereco
WHERE nivel > 1 --and id_def = 1
DECLARE @max_endereco int
set @max_endereco = (select max(id_endereco) from endereco)
DBCC CHECKIDENT (endereco, RESEED, @max_endereco)

ALTER TABLE log_produto_endereco CHECK CONSTRAINT ALL


---AQUI INICIA A IMPORTACAO DOS ENDERECOS DE FATO--
--NIVEL 2 -
insert endereco(id_def, nivel, endereco, id_pai, qtd_caixa, endereco_completo, id_lote_classificacao, cod_situacao_endereco)
select distinct 1, 2,  m1.OL, m2.id_endereco, null, m1.OL, dlc.id_lote_classificacao,1
from mig_pulmao_trabalho m1, endereco m2, def_lote_classificacao dlc
where  m2.endereco = m1.classificacao
and m1.classificacao_endereco = dlc.descricao
AND NOT EXISTS (SELECT 1 FROM ENDERECO E WHERE E.endereco_completo = m1.OL AND ID_DEF = 1 AND NIVEL = 2)
and m2.id_def = 1
and m2.nivel = 1

--NIVEL 3 - XX
insert endereco(id_def, nivel, endereco, id_pai, qtd_caixa, endereco_completo, id_lote_classificacao, cod_situacao_endereco)
select distinct  1, 3, m1.LINHA, m2.id_endereco, null, m1.LINHA ,dlc.id_lote_classificacao,1
from mig_pulmao_trabalho m1, endereco m2, def_lote_classificacao dlc
where m2.endereco_completo = m1.OL
and m1.classificacao_endereco = dlc.descricao
AND NOT EXISTS (SELECT 1 FROM ENDERECO E WHERE E.endereco_completo = m1.LINHA AND ID_DEF = 1 AND NIVEL = 3)
and m2.id_def = 1
and m2.nivel = 2


order by 3, 4

--NIVEL 4 - XX.XX
insert endereco(id_def, nivel, endereco, id_pai, qtd_caixa, endereco_completo, id_lote_classificacao, cod_situacao_endereco,
id_tipo_acesso_endereco, id_tipo_Armazenamento, id_tipo_volume)
select distinct 1, 4, m1.RUA, m2.id_endereco, null, m1.LINHA+m1.RUA, dlc.id_lote_classificacao,1,
NULL, NULL, null --dtve.id_tipo_volume_endereco
from mig_pulmao_trabalho m1, endereco m2, endereco m3, def_lote_classificacao dlc, def_tipo_volume_endereco dtve
where m2.endereco_completo = m1.LINHA
and m2.id_pai = M3.id_endereco
and M3.endereco_completo = m1.OL
and m2.id_def = 1 and m2.nivel = 3
and m1.classificacao_endereco = dlc.descricao
and dtve.descricao =  m1.tipo_volume
and not exists(select 1 from endereco m11,  endereco m22, endereco m33, endereco m44
                   where m11.endereco_completo = m1.LINHA + m1.RUA + '.'
				   and m11.id_pai = m22.id_endereco
				   and m22.id_pai = m33.id_endereco
				   and M33.ENDERECO_COMPLETO = m1.OL
				   and m33.id_pai = m44.id_endereco
				   and m44.endereco_completo = m1.classificacao) 


--NIVEL 5 - XX.XX.XX
insert endereco(id_def, nivel, endereco, id_pai, qtd_caixa, endereco_completo, id_lote_classificacao, cod_situacao_endereco,
id_tipo_acesso_endereco, id_tipo_Armazenamento, id_tipo_volume)
select distinct 1, 5, m1.LADO, m2.id_endereco, null, m1.LINHA + m1.RUA + '.' + m1.LADO , 
dlc.id_lote_classificacao,1,null, null, null
from mig_pulmao_trabalho m1, endereco m2, endereco m3, endereco m4, def_lote_classificacao dlc, def_tipo_acesso_endereco dtac, 
def_tipo_volume_endereco dtve, def_tipo_armazenamento_endereco dtae
where m2.endereco_completo =m1.LINHA + m1.RUA 
and m2.id_pai = m4.id_endereco
and m4.id_pai = M3.id_endereco
and M3.endereco_completo = m1.OL
and m2.id_def = 1 and m2.nivel = 4
and m1.classificacao_endereco = dlc.descricao
and DTAC.descricao = M1.tipo_de_acesso 
and dtac.id_tipo_endereco = 2 -- PULMAO
and dtve.descricao =  m1.tipo_volume
and dtae.descricao = m1.tipo_de_armazenamento
and not exists(select 1 from endereco m11, endereco m55, endereco m22, endereco m33, endereco m44
                   where m11.endereco_completo = m1.LINHA + m1.RUA + '.' + m1.LADO + '.'
				   and m11.id_pai = m55.id_endereco
				   and m55.id_pai = m22.id_endereco
				   and m22.id_pai = m33.id_endereco
				   and M33.ENDERECO_COMPLETO = m1.OL
				   and m33.id_pai = m44.id_endereco
				   and m44.endereco_completo = m1.classificacao)



--NIVEL 6 - XX.XX.XX
insert endereco(id_def, nivel, endereco, id_pai, qtd_caixa, endereco_completo, id_lote_classificacao, cod_situacao_endereco,
id_tipo_acesso_endereco, id_tipo_Armazenamento, id_tipo_volume)
select distinct 1, 6, m1.PREDIO, m2.id_endereco, null, m1.LINHA + m1.RUA + '.' + m1.LADO + m1.PREDIO, 
dlc.id_lote_classificacao,1,dtac.id_tipo_acesso_endereco, dtae.id_tipo_armazenamento_endereco,dtve.id_tipo_volume_endereco
from mig_pulmao_trabalho m1, endereco m2, endereco m3,endereco m5, endereco m4, def_lote_classificacao dlc, def_tipo_acesso_endereco dtac, 
def_tipo_volume_endereco dtve, def_tipo_armazenamento_endereco dtae
where m2.endereco_completo = m1.LINHA + m1.RUA + '.' + m1.LADO 
and m2.id_pai = m4.id_endereco
and m4.id_pai = m5.id_endereco
and m5.id_pai = M3.id_endereco
and M3.endereco_completo = m1.OL
and m2.id_def = 1 and m2.nivel = 5
and m1.classificacao_endereco = dlc.descricao
and DTAC.descricao = M1.tipo_de_acesso  
and dtac.id_tipo_endereco = 2 -- PULMAO
and dtve.descricao =  m1.tipo_volume
and dtae.descricao = m1.tipo_de_armazenamento
and not exists(select 1 from endereco m11,endereco m12, endereco m55, endereco m22, endereco m33, endereco m44
                   where m11.endereco_completo = m1.LINHA + m1.RUA + '.' + m1.LADO + m1.PREDIO
				   and m11.id_pai = m12.id_endereco
				   and m12.id_pai = m55.id_endereco
				   and m55.id_pai = m22.id_endereco
				   and m22.id_pai = m33.id_endereco
				   and M33.ENDERECO_COMPLETO = m1.OL
				   and m33.id_pai = m44.id_endereco
				   and m44.endereco_completo = m1.classificacao)
order by 6	 


--NIVEL 7 - XX.XX.XX.X
insert endereco(id_def, nivel, endereco, id_pai, qtd_caixa, endereco_completo, id_lote_classificacao, cod_situacao_endereco,
id_tipo_acesso_endereco, id_tipo_Armazenamento, id_tipo_volume)
select distinct 1, 7, m1.NIVEL, m2.id_endereco, null, m1.LINHA + m1.RUA + '.' + m1.LADO  + m1.PREDIO+ '.' + m1.NIVEL,
dlc.id_lote_classificacao,1,dtac.id_tipo_acesso_endereco, dtae.id_tipo_armazenamento_endereco,dtve.id_tipo_volume_endereco
from mig_pulmao_trabalho m1, endereco m2, endereco m3, endereco m5, endereco m6, endereco m4, def_lote_classificacao dlc, def_tipo_acesso_endereco dtac, 
def_tipo_volume_endereco dtve, def_tipo_armazenamento_endereco dtae
where m2.endereco_completo = m1.LINHA + m1.RUA + '.' + m1.LADO + m1.PREDIO
and m2.id_pai = m4.id_endereco
and m4.id_pai = m6.id_endereco
and m6.id_pai = m5.id_endereco
and m5.id_pai = M3.id_endereco
and M3.endereco_completo = m1.OL
and m2.id_def = 1 and m2.nivel = 6
and m1.classificacao_endereco = dlc.descricao
and DTAC.descricao = M1.tipo_de_acesso 
and dtac.id_tipo_endereco = 2 -- PULMAO
and dtve.descricao =  m1.tipo_volume
and dtae.descricao = m1.tipo_de_armazenamento
and not exists(select 1 from endereco m11, endereco m12, endereco m13, endereco m55, endereco m22, endereco m33, endereco m44
                   where m11.endereco_completo = m1.LINHA + m1.RUA + '.' + m1.LADO  + m1.PREDIO+ '.' + m1.NIVEL
				   and m11.id_pai = m13.id_endereco
				   and m13.id_pai = m12.id_endereco
				   and m12.id_pai = m55.id_endereco
				   and m55.id_pai = m22.id_endereco
				   and m22.id_pai = m33.id_endereco
				   and M33.ENDERECO_COMPLETO = m1.OL
				   and m33.id_pai = m44.id_endereco
				   and m44.endereco_completo = m1.classificacao)
order by 6

--VALDIA ENDEREÇOS DUPLICADOS 
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

 SELECT * FROM endereco WHERE id_def = 1 AND nivel = (select max(nivel) from def_endereco where id_def = 1)
 and id_tipo_Armazenamento is  null
 
 SELECT * FROM endereco WHERE id_def = 1 AND nivel = (select max(nivel) from def_endereco where id_def = 1)
 and id_tipo_acesso_endereco is  null
  
 SELECT * FROM endereco WHERE id_def =1 AND nivel = (select max(nivel) from def_endereco where id_def = 1)
 and id_def_endereco_setor is  null
   
 SELECT * FROM endereco WHERE id_def = 1 AND nivel = (select max(nivel) from def_endereco where id_def = 1)
 and id_tipo_volume is  null
  
*/
 

