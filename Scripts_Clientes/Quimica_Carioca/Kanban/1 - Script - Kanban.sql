--TABELA PARA TRABALHAR E NO FIM DELETAR
drop table mig_kanban_trabalho
select * INTO mig_kanban_trabalho from kanban_saldo


--VERIFICA SE A PLANILHA ENVIADA SEGUE AS REGRAS DO KANBAN
select * from mig_kanban_trabalho where convert(int,minimo) >= convert(int,maximo)


--VENDO OS PRODUTOS QUE EXISTEM NA BASE
select p.cod_produto,pr.*
from produto p (nolock)
inner join produto_relacionado pr (nolock) on p.cod_produto = pr.cod_produto
--inner join mig_kanban_trabalho mk (nolock) on try_convert(BIGINT, pr.cod_produto_rel) = try_convert(BIGINT, mk.cod_prod_daki)
inner join mig_kanban_trabalho mk (nolock) on pr.cod_produto_rel= mk.cod_prod_daki
--WHERE m.cod_sku = 759821

--VENDO OS PRODUTOS QUE NÃO EXISTEM NA BASE
select mk.cod_prod_daki as Mig ,pr.cod_produto as Prod_Rel,ptae.cod_produto as Prod_Tipo_Armz,p.cod_produto as Produto 
from mig_kanban_trabalho mk
	LEFT JOIN produto_relacionado pr on try_convert(BIGINT, pr.cod_produto_rel) = try_convert(BIGINT, mk.cod_prod_daki)
	LEFT JOIN produto_tipo_armazenagem_endereco ptae on ptae.cod_produto = pr.cod_produto
    LEFT JOIN produto p on  p.cod_produto = ptae.cod_produto
where  pr.cod_produto_rel is null


--VENDO OS PRODUTOS QUE NÃO EXISTEM NA BASE
select *
--mk.cod_sku, mk.descricao as Mig
from mig_kanban_trabalho mk
where not exists (select 1 from produto_relacionado pr where try_convert(BIGINT, pr.cod_produto_rel) = try_convert(BIGINT, mk.cod_prod_daki))
and try_convert(BIGINT, mk.cod_prod_daki)<> '0'


-- EM CASO DE ATUALIZAÇÂO DO KANBAN NÂO EXECUTAR O SCRIPT DE DELETE GERAL DA produto_tipo_armazenagem_endereco
-- USE ESTE ABAIXO QUE SO DELETA O QUE ESTA NA MIG

delete produto_tipo_armazenagem_endereco where cod_produto in ( 
		select p.cod_produto
		from produto p
		inner join produto_relacionado pr on p.cod_produto = pr.cod_produto
		inner join mig_kanban_trabalho mk on pr.cod_produto_rel = mk.cod_prod_daki) 


--LIMPE A TABELA QUANDO FOR FAZER UM INSER GERAL E INSERE AS REGRAS DO KANBAN

DELETE produto_tipo_armazenagem_endereco DBCC CHECKIDENT(produto_tipo_armazenagem_endereco, RESEED, 1)

--INSERE AS REGRAS DO KANBAN
insert produto_tipo_armazenagem_endereco (id_tipo_armazenamento_endereco, cod_produto, minimo, maximo, multiplo, quantidade_max_endereco, 
id_def_tipo_controle_armazenagem )
select 1, pr.cod_produto, convert(money,mk.minimo,0), convert(money,mk.maximo,0), convert(money,mk.multiplo,0), 0, 1
  from produto p
  inner join produto_relacionado pr on p.cod_produto = pr.cod_produto
  inner join mig_kanban_trabalho mk on pr.cod_produto_rel = mk.cod_prod_daki -- SEMPRE CONFERIR QUAL O CODIGO DO PRODUTO QUE ELE ESTA PASSANDO LEGADO OU DO WMS
  WHERE convert(money,mk.multiplo,0) <= convert(money,mk.maximo,0)
  and convert(money,mk.maximo,0) > convert(money,mk.minimo,0)
  and mk.cod_prod_daki not in ('0','')
  --and isnull(t.minimo,0) <> 0
  --AND NOT EXISTS (select 1 from mig_kanban_trabalho where convert(int,t.minimo) >= convert(int,t.maximo)) -- retira do select os enderecos que nao atendem a regra


--- Finaliza Kanban