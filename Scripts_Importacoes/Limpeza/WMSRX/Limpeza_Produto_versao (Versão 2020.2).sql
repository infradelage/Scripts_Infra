USE [WMSRX_MULTMIX]
GO

BEGIN TRAN DBCLEAN
GO

UPDATE cod_produto_serie SET id_produto_serie = 1

DELETE FROM produto_sugestao_kanban
GO

DELETE FROM produto_kanban_maximo
GO

DELETE caixa_esteira_produto DBCC CHECKIDENT(caixa_esteira_produto, RESEED, 1)
GO

DELETE FROM def_atributo_produto
GO

DELETE FROM def_atributo_opcao_produto
go

DELETE produto_def_grupo_produto_restricao DBCC CHECKIDENT(produto_def_grupo_produto_restricao, RESEED, 1)
GO

DELETE produto_operacao_logistica where cod_produto > 1 DBCC CHECKIDENT(produto_operacao_logistica, RESEED, 1)
GO

DELETE produto_tipo_armazenagem_endereco DBCC CHECKIDENT(produto_tipo_armazenagem_endereco, RESEED, 1)
GO

DELETE produto_def_tipo_volume_endereco DBCC CHECKIDENT(produto_def_tipo_volume_endereco, RESEED, 1)
GO

DELETE entidade_produto_def_tipo_volume_endereco DBCC CHECKIDENT(entidade_produto_def_tipo_volume_endereco, RESEED, 1)
GO

DELETE produto_endereco --where cod_produto > 1  
GO

DELETE log_produto_endereco DBCC CHECKIDENT(log_produto_endereco, RESEED, 1)
GO

DELETE produto_operacao_logistica DBCC CHECKIDENT(produto_operacao_logistica, RESEED, 1)
GO

DELETE param_ckeckout_aleatorio_produto 
go
GO
DELETE linha_produto_fornecedor DBCC CHECKIDENT(linha_produto, RESEED, 1)
go

DELETE produto_kit DBCC CHECKIDENT(produto_kit, RESEED, 1)
GO

DELETE produto_relacionado DBCC CHECKIDENT(produto_relacionado, RESEED, 1)
GO

DELETE grupo_restricao_produto 
GO

DELETE log_alteracao_dados DBCC CHECKIDENT(log_alteracao_dados, RESEED, 1)
GO

DELETE log_integracao_produto DBCC CHECKIDENT(log_integracao_produto, RESEED, 1)
GO

DELETE lote_estoque_LPN_movimento DBCC CHECKIDENT(lote_estoque_LPN_movimento, RESEED, 1)
GO

DELETE produto_endereco_armazenagem DBCC CHECKIDENT(produto_endereco_armazenagem, RESEED, 1)
GO

DELETE inventario_item_conf_LPN DBCC CHECKIDENT(produto_endereco_armazenagem, RESEED, 1)
GO

DELETE inventario_item_conf DBCC CHECKIDENT(produto_endereco_armazenagem, RESEED, 1)
GO

DELETE Lote_estoque_LPN DBCC CHECKIDENT(Lote_estoque_LPN, RESEED, 1)
GO

DELETE lote DBCC CHECKIDENT(lote, RESEED, 1)
GO

DELETE movimentacao_item_lote
GO

DELETE movimentacao_item
GO

DELETE pedido_item
GO

DELETE log_pedido_corte DBCC CHECKIDENT(log_pedido_corte, RESEED, 1)
GO

DELETE pedido_ocorrencia DBCC CHECKIDENT(pedido_ocorrencia, RESEED, 1)
GO

DELETE pedido_item_volume_conf DBCC CHECKIDENT(pedido_item_volume_conf, RESEED, 1)
GO

DELETE produto DBCC CHECKIDENT(produto, RESEED, 1)
GO



--COMMIT TRAN  DBCLEAN

--ROLLBACK TRAN DBCLEAN


/*

drop table titulo_bkp_03_07_2017                                                                                                            1
drop table titulo_plantao                                                                                                                   2

drop table migra_doca_drluvas                                                                                                               
drop table migra_endereco_03062020                                                                                                          
drop table migra_endereco_03062020_BUFFER                                                                                                   
drop table migra_endereco_03062020_pulmao                                                                                                   
drop table migra_endereco_03062020_segregado                                                                                                
drop table migra_endereco_pulmao2404                                                                                                        
drop table migra_ol_30042020                                                                                                                



veiculo

log_alteracao_dados                                                                                                              231
log_integracao_produto                                                                                                           16

veiculo


STP_WMS_DIVERGENCIA

SELECT t.[name], p.[rows]
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

SELECT * FROM motivos

SELECT * FROM grupo_usuario


*/
