--Por default o sistema não gera picking lista de caixa fechada 
--e para que imprima a picking deve alterar a param_estoque o campo imprime_picking_cf para 1

SELECT imprime_picking_cf,* FROM param_estoque

--Desativa
UPDATE param_estoque SET  imprime_picking_cf  = 0       

--Ativa
UPDATE param_estoque SET  imprime_picking_cf  = 1   
