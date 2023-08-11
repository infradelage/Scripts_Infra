
USE WMSRX
GO

--ROLLBACK
BEGIN TRAN
GO


--alter table migraestoque add data_validade smalldatetime
--alter table migraestoque add data_fabricacao smalldatetime

update migraestoque set DATA_VALIDADE = '2025-12-31', data_fabricacao = dateadd(d, -1, getdate())

produto
--SABER SE TEM PRODUTOS NA PLANILHA QUE NAO EXISTEM NO BANCO
select cod_produto_polo
from migraestoque 
where cod_produto_polo not in (select p.cod_produto_rel from produto_relacionado p (nolock))--17860 --5007
group by cod_produto_polo

select * from migraestoque where cod_produto_polo = '11762'


--SABER SE TEM ENDERECOS DUPLICADOS
select endereco_completo into #eP-- count(1) 
from endereco 
where id_def = 1
and nivel = 6
group by endereco_completo
having count(1) > 1

select endereco_completo into #eF-- count(1) 
from endereco 
where id_def = 2
and nivel = 6
group by endereco_completo
having count(1) > 1

--begin tran
--delete e
----select * 
--from endereco e
--inner join #e on e.endereco_completo = #e.endereco_completo
--where substring(e.id_endereco_completo,3,5) = '81352'
--rollback tran
--commit tran


select * from endereco where endereco_completo = 'P01.06.01.01'
delete m
--select cod_produto_polo, endereco_completo 
from migraestoque m
where m.endereco_completo not in (select endereco_completo from endereco)--17860 --5007
group by cod_produto_polo, endereco_completo


--update produto set controle_lote = 1
--update migraestoque set data_de_vencimento = '2021/02/28 00:00' where  data_de_vencimento = '2021/02/29 00:00'

--select (CONVERT(datetime, substring(data_de_fabricacao,1,11),121)) 
--from migraestoque l
--WHERE substring(data_de_fabricacao,1,4) not in('2012')
--and substring(data_de_fabricacao,6,2) = '01'

--select data_de_fabricacao
--from migraestoque l
--WHERE substring(data_de_fabricacao,1,4) not in '2014'

--drop table migraestoque


select* from migraestoque order by data_de_vencimento asc
select* from migraestoque order by data_De_fabricacao asc

--begin tran
--update migraestoque set lote = '2002302' where cod_produto_polo = 690716 and endereco = 'PS015203'
--update migraestoque set lote = '11110320' where cod_produto_polo = 678287 and endereco = 'PS025303'
--update migraestoque set lote = '639445' where cod_produto_polo = 701696 and endereco = 'PS025308'
--update migraestoque set endereco = replace(endereco,'.','')
--update migraestoque set lote = replace(lote,'.','')
--commit tran

--PEGAR A RAIZ DA LPN PARA SER USADO NO PROCESSO. 
--EXEMPLO: 00019200000000000001
select numero_prox_LPN from param_LPN 


--UPDATE PARAM_LPN SET numero_prox_LPN = '00019200000000001112'

--UPDATE PARAM_LPN SET numero_prox_LPN = '00019200000000000001'
--SELECT * FROM LPN

--PEGAR NO IDENTITY O PROXIMO NUMERO DA LPN 4 CASAS. 
--EXEMPLO: 00019200000000000001 => 00019200000000000001 + 1
drop table ee
--919583 5083
create table ee	(id_tabela int identity (2,1), cod_produto int, cod_produto_polo varchar (30), estoque int, lote varchar(30), 
data_validade smalldatetime, data_fabricacao smalldatetime, endereco varchar(30))

insert ee(cod_produto, cod_produto_polo, estoque, lote, data_validade, data_fabricacao, endereco)
select p.cod_produto, cod_produto_polo , [Estoque], '20240504', Convert(SMALLDATETIME, ecf.lote_validade, 103), 
Convert(SMALLDATETIME, ecf.data_fabricacao, 103), endereco_completo as endereco --into #ee-- into #E  ],
--select p.cod_produto, [cod_produto_polo], [Estoque], ecf.lote, convert(varchar(11),ecf.Vencimento,111) as vencimento, 
--convert(varchar(11),[DT_Fabricacao],111) as fabricacao, Endereco_WMS as endereco --into #ee-- into #E  ],
from produto p (nolock)
inner join produto_relacionado pr (nolock) on p.cod_produto = pr.cod_produto
INNER join migraestoque ecf on ecf.cod_produto_polo  = pr.cod_produto_rel
where ecf.estoque>0
--where [Estoque] > 0
--order by 7




--PRINT 'ITENS DELETADOS'
--DELETE isaldo_validade_220917 WHERE convert(varchar(20),cod_produto_polo) not in (select cod_produto_rel from produto_relacionado)

--select * from #E where cod_produto= 454
--select * from lote_estoque_lpn where id_lote = 3
--select * from lote where cod_produto= 454
--select * from isaldo_validade_220917 where cod_produto_polo = 220834

drop table #end
--CHECAR SE EXISTE ENDERECO DUPLICADO
SELECT endereco_completo into #end
FROM endereco 
WHERE id_def = 1 
AND nivel = 6

INSERT #end
SELECT endereco_completo
FROM endereco 
WHERE id_def = 2 
AND nivel = 6

PRINT 'ENDERECO DUPLICADO'
SELECT endereco_completo, count(*) 
FROM #end 
GROUP BY endereco_completo
HAVING count(*) > 1

--rollback tran
--delete endereco where id_endereco in (53249,4097,53268,53228,53265,53255,53277,53400,4098,3751,53254)
--IF (SELECT count(*) FROM endereco WHERE ENDERECO_COMPLETO = 'TP.01.01.A') is null GOTO Branch_One

--DELETE lote DBCC CHECKIDENT('[lote]', RESEED, 1)
begin tran
---DEFINITIVO---
ALTER TABLE lote DISABLE TRIGGER ALL
INSERT lote
SELECT L.cod_produto, L.LOTE, min(CONVERT(datetime, l.DATA_VALIDADE,105)) as validade, 1 as cod_situacao, 
getdate() as data_cadastro, null as emb_compra, min(CONVERT(datetime, l.DATA_FABRICACAO,105)) as data_fabricacao, 0 as lacre_seguranca,
1 as id_lote_classificacao_finalidade, null, null
FROM Ee L
WHERE NOT EXISTS (SELECT * FROM LOTE WHERE COD_PRODUTO = L.cod_produto AND LOTE = L.LOTE)
AND EXISTS (SELECT * FROM produto WHERE cod_produto = l.cod_produto)
AND L.LOTE IS NOT NULL
GROUP BY L.cod_produto, L.LOTE
ALTER TABLE lote ENABLE TRIGGER ALL

--INSERT LPN (numero, data_cadastro, cod_usuario, cod_operacao_logistica, id_endereco, id_LPN_pai, id_def_tipo_lpn, id_def_situacao_lpn)
--SELECT DISTINCT '00019200000000000001'  as numero, 
--								 getdate() as data_cadastro, 1 as cod_usuario, 1, e.id_endereco, NULL, 1, 1
--   FROM #E AS MIGRA WITH(NOLOCK),endereco AS e WITH(NOLOCK) 
--   WHERE e.id_endereco = 20477 --"FALTA INVENTARIO" CONFIRMAR EM PRODUCAO
----GROUP BY e.id_endereco
--ORDER BY 1

----CONFERIR COD_OPERACAO_LOGISTICA, POIS ESTA FIXO COMO 192
--- LPN ENDEREÇADA ---
INSERT LPN (numero, data_cadastro, cod_usuario, cod_operacao_logistica, id_endereco, id_LPN_pai, id_def_tipo_lpn, id_def_situacao_lpn)
SELECT (REPLICATE('0', 5 - LEN(CONVERT(VARCHAR(5), 19))) + RTrim(CONVERT(VARCHAR(5), 192))) +
								 REPLICATE('0', 13 - LEN(ROW_NUMBER() OVER (ORDER BY e.id_endereco))) + RTrim((CONVERT(VARCHAR(13), 
								 (ROW_NUMBER() OVER (ORDER BY e.id_endereco)) * 10 + dbo.CalcDigitoMod11(ROW_NUMBER() OVER (ORDER BY e.id_endereco))))) as numero, 
								 getdate() as data_cadastro, 1 as cod_usuario, 1, e.id_endereco, NULL, 1, 1
   FROM Ee AS MIGRA WITH(NOLOCK)
  INNER JOIN endereco AS e WITH(NOLOCK) ON '3978' = e.id_endereco --and e.id_def = 1 
GROUP BY e.id_endereco
ORDER BY 1

DISABLE TRIGGER trg_lote_estoque_LPN_sequencia ON lote_estoque_lpn

INSERT lote_estoque_lpn (id_lote, id_LPN, estoque, sequencia, data_cadastro)
SELECT l.id_lote, lpn.id_LPN, sum(MIGRA.estoque) as estoque, ROW_NUMBER() OVER (ORDER BY L.id_lote) AS sequencia,
getdate() as data_cadastro
  FROM lote AS L WITH(NOLOCK)
  INNER JOIN Ee AS MIGRA WITH(NOLOCK) ON l.cod_produto = MIGRA.cod_produto and l.lote = MIGRA.LOTE
  INNER JOIN endereco AS e WITH(NOLOCK) ON '3978' = e.id_endereco--and e.id_def = 1
  INNER JOIN LPN on LPN.id_endereco = e.id_endereco
  --where e.id_endereco = 12791
  --where MIGRA.cod_produto = 10465
GROUP BY l.id_lote, lpn.id_LPN,e.id_endereco, e.id_lote_classificacao, l.data_cadastro
ORDER BY 1
--select * into LPN_BKP_180620 from LPN

ENABLE TRIGGER trg_lote_estoque_LPN_sequencia ON lote_estoque_lpn

update lpn set numero = null

CREATE TABLE #LPN (id_lpn INT)

INSERT INTO #LPN
SELECT id_lpn
FROM lpn

DECLARE @id INT,
	@proximo_numero VARCHAR(20)

WHILE EXISTS (
		SELECT 1
		FROM #LPN
		)
BEGIN
	SELECT TOP 1 @id = id_lpn
	FROM #LPN

	EXEC stp_g_numero_lpn_gera 1,
		1,
		@proximo_numero OUTPUT

	UPDATE LPN
	SET numero = @proximo_numero
	WHERE id_lpn = @id

	DELETE #LPN
	WHERE id_lpn = @id
END

DROP TABLE #LPN

update def_tipo_endereco set tipo_sequencia_lote = 2 where id_tipo = 3
update lote set validade = validade
update def_tipo_endereco set tipo_sequencia_lote = 1 where id_tipo = 3

commit tran
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
update param_lpn set numero_prox_LPN = '00019200000000000002'


--VALIDA--
--select * from lpn where id_lpn = 72705
--select * from #E where id_tabela = 6334
--select * from lote where id_lote = 21044


--GOTO Branch_Two
--select * from produto_relacionado where cod_produto = 454


--Branch_One:
--    SELECT  MENSAGENS = 'EXISTE ENDERECO PARA TEMPORARIO'
--    UNION 
--    SELECT 'Exclua o endereço ou use o script de importação para um endereco Temporario.'
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


select p.cod_produto, p.descricao,e.endereco_completo, vw.estoque
from vw_lote_estoque vw
inner join endereco e on vw.id_endereco = e.id_endereco
inner join produto p on vw.cod_produto = p.cod_produto
order by e.endereco_completo asc

select * from endereco where endereco_completo = '101003051'

