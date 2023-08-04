--1 - Cria a tabala mig_tipo_volume
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[mig_tipo_volume]') AND type in (N'U'))
DROP TABLE [dbo].mig_tipo_volume
GO
CREATE TABLE [dbo].mig_tipo_volume(
	cod_prod_erp [nvarchar](255) NULL,
	descricao [nvarchar](255) NULL,
	tipo_volume [nvarchar](255) NULL,
	caixas_por_camada [nvarchar](255) NULL,
	camadas_por_pallet [nvarchar](255) NULL,
	quantidade_caixas [nvarchar](255) NULL,
	id_tipo_volume [nvarchar](255) NULL
) ON [PRIMARY]
GO


--2 - UPDATE NA TABELA MIG PARA INSERIR O id_tipo_volume
UPDATE mig_tipo_volume SET id_tipo_volume = dtve.id_tipo_volume_endereco
--SELECT mtv.cod_prod_erp,dtve.id_tipo_volume_endereco,dtve.descricao,mtv.id_tipo_volume
FROM mig_tipo_volume mtv 
inner join def_tipo_volume_endereco dtve on dtve.descricao = mtv.tipo_volume
inner join produto_relacionado pr on pr.cod_produto_rel = mtv.cod_prod_erp
--where pr.cod_produto = 138

--3 - VALIDA SE TODOS OS PRODUTOS DA PLANILHA EXISTEM NO BANCO
select mtv.cod_prod_erp, pr.cod_produto
from  mig_tipo_volume mtv
LEFT join produto_relacionado pr on pr.cod_produto_rel = mtv.cod_prod_erp
where pr.cod_produto is null

-- 4 - BACKUP DA TABELA ATUAL
SELECT * INTO produto_def_tipo_volume_endereco_bkp150323 FROM produto_def_tipo_volume_endereco

-- 5 - **** EM CASO DE ATUALIZACAO DO LASTRO **NAO** EXECUTAR O SCRIPT ITEM 5 DE DELETE GERAL
-- **** USE ESTE ABAIXO QUE SO DELETA O QUE ESTA NA MIG

delete produto_def_tipo_volume_endereco where cod_produto in ( 
		select p.cod_produto
		from produto p
		inner join produto_relacionado pr on p.cod_produto = pr.cod_produto
		inner join mig_tipo_volume mtv  on pr.cod_produto_rel = mtv.cod_prod_erp )

-- 6 - **** EM CASO DE PRIMEIRA CARGA DO LASTRO **EXECUTAR** O SCRIPT ABAIXO RESETANDO O IDENTITY
DELETE produto_def_tipo_volume_endereco DBCC CHECKIDENT(produto_def_tipo_volume_endereco, RESEED, 1)
GO

-- 7 - INSERT NA TABELA produto_def_tipo_volume_endereco
INSERT produto_def_tipo_volume_endereco (cod_produto,id_def_tipo_volume_endereco,quantidade_caixas,
camadas_por_pallet,caixas_por_camada,pallet_padrao,id_def_posicionamento)
select pr.cod_produto,mtv.id_tipo_volume,mtv.quantidade_caixas,mtv.camadas_por_pallet,mtv.caixas_por_camada,null,null
from  mig_tipo_volume mtv
inner join produto_relacionado pr on pr.cod_produto_rel = mtv.cod_prod_erp
--where pr.cod_produto = 138


-- 8 - Valida informações inseridas
SELECT *
FROM produto_def_tipo_volume_endereco pdtve
inner join produto_relacionado pr on pr.cod_produto = pdtve.cod_produto 
inner join mig_tipo_volume mtv  on  pr.cod_produto_rel = mtv.cod_prod_erp 
AND pdtve.quantidade_caixas = mtv.quantidade_caixas
and pdtve.camadas_por_pallet = mtv.camadas_por_pallet
AND pdtve.caixas_por_camada = mtv.caixas_por_camada
--where cod_produto = 138



