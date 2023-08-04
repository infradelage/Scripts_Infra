/*-------------------------------------------------------------------
-												 -
-- Criação da árvore de endereço - SEGREGADO - COM 1 NIVEL FINAL	-
-																	-
--					endereco_completo								-	
--                  FALTAS											-
-- FALTAS	- MOTIVO												-
--																	-
-------------------------------------------------------------------*/

-- REDEFINE NIVEIS DE ENDEREÇAMENTO
ALTER TABLE endereco NOCHECK CONSTRAINT ALL

DELETE def_endereco where id_def = 5 and nivel > 1

INSERT def_endereco(id_def, nivel, descricao, id_tipo, divide_volume, validacao, msgerro, separador, compoe_endereco, endereco_movel)
-- PULM�O
--SELECT 5, 1, 'CLASSIF.', 6, 0, NULL, NULL, NULL, 0, 0 UNION
SELECT 5, 2, 'LINHA', 6, 0, NULL, NULL, '.', 1, 0 UNION
SELECT 5, 3, 'RUA', 6, 0, NULL, NULL, NULL, 1, 0 ---UNION
--SELECT 5, 4, 'AREA', 6, 0, NULL, NULL, NULL, 1, 0 


ALTER TABLE endereco CHECK CONSTRAINT ALL
GO

--
SELECT * from def_endereco where id_def = 5 and nivel > 1

drop table mig_segregado_trabalho
--TABELA PARA TRABALHAR E NO FIM DELETAR
select * INTO mig_segregado_trabalho  from mig_segregado

/*CURINGA! Se alguma columa estiver como float basta alterar ela para varchar! 
Exemplo abaixo:
alter table mig_segregado_trabalho alter column palete varchar(30)
*/


--AJUSTES CASO PRECISEM--
--ACESSO--
select * from def_tipo_acesso_endereco where id_tipo_endereco = 6
update def_tipo_acesso_endereco set descricao = 'A PÉ (SEGREGADO)' where descricao like '%A PÉ%' and id_tipo_endereco = 6 --SEGREGADO
--delete from def_tipo_acesso_endereco where id_tipo_acesso_endereco = 13 and id_tipo_endereco = 6

select distinct tipo_de_acesso from mig_segregado_trabalho
update mig_segregado_trabalho set tipo_de_acesso = 'A PÉ (SEGREGADO)' where tipo_de_acesso like '%A PÉ%'
update mig_segregado_trabalho set tipo_de_acesso = 'ESCADA (SEGREGADO)' where tipo_de_acesso like '%ESCADA%'
update mig_segregado_trabalho set tipo_de_acesso = 'EMPILHADEIRA (SEGREGADO)' where tipo_de_acesso like '%EMPILHADEIRA%'

select distinct tipo_de_armazenamento from mig_segregado_trabalho
update mig_segregado_trabalho set tipo_de_armazenamento = 'PULMAO' where tipo_de_armazenamento like '%FLOWRACK%'

select distinct classificacao_endereco from mig_segregado_trabalho
update mig_segregado_trabalho set classificacao_endereco = 'DEVOLUCAO CLIENTE' where classificacao_endereco like '%DEVOLUÇÃO CLIENTE%'
update mig_segregado_trabalho set classificacao_endereco = 'DEVOLUCAO FORN' where classificacao_endereco like '%DEVOLUÇÃO FORN%'

select distinct linha from mig_segregado_trabalho
update mig_segregado_trabalho set linha = 'DEVOLUCAO CLIENTE' where classificacao_endereco like '%DEVOLUÇÃO CLIENTE%'
update mig_segregado_trabalho set linha = 'DEVOLUCAO FORN' where classificacao_endereco like '%DEVOLUÇÃO FORN%'

select distinct setor from mig_segregado_trabalho
update mig_segregado_trabalho set setor = 'DEVOLUCAO CLIENTE' where setor like '%DEVOLUÇÃO CLIENTE%'
update mig_segregado_trabalho set setor = 'DEVOLUCAO FORN' where setor like '%DEVOLUÇÃO FORN%'

select DISTINCT tipo_volume from mig_segregado_trabalho
update mig_segregado_trabalho set tipo_volume = 'PALLET PADRAO' where tipo_volume like '%PALETE%'

select DISTINCT classificacao_endereco from mig_segregado_trabalho
update mig_segregado_trabalho set classificacao_endereco = 'NORMAL' 



--FIM AJUSTES


--ATENCAO AQUI--NAO PODE RETORNAR NENHUMA LINHA AQUI. SE RETORNAR DEVOLVER A PLANILHA
select * from mig_segregado_trabalho where endereco_completo is null


--INSERÇÕES EM DEFs CASO PRECISE--
--SETOR
insert def_endereco_setor
select distinct setor,2 from mig_segregado_trabalho
where setor not in (select descricao from def_endereco_setor where descricao = setor and id_tipo = 6)

--ACESSO
insert def_tipo_acesso_endereco (descricao, id_tipo_endereco)
select distinct tipo_de_acesso,6 from mig_segregado_trabalho
where  tipo_de_acesso not in 
(select tipo_de_acesso from def_tipo_acesso_endereco where descricao = tipo_de_acesso)


--VOLUME 
-->SOLICITAR REVISAO POSTERIOR NAS QUANTIDADE DE CAIXAS E DIMENSSOES VIA SISTEMA<--
insert def_tipo_volume_endereco
select distinct tipo_volume, 1, 1,1,1,0,null,0,0,0 from mig_segregado_trabalho
where  tipo_volume not in 
(select tipo_volume from def_tipo_volume_endereco where descricao = tipo_volume)

--CLASSIFICACAO
set IDENTITY_INSERT def_lote_classificacao ON
insert INTO def_lote_classificacao (id_lote_classificacao,descricao,le_estoque_segregado,principal,trava_endereco,exporta_estoque,exporta_pedido,classificacao_lote_bloqueado,id_lote_classificacao_rel,classificacao_lote_inexistente,conferencia_nao_cega_inv_entrada,permite_rastreio_nao_realizado,sugere_endereco)
select distinct '6',classificacao_endereco,'0','0',NULL,'0','0','0',NULL,'0','0','1','0' from mig_segregado_trabalho
where  classificacao_endereco not in 
(select dlc.descricao from def_lote_classificacao dlc where dlc.descricao = tipo_de_armazenamento)
set IDENTITY_INSERT def_lote_classificacao OFF
--FIM INSERÇÕES


--DELETE ENDERECO DE FLOW PARA COMEÇAR DO PRIMEIRO NIVEL E ACERTAR O IDENTITY
DELETE endereco
WHERE nivel > 1 and id_def = 5
DECLARE @max_endereco int
set @max_endereco = (select max(id_endereco) from endereco)
DBCC CHECKIDENT (endereco, RESEED, @max_endereco)

---AQUI INICIA A IMPORTACAO DOS ENDERECOS DE FATO--
--NIVEL 2 -
insert endereco(id_def, nivel, endereco, id_pai, qtd_caixa, endereco_completo, id_lote_classificacao, cod_situacao_endereco)
select distinct 5, 2,  m1.LINHA, m2.id_endereco, null, m1.LINHA, dlc.id_lote_classificacao,1
from mig_segregado_trabalho m1, endereco m2, def_lote_classificacao dlc
where  m2.endereco = m1.classificacao
and m1.classificacao_endereco = dlc.descricao
AND NOT EXISTS (SELECT 1 FROM ENDERECO E WHERE E.endereco_completo = m1.LINHA AND ID_DEF = 5 AND NIVEL = 2)
and m2.id_def = 5
and m2.nivel = 1

--NIVEL 3 - XX
insert endereco(id_def, nivel, endereco, id_pai, qtd_caixa, endereco_completo, id_lote_classificacao, cod_situacao_endereco)
select distinct 5, 3, m1.RUA, m2.id_endereco, null, m1.RUA+'.'+m1.LINHA ,dlc.id_lote_classificacao,1
from mig_segregado_trabalho m1, endereco m2, def_lote_classificacao dlc
where m2.endereco_completo = m1.LINHA
and m1.classificacao_endereco = dlc.descricao
AND NOT EXISTS (SELECT 1 FROM ENDERECO E WHERE E.endereco_completo = m1.RUA+'.'+m1.LINHA AND ID_DEF = 5 AND NIVEL = 3)
and m2.id_def = 5
and m2.nivel = 2


order by 3, 4

----NIVEL 4 - XX.XX
--insert endereco(id_def, nivel, endereco, id_pai, qtd_caixa, endereco_completo, id_lote_classificacao, cod_situacao_endereco,
--id_tipo_acesso_endereco, id_tipo_Armazenamento, id_tipo_volume)
--select distinct 5, 4, m1.AREA, m2.id_endereco, null, m1.AREA, dlc.id_lote_classificacao,1,
--dtac.id_tipo_acesso_endereco, dtae.id_tipo_armazenamento_endereco,dtve.id_tipo_volume_endereco
--from mig_segregado_trabalho m1, endereco m2, endereco m3,  def_lote_classificacao dlc, def_tipo_acesso_endereco dtac, 
--def_tipo_volume_endereco dtve, def_tipo_armazenamento_endereco dtae
--where m2.endereco_completo = m1.MODULO 
--and m2.id_pai = M3.id_endereco
--and M3.endereco_completo = m1.LINHA
--and m2.id_def = 5 
--and m2.nivel = 3
--and m1.classificacao_endereco = dlc.descricao
--and DTAC.descricao = M1.tipo_de_acesso 
--and dtve.descricao =  m1.tipo_volume
--and dtae.descricao = m1.tipo_de_armazenamento
--and not exists(select 1 from endereco m11,  endereco m22, endereco m33, endereco m44
--                   where m11.endereco_completo = m1.LINHA+m1.MODULO +m1.AREA
--				   and m11.id_pai = m22.id_endereco
--				   and m22.id_pai = m33.id_endereco
--				   and M33.ENDERECO_COMPLETO = m1.LINHA
--				   and m33.id_pai = m44.id_endereco
--				   and m44.endereco_completo = m1.classificacao) 


----NIVEL 5 - XX.XX.XX
--insert endereco(id_def, nivel, endereco, id_pai, qtd_caixa, endereco_completo, id_lote_classificacao, cod_situacao_endereco,
--id_tipo_acesso_endereco, id_tipo_Armazenamento, id_tipo_volume)
--select distinct 5, 5, m1.MODULO, m2.id_endereco, null, m1.LINHA+'-'+m1.MODULO+'-'+m1.LINHA+'-'+m1.MODULO, 
--dlc.id_lote_classificacao,1,dtac.id_tipo_acesso_endereco, dtae.id_tipo_armazenamento_endereco,dtve.id_tipo_volume_endereco
--from mig_segregado_trabalho m1, endereco m2, endereco m3, endereco m4, def_lote_classificacao dlc, def_tipo_acesso_endereco dtac, 
--def_tipo_volume_endereco dtve, def_tipo_armazenamento_endereco dtae
--where m2.endereco_completo = m1.LINHA+'-'+m1.MODULO+'-'+m1.LINHA
--and m2.id_pai = m4.id_endereco
--and m4.id_pai = M3.id_endereco
--and M3.endereco_completo = m1.LINHA
--and m2.id_def = 5 and m2.nivel = 4
--and m1.classificacao_endereco = dlc.descricao
--and DTAC.descricao = M1.tipo_de_acesso 
--and dtac.id_tipo_endereco = 6 -- SEGREGADO
--and dtve.descricao =  m1.tipo_volume
--and dtae.descricao = m1.tipo_de_armazenamento
--and not exists(select 1 from endereco m11, endereco m55, endereco m22, endereco m33, endereco m44
--                   where m11.endereco_completo = m1.LINHA+'-'+m1.MODULO+'-'+m1.LINHA+'-'+m1.MODULO
--				   and m11.id_pai = m55.id_endereco
--				   and m55.id_pai = m22.id_endereco
--				   and m22.id_pai = m33.id_endereco
--				   and M33.ENDERECO_COMPLETO = m1.LINHA
--				   and m33.id_pai = m44.id_endereco
--				   and m44.endereco_completo = m1.classificacao)

--				   order by 6

-- VALIDA ENDEREÇOS DUPLICADOS
select endereco_completo, count(1)
from mig_segregado_trabalho
group by endereco_completo
having count(1) > 1


--FIM IMPORTACAO DOS ENDERECOS 
				   

--UPDATES ADICIONAIS DEPOIS DE IMPORTADO OS ENDERECOS--		   
UPDATE endereco
   SET  endereco_completo_3D = dbo.getEnderecoCompleto3D(id_endereco),
	   id_endereco_completo = dbo.getEnderecoCompletoID(id_endereco),
	   id_endereco_div = dbo.GetEnderecoDivID(id_endereco)
	   WHERE id_def = 5

UPDATE E
   SET E.endereco_completo_pai = PAI.endereco_completo
  FROM endereco E INNER JOIN
       endereco PAI ON PAI.id_endereco = E.id_pai
	   WHERE e.id_def = 5

UPDATE endereco
   SET  GetEnderecoPaiNivel = dbo.GetEnderecoPaiNivel(id_endereco,nivel)   
	   WHERE id_def = 5

UPDATE e set
e.id_def_endereco_setor = def.id_def_endereco_setor
--SELECT * 
from endereco e
inner join mig_segregado_trabalho m1 on e.endereco_completo = m1.endereco_completo
inner join def_endereco_setor def on def.descricao = m1.setor
where e.id_def = 5 and def.id_tipo = 6--SEGREGADO

--FIM UPDATES ADICIONAIS


/*
Validacoes

 SELECT count(1) as enderecos_a_migrar from mig_segregado_trabalho
 SELECT count(1) as enderecos_migrados from endereco where id_def = 5 and nivel = (select max(nivel) from def_endereco where id_def = 5)

  SELECT * FROM endereco WHERE id_def = 5 AND nivel = (select max(nivel) from def_endereco where id_def = 5)
 and id_tipo_Armazenamento is  null
 
 SELECT * FROM endereco WHERE id_def = 5 AND nivel = (select max(nivel) from def_endereco where id_def = 5)
 and id_tipo_acesso_endereco is  null
  
 SELECT * FROM endereco WHERE id_def = 5 AND nivel = (select max(nivel) from def_endereco where id_def = 5)
 and id_def_endereco_setor is  null
   
 SELECT * FROM endereco WHERE id_def = 5 AND nivel = (select max(nivel) from def_endereco where id_def = 5)
 and id_tipo_volume is  null
  
*/
 

