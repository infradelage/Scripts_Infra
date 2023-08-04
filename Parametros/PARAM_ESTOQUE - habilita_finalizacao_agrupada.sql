-- habilita_finalizacao_agrupada este parâmetro so finaliza 
	-- se caixas forem do mesmo item, no mesmo endereço e mesmo lote.
-- Ao habilitar sempre será solicitado a quantidade na finalização da caixa fechada

SELECT habilita_finalizacao_agrupada,* FROM param_estoque

-- 1 Ativo
-- 0 Desativado

Update param_estoque set habilita_finalizacao_agrupada = XXX 