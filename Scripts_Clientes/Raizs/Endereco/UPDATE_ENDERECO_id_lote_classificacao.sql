--SELECT * FROM mig_flowrack WHERE classificacao_endereco LIKE '%PUBLICO%'
--SELECT * FROM mig_pulmao WHERE classificacao_endereco LIKE '%PUBLICO%'

--SELECT * FROM def_lote_classificacao WHERE descricao LIKE '%PUBLICO%'

-- INSERT CALSSIFICACAO
insert def_lote_classificacao (descricao,le_estoque_segregado,principal,trava_endereco,exporta_estoque,exporta_pedido,classificacao_lote_bloqueado,id_lote_classificacao_rel,classificacao_lote_inexistente,conferencia_nao_cega_inv_entrada)
select distinct classificacao_endereco,0,0,NULL,-1,1,0,01,0,0 from MIG_SEGREGADO
where  classificacao_endereco not in 
(select descricao from def_lote_classificacao where descricao = classificacao_endereco)


-- BUSCA ID_LOTE_CLASSIFICACAO
SELECT distinct classificacao_endereco,id_lote_classificacao FROM mig_segregado mig
inner join  def_lote_classificacao dlc on dlc.descricao = mig.classificacao_endereco
--WHERE descricao LIKE '%CONSIGNADO%'


UPDATE endereco SET id_lote_classificacao = dlc.id_lote_classificacao
--SELECT distinct mig.classificacao_endereco,dlc.id_lote_classificacao
FROM endereco e 
inner join mig_segregado mig on mig.endereco_completo = e.endereco_completo and e.nivel = (select max(nivel) from def_endereco where id_def = 5)
inner join def_lote_classificacao dlc on dlc.descricao = mig.classificacao_endereco

--SELECT * FROM ENDERECO WHERE id_def = 5

