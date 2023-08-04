
--USE WMSRX
GO

--ROLLBACK
BEGIN TRAN
GO


--alter table migraestoque add data_validade smalldatetime
--alter table migraestoque add dt_fabricacao smalldatetime

update mig_estoque set dt_validade = '2025-12-31', dt_fabricacao = dateadd(d, -1, getdate())


--PASSO 1
--SABER SE TEM PRODUTOS NA PLANILHA QUE NAO EXISTEM NO BANCO
select convert(varchar(100),cod_prod_sku),descricao
from mig_estoque 
where   cod_prod_sku not in (select convert(varchar(100),p.cod_produto_rel)  from produto_relacionado p (nolock))--17860 --5007
--where   cod_produto  not in (select p.cod_produto  from produto_relacionado p (nolock))--17860 --5007
group by cod_prod_sku,descricao

SELECT * FROM mig_estoque where cod_prod_sku = '0001319'
select *  from produto_relacionado where cod_produto_rel = '0000500'
select controle_lote,*  from produto where (cod_produto) = (0000500)



--PASSO 2
--VER SE TODOS OS ENDERECOS EXISTEM NA BASE
select cod_prod_sku, endereco
from mig_estoque m
where m.endereco not in (select endereco_completo from endereco)--17860 --5007
group by cod_prod_sku, endereco

--
select --MAX(dt_fabricacao)
YEAR(convert(date, dt_fabricacao,105)) ano,
month(convert(date, dt_fabricacao,105)) mes,
day(convert(date, dt_fabricacao,105)) dia
from mig_estoque
GROUP BY dt_fabricacao
order by dt_fabricacao asc


select --MAX(dt_validade)
YEAR(convert(date, dt_validade,105)) ano,
month(convert(date, dt_validade,105)) mes,
day(convert(date, dt_validade,105)) dia
from mig_estoque
GROUP BY dt_validade
order by dt_validade asc


update mig_estoque set estoque = replace(estoque,',','.')




--PEGAR A RAIZ DA LPN PARA SER USADO NO PROCESSO. 
--EXEMPLO: 00019200000000000001
--select numero_prox_LPN from param_LPN 

--PASSO 3
--PEGAR NO IDENTITY O PROXIMO NUMERO DA LPN 4 CASAS. 
--EXEMPLO: 00019200000000000001 => 00019200000000000001 + 1
drop table ee -- PASSO 1
--919583 5083
create table ee	(id_tabela int identity (2,1), cod_produto int, cod_erp varchar (30), estoque money, lote varchar(30), 
dt_validade smalldatetime, dt_fabricacao smalldatetime, endereco varchar(30))

insert ee(cod_produto, cod_erp, estoque, lote, dt_validade, dt_fabricacao, endereco)
select p.cod_produto, ecf.cod_prod_sku , ecf.Estoque, ecf.lote, Convert(SMALLDATETIME, ecf.dt_validade, 103), 
Convert(SMALLDATETIME, ecf.dt_fabricacao, 103), ecf.endereco as endereco --into #ee-- into #E  ],
--select p.cod_produto, [cod_erp], [Estoque], ecf.lote, convert(varchar(11),ecf.Vencimento,111) as vencimento, 
--convert(varchar(11),[DT_Fabricacao],111) as fabricacao, endereco as endereco --into #ee-- into #E  ],
from produto p (nolock)
inner join produto_relacionado pr (nolock) on p.cod_produto = pr.cod_produto
INNER join mig_estoque ecf on ecf.cod_prod_sku  = pr.cod_produto_rel and pr.cod_operacao_logistica = 5926
--where pr.
--order by 7


--PRINT 'ITENS DELETADOS'
--DELETE isaldo_validade_220917 WHERE convert(varchar(20),cod_erp) not in (select cod_produto_rel from produto_relacionado)

--select * from #E where cod_produto= 454
--select * from lote_estoque_lpn where id_lote = 3
--select * from lote where cod_produto= 454
--select * from isaldo_validade_220917 where cod_erp = 220834

--drop table #end
----CHECAR SE EXISTE ENDERECO DUPLICADO
--SELECT endereco_completo into #end
--FROM endereco 
--WHERE id_def = 1 
--AND nivel = 6

--INSERT #end
--SELECT endereco_completo
--FROM endereco 
--WHERE id_def = 2 
--AND nivel = 6

--PRINT 'ENDERECO DUPLICADO'
--SELECT endereco_completo, count(*) 
--FROM #end 
--GROUP BY endereco_completo
--HAVING count(*) > 1

--rollback tran
--delete endereco where id_endereco in (53249,4097,53268,53228,53265,53255,53277,53400,4098,3751,53254)
--IF (SELECT count(*) FROM endereco WHERE ENDERECO_COMPLETO = 'TP.01.01.A') is NULL, GOTO Branch_One

--DELETE lote DBCC CHECKIDENT('[lote]', RESEED, 1)
--begin tran

--PASS0 4
---DEFINITIVO---
ALTER TABLE lote DISABLE TRIGGER ALL
INSERT lote
SELECT L.cod_produto, L.LOTE, min(CONVERT(datetime, l.dt_validade,105)) as validade, 1 as cod_situacao, 
getdate() as data_cadastro, null as emb_compra, min(CONVERT(datetime, l.dt_fabricacao,105)) as data_fabricacao, 1,1, null,null,0 as laudo
FROM Ee L
WHERE NOT EXISTS (SELECT * FROM LOTE WHERE COD_PRODUTO = L.cod_produto AND LOTE = L.LOTE)
AND EXISTS (SELECT * FROM produto WHERE cod_produto = l.cod_produto)
AND L.LOTE IS NOT NULL
GROUP BY L.cod_produto, L.LOTE
ALTER TABLE lote ENABLE TRIGGER ALL 

--INSERT LPN (numero, data_cadastro, cod_usuario, cod_operacao_logistica, id_endereco, id_LPN_pai, id_def_tipo_lpn, id_def_situacao_lpn)
--SELECT DISTINCT '00019200000000000001'  as numero, 
--								 getdate() as data_cadastro, 1 as cod_usuario, 1, e.id_endereco, NULL,, 1, 1
--   FROM #E AS MIGRA WITH(NOLOCK),endereco AS e WITH(NOLOCK) 
--   WHERE e.id_endereco = 20477 --"FALTA INVENTARIO" CONFIRMAR EM PRODUCAO
----GROUP BY e.id_endereco
--ORDER BY 1

--PASSO 5
----CONFERIR COD_OPERACAO_LOGISTICA, POIS ESTA FIXO COMO 192
--- LPN ENDERE�ADA ---
INSERT LPN (numero, data_cadastro, cod_usuario, cod_operacao_logistica, id_endereco, id_LPN_pai, id_def_tipo_lpn, id_def_situacao_lpn)
SELECT (REPLICATE('0', 5 - LEN(CONVERT(VARCHAR(5), 19))) + RTrim(CONVERT(VARCHAR(5), 192))) +
								 REPLICATE('0', 13 - LEN(ROW_NUMBER() OVER (ORDER BY e.id_endereco))) + RTrim((CONVERT(VARCHAR(13), 
								 (ROW_NUMBER() OVER (ORDER BY e.id_endereco)) * 10 + dbo.CalcDigitoMod11(ROW_NUMBER() OVER (ORDER BY e.id_endereco))))) as numero, 
								 getdate() as data_cadastro, 1 as cod_usuario, cod_operacao_logistica, e.id_endereco, NULL, 1, 1
   FROM Ee AS MIGRA WITH(NOLOCK)
  INNER JOIN endereco AS e WITH(NOLOCK) ON MIGRA.ENDERECO = e.endereco_completo --and e.id_def = 1 
GROUP BY e.id_endereco
ORDER BY 1


--PASSO 5
DISABLE TRIGGER trg_lote_estoque_LPN_sequencia ON lote_estoque_lpn
INSERT lote_estoque_lpn (id_lote, id_LPN, estoque, sequencia, data_cadastro,id_lote_classificacao,rastreabilidade,cod_pedido_entrada,rastreio_realizado)
SELECT l.id_lote, lpn.id_LPN, sum(MIGRA.estoque) as estoque, ROW_NUMBER() OVER (ORDER BY L.id_lote) AS sequencia,
getdate() as data_cadastro,1,0,0,0
  FROM lote AS L WITH(NOLOCK)
  INNER JOIN Ee AS MIGRA WITH(NOLOCK) ON l.cod_produto = MIGRA.cod_produto and l.lote = MIGRA.LOTE
  INNER JOIN endereco AS e WITH(NOLOCK) ON MIGRA.ENDERECO = e.endereco_completo --and e.id_def = 1
  INNER JOIN LPN on LPN.id_endereco = e.id_endereco
  --where e.id_endereco = 12791
  --where MIGRA.cod_produto = 10465
GROUP BY l.id_lote, lpn.id_LPN,e.id_endereco, e.id_lote_classificacao, l.data_cadastro
ORDER BY 1
--select * into LPN_BKP_180620 from LPN
GO
ENABLE TRIGGER trg_lote_estoque_LPN_sequencia ON lote_estoque_lpn




--PASSO 6
update lpn set numero = NULL
update def_tipo_endereco set tipo_sequencia_lote = 2 where id_tipo = 3
update lote set validade = validade
update def_tipo_endereco set tipo_sequencia_lote = 1 where id_tipo = 3

--commit tran
----783
--INSERT lote_estoque_lpn (id_lote, id_LPN, estoque, sequencia, data_cadastro)
--SELECT l.id_lote, lpn.id_LPN, sum(MIGRA.estoque) as estoque, ROW_NUMBER() OVER (ORDER BY L.id_lote) AS sequencia,
--getdate() as data_cadastro
-- --select LPN.*
-- FROM lote AS L WITH(NOLOCK)
--  INNER JOIN #E AS MIGRA WITH(NOLOCK) ON l.cod_produto = MIGRA.cod_produto and l.lote = MIGRA.LOTE
--  INNER JOIN endereco AS e WITH(NOLOCK) ON E.endereco_completo = MIGRA.endereco
--  INNER JOIN LPN on LPN.id_endereco = E.id_endereco 
--  and lpn.cod_operacao_logistica = 1
--  WHERE  e.id_endereco = 20477
--GROUP BY l.id_lote, lpn.id_LPN,e.id_endereco, e.id_lote_classificacao, l.data_cadastro
--ORDER BY 1


-- PEGAR A RAIZ DA LPN UTILIZADA ACIMA + O ULTIMO VALOR DA COLUNA ID_TABELA DOA TEMPORARIA + 1
-- EXEMPLO: 000192091956214 + 9493 + 1 = 0001920919562149494
--update param_lpn set numero_prox_LPN = '00019200000000000002'


--VALIDA--
--select * from lpn where id_lpn = 72705
--select * from #E where id_tabela = 6334
--select * from lote where id_lote = 21044


--GOTO Branch_Two
--select * from produto_relacionado where cod_produto = 454


--Branch_One:
--    SELECT  MENSAGENS = 'EXISTE ENDERECO PARA TEMPORARIO'
--    UNION 
--    SELECT 'Exclua o endere�o ou use o script de importa��o para um endereco Temporario.'
--    UNION
--    SELECT 'EXECUTE ROLLBACK'
--    GOTO Branch_Two; --This will prevent Branch_Two from executing.

--Branch_Two:
--PRINT 'ESTOQUE MIGRADO'
--SELECT CONVERT(VARCHAR(30),sum(estoque)) as ESTOQUE_MIGRADO from lote_estoque_lpn
--PRINT 'ESTOQUE PLANILHA'
--SELECT CONVERT(VARCHAR(30),sum(estoque)) as ESTOQUE_MIGRADO from isaldo_validade_220917 

--UNION
SELECT 'Se o processamento deu certo:'
UNION
SELECT 'EXECUTE COMMIT'
GO

DROP TABLE #E
-- COMMIT 
-- ROLLBACK 


select SUM( vw.estoque) --p.cod_produto, p.descricao,e.endereco_completo,
from vw_lote_estoque vw
inner join endereco e on vw.id_endereco = e.id_endereco
inner join produto p on vw.cod_produto = p.cod_produto
--order by e.endereco_completo asc

--RELATORIO DE IMPORTAÇÃO
select p.cod_produto, p.descricao,e.endereco_completo,vw.estoque
from vw_lote_estoque vw
inner join endereco e on vw.id_endereco = e.id_endereco
inner join produto p on vw.cod_produto = p.cod_produto
where p.cod_produto = 1869


--VALIDA A SOMA DO ESTOQUE COM A SOMA DO ESTOUE DA MIG_ESTOQUE
select sum (estoque) from vw_lote_estoque
select sum (convert(int,estoque)) from mig_estoque

--PRINT 'ESTOQUE MIGRADO'
SELECT CONVERT(VARCHAR(30),sum(estoque)) as ESTOQUE_MIGRADO from lote_estoque_lpn
--PRINT 'ESTOQUE PLANILHA'
SELECT CONVERT(VARCHAR(100),SUM(CAST(estoque as money))) as ESTOQUE_PLANILHA from mig_estoque

