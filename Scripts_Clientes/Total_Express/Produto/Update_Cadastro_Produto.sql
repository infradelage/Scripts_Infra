--VALIDA PRODUTO ENTRE MIG E PRODUTO
select convert(varchar(100),cod_prod_sku),descricao
from mig_cad 
where   cod_prod_sku not in (select convert(varchar(100),p.cod_produto_rel)  from produto_relacionado p (nolock))--17860 --5007
--where   cod_produto  not in (select p.cod_produto  from produto_relacionado p (nolock))--17860 --5007
group by cod_prod_sku,descricao




-- TROCA VIRGULA POR PONTO
update mig_cad set preco_custo = replace(preco_custo,',','.')
update mig_cad set comprimento = replace(comprimento,',','.')
update mig_cad set largura = replace(largura,',','.')
update mig_cad set altura = replace(altura,',','.')



--UPDATE NO CADASTRO DE PRODUTO
UPDATE produto  SET 
descricao = substring(mig.descricao,1,79),
ALTURA = mig.ALTURA,
LARGURA = mig.LARGURA,
COMPRIMENTO = mig.COMPRIMENTO,
peso = mig.PESO,
emb_compra = mig.emb_compra,
preco = mig.preco_custo,
controle_lote = mig.controle_lote
--SELECT distinct mig.*,pr.cod_produto
FROM mig_cad mig
inner join produto_relacionado pr on pr.cod_produto_rel = mig.EAN
INNER join produto p on p.cod_produto =  pr.cod_produto
where mig.ean  = '3661734395588'
--order by p.cod_produto


select * from produto where cod_produto = 26636