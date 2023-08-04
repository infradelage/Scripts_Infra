--stp_wmsoper_produto_grava

select nao_atualiza_dimensao_produto,nao_atualiza_emb_produto from parametros

update parametros set
nao_atualiza_dimensao_produto = 1,	-- desativa a atualização das dimensões do produto
nao_atualiza_emb_produto = 1 -- desativa a atualização da embalagem de compra e venda do produto
