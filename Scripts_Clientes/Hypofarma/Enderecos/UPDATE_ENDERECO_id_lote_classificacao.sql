--SELECT * FROM mig_segregado WHERE classificacao_endereco LIKE '%PUBLICO%'
--SELECT * FROM mig_pulmao WHERE classificacao_endereco LIKE '%PUBLICO%'

--SELECT * FROM def_lote_classificacao WHERE descricao LIKE '%PUBLICO%'

-- INSERT CALSSIFICACAO
insert def_lote_classificacao (descricao,le_estoque_segregado,principal,trava_endereco,exporta_estoque,exporta_pedido,classificacao_lote_bloqueado,id_lote_classificacao_rel,classificacao_lote_inexistente,conferencia_nao_cega_inv_entrada)
select distinct classificacao_endereco,0,0,NULL,-1,1,0,01,0,0 from mig_segregado
where  classificacao_endereco not in 
(select descricao from def_lote_classificacao where descricao = classificacao_endereco)

-- BUSCA ID_LOTE_CLASSIFICACAO
SELECT distinct classificacao_endereco,id_lote_classificacao FROM mig_segregado mig
inner join  def_lote_classificacao dlc on dlc.descricao = mig.classificacao_endereco
--WHERE descricao LIKE '%CONSIGNADO%'


UPDATE endereco SET id_lote_classificacao = 45
--SELECT *
FROM endereco e 
inner join mig_segregado mig on mig.endereco_completo = e.endereco_completo AND mig.classificacao_endereco LIKE '%CONTROLADO%'

UPDATE endereco SET id_lote_classificacao = 48
--SELECT *
FROM endereco e 
inner join mig_segregado mig on mig.endereco_completo = e.endereco_completo AND mig.classificacao_endereco LIKE '%DEVOLUÇÃO%'


UPDATE endereco SET id_lote_classificacao = 49
--SELECT *
FROM endereco e 
inner join mig_segregado mig on mig.endereco_completo = e.endereco_completo AND mig.classificacao_endereco LIKE '%PROXIMO VENCIMENTO%'


UPDATE endereco SET id_lote_classificacao = 50
--SELECT *
FROM endereco e 
inner join mig_segregado mig on mig.endereco_completo = e.endereco_completo AND mig.classificacao_endereco LIKE '%RECOLHIMENTO%'

UPDATE endereco SET id_lote_classificacao = 51
--SELECT *
FROM endereco e 
inner join mig_segregado mig on mig.endereco_completo = e.endereco_completo AND mig.classificacao_endereco LIKE '%REPROVADOS%'


