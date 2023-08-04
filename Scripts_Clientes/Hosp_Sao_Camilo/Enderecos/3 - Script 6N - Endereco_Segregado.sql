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
SELECT 5, 2, 'OL', 6, 0, NULL, NULL, NULL, 0, 0 UNION
SELECT 5, 3, 'SETOR', 6, 0, NULL, NULL, NULL, 1, 0 UNION
SELECT 5, 4, 'RUA', 6, 0, NULL, NULL, NULL, 0, 0 --UNION
--SELECT 5, 5, 'BLOCO', 6, 0, NULL, NULL, '.', 1, 0 UNION
--SELECT 5, 6, 'NIVEL', 6, 0, NULL, NULL, null, 1, 0 --UNION
--SELECT 5, 7, 'POSICAO', 6, 0, NULL, NULL, NULL, 1, 0 

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
--INSERT INTO def_tipo_acesso_endereco VALUES ('A PÉ (SEGREGADO)','0.00',6)
--DELETE FROM def_tipo_acesso_endereco where id_tipo_acesso_endereco = 13

select distinct tipo_de_acesso from mig_segregado_trabalho
update mig_segregado_trabalho set tipo_de_acesso = 'A PÉ (SEGREGADO)' where tipo_de_acesso like '%A PÉ%'
update mig_segregado_trabalho set tipo_de_acesso = 'ESCADA (SEGREGADO)' where tipo_de_acesso like '%ESCADA%'
update mig_segregado_trabalho set tipo_de_acesso = 'EMPILHADEIRA (SEGREGADO)' where tipo_de_acesso like '%EMPILHADEIRA%'

select distinct classificacao_endereco from mig_segregado_trabalho
update mig_segregado_trabalho set classificacao_endereco = 'NORMAL' 

select distinct setor from mig_segregado_trabalho
update mig_segregado_trabalho set setor = 'ALMOXARIFADO' where setor like '%Almoxarifado%'
update mig_segregado_trabalho set setor = 'EMBALAGEM/SEMI ACABADO' where setor like '%Embalagem/Semi Acabado%'
update mig_segregado_trabalho set setor = 'PRODUÇÃO' where setor like '%Produção%'
update mig_segregado_trabalho set setor = 'PRODUTO ACABADO' where setor like '%Produto Acabado%'
update mig_segregado_trabalho set setor = 'DEVOLUCAO' where setor like '%DEVOLUÇÃO%'


select DISTINCT tipo_volume from mig_segregado_trabalho
update mig_segregado_trabalho set tipo_volume = 'PALLET PADRAO' where tipo_volume like '%PALETE%'
update mig_segregado_trabalho set tipo_volume = 'CAIXA' where tipo_volume like 'Caixa'

select DISTINCT classificacao from mig_segregado_trabalho
update mig_segregado_trabalho set classificacao = 'SEGREGADO' where classificacao like '%SEGREGADO%'
--FIM AJUSTES


--ATENCAO AQUI--NAO PODE RETORNAR NENHUMA LINHA AQUI. SE RETORNAR DEVOLVER A PLANILHA
select * from mig_segregado_trabalho where endereco_completo is null


--INSERÇÕES EM DEFs CASO PRECISE--
--SETOR
insert def_endereco_setor
select distinct setor,6 from mig_segregado_trabalho
where setor NOT in (select descricao from def_endereco_setor where descricao = setor and id_tipo = 6)

--ACESSO
insert def_tipo_acesso_endereco (descricao, id_tipo_endereco)
select distinct tipo_de_acesso,6 from mig_segregado_trabalho
where  tipo_de_acesso not in 
(select tipo_de_acesso from def_tipo_acesso_endereco where descricao = tipo_de_acesso)


--VOLUME 
-->SOLICITAR REVISAO POSTERIOR NAS QUANTIDADE DE CAIXAS E DIMENSSOES VIA SISTEMA<--
insert def_tipo_volume_endereco
select distinct UPPER(tipo_volume), 1, 1,1,1,0,null,0,0,0,null from mig_segregado_trabalho
where  tipo_volume not in 
(select tipo_volume from def_tipo_volume_endereco where descricao = tipo_volume)
--FIM INSERÇÕES


--DELETE ENDERECO DE FLOW PARA COMEÇAR DO PRIMEIRO NIVEL E ACERTAR O IDENTITY
DELETE endereco
WHERE nivel > 1 and id_def = 5 --and id_endereco > 8148
DECLARE @max_endereco int
set @max_endereco = (select max(id_endereco) from endereco)
DBCC CHECKIDENT (endereco, RESEED, @max_endereco)

---AQUI INICIA A IMPORTACAO DOS ENDERECOS DE FATO--
--NIVEL 2 -
insert endereco(id_def, nivel, endereco, id_pai, qtd_caixa, endereco_completo, id_lote_classificacao, cod_situacao_endereco)
select distinct 5, 2,  m1.OL, m2.id_endereco, null, m1.OL, dlc.id_lote_classificacao,1
from mig_segregado_trabalho m1, endereco m2, def_lote_classificacao dlc
where  m2.endereco = m1.classificacao
and m1.classificacao = dlc.descricao
AND NOT EXISTS (SELECT 1 FROM ENDERECO E WHERE E.endereco = m1.OL AND ID_DEF = 5 AND NIVEL = 2)
and m2.id_def = 5
and m2.nivel = 1

--NIVEL 3 - XX
insert endereco(id_def, nivel, endereco, id_pai, qtd_caixa, endereco_completo, id_lote_classificacao, cod_situacao_endereco)
select distinct 5, 3, m1.SETOR, m2.id_endereco, null, m1.OL+m1.SETOR ,dlc.id_lote_classificacao,1
from mig_segregado_trabalho m1, endereco m2, def_lote_classificacao dlc
where m2.endereco_completo = m1.OL
and m1.classificacao_endereco = dlc.descricao
AND NOT EXISTS (SELECT 1 FROM ENDERECO E WHERE E.endereco= m1.OL+m1.SETOR AND ID_DEF = 5 AND NIVEL = 3)
and m2.id_def = 5
and m2.nivel = 2


order by 3, 4

--NIVEL 4 - XX.XX
insert endereco(id_def, nivel, endereco, id_pai, qtd_caixa, endereco_completo, id_lote_classificacao, cod_situacao_endereco,
id_tipo_acesso_endereco, id_tipo_Armazenamento, id_tipo_volume)
select distinct 5, 4, m1.RUA, m2.id_endereco, null, m1.OL+m1.SETOR+'.'+m1.RUA, dlc.id_lote_classificacao,1,--null,null,null
dtac.id_tipo_acesso_endereco, dtae.id_tipo_armazenamento_endereco,dtve.id_tipo_volume_endereco
from mig_segregado_trabalho m1, endereco m2, endereco m3,  def_lote_classificacao dlc, def_tipo_acesso_endereco dtac, 
def_tipo_volume_endereco dtve, def_tipo_armazenamento_endereco dtae
where m2.endereco_completo = m1.OL+m1.SETOR 
and m2.id_pai = M3.id_endereco
and M3.endereco_completo = m1.OL
and m2.id_def = 5 
and m2.nivel = 3
and m1.classificacao_endereco = dlc.descricao
and DTAC.descricao = M1.tipo_de_acesso 
--and dtac.id_tipo_endereco = 6 -- SEGREGADO
and dtve.descricao =  m1.tipo_volume
and dtae.descricao = m1.tipo_de_armazenamento
and not exists(select 1 from endereco m11,  endereco m22, endereco m33, endereco m44
                   where m11.endereco = m1.OL+m1.SETOR+'.'+m1.RUA
				   and m11.id_pai = m22.id_endereco
				   and m22.id_pai = m33.id_endereco
				   and M33.ENDERECO_COMPLETO = m1.OL
				   and m33.id_pai = m44.id_endereco
				   and m44.endereco_completo = m1.classificacao) 


----NIVEL 5 - XX.XX.XX
--insert endereco(id_def, nivel, endereco, id_pai, qtd_caixa, endereco_completo, id_lote_classificacao, cod_situacao_endereco,
--id_tipo_acesso_endereco, id_tipo_Armazenamento, id_tipo_volume)
--select distinct 5, 5, m1.BLOCO, m2.id_endereco, null, m1.SETOR+'.'+m1.RUA+'.'+m1.BLOCO, 
--dlc.id_lote_classificacao,1,null,null,null--dtac.id_tipo_acesso_endereco, dtae.id_tipo_armazenamento_endereco,dtve.id_tipo_volume_endereco
--from mig_segregado_trabalho m1, endereco m2, endereco m3, endereco m4, def_lote_classificacao dlc, def_tipo_acesso_endereco dtac, 
--def_tipo_volume_endereco dtve, def_tipo_armazenamento_endereco dtae
--where m2.endereco_completo = m1.OL+m1.SETOR+'.'+m1.RUA
--and m2.id_pai = m4.id_endereco
--and m4.id_pai = M3.id_endereco
--and M3.endereco_completo = m1.OL
--and m2.id_def = 5 and m2.nivel = 4
--and m1.classificacao_endereco = dlc.descricao
----and DTAC.descricao = M1.tipo_de_acesso 
----and dtac.id_tipo_endereco = 6 -- SEGREGADO
----and dtve.descricao =  m1.tipo_volume
----and dtae.descricao = m1.tipo_de_armazenamento
--and not exists(select 1 from endereco m11, endereco m55, endereco m22, endereco m33, endereco m44
--                   where m11.endereco = m1.OL+m1.SETOR+'.'+m1.RUA+'.'+m1.BLOCO
--				   and m11.id_pai = m55.id_endereco
--				   and m55.id_pai = m22.id_endereco
--				   and m22.id_pai = m33.id_endereco
--				   and M33.ENDERECO_COMPLETO = m1.OL
--				   and m33.id_pai = m44.id_endereco
--				   and m44.endereco_completo = m1.classificacao)

--				   order by 6

----NIVEL 6 - XX.XX.XX
--insert endereco(id_def, nivel, endereco, id_pai, qtd_caixa, endereco_completo, id_lote_classificacao, cod_situacao_endereco,
--id_tipo_acesso_endereco, id_tipo_Armazenamento, id_tipo_volume)
--select distinct 5, 6, m1.NIVEL, m2.id_endereco, null,m1.SETOR+'.'+m1.RUA+'.'+m1.BLOCO+'.'+m1.NIVEL, 
--dlc.id_lote_classificacao,1,dtac.id_tipo_acesso_endereco, dtae.id_tipo_armazenamento_endereco,dtve.id_tipo_volume_endereco
--from mig_segregado_trabalho m1, endereco m2, endereco m3, endereco m5, endereco m4, def_lote_classificacao dlc, def_tipo_acesso_endereco dtac, 
--def_tipo_volume_endereco dtve, def_tipo_armazenamento_endereco dtae
--where m2.endereco_completo = m1.SETOR+'.'+m1.RUA+'.'+m1.BLOCO
--and m2.id_pai = m4.id_endereco
--and m4.id_pai = m5.id_endereco
--and m5.id_pai = M3.id_endereco
--and M3.endereco_completo = m1.OL
--and m2.id_def = 5 and m2.nivel = 5
--and m1.classificacao_endereco = dlc.descricao
--and DTAC.descricao = M1.tipo_de_acesso 
--and dtac.id_tipo_endereco = 6 -- SEGREGADO
--and dtve.descricao =  m1.tipo_volume
--and dtae.descricao = m1.tipo_de_armazenamento
--and not exists(select 1 from endereco m11, endereco m12, endereco m55, endereco m22, endereco m33, endereco m44
--                   where m11.endereco_completo = m1.OL+m1.SETOR+'.'+m1.RUA+'.'+m1.BLOCO+'.'+m1.NIVEL
--				   and m11.id_pai = m12.id_endereco
--				   and m12.id_pai = m55.id_endereco
--				   and m55.id_pai = m22.id_endereco
--				   and m22.id_pai = m33.id_endereco
--				   and M33.ENDERECO_COMPLETO = m1.OL
--				   and m33.id_pai = m44.id_endereco
--				   and m44.endereco_completo = m1.classificacao)



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
	   id_endereco_div = dbo.GetEnderecoDivID(id_endereco),
	   endereco_completo = dbo.getEnderecoCompleto(id_endereco)
WHERE id_def = 5 and id_endereco >= 59579

UPDATE E
   SET E.endereco_completo_pai = PAI.endereco_completo
  FROM endereco E INNER JOIN
       endereco PAI ON PAI.id_endereco = E.id_pai
WHERE e.id_def = 5 and e.id_endereco >= 59579

UPDATE endereco
   SET  GetEnderecoPaiNivel = dbo.GetEnderecoPaiNivel(id_endereco,nivel)   
WHERE id_def = 5 and id_endereco >= 59579

UPDATE e set
e.id_def_endereco_setor = def.id_def_endereco_setor
--SELECT * 
from endereco e
inner join mig_segregado_trabalho m1 on e.endereco_completo = m1.endereco_completo
inner join def_endereco_setor def on def.descricao = m1.setor
where e.id_def = 5 and def.id_tipo = 6 and id_endereco >= 59579
--AND e.nivel = 4 


--FIM UPDATES ADICIONAIS


/*
Validacoes

 SELECT count(1) as enderecos_a_migrar from mig_segregado_trabalho
 SELECT count(1) as enderecos_migrados from endereco where id_def = 5 and nivel =  (select max(nivel) from def_endereco where id_def = 5)

  SELECT * FROM endereco WHERE id_def = 5 AND nivel = (select max(nivel) from def_endereco where id_def = 5)
 and id_tipo_Armazenamento is  null
 
 SELECT * FROM endereco WHERE id_def = 5 AND nivel = (select max(nivel) from def_endereco where id_def = 5)
 and id_tipo_acesso_endereco is  null
  
 SELECT * FROM endereco WHERE id_def = 5 AND nivel = (select max(nivel) from def_endereco where id_def = 5)
 and id_def_endereco_setor is  null
   
 SELECT * FROM endereco WHERE id_def = 5 AND nivel = (select max(nivel) from def_endereco where id_def = 5)
 and id_tipo_volume is  null
  
*/
 

