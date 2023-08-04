
USE WMSRXTeste

--drop table #prod_serie

create table #prod_serie ( contador int identity(1,1), cod_produto int, cod_pedido_entrada int, data_cadastro datetime, id_lpn int, id_lote int, numero varchar (200))

insert #prod_serie (cod_produto,cod_pedido_entrada,data_cadastro, id_lpn, id_lote, numero)
select pr.cod_produto, ped.cod_pedido, Convert(SMALLDATETIME, getdate(), 103), l.id_lpn, le.id_lote, m.numero
from mig_controle m
inner join produto_relacionado pr on RTRIM(m.cod_produto) = pr.cod_produto_rel
inner join vw_lote_estoque le on pr.cod_produto = le.cod_produto
inner join lpn l on l.id_endereco = le.id_endereco
inner join lote  on le.id_lote = lote.id_lote and m.lote = lote.lote
inner join def_lote_classificacao_finalidade def on lote.id_lote_classificacao_finalidade = def.id_lote_classificacao_finalidade and RTRIM(m.finalidade) = def.descricao
inner join pedido ped  on ped.obs_PN = 'Migração inicial de estoque'
--where m.cod_produto = 231133--     and m.lote = '202241'    
group by pr.cod_produto,id_lpn, le.id_lote, m.numero, ped.cod_pedido
GO

   
DELETE produto_serie_numero DBCC CHECKIDENT(produto_serie_numero, RESEED, 1)
DELETE produto_serie --DBCC CHECKIDENT(produto_serie, RESEED, 1)

GO

insert produto_serie(id_produto_serie,cod_produto,cod_pedido_entrada,data_cadastro, id_lpn, id_lote)
select contador,cod_produto,cod_pedido_entrada,data_cadastro, id_lpn, id_lote
from #prod_serie
order by contador asc

GO

insert produto_serie_numero (id_produto_serie,id_Def_produto_serie,numero_serie, rastreabilidade, modelo_impressao, bloqueio, data_alteracao)
select ps.contador, 2 as is_def_produto_serie, m.numero, m.numero, 1 as modelo_impressora, 0 as bloqueio, ps.data_cadastro
from #prod_serie ps
inner join produto_relacionado pr on ps.cod_produto = pr.cod_produto
inner join mig_controle m on pr.cod_produto_rel = RTRIM(m.cod_produto)
inner join lote l on m.lote = l.lote and ps.id_lote = l.id_lote and l.cod_produto = ps.cod_produto and ps.numero = m.numero
inner join def_lote_classificacao_finalidade def on l.id_lote_classificacao_finalidade = def.id_lote_classificacao_finalidade and def.descricao = m.finalidade
--where pr.cod_produto_rel = 113498 and numero = '1134981010102106299880017640009240920220000'
group by ps.contador, m.numero, m.numero, ps.data_cadastro
order by ps.contador asc
    