--TABELA PARA TRABALHAR E NO FIM DELETAR
drop table mig_kanban_trabalho
select * INTO mig_kanban_trabalho from mig_kanban

--VERIFICA SE A PLANILHA ENVIADA SEGUE AS REGRAS DO KANBAN
select * from mig_kanban_trabalho where convert(int,minimo) >= convert(int,maximo)


--VENDO OS PRODUTOS QUE EXISTEM NA BASE
select p.* 
from produto p (nolock)
inner join produto_relacionado pr (nolock) on p.cod_produto = pr.cod_produto
inner join mig_kanban_trabalho m (nolock) on pr.cod_produto_rel = m.cod_produto
--WHERE m.cod_produto = 46848

--VENDO OS PRODUTOS QUE Nao EXISTEM NA BASE
select kb.cod_produto as Mig ,pr.cod_produto as Prod_Rel,ptae.cod_produto as Prod_Tipo_Armz,p.cod_produto as Produto from mig_kanban_trabalho kb
	LEFT JOIN produto_relacionado pr on pr.cod_produto_rel = kb.cod_produto
	LEFT JOIN produto_tipo_armazenagem_endereco ptae on ptae.cod_produto = pr.cod_produto
    LEFT JOIN produto p on  p.cod_produto = ptae.cod_produto
where  pr.cod_produto_rel is null


--LIMPA A TABELA E INSERE AS REGRAS DO KANBAN
delete produto_tipo_armazenagem_endereco
insert produto_tipo_armazenagem_endereco (id_tipo_armazenamento_endereco, cod_produto, minimo, maximo, multiplo, quantidade_max_endereco, 
id_def_tipo_controle_armazenagem )
select 1, pr.cod_produto, round(t.minimo,0), round(t.maximo,0), t.multiplo, null, 1
  from produto p
  inner join produto_relacionado pr on p.cod_produto = pr.cod_produto
  inner join mig_kanban_trabalho t on pr.cod_produto = t.cod_produto -- SEMPRE CONFERIR QUAL O CODIGO DO PRODUTO QUE ELE ESTA PASSANDO LEGADO OU DO WMS
  WHERE t.multiplo != '' --Valida se esta vazio

--and pr.cod_produto_rel not in (16799)
--group by pr.cod_produto, round(t.minimo,0), round(t.maximo,0), t.multiplo

--#### CASO OCORRA ERRO AO EXECUTAR O SCRIPT ACIMA INFORMANDO ####
--the insert statement conflicted with the foreign key constraint "FK_produto_tipo_armazenagem_endereco_produto"
--the conflict occurred in database "WMSRX", table "dbo.produto", colum "cod_produto"
-- este erro acontece devido a duplicidde na tabela MIG

--#### Cria uma tabela temporaria com os duplicados ####
select cod_produto_rel, count(1) as contador into #tempduplicados
from mig_kanban_trabalho
group by cod_produto_rel
having count(1) > 1

-- Gera um comparação entre a mig_kanban_trabalho e a tabela temporaria criada acima
select *
from mig_kanban_trabalho
where cod_produto_rel in (
select cod_produto_rel
from #p)
--order by 2

--- Finaliza Kanban