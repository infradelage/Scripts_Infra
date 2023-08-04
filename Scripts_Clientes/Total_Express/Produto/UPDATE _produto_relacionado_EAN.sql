--INSERI NA MIG O CODIGO DO PRODUTO POIS A MIG TEM O COD REL
UPDATE mig set mig.cod_prod_wms = pr.cod_produto
--select MIG.*,pr.cod_produto
from mig_cad mig
inner join produto_relacionado_bkp_2107 pr on pr.cod_produto_rel = mig.cod_prod_sku
where mig.cod_prod_sku in (select cod_produto_rel from produto_relacionado_bkp_2107 )
--and mig.cod_prod_sku_rel = 0000527
--order by mig.cod_prod_sku desc


--UPDATE NA PRODUTO RELACIONADO NO CAMPO cod_produto_rel COM BASE NO EAN DA MIG
UPDATE pr set cod_produto_rel = mig.EAN
--select pr.cod_produto
from produto_relacionado pr 
inner join mig_cad mig on mig.cod_prod_wms = pr.cod_produto

