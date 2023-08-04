/*-------------------------------------------------------------------
-												 -
-- CRIAÇÃO DA ARVORE DE ENDEREÇO - COLMEIA - COM 3 NIVEIS FINAIS	-
-																	-
--					XX.XXX											-	
--                  11.011											-
-- 11	- ESTACAO													-
-- 0	- NIVEL														-
-- 11	- POSICAO													-
--																	-
-------------------------------------------------------------------*/

 

-- REDEFINE NIVEIS DE ENDEREÇAMENTO
ALTER TABLE endereco NOCHECK CONSTRAINT ALL

DELETE def_endereco where id_def = 18 and nivel > 1

INSERT def_endereco(id_def, nivel, descricao, id_tipo, divide_volume, validacao, msgerro, separador, compoe_endereco, endereco_movel)
-- COLMEIA
--SELECT 18, 1, 'CLASSIF.', 12, 0, NULL, NULL, NULL, 0, 0 UNION
SELECT 18, 2, 'COLMEIA', 12, 1, NULL, NULL, NULL, 0, 0 UNION
SELECT 18, 3, 'COLUNA', 12, 0, NULL, NULL, NULL, 0, 0 UNION
SELECT 18, 4, 'ESCANINHO', 12, 0, NULL, NULL, NULL, 1, 0 
 

ALTER TABLE endereco CHECK CONSTRAINT ALL
GO
 
-- INSERIR ENDERECO NIVEL SEPARACAO(COLMEIA), CASO O NIVEL NÃO EXISTA NA TABELA ENDRECO
--insert endereco (id_def, nivel, endereco, endereco_completo, id_lote_classificacao, permite_inventario, id_tipo_Armazenamento, cod_situacao_endereco)
--select 18,1,'SEPARACAO', 'SEPARACAO', 2,1,1,12,1

-- VALIDAR ocampo id_tipo data tabela def_endereco deve ser o mesmo do campo id_tipo_colmeia da tabela param_def_tipo_endereco
--  Caso seja diferente fazer o update para que o campo id_tipo_colmeia fique igual ao id_tipo
select id_tipo_colmeia,* from param_def_tipo_endereco
SELECT * FROM def_endereco WHERE id_def = 17


--DELETE A PARTIR DO ULTIMO id_endereco ENDERECO PARA COMEÇAR DO PRIMEIRO NIVEL E ACERTAR O IDENTITY
DELETE endereco
WHERE id_endereco > 'Ultimo_id_endereco'
DECLARE @max_endereco int
set @max_endereco = (select max(id_endereco) from endereco)
DBCC CHECKIDENT (endereco, RESEED, @max_endereco)

delete entidade_endereco_colmeia
--begin tran anna

--rollback tran anna

--commit tran anna

------------------------------------ COLMEIA 01 ---------------------------------------------

------------------------------------ Estrutura linha ----------------------------------------
DECLARE @id_lote_classificacao INT
DECLARE @id_pai INT 

INSERT endereco (id_def, nivel, endereco, id_pai,qtd_caixa, endereco_completo, id_lote_classificacao, permite_inventario,refugo) 
SELECT 18,2,'01',23559,null,'01',2,-1,0

SELECT @id_pai = @@IDENTITY

INSERT endereco (id_def, nivel, endereco, id_pai,qtd_caixa, endereco_completo, id_lote_classificacao, permite_inventario,refugo) 
SELECT 18,3,'01',@id_pai,null,'01',2,-1,0 UNION
SELECT 18,3,'02',@id_pai,null,'02',2,-1,0 UNION
SELECT 18,3,'03',@id_pai,null,'03',2,-1,0 UNION
SELECT 18,3,'04',@id_pai,null,'04',2,-1,0 

------------------------------------ Fim Estrutura linha ------------------------------------

------------------------------------ Estrutura Coluna 01 ----------------------------------------
SELECT @id_pai = id_endereco
FROM endereco
WHERE endereco_completo = '01'
AND id_def = 18
AND nivel = 3
--SELECT * FROM DEF_ENDERECO
INSERT endereco (id_def, nivel, endereco, id_pai,qtd_caixa, endereco_completo, id_lote_classificacao, permite_inventario,refugo) 
SELECT 18,4,'01',@id_pai,null,'01',2,-1,0 UNION
SELECT 18,4,'05',@id_pai,null,'05',2,-1,0 UNION
SELECT 18,4,'09',@id_pai,null,'09',2,-1,0

------------------------------------ Estrutura Coluna 02 ----------------------------------------
SELECT @id_pai = id_endereco
FROM endereco
WHERE endereco_completo = '02'
AND id_def = 18
AND nivel = 3
--SELECT * FROM DEF_ENDERECO
INSERT endereco (id_def, nivel, endereco, id_pai,qtd_caixa, endereco_completo, id_lote_classificacao, permite_inventario,refugo) 
SELECT 18,4,'02',@id_pai,null,'02',2,-1,0 UNION
SELECT 18,4,'06',@id_pai,null,'06',2,-1,0 UNION
SELECT 18,4,'10',@id_pai,null,'10',2,-1,0 
--SELECT 18,4,'08',@id_pai,null,'08',2,-1,0 

------------------------------------ Estrutura Coluna 03 ----------------------------------------
SELECT @id_pai = id_endereco
FROM endereco
WHERE endereco_completo = '03'
AND id_def = 18
AND nivel = 3
--SELECT * FROM DEF_ENDERECO
INSERT endereco (id_def, nivel, endereco, id_pai,qtd_caixa, endereco_completo, id_lote_classificacao, permite_inventario,refugo) 
SELECT 18,4,'03',@id_pai,null,'03',2,-1,0 UNION
SELECT 18,4,'07',@id_pai,null,'07',2,-1,0 UNION
SELECT 18,4,'11',@id_pai,null,'11',2,-1,0 
--SELECT 18,4,'12',@id_pai,null,'12',2,-1,0 

------------------------------------ Estrutura Coluna 04 ----------------------------------------
SELECT @id_pai = id_endereco
FROM endereco
WHERE endereco_completo = '04'
AND id_def = 18
AND nivel = 3
--SELECT * FROM DEF_ENDERECO
INSERT endereco (id_def, nivel, endereco, id_pai,qtd_caixa, endereco_completo, id_lote_classificacao, permite_inventario,refugo) 
SELECT 18,4,'04',@id_pai,null,'04',2,-1,0 UNION
SELECT 18,4,'08',@id_pai,null,'08',2,-1,0 UNION
SELECT 18,4,'12',@id_pai,null,'12',2,-1,0 
--SELECT 18,4,'04',@id_pai,null,'04',2,-1,0 

------------------------------------ FIM Estruturas Colunas ----------------------------------------

------------------------------------ COLMEIA 01 ---------------------------------------------

------------------------------------ Estrutura linha ----------------------------------------

INSERT endereco (id_def, nivel, endereco, id_pai,qtd_caixa, endereco_completo, id_lote_classificacao, permite_inventario,refugo) 
SELECT 18,2,'02',23559,null,'02',2,-1,0

SELECT @id_pai = @@IDENTITY

INSERT endereco (id_def, nivel, endereco, id_pai,qtd_caixa, endereco_completo, id_lote_classificacao, permite_inventario,refugo) 
SELECT 18,3,'01',@id_pai,null,'01',2,-1,0 UNION
SELECT 18,3,'02',@id_pai,null,'02',2,-1,0 UNION
SELECT 18,3,'03',@id_pai,null,'03',2,-1,0 UNION
SELECT 18,3,'04',@id_pai,null,'04',2,-1,0 


------------------------------------ Fim Estrutura linha ------------------------------------

------------------------------------ Estrutura Coluna 01 ----------------------------------------
SELECT @id_pai = id_endereco
FROM endereco
WHERE endereco_completo = '01'
AND id_def = 18
AND nivel = 3
AND id_endereco not in (select id_pai from endereco where id_def = 18 and nivel = 4)
--SELECT * FROM DEF_ENDERECO
INSERT endereco (id_def, nivel, endereco, id_pai,qtd_caixa, endereco_completo, id_lote_classificacao, permite_inventario,refugo) 
SELECT 18,4,'01',@id_pai,null,'01',2,-1,0 UNION
SELECT 18,4,'05',@id_pai,null,'05',2,-1,0 UNION
SELECT 18,4,'09',@id_pai,null,'09',2,-1,0 
--SELECT 18,4,'04',@id_pai,null,'04',2,-1,0 

------------------------------------ Estrutura Coluna 02 ----------------------------------------
SELECT @id_pai = id_endereco
FROM endereco
WHERE endereco_completo = '02'
AND id_def = 18
AND nivel = 3
AND id_endereco not in (select id_pai from endereco where id_def = 18 and nivel = 4)
--SELECT * FROM DEF_ENDERECO
INSERT endereco (id_def, nivel, endereco, id_pai,qtd_caixa, endereco_completo, id_lote_classificacao, permite_inventario,refugo) 
SELECT 18,4,'02',@id_pai,null,'02',2,-1,0 UNION
SELECT 18,4,'06',@id_pai,null,'06',2,-1,0 UNION
SELECT 18,4,'10',@id_pai,null,'10',2,-1,0 
--SELECT 18,4,'08',@id_pai,null,'08',2,-1,0 

------------------------------------ Estrutura Coluna 03 ----------------------------------------
SELECT @id_pai = id_endereco
FROM endereco
WHERE endereco_completo = '03'
AND id_def = 18
AND nivel = 3
AND id_endereco not in (select id_pai from endereco where id_def = 18 and nivel = 4)
--SELECT * FROM DEF_ENDERECO
INSERT endereco (id_def, nivel, endereco, id_pai,qtd_caixa, endereco_completo, id_lote_classificacao, permite_inventario,refugo) 
SELECT 18,4,'03',@id_pai,null,'03',2,-1,0 UNION
SELECT 18,4,'07',@id_pai,null,'07',2,-1,0 UNION
SELECT 18,4,'11',@id_pai,null,'11',2,-1,0 
--SELECT 18,4,'12',@id_pai,null,'12',2,-1,0 

------------------------------------ Estrutura Coluna 04 ----------------------------------------
SELECT @id_pai = id_endereco
FROM endereco
WHERE endereco_completo = '04'
AND id_def = 18
AND nivel = 3
AND id_endereco not in (select id_pai from endereco where id_def = 18 and nivel = 4)
--SELECT * FROM DEF_ENDERECO
INSERT endereco (id_def, nivel, endereco, id_pai,qtd_caixa, endereco_completo, id_lote_classificacao, permite_inventario,refugo) 
SELECT 18,4,'04',@id_pai,null,'04',2,-1,0 UNION
SELECT 18,4,'08',@id_pai,null,'08',2,-1,0 UNION
SELECT 18,4,'12',@id_pai,null,'12',2,-1,0 
--SELECT 18,4,'04',@id_pai,null,'04',2,-1,0 

------------------------------------ Valida dados inseridos ----------------------------------------
 select * from endereco where id_def = 18

------------------------------------ UPDATES NECESSARIOS ----------------------------------------
update endereco set cod_situacao_endereco = 1
where id_def = 18 

update endereco set id_tipo_volume = 161
where id_def = 18 
--DEF_TIPO_VOLUME_ENDERECO


update endereco set id_tipo_acesso_endereco = 6
where id_def = 18 
--DEF_tipo_acesso_endereco
--INSERT DEF_tipo_acesso_endereco VALUES ('COLMEIA','0.00','13')


update endereco set id_tipo_Armazenamento = 12
where id_def = 18 
--DEF_tipo_Armazenamento_ENDEReco


UPDATE endereco set id_def_endereco_setor = 9
where id_def = 17 
--def_endereco_setor

------------------------------------ FIM IMPORTACAO DOS ENDERECOS  ----------------------------------------

-- UPDATES ADICIONAIS DEPOIS DE IMPORTADO OS ENDERECOS--		   
UPDATE endereco
   SET  endereco_completo_3D = dbo.getEnderecoCompleto3D(id_endereco),
	   id_endereco_completo = dbo.getEnderecoCompletoID(id_endereco),
	   id_endereco_div = dbo.GetEnderecoDivID(id_endereco)
	   where id_def = 18 

UPDATE E
   SET E.endereco_completo_pai = PAI.endereco_completo
  FROM endereco E INNER JOIN
       endereco PAI ON PAI.id_endereco = E.id_pai
	   where e.id_def = 18 

UPDATE endereco
   SET  GetEnderecoPaiNivel = dbo.GetEnderecoPaiNivel(id_endereco,nivel)   
   where id_def = 18 

 UPDATE endereco set  endereco_completo = endereco where id_def = 18 and id_endereco >= 88252