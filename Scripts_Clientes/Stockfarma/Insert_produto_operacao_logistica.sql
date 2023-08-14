-- Verifica os produtos que n�o existe na produto_operacao_logistica
select p.cod_situacao ,* from produto p 
left join produto_operacao_logistica pol on p.cod_produto = pol.cod_produto
where pol.cod_produto is null

-- insert produto_operacao_logistica

insert produto_operacao_logistica (cod_operacao_logistica, cod_produto, nao_confere_cf, confirma_lote_separacao_cf,separar_somente_flowrack,enderecamento_dinamico)
select 1, cod_produto, 0, 0,0,null
from produto eo
where not exists (select 1 from produto_operacao_logistica e where e.cod_produto = eo.cod_produto and e.cod_operacao_logistica = 1)

