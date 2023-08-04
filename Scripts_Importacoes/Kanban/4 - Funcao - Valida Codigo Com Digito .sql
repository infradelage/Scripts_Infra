SELECT * FROM PRODUTO WHERE cod_produto = 15
SELECT * FROM mig_kanban_trabalho WHERE cod_sku = 159
SELECT * FROM produto_relacionado WHERE cod_produto = 15

-- FUNÇÃO QUE VALIDA O CODIGO ENVIADO TENDO DIGITO COM O CAMPO DA TABELA PRODUTO CONCATENANDO O DIGITO
select p.cod_produto AS Cod_Prod, p.digito ,m.cod_sku, p.descricao As DESC_PROD, m.descricao As DESC_PROD_MIG
from produto p
inner join mig_kanban_trabalho m on p.cod_produto*10 + dbo.calcDigitoMod11(p.cod_produto) = m.cod_sku


