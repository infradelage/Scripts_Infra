select conferencia_pedido_confirma_volume from param_estoque

--finaliza o volume automatico
UPDATE param_estoque set conferencia_pedido_confirma_volume = 0 

--Não finaliza o volume automatico
UPDATE param_estoque set conferencia_pedido_confirma_volume = 1