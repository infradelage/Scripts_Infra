USE WMSRX
GO

--PASSO 1 
--SABER SE TEM PRODUTOS NA PLANILHA QUE NAO EXISTEM NO BANCO
select codigo_erp
from mig_estoque 
where codigo_erp not in (select p.cod_produto_rel from produto_relacionado p (nolock))--17860 --5007
group by codigo_erp 

----SABER SE TEM ENDERECOS DUPLICADOS
select endereco_completo --into #eP-- count(1) 
from endereco 
where id_def = 1
and nivel = 6
group by endereco_completo
having count(1) > 1

--PASSO 2
--VER SE TODOS OS ENDERECOS EXISTEM NA BASE
select codigo_erp, endereco_wms
from mig_estoque m
where m.endereco_wms not in (select endereco_completo from endereco)--17860 --5007
group by codigo_erp, endereco_wms


--PASSO 3
--VER SE TODOS AS FINALIDADES EXISTEM NA BASE
select cod_produto, endereco 
from mig_estoque m
where m.finalidade not in (select descricao from def_lote_classificacao_finalidade)--17860 --5007
group by cod_produto, endereco


--PEGAR A RAIZ DA LPN PARA SER USADO NO PROCESSO. 
--EXEMPLO: 00019200000000000001
select numero_prox_LPN from param_LPN 

--PASSO 4
--PEGAR NO IDENTITY O PROXIMO NUMERO DA LPN 4 CASAS. 
--EXEMPLO: 00019200000000000001 => 00019200000000000001 + 1
drop table ee 
create table ee	(id_tabela int identity (2,1), cod_produto int, codigo_erp varchar (30), estoque int, lote varchar(30), 
data_validade smalldatetime, data_fabricacao smalldatetime, endereco varchar(30), id_endereco int, endereco_nivel_2 varchar(30))

--PASSO 5
--INSERE OS DADOS DE ESTOQUE NA TABELA EE
insert ee(cod_produto, codigo_erp, estoque, lote, data_validade, data_fabricacao, endereco, id_endereco, endereco_nivel_2)
select p.cod_produto, ecf.codigo_erp , ecf.Estoque, ecf.lote, Convert(SMALLDATETIME, ecf.data_vencimento, 103), 
Convert(SMALLDATETIME, ecf.data_fabricacao, 103), endereco_wms as endereco, e.id_endereco,
Classificacao_wms as  endereco_nivel_2 --into #ee
from produto p (nolock)
inner join produto_relacionado pr (nolock) on p.cod_produto = pr.cod_produto
INNER join mig_estoque ecf on ecf.codigo_erp  = pr.cod_produto_rel
  INNER JOIN endereco AS e WITH(NOLOCK) ON ecf.endereco_wms = e.endereco_completo --and e.id_def = 1 
  INNER JOIN endereco AS e6 WITH(NOLOCK) ON e.id_pai = e6.id_endereco --and e.id_def = 1 
  INNER JOIN endereco AS e5 WITH(NOLOCK) ON e6.id_pai = e5.id_endereco --and e.id_def = 1 
  INNER JOIN endereco AS e4 WITH(NOLOCK) ON e5.id_pai = e4.id_endereco --and e.id_def = 1 
  INNER JOIN endereco AS e3 WITH(NOLOCK) ON e4.id_pai = e3.id_endereco --and e.id_def = 1 
  INNER JOIN endereco AS e2 WITH(NOLOCK) ON e3.id_pai = e2.id_endereco  and e2.endereco = ecf.Classificacao_wms 
--inner join def_lote_classificacao_finalidade d on ecf.finalidade = d.descricao
--where [Estoque] > 0
--order by 7


--PASS0 6
---DEFINITIVO---
ALTER TABLE lote DISABLE TRIGGER ALL
INSERT lote
SELECT L.cod_produto, L.LOTE, min(CONVERT(datetime, l.DATA_VALIDADE,105)) as validade, 1 as cod_situacao, 
getdate() as data_cadastro, null as emb_compra, min(CONVERT(datetime, l.DATA_FABRICACAO,105)) as data_fabricacao, 
null as laudo, 0, 1
FROM Ee L
WHERE NOT EXISTS (SELECT * FROM LOTE WHERE COD_PRODUTO = L.cod_produto AND LOTE = L.LOTE)
AND EXISTS (SELECT * FROM produto WHERE cod_produto = l.cod_produto)
AND L.LOTE IS NOT NULL
GROUP BY L.cod_produto, L.LOTE
order by 1
ALTER TABLE lote ENABLE TRIGGER ALL
--order by 10

--PASSO 6
--******#####*CONFERIR COD_OPERACAO_LOGISTICA*#####**********
SELECT * FROM ENTIDADE WHERE cod_tipo = '14' 
--- LPN ENDERE�ADA ---
INSERT LPN (numero, data_cadastro, cod_usuario, cod_operacao_logistica, id_endereco, id_LPN_pai, id_def_tipo_lpn, id_def_situacao_lpn)
SELECT (REPLICATE('0', 5 - LEN(CONVERT(VARCHAR(5), 19))) + RTrim(CONVERT(VARCHAR(5), 192))) +
								 REPLICATE('0', 13 - LEN(ROW_NUMBER() OVER (ORDER BY migra.id_endereco))) + RTrim((CONVERT(VARCHAR(13), 
								 (ROW_NUMBER() OVER (ORDER BY migra.id_endereco)) * 10 + dbo.CalcDigitoMod11(ROW_NUMBER() OVER (ORDER BY migra.id_endereco))))) as numero, 
								 getdate() as data_cadastro, 1 as cod_usuario, 1, migra.id_endereco, NULL, 1, 1
   FROM Ee AS MIGRA WITH(NOLOCK)

GROUP BY migra.id_endereco
ORDER BY 1



--PASSO 7
DISABLE TRIGGER trg_lote_estoque_LPN_sequencia ON lote_estoque_lpn
INSERT lote_estoque_lpn (id_lote, id_LPN, estoque, sequencia, data_cadastro)
SELECT l.id_lote, lpn.id_LPN, sum(MIGRA.estoque) as estoque, ROW_NUMBER() OVER (ORDER BY L.id_lote) AS sequencia,
getdate() as data_cadastro
  FROM lote AS L WITH(NOLOCK)
  INNER JOIN Ee AS MIGRA WITH(NOLOCK) ON l.cod_produto = MIGRA.cod_produto 
											and l.lote = MIGRA.LOTE 											
  INNER JOIN endereco AS e WITH(NOLOCK) ON MIGRA.id_endereco = e.id_endereco --and e.id_def = 1
    INNER JOIN LPN on LPN.id_endereco = e.id_endereco
  --where e.id_endereco = 12791
  --where MIGRA.cod_produto = 10465
GROUP BY l.id_lote, lpn.id_LPN,e.id_endereco, e.id_lote_classificacao, l.data_cadastro
ORDER BY 1
--select * into LPN_BKP_180620 from LPN
GO
ENABLE TRIGGER trg_lote_estoque_LPN_sequencia ON lote_estoque_lpn

--PASSO 6
update lpn set numero = null
update def_tipo_endereco set tipo_sequencia_lote = 2 where id_tipo = 3
update lote set validade = validade
update def_tipo_endereco set tipo_sequencia_lote = 1 where id_tipo = 3


-- COMMIT 
-- ROLLBACK 


select p.cod_produto, p.descricao,e.endereco_completo, vw.estoque
from vw_lote_estoque vw
inner join endereco e on vw.id_endereco = e.id_endereco
inner join produto p on vw.cod_produto = p.cod_produto
order by e.endereco_completo asc


--VALIDA A SOMA DO ESTOQUE COM A SOMA DO ESTOUE DA MIG_ESTOQUE
select sum (estoque) from vw_lote_estoque
select sum (convert(int,estoque)) from mig_estoque