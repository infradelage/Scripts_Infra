

BEGIN TRAN DBCLEAN
--COMMIT TRAN DBCLEAN

--ROLLBACK TRAN DBCLEAN


GO
UPDATE cod_produto_serie SET id_produto_serie = 1

DELETE FROM produto_sugestao_kanban

GO

DELETE FROM produto_kanban_maximo
GO



DELETE caixa_esteira_produto DBCC CHECKIDENT(caixa_esteira_produto, RESEED, 1)
go

DELETE FROM produto_atributo
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

go
DELETE log_alteracao_dados DBCC CHECKIDENT(log_alteracao_dados, RESEED, 1)
GO


DELETE log_integracao_produto DBCC CHECKIDENT(log_integracao_produto, RESEED, 1)
GO


go
DELETE produto_endereco_armazenagem DBCC CHECKIDENT(produto_endereco_armazenagem, RESEED, 1)
GO

go

DELETE shelf_life_entidade_subgrupo_produto DBCC CHECKIDENT(shelf_life_entidade_subgrupo_produto, RESEED, 1)
GO

DELETE SubGrupo DBCC CHECKIDENT(SubGrupo, RESEED, 1)
GO

go
DELETE Grupo DBCC CHECKIDENT(Grupo, RESEED, 1)
GO

go
DELETE grupo_restricao DBCC CHECKIDENT(grupo_restricao, RESEED, 1)
GO

go

DELETE endereco_restricao DBCC CHECKIDENT(grupo_restricao, RESEED, 1)
GO


DELETE def_tipo_endereco_grupo DBCC CHECKIDENT(def_tipo_endereco_grupo, RESEED, 1)
GO

go
DELETE grupo_shelf_life DBCC CHECKIDENT(grupo_shelf_life, RESEED, 1)
GO

go
DELETE grupo_temperatura DBCC CHECKIDENT(grupo_temperatura, RESEED, 1)
GO

go
DELETE produto DBCC CHECKIDENT(produto, RESEED, 1)
GO


--go
--drop table produto_emb_saida_020720
--drop table produto_somente_flow_290620
--drop table Produtos_SEM_Grupo_020720
--drop table produto_endereco_bkp_220720
--drop table produto_endereco_200720
--drop table dpsp_es_kanban_produto_endereco_reserva_110720
--drop table dpsp_es_kanban_produto_endereco_reserva_090720
--drop table dpsp_es_kanban_produto_endereco_reserva_080720
--drop table produto_tipo_armazenagem_endereco_bkp_220720
--drop table dpsp_es_kanban_produto_endereco_reserva_160620
--drop table dpsp_es_kanban_produto_endereco_reserva_010720
--drop table dpsp_es_kanban_produto_endereco_reserva_210720
--drop table dpsp_es_kanban_produto_endereco_reserva_220720
--drop table dpsp_es_kanban_produto_endereco_reserva_200720
--drop table produto_estoque_tipo_armazenagem_hist
--drop table dpsp_es_kanban_produto_endereco_reserva_300720
--drop table produto_rota_120720
--drop table produtos_com_grupo_sem_ref_020720
--drop table Produtos_CORRELATOS_020720
--drop table Produtos_TODOS_020720
--drop table dpsp_es_kanban_produto_endereco_reserva_280720
--drop table dpsp_es_kanban_produto_endereco_coringa_080720
--drop table prod_separa_270620
--drop table Planilha1
--drop table migraestoque_02072020
--drop table migraestoque_10072020_1
--drop table migraestoque_10072020
--drop table e
--drop table migraestoque_11072020
--drop table migraestoque_18062020
--drop table endereco_bkp_250620
--drop table endereco_bkp_190620
--drop table endereco_bkp_010720
--drop table CONTROLE_LOTE_ES
--drop table LPN_BKP_180620
--drop table ent
--drop table mig_pulmao
--drop table mig_pulmao_trabalho
--drop table mig_estoque
--drop table ee
--drop table _enderecos_bloqueados
--drop table mig_kanban
--drop table ajuste_ean_120720
--drop table romaneio_120720
--drop table mig_flowrack
--drop table mig_flowrack_trabalho
--drop table migra_2509
--drop table mig_doca
--drop table mig_doca_trabalho
--drop table mig_segregado_trabalho
--drop table mig_segregado
--drop table lpn_bkp_270620
--drop table def_endereco_bkp_190620
--drop table titulo_bkp_03_07_2017
--drop table qms_120720


--Niazi


--drop table endereco_log_regra_endereco
--drop table endereco_log_regra
--drop table endereco_log
--drop table endereco_log_resultado

--drop table log_baixa_divergencia_inventario
--drop table lote_backup20220317
--drop table pedido_item_lote_endereco_lpn
--drop table lote_20191009
--drop table divergencia_10_09_2020_apos_expurgo
--drop table produto_divergencia_expurgo
--drop table _bkp_produto
--drop table migra_estoque_09052019
--drop table migra_estoque_06052019


--drop table migra_pulmao_26092019
--drop table migra_picking_15042019
--drop table migra_separacao_23042019
--drop table lote_estoque_lpn_bkp_20190820_prod_ol2_na_ol1
--drop table migra_final_pulmao_correto
--drop table migra_final_picking_correto
--drop table migra_pickingPROD0705
--drop table migra_pulmao_15042019
--drop table migra_endereco02052019
--drop table divergencia_20_08_2019
--drop table lote_estoque_lpn_bkp_20190827_prod_ol2_na_ol1
--drop table migra_pulmaoPROD0705
--drop table migra_acerto_pedido
--drop table migra_acerto
--drop table migra_pulmao06052019
--drop table migra_endereco_pulmao_10062020
--drop table migra_estoqueSegregado_09052019
--drop table lote_estoque_lpn_bkp_20190822_prod_ol2_na_ol1
--drop table lote_estoque_lpn_bkp_20191016_prod_ol2_na_ol1
--drop table lote_estoque_lpn_bkp_20190828_prod_ol2_na_ol1
--drop table lote_estoque_lpn_bkp_20190905_prod_ol2_na_ol1


--go


---------PACHECO AZURE
--drop table produto_emb_saida_020720
--drop table prod_separa_270620
--drop table produto_somente_flow_290620
--drop table migraestoque_02072020
--drop table migraestoque_10072020_1
--drop table e
--drop table migraestoque_11072020
--drop table ee
--drop table migraestoque_18062020
--drop table endereco_bkp_250620
--drop table endereco_bkp_190620
--drop table endereco_bkp_010720
--drop table Produtos_SEM_Grupo_020720
--drop table CONTROLE_LOTE_ES
--drop table produto_endereco_bkp_220720
--drop table produto_endereco_200720
--drop table LPN_BKP_180620
--drop table dpsp_es_kanban_produto_endereco_reserva_110720
--drop table dpsp_es_kanban_produto_endereco_reserva_080720
--drop table dpsp_es_kanban_produto_endereco_reserva_090720
--drop table ent
--drop table produto_tipo_armazenagem_endereco_bkp_220720
--drop table dpsp_es_kanban_produto_endereco_reserva_160620
--drop table dpsp_es_kanban_produto_endereco_reserva_010720
--drop table dpsp_es_kanban_produto_endereco_reserva_220720
--drop table dpsp_es_kanban_produto_endereco_reserva_210720
--drop table dpsp_es_kanban_produto_endereco_reserva_200720
--drop table produto_estoque_tipo_armazenagem_hist
--drop table dpsp_es_kanban_produto_endereco_reserva_300720
--drop table produto_rota_120720
--drop table produtos_com_grupo_sem_ref_020720
--drop table Produtos_CORRELATOS_020720
--drop table ajuste_ean_120720
--drop table romaneio_120720
--drop table Produtos_TODOS_020720
--drop table qms_120720
--drop table dpsp_es_kanban_produto_endereco_reserva_280720
--drop table lpn_bkp_270620
--drop table dpsp_es_kanban_produto_endereco_coringa_080720
--drop table def_endereco_bkp_190620
--drop table migraestoque_10072020
--drop table Planilha1
--drop table 
--drop table 
--drop table 
--drop table 
--drop table 
--drop table 
--drop table 
--drop table 
--drop table 
--drop table 
--drop table 
--drop table 
--drop table 
--drop table 
--drop table 
--drop table 
--drop table 
--drop table 
--drop table 
--drop table 
--drop table 
--drop table 
--drop table 
--drop table 
--drop table 
--drop table 
--drop table 
--drop table 
--drop table 
--drop table 
--drop table 
--drop table 
--drop table 
--drop table 











--go
--update def_produto_serie set descricao = 'Numero de Série Nacional' where id_def_produto_serie = 2
--go





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
t.[name] like '%produto%'
ORDER BY
  t.[name]

SELECT * FROM motivos

SELECT * FROM grupo_usuario


*/






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
WHERE p.[rows] > 1
--and t.[name] like '%bkp%'
ORDER BY
 p.[rows] desc



 select * from lote_estoque_em_pedido