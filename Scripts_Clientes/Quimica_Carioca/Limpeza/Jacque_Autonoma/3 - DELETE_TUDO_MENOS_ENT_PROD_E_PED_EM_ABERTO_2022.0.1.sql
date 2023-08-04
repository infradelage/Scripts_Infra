/* 

--Script varia de acordo com OPER LOGISTICA

Select object_name(id),rowcnt,dpages*8/1024.0/1024.0 as [tamanho gB] from sysindexes 
where indid in (1,0) and objectproperty(id,'isusertable')=1 
order by 2 desc


SELECT 'DELETE ' + t.[name] + ' DBCC CHECKIDENT('+ t.[name]+', RESEED, 1)'--, p.[rows]
FROM sys.schemas s
INNER JOIN sys.tables t
  ON t.[schema_id] = s.[schema_id]
INNER JOIN sys.indexes i
  ON i.[object_id] = t.[object_id]
  AND i.[type] IN (0,1)
INNER JOIN sys.partitions p
  ON p.[object_id] = t.[object_id]
  AND p.[index_id] = i.[index_id]
WHERE p.[rows] > 0
ORDER BY
  t.[name]
*/


--BEGIN TRAN DBCLEAN

USE WMSRXDaki

DELETE auditoria_inventario_documento DBCC CHECKIDENT(auditoria_inventario_documento, RESEED, 1)

GO

--delete Grupo where cod_grupo > 1  DBCC CHECKIDENT(Grupo, RESEED, 1)

go 
truncate table  dias_entrega_ajustados

go

DELETE box DBCC CHECKIDENT(box, RESEED, 1)

go


truncate table grupo_usuario_claim
  GO
  truncate table lote_estoque_lpn_erro
  GO
  truncate table pedido_item_volume_vinculo_lote_log

  GO
  truncate table pedido_transportadora_complementar
  
DELETE def_retorno_integracao DBCC CHECKIDENT(def_retorno_integracao, RESEED, 1)

  GO
TRUNCATE TABLE log_impressao_etiqueta
  GO
UPDATE cod_espelho SET cod_espelho = 1
GO
UPDATE cod_prenota SET cod_prenota = 1
GO
TRUNCATE TABLE edi_pedido
GO
DELETE edi DBCC CHECKIDENT(edi, RESEED, 1)
GO
DELETE inventario_item_conf_lpn_serie_numero DBCC CHECKIDENT(inventario_item_conf_lpn_serie_numero, RESEED, 1)
GO
DELETE inventario_item_conf_LPN DBCC CHECKIDENT(inventario_item_conf_LPN, RESEED, 1)
GO
DELETE registra_conf_autorizacao DBCC CHECKIDENT(registra_conf_autorizacao, RESEED, 1)
GO
DELETE inventario_ciclico DBCC CHECKIDENT(inventario_ciclico, RESEED, 1)
GO
DELETE inventario_conf_endereco --DBCC CHECKIDENT(inventario_conf_endereco, RESEED, 1)
GO
DELETE inventario_conf DBCC CHECKIDENT(inventario_conf, RESEED, 1)
GO
TRUNCATE TABLE inventario_conf_endereco 
GO
TRUNCATE TABLE inventario_endereco 
GO
DELETE inventario_item 
GO
DELETE inventario_item_conf DBCC CHECKIDENT(inventario_item_conf, RESEED, 1)
GO
TRUNCATE TABLE Inventario_Mov DBCC CHECKIDENT(Inventario_Mov, RESEED, 1)
GO
TRUNCATE TABLE inventario_pedido 
GO
DELETE inventario DBCC CHECKIDENT(inventario, RESEED, 1)
GO
TRUNCATE TABLE log_erro_edi DBCC CHECKIDENT(log_erro_edi, RESEED, 1)
GO
TRUNCATE TABLE log_sql DBCC CHECKIDENT(log_sql, RESEED, 1)
GO
TRUNCATE TABLE pedido_titulo 
GO
TRUNCATE TABLE pedido_ocorrencia DBCC CHECKIDENT(pedido_ocorrencia, RESEED, 1)
GO
--TRUNCATE TABLE pedido_romaneio DBCC CHECKIDENT(pedido_romaneio, RESEED, 1)
--DELETE pedido_romaneio where cod_pedido not in (select cod_pedido from pedido)
--GO
DELETE decanting_slot_item DBCC CHECKIDENT(decanting_slot_item, RESEED, 1)
GO
DELETE decanting_lpn DBCC CHECKIDENT(decanting_lpn, RESEED, 1)
GO
DELETE decanting_slot DBCC CHECKIDENT(decanting_slot, RESEED, 1)
GO
DELETE decanting DBCC CHECKIDENT(decanting, RESEED, 1)
GO

DELETE Ordem_mov_item  DBCC CHECKIDENT(Ordem_mov_item, RESEED, 1)

GO 

DELETE pedido_item_volume_lote_numero_serie --DBCC CHECKIDENT(pedido_item_volume_lote_numero_serie, RESEED, 1)
GO
DELETE pedido_item_volume_lote_lpn   DBCC CHECKIDENT(pedido_item_volume_lote_lpn, RESEED, 1)
GO
DELETE pedido_item_volume_numero_serie DBCC CHECKIDENT(pedido_item_volume_numero_serie, RESEED, 1)
GO
DELETE pedido_item_lote_endereco WHERE cod_pedido not in (SELECT cod_pedido FROM pedido where cod_situacao = 1 and operacao in (1,2))--DBCC CHECKIDENT(pedido_item_lote_endereco, RESEED, 1)
GO
TRUNCATE TABLE pedido_item_lote_endereco_baixa 
GO
DELETE pedido_item_volume DBCC CHECKIDENT(pedido_item_volume, RESEED, 1)
GO
TRUNCATE TABLE pedido_item_volume_exporta
GO
TRUNCATE TABLE pedido_item_volume_sobra 
GO
DELETE pedido_item_volume_conf DBCC CHECKIDENT(pedido_item_volume_conf, RESEED, 1)
GO
DELETE pedido_volume_conf DBCC CHECKIDENT(pedido_volume_conf, RESEED, 1)
GO
DELETE pedido_item_volume_lote_slot DBCC CHECKIDENT(pedido_item_volume_lote_slot, RESEED, 1)
GO
DELETE pedido_item_volume_slot DBCC CHECKIDENT(pedido_item_volume_slot, RESEED, 1)
GO
DELETE pedido_volume_slot DBCC CHECKIDENT(pedido_volume_slot, RESEED, 1)
GO
DELETE pedido_item_volume_lote DBCC CHECKIDENT(pedido_item_volume_lote, RESEED, 1)
GO

TRUNCATE TABLE pedido_item_volume_conf

GO

DELETE pedido_item_volume_lote DBCC CHECKIDENT(pedido_item_volume_lote, RESEED, 1)
GO
DELETE pedido_exportacao_sorter DBCC CHECKIDENT(pedido_exportacao_sorter, RESEED, 1)
GO
DELETE pedido_volume_carregamento DBCC CHECKIDENT(pedido_volume_carregamento, RESEED, 1)
GO
DELETE movimentacao_item_lote_numero_serie DBCC CHECKIDENT(movimentacao_item_lote_numero_serie, RESEED, 1)
GO
DELETE movimentacao_item_lote DBCC CHECKIDENT(movimentacao_item_lote, RESEED, 1)
GO
DELETE movimentacao_item --DBCC CHECKIDENT(movimentacao_item, RESEED, 1)
GO
DELETE movimentacao DBCC CHECKIDENT(movimentacao, RESEED, 1)
GO
DELETE pedido_volume
GO
DELETE pedido_item WHERE cod_pedido not in (SELECT cod_pedido FROM pedido where cod_situacao = 1 and operacao in (1,2))
GO
DELETE log_pedido_corte DBCC CHECKIDENT(log_pedido_corte, RESEED, 1)
GO
DELETE pedido_volume_retorno DBCC CHECKIDENT(pedido_volume_retorno, RESEED, 1)
GO
DELETE produto_serie_numero DBCC CHECKIDENT(produto_serie_numero, RESEED, 1)
GO
DELETE produto_serie --DBCC CHECKIDENT(produto_serie, RESEED, 1)
GO
DELETE pedido_pedido --DBCC CHECKIDENT(pedido_pedido, RESEED, 1)
GO 
DELETE pedido_romaneio DBCC CHECKIDENT(pedido_romaneio, RESEED, 1)
GO
DELETE pedido WHERE cod_pedido not in (SELECT cod_pedido FROM pedido where cod_situacao = 1 and operacao in (1,2))--DBCC CHECKIDENT(pedido, RESEED, 1)
GO
truncate table  Ordem_mov_item_pedido_item_volume
go
DELETE Ordem_mov_item DBCC CHECKIDENT(Ordem_mov_item, RESEED, 1)

GO
DELETE onda_volume DBCC CHECKIDENT(onda_volume, RESEED, 1)
GO
DELETE onda DBCC CHECKIDENT(onda, RESEED, 1)
GO
--TRUNCATE TABLE titulo_romaneio DBCC CHECKIDENT(titulo_romaneio, RESEED, 1)
GO
--DELETE romaneio_romaneio_entrega DBCC CHECKIDENT(romaneio_romaneio_entrega, RESEED, 1)
GO
--DELETE romaneio DBCC CHECKIDENT(romaneio, RESEED, 1)
GO
--DELETE romaneio_entrega_cliente 
GO
--DELETE romaneio_entrega DBCC CHECKIDENT(romaneio_entrega, RESEED, 1)
GO 
DELETE titulo_romaneio DBCC CHECKIDENT(titulo_romaneio, RESEED, 1)
GO
DELETE titulo DBCC CHECKIDENT(titulo, RESEED, 1)
GO
TRUNCATE TABLE lote_estoque_movimento DBCC CHECKIDENT(lote_estoque_movimento, RESEED, 1)
GO
TRUNCATE TABLE ordem_montagem_kit_kit_lote DBCC CHECKIDENT(ordem_montagem_kit_kit_lote, RESEED, 1)
GO
DELETE ordem_mov_item_coleta DBCC CHECKIDENT(ordem_mov_item_coleta, RESEED, 1)
GO
DELETE ordem_mov_item_entrega DBCC CHECKIDENT(ordem_mov_item_entrega, RESEED, 1)
GO
GO
DELETE container DBCC CHECKIDENT(container, RESEED, 1)
GO
DELETE lote_estoque_lpn DBCC CHECKIDENT(lote_estoque_lpn, RESEED, 1)
GO
DELETE lote_estoque_LPN_movimento DBCC CHECKIDENT(lote_estoque_LPN_movimento, RESEED, 1)
GO

TRUNCATE TABLE lpn_impressao_inventario

GO

DELETE LPN WHERE id_lpn > 1 DBCC CHECKIDENT(LPN, RESEED, 1)
GO
GO

DELETE movimentacao_item --DBCC CHECKIDENT(movimentacao_item, RESEED, 1)
GO
DELETE movimentacao_item_lote DBCC CHECKIDENT(movimentacao_item_lote, RESEED, 1)
GO
--DELETE lote DBCC CHECKIDENT(lote, RESEED, 1)
DELETE lote where id_lote not in (select id_lote from pedido_item_lote_endereco)
GO
--DELETE produto_def_grupo_produto_restricao DBCC CHECKIDENT(produto_def_grupo_produto_restricao, RESEED, 1)
--GO
--DELETE produto_operacao_logistica where cod_produto > 1 DBCC CHECKIDENT(produto_operacao_logistica, RESEED, 1)
--GO
--DELETE produto_tipo_armazenagem_endereco DBCC CHECKIDENT(produto_tipo_armazenagem_endereco, RESEED, 1)
--GO
--DELETE produto_def_tipo_volume_endereco DBCC CHECKIDENT(produto_def_tipo_volume_endereco, RESEED, 1)
--GO
--DELETE entidade_produto_def_tipo_volume_endereco DBCC CHECKIDENT(entidade_produto_def_tipo_volume_endereco, RESEED, 1)
--GO
--DELETE produto_endereco --where cod_produto > 1  
--GO
--DELETE log_produto_endereco DBCC CHECKIDENT(log_produto_endereco, RESEED, 1)
--GO
--DELETE produto_operacao_logistica DBCC CHECKIDENT(produto_operacao_logistica, RESEED, 1)
--GO
--DELETE caixa_fechada --DBCC CHECKIDENT(caixa_fechada, RESEED, 1)
--GO
--DELETE linha_produto_fornecedor-- DBCC CHECKIDENT(linha_produto_fornecedor, RESEED, 1)
--GO
--DELETE linha_produto DBCC CHECKIDENT(linha_produto, RESEED, 1)
--GO
--DELETE produto DBCC CHECKIDENT(produto, RESEED, 1)
GO
DELETE ordem_mov DBCC CHECKIDENT(ordem_mov, RESEED, 1)
GO
DELETE agrupamento_ordem_mov DBCC CHECKIDENT(agrupamento_ordem_mov, RESEED, 1)
GO
--DELETE caixa_esteira_entidade  DBCC CHECKIDENT(caixa_esteira_entidade, RESEED, 1)
GO
--DELETE entidade_produto_def_tipo_volume_endereco DBCC CHECKIDENT(entidade_produto_def_tipo_volume_endereco, RESEED, 1) 
GO

truncate table questionario_resposta
GO

truncate table notificacao_destinatario

GO

--truncate table grupo_usuario_entidade

go


DELETE questionario  DBCC CHECKIDENT(questionario, RESEED, 1)

go

DELETE notificacao  DBCC CHECKIDENT(notificacao, RESEED, 1)  

GO

--TRUNCATE TABLE entidade_tipo_acesso_endereco

GO

--DELETE entrada_caminhao_pedido DBCC CHECKIDENT(entrada_caminhao_pedido, RESEED, 1)


GO


TRUNCATE TABLE notificacao_acao_destinatario


--go
--DELETE  entidade_operacao_logistica  where cod_entidade > 3 --DBCC CHECKIDENT(entidade_operacao_logistica, RESEED, 2)

--go

--TRUNCATE TABLE entidade_permissao_operacao_logistica

--go

--TRUNCATE TABLE funcionario_def_endereco_setor DBCC CHECKIDENT(funcionario_def_endereco_setor, RESEED, 1)

--GO

--TRUNCATE TABLE funcionario_def_equipamento DBCC CHECKIDENT(funcionario_def_equipamento, RESEED, 1)

--GO

--TRUNCATE TABLE funcionario_def_operacao_ordem DBCC CHECKIDENT(funcionario_def_operacao_ordem, RESEED, 1)

--GO

--TRUNCATE TABLE grupo_usuario_entidade --DBCC CHECKIDENT(grupo_usuario_entidade, RESEED, 1)

--GO

--DELETE caixa_esteira_entidade DBCC CHECKIDENT(caixa_esteira_entidade, RESEED, 1) 
--GO

--DELETE entidade_funcionalidade
--GO

--DELETE entidade_tipo_acesso_endereco
--GO
--DELETE entidade_endereco_colmeia
--GO
--DELETE veiculo --DBCC CHECKIDENT(veiculo, RESEED, 1) 
--GO
--DELETE entidade where cod_entidade > 3 DBCC CHECKIDENT(entidade, RESEED, 3)  --DEIXAR ENTIDADE OPER logistica, usuario e cliente
--go

--update entidade set identityID = null

--go

--delete AspNetUsers 

--DELETE ENDERECO WHERE NIVEL > 1

--truncate table arvore_esteira


--IF OBJECT_ID('migra_grupo_subgrupo', 'U') IS NOT NULL
--DROP TABLE migra_grupo_subgrupo;

--IF OBJECT_ID('migra_linha2', 'U') IS NOT NULL
--DROP TABLE migra_linha2;

--IF OBJECT_ID('migra_flowrack', 'U') IS NOT NULL
--DROP TABLE migra_flowrack;

--IF OBJECT_ID('endereco_bkp_190719', 'U') IS NOT NULL
--DROP TABLE endereco_bkp_190719;

--IF OBJECT_ID('migraestoque_01072019', 'U') IS NOT NULL
--DROP TABLE migraestoque_01072019;

--IF OBJECT_ID('end_pulmao', 'U') IS NOT NULL
--DROP TABLE end_pulmao;

--IF OBJECT_ID('migra_linha', 'U') IS NOT NULL
--DROP TABLE migra_linha;

--IF OBJECT_ID('migraestoque_01072019_flow', 'U') IS NOT NULL
--DROP TABLE migraestoque_01072019_flow;

--IF OBJECT_ID('migra_flowrack_drluvas', 'U') IS NOT NULL
--DROP TABLE migra_flowrack_drluvas;

--IF OBJECT_ID('migra_pulmao_drluvas', 'U') IS NOT NULL
--DROP TABLE migra_pulmao_drluvas;


--IF OBJECT_ID('migra_doca_drluvas', 'U') IS NOT NULL
--DROP TABLE migra_doca_drluvas;


--IF OBJECT_ID('pile_bkp', 'U') IS NOT NULL
--DROP TABLE pile_bkp;



--IF OBJECT_ID('pulmao', 'U') IS NOT NULL
--DROP TABLE pulmao;



--COMMIT TRAN  DBCLEAN

--ROLLBACK TRAN DBCLEAN

