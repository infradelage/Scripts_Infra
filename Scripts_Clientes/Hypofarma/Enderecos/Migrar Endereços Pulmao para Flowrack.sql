-- CRIA A OL
insert endereco(id_def, nivel, endereco, id_pai, qtd_caixa, endereco_completo, id_lote_classificacao, cod_situacao_endereco)
select distinct 2, 2,'FILIAL GV', m2.id_endereco, null, 'FILIAL GV', dlc.id_lote_classificacao,1
from mig_flowrack_trabalho m1, endereco m2, def_lote_classificacao dlc
where  m2.endereco = 'FLOWRACK'
and 'FLOWRACK' = dlc.descricao
AND NOT EXISTS (SELECT 1 FROM ENDERECO E WHERE E.endereco_completo = m1.OL AND ID_DEF = 2 AND NIVEL = 2)
and m2.id_def = 2
and m2.nivel = 1

--CRIA O SETOR
insert endereco(id_def, nivel, endereco, id_pai, qtd_caixa, endereco_completo, id_lote_classificacao, cod_situacao_endereco)
select distinct  2, 3, 'PRODUTO ACABADO', m2.id_endereco, null, 'PRODUTO ACABADO',dlc.id_lote_classificacao,1
from endereco m2, def_lote_classificacao dlc
where m2.endereco_completo = 'FILIAL GV'
and 'FLOWRACK' = dlc.descricao
AND NOT EXISTS (SELECT 1 FROM ENDERECO E WHERE E.endereco_completo = 'FLOWRACK' AND ID_DEF = 2 AND NIVEL = 3)
and m2.id_def = 2
and m2.nivel = 2

-- CRIA A RUA
insert endereco(id_def, nivel, endereco, id_pai, qtd_caixa, endereco_completo, id_lote_classificacao, cod_situacao_endereco,
id_tipo_acesso_endereco, id_tipo_Armazenamento, id_tipo_volume)
select distinct 2, 4, '02', m2.id_endereco, null, '02' , dlc.id_lote_classificacao,1,
NULL, NULL, null
from mig_flowrack_trabalho m1, endereco m2, endereco m3, def_lote_classificacao dlc 
where m2.endereco_completo = 'PRODUTO ACABADO'
and m2.id_pai = M3.id_endereco
and M3.endereco = 'FILIAL GV'
and m2.id_def = 2 
and m2.nivel = 3
and 'FLOWRACK' = dlc.descricao
and not exists(select 1 from endereco m11
				where id_def = 2 and nivel = 4
				and endereco_completo = '02' ) 


--CRIA O LADO
insert endereco(id_def, nivel, endereco, id_pai, qtd_caixa, endereco_completo, id_lote_classificacao, cod_situacao_endereco,
id_tipo_acesso_endereco, id_tipo_Armazenamento, id_tipo_volume)
select distinct 2, 5, '1', m2.id_endereco, null, '02' + '.' + '1', 
dlc.id_lote_classificacao,1,null,null,null
--dtac.id_tipo_acesso_endereco, dtae.id_tipo_armazenamento_endereco,null--dtve.id_tipo_volume_endereco
from mig_flowrack_trabalho m1, endereco m2, endereco m3, endereco m4, def_lote_classificacao dlc, def_tipo_acesso_endereco dtac, 
def_tipo_volume_endereco dtve, def_tipo_armazenamento_endereco dtae
where m2.endereco_completo = '02'
and m2.id_pai = m4.id_endereco
and m4.id_pai = M3.id_endereco
and M3.endereco = 'FILIAL GV'
and m2.id_def = 2 and m2.nivel = 4
and 'FLOWRACK' = dlc.descricao
and not exists(select 1 from endereco m11, endereco m55, endereco m22, endereco m33, endereco m44
                   where m11.endereco_completo = '02' + '.' + '1'
				   and m11.id_pai = m55.id_endereco
				   and m55.id_pai = m22.id_endereco
				   and m22.id_pai = m33.id_endereco
				   and M33.ENDERECO_COMPLETO = 'PRODUTO ACABADO'
				   and m33.id_pai = m44.id_endereco
				   and m44.endereco_completo = m1.CLASSIFICACAO)


-- CRIA OS PREDIOS
insert endereco(id_def, nivel, endereco, id_pai, qtd_caixa, endereco_completo, id_lote_classificacao, cod_situacao_endereco,
id_tipo_acesso_endereco, id_tipo_Armazenamento, id_tipo_volume)
select distinct 2, 6, '01', m2.id_endereco, null, '02' + '.' + '1' + '01',dlc.id_lote_classificacao,1,null,null,null
--,dtac.id_tipo_acesso_endereco, dtae.id_tipo_armazenamento_endereco,null--dtve.id_tipo_volume_endereco
from  endereco m2, endereco m3,endereco m5, endereco m4, def_lote_classificacao dlc, def_tipo_acesso_endereco dtac, 
def_tipo_volume_endereco dtve, def_tipo_armazenamento_endereco dtae
where m2.endereco_completo = '02' + '.' + '1'
and m2.id_pai = m4.id_endereco
and m4.id_pai = m5.id_endereco
and m5.id_pai = M3.id_endereco
and M3.endereco_completo = 'FILIAL GV'
and m2.id_def = 2 and m2.nivel = 5
and 'FLOWRACK' = dlc.descricao

insert endereco(id_def, nivel, endereco, id_pai, qtd_caixa, endereco_completo, id_lote_classificacao, cod_situacao_endereco,
id_tipo_acesso_endereco, id_tipo_Armazenamento, id_tipo_volume)
select distinct 2, 6, '03', m2.id_endereco, null, '02' + '.' + '1' + '03',dlc.id_lote_classificacao,1,null,null,null
--,dtac.id_tipo_acesso_endereco, dtae.id_tipo_armazenamento_endereco,null--dtve.id_tipo_volume_endereco
from  endereco m2, endereco m3,endereco m5, endereco m4, def_lote_classificacao dlc, def_tipo_acesso_endereco dtac, 
def_tipo_volume_endereco dtve, def_tipo_armazenamento_endereco dtae
where m2.endereco_completo = '02' + '.' + '1'
and m2.id_pai = m4.id_endereco
and m4.id_pai = m5.id_endereco
and m5.id_pai = M3.id_endereco
and M3.endereco_completo = 'FILIAL GV'
and m2.id_def = 2 and m2.nivel = 5
and 'FLOWRACK' = dlc.descricao

insert endereco(id_def, nivel, endereco, id_pai, qtd_caixa, endereco_completo, id_lote_classificacao, cod_situacao_endereco,
id_tipo_acesso_endereco, id_tipo_Armazenamento, id_tipo_volume)
select distinct 2, 6, '05', m2.id_endereco, null, '02' + '.' + '1' + '05',dlc.id_lote_classificacao,1,null,null,null
--,dtac.id_tipo_acesso_endereco, dtae.id_tipo_armazenamento_endereco,null--dtve.id_tipo_volume_endereco
from  endereco m2, endereco m3,endereco m5, endereco m4, def_lote_classificacao dlc, def_tipo_acesso_endereco dtac, 
def_tipo_volume_endereco dtve, def_tipo_armazenamento_endereco dtae
where m2.endereco_completo = '02' + '.' + '1'
and m2.id_pai = m4.id_endereco
and m4.id_pai = m5.id_endereco
and m5.id_pai = M3.id_endereco
and M3.endereco_completo = 'FILIAL GV'
and m2.id_def = 2 and m2.nivel = 5
and 'FLOWRACK' = dlc.descricao

insert endereco(id_def, nivel, endereco, id_pai, qtd_caixa, endereco_completo, id_lote_classificacao, cod_situacao_endereco,
id_tipo_acesso_endereco, id_tipo_Armazenamento, id_tipo_volume)
select distinct 2, 6, '07', m2.id_endereco, null, '02' + '.' + '1' + '07',dlc.id_lote_classificacao,1,null,null,null
--,dtac.id_tipo_acesso_endereco, dtae.id_tipo_armazenamento_endereco,null--dtve.id_tipo_volume_endereco
from  endereco m2, endereco m3,endereco m5, endereco m4, def_lote_classificacao dlc, def_tipo_acesso_endereco dtac, 
def_tipo_volume_endereco dtve, def_tipo_armazenamento_endereco dtae
where m2.endereco_completo = '02' + '.' + '1'
and m2.id_pai = m4.id_endereco
and m4.id_pai = m5.id_endereco
and m5.id_pai = M3.id_endereco
and M3.endereco_completo = 'FILIAL GV'
and m2.id_def = 2 and m2.nivel = 5
and 'FLOWRACK' = dlc.descricao

insert endereco(id_def, nivel, endereco, id_pai, qtd_caixa, endereco_completo, id_lote_classificacao, cod_situacao_endereco,
id_tipo_acesso_endereco, id_tipo_Armazenamento, id_tipo_volume)
select distinct 2, 6, '09', m2.id_endereco, null, '02' + '.' + '1' + '09',dlc.id_lote_classificacao,1,null,null,null
--,dtac.id_tipo_acesso_endereco, dtae.id_tipo_armazenamento_endereco,null--dtve.id_tipo_volume_endereco
from  endereco m2, endereco m3,endereco m5, endereco m4, def_lote_classificacao dlc, def_tipo_acesso_endereco dtac, 
def_tipo_volume_endereco dtve, def_tipo_armazenamento_endereco dtae
where m2.endereco_completo = '02' + '.' + '1'
and m2.id_pai = m4.id_endereco
and m4.id_pai = m5.id_endereco
and m5.id_pai = M3.id_endereco
and M3.endereco_completo = 'FILIAL GV'
and m2.id_def = 2 and m2.nivel = 5
and 'FLOWRACK' = dlc.descricao

insert endereco(id_def, nivel, endereco, id_pai, qtd_caixa, endereco_completo, id_lote_classificacao, cod_situacao_endereco,
id_tipo_acesso_endereco, id_tipo_Armazenamento, id_tipo_volume)
select distinct 2, 6, '11', m2.id_endereco, null, '02' + '.' + '1' + '11',dlc.id_lote_classificacao,1,null,null,null
--,dtac.id_tipo_acesso_endereco, dtae.id_tipo_armazenamento_endereco,null--dtve.id_tipo_volume_endereco
from  endereco m2, endereco m3,endereco m5, endereco m4, def_lote_classificacao dlc, def_tipo_acesso_endereco dtac, 
def_tipo_volume_endereco dtve, def_tipo_armazenamento_endereco dtae
where m2.endereco_completo = '02' + '.' + '1'
and m2.id_pai = m4.id_endereco
and m4.id_pai = m5.id_endereco
and m5.id_pai = M3.id_endereco
and M3.endereco_completo = 'FILIAL GV'
and m2.id_def = 2 and m2.nivel = 5
and 'FLOWRACK' = dlc.descricao

insert endereco(id_def, nivel, endereco, id_pai, qtd_caixa, endereco_completo, id_lote_classificacao, cod_situacao_endereco,
id_tipo_acesso_endereco, id_tipo_Armazenamento, id_tipo_volume)
select distinct 2, 6, '13', m2.id_endereco, null, '02' + '.' + '1' + '13',dlc.id_lote_classificacao,1,null,null,null
--,dtac.id_tipo_acesso_endereco, dtae.id_tipo_armazenamento_endereco,null--dtve.id_tipo_volume_endereco
from  endereco m2, endereco m3,endereco m5, endereco m4, def_lote_classificacao dlc, def_tipo_acesso_endereco dtac, 
def_tipo_volume_endereco dtve, def_tipo_armazenamento_endereco dtae
where m2.endereco_completo = '02' + '.' + '1'
and m2.id_pai = m4.id_endereco
and m4.id_pai = m5.id_endereco
and m5.id_pai = M3.id_endereco
and M3.endereco_completo = 'FILIAL GV'
and m2.id_def = 2 and m2.nivel = 5
and 'FLOWRACK' = dlc.descricao


insert endereco(id_def, nivel, endereco, id_pai, qtd_caixa, endereco_completo, id_lote_classificacao, cod_situacao_endereco,
id_tipo_acesso_endereco, id_tipo_Armazenamento, id_tipo_volume)
select distinct 2, 6, '15', m2.id_endereco, null, '02' + '.' + '1' + '15',dlc.id_lote_classificacao,1,null,null,null
--,dtac.id_tipo_acesso_endereco, dtae.id_tipo_armazenamento_endereco,null--dtve.id_tipo_volume_endereco
from  endereco m2, endereco m3,endereco m5, endereco m4, def_lote_classificacao dlc, def_tipo_acesso_endereco dtac, 
def_tipo_volume_endereco dtve, def_tipo_armazenamento_endereco dtae
where m2.endereco_completo = '02' + '.' + '1'
and m2.id_pai = m4.id_endereco
and m4.id_pai = m5.id_endereco
and m5.id_pai = M3.id_endereco
and M3.endereco_completo = 'FILIAL GV'
and m2.id_def = 2 and m2.nivel = 5
and 'FLOWRACK' = dlc.descricao


--UPDATE COMPLEMENTAR
UPDATE endereco
   SET  endereco_completo_3D = dbo.getEnderecoCompleto3D(id_endereco),
	   id_endereco_completo = dbo.getEnderecoCompletoID(id_endereco),
	   id_endereco_div = dbo.GetEnderecoDivID(id_endereco),
	   endereco_completo = dbo.getEnderecoCompleto(id_endereco)
	   where id_def = 2 and id_endereco >= 8360

UPDATE E
   SET E.endereco_completo_pai = PAI.endereco_completo
  FROM endereco E INNER JOIN
       endereco PAI ON PAI.id_endereco = E.id_pai
		where e.id_def = 2 and e.id_endereco >= 8360

UPDATE endereco
   SET  GetEnderecoPaiNivel = dbo.GetEnderecoPaiNivel(id_endereco,nivel)   
   	   where id_def = 2 and id_endereco >= 8360

-- AJUSTE NOS ENDEREÇOS COMPLETOS 3D QUE FORAM MIGRADOS
UPDATE endereco
   SET  endereco_completo_3D = dbo.getEnderecoCompleto3D(id_endereco),
	   id_endereco_completo = dbo.getEnderecoCompletoID(id_endereco),
	   id_endereco_div = dbo.GetEnderecoDivID(id_endereco),
	   endereco_completo = dbo.getEnderecoCompleto(id_endereco)
	   where id_def = 2 and id_endereco in (3979,4021,4063,4105,4147,4182,4217,4254)

UPDATE E
   SET E.endereco_completo_pai = PAI.endereco_completo
  FROM endereco E INNER JOIN
       endereco PAI ON PAI.id_endereco = E.id_pai
		where e.id_def = 2 and e.id_endereco in (3979,4021,4063,4105,4147,4182,4217,4254)

UPDATE endereco
   SET  GetEnderecoPaiNivel = dbo.GetEnderecoPaiNivel(id_endereco,nivel)   
   	   where id_def = 2 and id_endereco in (3979,4021,4063,4105,4147,4182,4217,4254)


-- MOVE O NIVEIS PARA O NOVO ID_PAI
SELECT e.id_endereco, e.id_pai,e.endereco_completo,vw.id_lote,vw.estoque FROM ENDERECO e
--inner  JOIN vw_lote_estoque vw on vw.id_endereco = e.id_endereco 
LEFT  JOIN vw_lote_estoque vw on vw.id_endereco = e.id_endereco 
where e.endereco_completo in ('02.01.01','02.03.01','02.05.01','02.07.01','02.09.01','02.11.01','02.13.01','02.15.01')

--select * from endereco where endereco_completo in ('02.01.01','02.03.01','02.05.01','02.07.01','02.09.01','02.11.01','02.13.01','02.15.01')

-- ALTERA OS ENDEREÇOS QUE FORAM MIGRADOS DE PULMAO PARA FLOWRACK
UPDATE ENDERECO set id_def = 2 where endereco_completo in ('02.01.01','02.03.01','02.05.01','02.07.01','02.09.01','02.11.01','02.13.01','02.15.01')

UPDATE ENDERECO SET ID_PAI = 8364 WHERE id_endereco IN (3979) --01
UPDATE ENDERECO SET ID_PAI = 8365 WHERE id_endereco IN (4021) --03
UPDATE ENDERECO SET ID_PAI = 8366 WHERE id_endereco IN (4063) --05
UPDATE ENDERECO SET ID_PAI = 8367 WHERE id_endereco IN (4105) --07
UPDATE ENDERECO SET ID_PAI = 8368 WHERE id_endereco IN (4147) --09
UPDATE ENDERECO SET ID_PAI = 8369 WHERE id_endereco IN (4182) --11
UPDATE ENDERECO SET ID_PAI = 8370 WHERE id_endereco IN (4217) --13
UPDATE ENDERECO SET ID_PAI = 8371 WHERE id_endereco IN (4254) --15

--classificacao = Normal
--Acesso = A pé flowrack
--Volume Pallet Padrão
--Armazenamento = Flowrack

UPDATE ENDERECO SET 
id_lote_classificacao = 1,
id_tipo_acesso_endereco = 6,
id_tipo_volume = 9,
id_tipo_Armazenamento = 1
,id_def_endereco_setor = 119
where endereco_completo in ('02.01.01','02.03.01','02.05.01','02.07.01','02.09.01','02.11.01','02.13.01','02.15.01')

