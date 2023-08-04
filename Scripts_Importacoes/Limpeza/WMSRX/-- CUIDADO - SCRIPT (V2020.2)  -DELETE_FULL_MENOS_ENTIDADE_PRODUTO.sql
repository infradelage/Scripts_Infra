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

BEGIN TRAN DBCLEAN

--COMMIT TRAN DBCLEAN

--ROLLBACK TRAN DBCLEAN


DELETE log_alteracao_produto DBCC CHECKIDENT(log_alteracao_produto, RESEED, 1)

GO





DELETE modulo_opcao_permissao 

GO


DELETE pedido_item_cancelamento DBCC CHECKIDENT(pedido_item_cancelamento, RESEED, 1)

GO



GO


DELETE movimentacao_item_lote_numero_serie DBCC CHECKIDENT(movimentacao_item_lote_numero_serie, RESEED, 1)

go



DELETE movimentacao_item_lote DBCC CHECKIDENT(movimentacao_item_lote, RESEED, 1)


GO


DELETE movimentacao_item

GO



DELETE movimentacao DBCC CHECKIDENT(movimentacao, RESEED, 1)

GO




go
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
UPDATE cod_produto_serie SET id_produto_serie = 1
GO
TRUNCATE TABLE edi_pedido
GO
DELETE edi_romaneio
go
DELETE edi_movimentacao

GO
DELETE edi_entrega

GO
DELETE edi_checkout

GO
DELETE edi DBCC CHECKIDENT(edi, RESEED, 1)
GO





DELETE inventario_item_conf_lpn_serie_numero DBCC CHECKIDENT(inventario_item_conf_lpn_serie_numero, RESEED, 1)
GO

DELETE inventario_item_conf_lpn_serie_numero_previsto DBCC CHECKIDENT(inventario_item_conf_lpn_serie_numero_previsto, RESEED, 1)
GO

DELETE inventario_item_conf_LPN DBCC CHECKIDENT(inventario_item_conf_LPN, RESEED, 1)
GO




DELETE inventario_item_conf_volume DBCC CHECKIDENT(inventario_item_conf_volume, RESEED, 1)
GO
DELETE inventario_item_conf DBCC CHECKIDENT(inventario_item_conf, RESEED, 1)
GO
DELETE registra_conf_autorizacao DBCC CHECKIDENT(registra_conf_autorizacao, RESEED, 1)
GO
DELETE inventario_ciclico DBCC CHECKIDENT(inventario_ciclico, RESEED, 1)
GO
DELETE inventario_conf_volume_temperatura DBCC CHECKIDENT(inventario_conf_volume_temperatura, RESEED, 1)

GO
DELETE inventario_conf_temperatura DBCC CHECKIDENT(inventario_conf_temperatura, RESEED, 1)
GO

DELETE inventario_conf_volume DBCC CHECKIDENT(inventario_conf_volume, RESEED, 1)
GO


DELETE inventario_conf_endereco --DBCC CHECKIDENT(inventario_conf_endereco, RESEED, 1)
GO
DELETE inventario_conf DBCC CHECKIDENT(inventario_conf, RESEED, 1)
GO
TRUNCATE TABLE inventario_conf_endereco 
GO
TRUNCATE TABLE inventario_endereco 
GO

DELETE inventario_item_conf DBCC CHECKIDENT(inventario_item_conf, RESEED, 1)
GO


DELETE inventario_item_conf DBCC CHECKIDENT(inventario_item_conf, RESEED, 1)
GO

DELETE inventario_conf DBCC CHECKIDENT(inventario_conf, RESEED, 1)
GO

TRUNCATE TABLE Inventario_Mov DBCC CHECKIDENT(Inventario_Mov, RESEED, 1)
GO

DELETE inventario_item 
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
TRUNCATE TABLE pedido_romaneio DBCC CHECKIDENT(pedido_romaneio, RESEED, 1)
GO


DELETE decanting_slot_item_serie_numero DBCC CHECKIDENT(decanting_slot_item_serie_numero, RESEED, 1)
GO

DELETE decanting_slot_item DBCC CHECKIDENT(decanting_slot_item, RESEED, 1)
GO
DELETE decanting_lpn DBCC CHECKIDENT(decanting_lpn, RESEED, 1)
GO
DELETE decanting_slot DBCC CHECKIDENT(decanting_slot, RESEED, 1)
GO

DELETE decanting_pedido_armazenagem DBCC CHECKIDENT(decanting_pedido_armazenagem, RESEED, 1)
GO
DELETE decanting DBCC CHECKIDENT(decanting, RESEED, 1)
GO

DELETE Ordem_mov_item  DBCC CHECKIDENT(Ordem_mov_item, RESEED, 1)

GO 

DELETE pedido_item_volume_lote_lpn   DBCC CHECKIDENT(pedido_item_volume_lote_lpn, RESEED, 1)
GO
DELETE pedido_item_volume_lote_slot DBCC CHECKIDENT(pedido_item_volume_lote_slot, RESEED, 1)

go
DELETE .pedido_item_volume_lote_numero_serie DBCC CHECKIDENT(pedido_item_volume_lote_numero_serie, RESEED, 1)
GO

DELETE pedido_item_volume_lote DBCC CHECKIDENT(pedido_item_volume_lote, RESEED, 1)
GO

DELETE pedido_item_volume_conf DBCC CHECKIDENT(pedido_item_volume_conf, RESEED, 1)
GO

--DELETE pedido_volume_conf DBCC CHECKIDENT(pedido_volume_conf, RESEED, 1)
--GO

TRUNCATE TABLE pedido_item_volume_exporta
GO

DELETE pedido_item_volume_slot DBCC CHECKIDENT(pedido_item_volume_slot, RESEED, 1)
GO


DELETE pedido_item_volume_lote_numero_serie DBCC CHECKIDENT(pedido_item_volume_lote_numero_serie, RESEED, 1)
GO

DELETE pedido_item_volume_numero_serie DBCC CHECKIDENT(pedido_item_volume_numero_serie, RESEED, 1)
GO

GO
DELETE pedido_item_volume DBCC CHECKIDENT(pedido_item_volume, RESEED, 1)
GO

TRUNCATE TABLE pedido_item_volume_sobra 
GO


TRUNCATE TABLE pedido_item_lote_endereco_baixa 
GO

DELETE pedido_item_lote_endereco DBCC CHECKIDENT(pedido_item_lote_endereco, RESEED, 1)
GO
          




DELETE pedido_volume_slot DBCC CHECKIDENT(pedido_volume_slot, RESEED, 1)
GO



DELETE pedido_exportacao_sorter DBCC CHECKIDENT(pedido_exportacao_sorter, RESEED, 1)
GO
DELETE pedido_volume_retorno DBCC CHECKIDENT(pedido_volume_retorno, RESEED, 1)
GO

DELETE pedido_volume_carregamento DBCC CHECKIDENT(pedido_volume_carregamento, RESEED, 1)
GO
DELETE pedido_volume
GO

DELETE liberacao_volume DBCC CHECKIDENT(liberacao_volume, RESEED, 1)

GO

DELETE consolidacao_pedido_acao DBCC CHECKIDENT(consolidacao_pedido_acao, RESEED, 1)

GO

DELETE consolidacao DBCC CHECKIDENT(consolidacao, RESEED, 1)

GO

DELETE agrupamento_consolidacao DBCC CHECKIDENT(agrupamento_consolidacao, RESEED, 1)

go






DELETE log_pedido_corte DBCC CHECKIDENT(log_pedido_corte, RESEED, 1)
GO

DELETE pedido_romaneio 
GO

DELETE pedido_item 
GO


DELETE conf_validacao DBCC CHECKIDENT(conf_validacao, RESEED, 1)


GO
DELETE picking_agrupada_item DBCC CHECKIDENT(picking_agrupada_item, RESEED, 1)
GO


GO
DELETE lote_estoque_lpn_serie_numero_automatizado DBCC CHECKIDENT(lote_estoque_lpn_serie_numero_automatizado, RESEED, 1)
GO


GO
DELETE produto_serie_numero DBCC CHECKIDENT(produto_serie_numero, RESEED, 1)
GO

DELETE produto_serie 
GO

GO

DELETE pedido_volume_documento 
GO

DELETE pedido_documento DBCC CHECKIDENT(pedido_documento, RESEED, 1)
GO


DELETE documento DBCC CHECKIDENT(documento, RESEED, 1)

GO

DELETE entrada_operacao_logistica_produto_lote 
GO

DELETE movimentacao_parcial_produto_serie_numero DBCC CHECKIDENT(movimentacao_parcial_produto_serie_numero, RESEED, 1)
GO

DELETE movimentacao_parcial_produto_serie DBCC CHECKIDENT(movimentacao_parcial_produto_serie, RESEED, 1)
GO

DELETE pedido_volume_finalizacao_checkout DBCC CHECKIDENT(pedido_volume_finalizacao_checkout, RESEED, 1)
GO

DELETE pedido DBCC CHECKIDENT(pedido, RESEED, 1)
GO

truncate table  Ordem_mov_item_pedido_item_volume
go
DELETE Ordem_mov_item DBCC CHECKIDENT(Ordem_mov_item, RESEED, 1)

GO




TRUNCATE TABLE romaneio_romaneio_entrega DBCC CHECKIDENT(romaneio_romaneio_entrega, RESEED, 1)
GO


DELETE romaneio_entrega_cliente 
GO


DELETE titulo_romaneio DBCC CHECKIDENT(titulo_romaneio, RESEED, 1)
GO
DELETE romaneio DBCC CHECKIDENT(romaneio, RESEED, 1)
GO


DELETE romaneio_entrega DBCC CHECKIDENT(romaneio_entrega, RESEED, 1)
GO

DELETE titulo_romaneio DBCC CHECKIDENT(titulo_romaneio, RESEED, 1)
GO
DELETE romaneio DBCC CHECKIDENT(romaneio, RESEED, 1)
GO

go
DELETE onda_volume DBCC CHECKIDENT(onda_volume, RESEED, 1)
GO


go
DELETE onda DBCC CHECKIDENT(onda, RESEED, 1)
GO




DELETE titulo DBCC CHECKIDENT(titulo, RESEED, 1)
GO
DELETE lote_estoque_LPN_movimento DBCC CHECKIDENT(lote_estoque_LPN_movimento, RESEED, 1)
GO
TRUNCATE TABLE ordem_montagem_kit_kit_lote DBCC CHECKIDENT(ordem_montagem_kit_kit_lote, RESEED, 1)
GO
DELETE ordem_mov_item_coleta DBCC CHECKIDENT(ordem_mov_item_coleta, RESEED, 1)
GO
DELETE ordem_mov_item_entrega DBCC CHECKIDENT(ordem_mov_item_entrega, RESEED, 1)
GO
GO
DELETE container DBCC CHECKIDENT(container, RESEED, 1)

DELETE log_alteracao_lote_estoque_lpn DBCC CHECKIDENT(log_alteracao_lote_estoque_lpn, RESEED, 1)


GO
GO
DELETE lote_estoque_lpn DBCC CHECKIDENT(lote_estoque_lpn, RESEED, 1)
GO


TRUNCATE TABLE lpn_impressao_inventario

GO


DELETE LPN WHERE id_lpn > 108 DBCC CHECKIDENT(LPN, RESEED, 500)
GO

GO
DELETE lote_estoque_lpn_automatizado DBCC CHECKIDENT(lote_estoque_lpn_automatizado, RESEED, 1)
GO

GO
DELETE snapshot_knapp DBCC CHECKIDENT(snapshot_knapp, RESEED, 1)
GO


GO
DELETE lote DBCC CHECKIDENT(lote, RESEED, 1)
GO

--GO

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

DELETE notificacao_mensagem DBCC CHECKIDENT(notificacao_mensagem, RESEED, 1) 
GO

DELETE notificacao  DBCC CHECKIDENT(notificacao, RESEED, 1)  

GO

--TRUNCATE TABLE entidade_tipo_acesso_endereco

GO

--DELETE entrada_caminhao_pedido DBCC CHECKIDENT(entrada_caminhao_pedido, RESEED, 1)


GO

go

TRUNCATE TABLE log_alteracao_dados                                                                                                             
TRUNCATE TABLE log_erro  


TRUNCATE TABLE notificacao_acao_destinatario


go

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