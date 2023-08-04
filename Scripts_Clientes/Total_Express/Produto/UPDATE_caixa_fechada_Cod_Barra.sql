--INSERT DOS QUE NÃO EXISTEM
insert caixa_fechada
select mig.EAN,pr.cod_produto,1,'1.00',1,null,null,null,null
from mig_cad mig
inner join produto_relacionado pr on pr.cod_produto_rel = mig.cod_prod_sku and pr.cod_operacao_logistica = 5926
--inner join caixa_fechada cf on cf.cod_produto = pr.cod_produto
where pr.cod_produto in (select cod_produto from caixa_fechada)



--UPDATE DOS QUE EXEXISTEM COD_PRODUTO NA CAIXA_FECHADA MAS O COD_BARRA ESTA DIFERENTE
UPDATE  cf set cf.cod_barra = mig.EAN 
--select mig.EAN,pr.cod_produto,1,'1.00',1,null,null,null,null
from mig_cad mig
inner join produto_relacionado pr on pr.cod_produto_rel = mig.cod_prod_sku and pr.cod_operacao_logistica = 5926
inner join caixa_fechada cf on cf.cod_produto = pr.cod_produto
where pr.cod_produto in (select cod_produto from caixa_fechada)
and mig.EAN not in (select cod_barra from caixa_fechada)