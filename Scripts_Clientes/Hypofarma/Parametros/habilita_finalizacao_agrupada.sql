-- habilita_finalizacao_agrupada este par�metro so finaliza 
	-- se caixas forem do mesmo item, no mesmo endere�o e mesmo lote.
-- Ao habilitar sempre ser� solicitado a quantidade na finaliza��o da caixa fechada

SELECT habilita_finalizacao_agrupada,* FROM param_estoque

-- 1 Ativo
-- 0 Desativado

Update param_estoque set habilita_finalizacao_agrupada = 1 