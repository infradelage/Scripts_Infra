SELECT associa_produto_a_todas_operacoes_logisticas FROM param_estoque

--INATIVO
UPDATE param_estoque set associa_produto_a_todas_operacoes_logisticas = 0

--ATIVO
UPDATE param_estoque set associa_produto_a_todas_operacoes_logisticas = 1 