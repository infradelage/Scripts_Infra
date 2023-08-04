select habilita_LPN, permite_n_lote_produto_mesma_LPN, permite_n_produto_mesma_LPN from param_estoque
select * from param_lpn

UPDATE param_lpn SET
habilita_LPN = 1,
permite_n_lote_produto_mesma_LPN = 1 , 
permite_n_produto_mesma_LPN  = 1 

-- NECESSARIO LIMPEZA DA BASE

-- NECESSARIO AJUESTE NA LPN

update def_lpn set prox_numero = '00000000000002' where id_def_lpn = 1