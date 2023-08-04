--Se o parâmetro nao_controla_estoques estaver ativado, o sistema 
-- não gera lote_estoque_LPN, logo não registra as movimentações saldo.

SELECT nao_controla_estoques,* FROM param_estoque

--Desativa
UPDATE param_estoque SET  nao_controla_estoques  = 0       

--Ativa
UPDATE param_estoque SET  nao_controla_estoques  = 1  