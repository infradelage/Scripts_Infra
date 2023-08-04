-- davi.cardoso@2019-05-09 11:29:24: <select comentado quando qtd_impressoes não é nulo>  
-- davi.cardoso@2019-05-07 10:59:38: <nomes atribuídos para as colunas sigla e cod_externo>  
-- jorge.moreira@2018-06-26 13:19:22: <alteração no cáclulo do dia de entrega com base nos feriados para incluir feriados anualmente recorrentes>  
-- DELAGE\jonathan.muniz@2018-01-30 14:37:34: <tratativa da sigla do cep>  
-- DELAGE\jonathan.muniz@2018-01-29 14:08:39: <tratativa da sigla_transportadora>  
-- jorge.moreira@2018-01-29 13:42:15: <cáclulo do dia de entrega com base nos feriados>  
CREATE OR ALTER PROCEDURE stp_WMS_etiqueta_le_embarque 
@cod_prenota_ini INT  
 ,@cod_prenota_fim INT  
 ,@cod_operacao_logistica INT  
 ,@situacao INT = NULL  
 ,@caixa_fechada SMALLINT = NULL  
 ,@volume_ini INT = NULL  
 ,@volume_fim INT = NULL  
 ,@cod_distribuicao INT = NULL  
 ,@qtd_impressoes INT = NULL  
AS  
DECLARE @imprime_etiqueta_pedido_filho BIT  
DECLARE @volume INT  
   
SELECT @imprime_etiqueta_pedido_filho = ISNULL(imprime_etiqueta_pedido_filho, 1)  
FROM param_agrupamento_volume  
   
-- drop table #pedidos drop table #pedidos_embarque    
CREATE TABLE #pedidos (  
 cod_pedido INT  
 ,volume INT  
 )  
   
CREATE TABLE #pedidos_embarque (  
 cod_pedido INT  
 ,volume INT  
 ,volumes INT  
 )  
   
IF @qtd_impressoes IS NULL  
BEGIN  
 --declare    
 --@cod_prenota_ini int = 2,    
 --@cod_prenota_fim int = 2,    
 --@volume_ini int = 1,    
 --@volume_fim int = 21    
 INSERT #pedidos (  
  cod_pedido  
  ,volume  
  )  
 SELECT p.cod_pedido  
  ,pv.volume  
 FROM pedido p  
 LEFT JOIN pedido_volume pv(NOLOCK) ON pv.cod_pedido = p.cod_pedido  
 LEFT JOIN vw_pedido_item_volume piv(NOLOCK) ON p.cod_pedido = pv.cod_pedido  
  AND piv.volume = pv.volume  
 LEFT JOIN  
  --pedido_volume pv (NOLOCK) ON pv.cod_pedido = piv.cod_pedido    
  --          AND pv.volume = piv.volume left JOIN    
  def_origem_ped dop(NOLOCK) ON dop.cod_origem_ped = p.cod_origem_ped  
 WHERE p.cod_prenota >= @cod_prenota_ini  
  AND p.cod_prenota <= @cod_prenota_fim  
  AND (  
   pv.volume >= @volume_ini  
   OR @volume_ini IS NULL  
   )  
  AND (  
   pv.volume <= @volume_fim  
   OR @volume_fim IS NULL  
   )  
  AND dop.imprime_etiqueta_embarque = 1  
  AND NOT EXISTS (  
   SELECT 1  
   FROM vw_pedido_item_corte vpic  
   WHERE vpic.cod_pedido = p.cod_pedido  
   )  
 GROUP BY p.cod_pedido  
  ,pv.volume  
END  
   
IF @qtd_impressoes IS NOT NULL  
BEGIN  
 SET @volume = 1  
   
 WHILE @volume <= @qtd_impressoes  
  --select @volume    
 BEGIN  
  INSERT #pedidos (  
   cod_pedido  
   ,volume  
   )  
  SELECT p.cod_pedido  
   ,@volume  
  FROM pedido p  
  INNER JOIN def_origem_ped dop(NOLOCK) ON dop.cod_origem_ped = p.cod_origem_ped  
  WHERE p.cod_prenota >= @cod_prenota_ini  
   AND p.cod_prenota <= @cod_prenota_fim  
   AND dop.imprime_etiqueta_embarque = 1  
   
  SET @volume = @volume + 1  
 END  
   
 -- select * from #pedidos    
 -- declare #pedidos_embarque int = null     
 --INSERT #pedidos_embarque (cod_pedido, volumes, volume) select 2, 21, null     
 --SELECT cod_pedido  
 -- ,ROW_NUMBER() OVER (  
 --  PARTITION BY cod_pedido ORDER BY cod_pedido ASC  
 --  ) AS volumes  
 -- ,@qtd_impressoes  
 --FROM #pedidos  
 --GROUP BY cod_pedido  
 -- ,volume  
END;  
   
-- Tratativa de Sigla da Transportadora -- INICIO  
CREATE TABLE #pedido_endereco (  
 cod_pedido INT  
 ,cod_transportadora INT  
 ,cep CHAR(9)  
 ,id_pais INT  
 ,estado CHAR(2)  
 ,id_municipio INT  
 )  
   
INSERT INTO #pedido_endereco  
SELECT p.cod_pedido  
 ,CASE   
  WHEN p.cod_transportadora IS NOT NULL  
   THEN p.cod_transportadora  
  WHEN pe.id_pedido_ender IS NOT NULL  
   THEN trpe.cod_transportadora  
  ELSE tree.cod_transportadora  
  END  
 ,CASE   
  WHEN pe.id_pedido_ender IS NOT NULL  
   THEN ceppe.cep  
  ELSE cepee.cep  
  END  
 ,CASE   
  WHEN pe.id_pedido_ender IS NOT NULL  
   THEN epe.id_pais  
  ELSE eee.id_pais  
  END  
 ,CASE   
  WHEN pe.id_pedido_ender IS NOT NULL  
   THEN epe.sigla_estado  
  ELSE eee.sigla_estado  
  END  
 ,CASE   
  WHEN pe.id_pedido_ender IS NOT NULL  
   THEN mpe.id_municipio  
  ELSE mee.id_municipio  
  END  
FROM pedido p(NOLOCK)  
LEFT JOIN pedido_ender pe(NOLOCK) ON pe.cod_pedido = p.cod_pedido  
LEFT JOIN cep ceppe(NOLOCK) ON ceppe.cep = pe.cep  
LEFT JOIN estado epe(NOLOCK) ON epe.sigla_estado = ceppe.sigla_estado  
LEFT JOIN municipio mpe(NOLOCK) ON mpe.nome = ceppe.cidade  
 AND mpe.sigla_estado = epe.sigla_estado  
OUTER APPLY (  
 SELECT TOP 1 *  
 FROM transportadora_rota  
 WHERE cod_rota = pe.cod_rota  
  AND transportadora_principal = 1  
 ) AS trpe  
LEFT JOIN entidade_ender ee(NOLOCK) ON p.cod_entidade = ee.cod_entidade  
 AND ISNULL(ee.principal, 0) <> 0  
LEFT JOIN cep cepee(NOLOCK) ON cepee.cep = ee.cep  
LEFT JOIN estado eee(NOLOCK) ON eee.sigla_estado = cepee.sigla_estado  
LEFT JOIN municipio mee(NOLOCK) ON mee.nome = cepee.cidade  
 AND mee.sigla_estado = eee.sigla_estado  
OUTER APPLY (  
 SELECT TOP 1 *  
 FROM transportadora_rota  
 WHERE cod_rota = ee.cod_rota  
  AND transportadora_principal = 1  
 ) AS tree  
WHERE p.cod_prenota BETWEEN @cod_prenota_ini  
  AND @cod_prenota_fim  
 AND (  
  ceppe.cep IS NOT NULL  
  OR cepee.cep IS NOT NULL  
  )  
   
CREATE TABLE #pedido_sigla (  
 cod_pedido INT  
 ,sigla VARCHAR(30)  
 ,cod_externo VARCHAR(30)  
 )  
   
   
INSERT INTO #pedido_sigla  
SELECT pe.cod_pedido  
 ,CASE   
  WHEN sigla_cep.sigla IS NOT NULL  
   THEN sigla_cep.sigla  
  WHEN sigla_municipio.sigla IS NOT NULL  
   THEN sigla_municipio.sigla  
  WHEN sigla_estado.sigla IS NOT NULL  
   THEN sigla_estado.sigla  
  WHEN sigla_pais.sigla IS NOT NULL  
   THEN sigla_pais.sigla  
  END  
 ,CASE   
  WHEN sigla_cep.sigla IS NOT NULL  
   THEN sigla_cep.cod_externo  
  WHEN sigla_municipio.sigla IS NOT NULL  
   THEN sigla_municipio.cod_externo  
  WHEN sigla_estado.sigla IS NOT NULL  
   THEN sigla_estado.cod_externo  
  WHEN sigla_pais.sigla IS NOT NULL  
   THEN sigla_pais.cod_externo  
  END  
FROM #pedido_endereco pe(NOLOCK)  
LEFT JOIN sigla_transportadora sigla_pais(NOLOCK) ON pe.cod_transportadora = sigla_pais.cod_transportadora  
 AND pe.id_pais = sigla_pais.id_pais  
 AND sigla_pais.sigla_estado IS NULL  
 AND sigla_pais.id_municipio IS NULL  
LEFT JOIN sigla_transportadora sigla_estado ON pe.cod_transportadora = sigla_estado.cod_transportadora  
 AND pe.id_pais = sigla_estado.id_pais  
 AND pe.estado = sigla_estado.sigla_estado  
 AND pe.id_municipio IS NULL  
LEFT JOIN sigla_transportadora sigla_municipio ON pe.cod_transportadora = sigla_municipio.cod_transportadora  
 AND pe.id_pais = sigla_municipio.id_pais  
 AND pe.estado = sigla_municipio.sigla_estado  
 AND pe.id_municipio = sigla_municipio.id_municipio  
LEFT JOIN sigla_transportadora sigla_cep ON pe.cod_transportadora = sigla_cep.cod_transportadora  
 AND pe.id_pais = sigla_cep.id_pais  
 AND sigla_cep.sigla_estado IS NULL  
 AND sigla_cep.id_municipio IS NULL  
 AND pe.cep BETWEEN sigla_cep.cep_inicial AND sigla_cep.cep_final  
WHERE (  
  sigla_municipio.sigla IS NOT NULL  
  OR sigla_estado.sigla IS NOT NULL  
  OR sigla_pais.sigla IS NOT NULL  
  OR sigla_cep.sigla IS NOT NULL  
  )  
   
-- Tratativa de Sigla da Transportadora -- FIM  
-- begin obs@Jorge#29/01/2017: criação de tabelas para o cálculo do dia de entrega  
CREATE TABLE #dias_entrega_ajustados (  
 cod_pedido INT NOT NULL  
 ,dias_entrega INT  
 )  
   
DECLARE @cod_pedido_aux INT = NULL  
DECLARE @dias_a_mais INT = 0  
 ,@data_auxiliar SMALLDATETIME  
 ,@avaliar_feriado BIT = 1  
DECLARE @data_saida_transp SMALLDATETIME  
 ,@dias_entrega INT  
 ,@sigla_estado_entrega CHAR(2)  
 ,@municipio_entrega VARCHAR(20)  
   
--obs@Jorge: enquanto houver pedidos da #pedidos que não estão na dias_entrega_ajustados  
WHILE EXISTS (  
  SELECT 1  
  FROM #pedidos p  
  LEFT JOIN dias_entrega_ajustados d ON p.cod_pedido = d.cod_pedido  
  WHERE d.cod_pedido IS NULL  
  )  
BEGIN  
   
 --obs@Jorge: pega o primeiro pedido da #pedidos que não está na #dias_entrega_ajustados  
 SELECT TOP 1 @cod_pedido_aux = p.cod_pedido  
 FROM #pedidos p  
 LEFT JOIN dias_entrega_ajustados d ON p.cod_pedido = d.cod_pedido  
 WHERE d.cod_pedido IS NULL  
   
 SET @dias_a_mais = 0  
   
 SELECT @data_auxiliar = ISNULL(DATEADD(day, (dias_entrega), data_saida_transp), GETDATE())  
  ,@data_saida_transp = data_saida_transp  
  ,@dias_entrega = dias_entrega  
  ,@municipio_entrega = CASE   
   WHEN pe.id_pedido_ender IS NOT NULL  
    THEN pecep.cidade  
   ELSE eecep.cidade  
   END  
  ,@sigla_estado_entrega = CASE   
   WHEN pe.id_pedido_ender IS NOT NULL  
    THEN pecep.sigla_estado  
   ELSE eecep.sigla_estado  
   END  
 FROM pedido p(NOLOCK)  
 LEFT JOIN entidade_ender ee(NOLOCK) ON p.cod_entidade = ee.cod_entidade  
  AND ISNULL(ee.principal, 0) <> 0  
 LEFT JOIN cep eecep(NOLOCK) ON ee.cep = eecep.cep  
 LEFT JOIN pedido_ender pe(NOLOCK) ON p.cod_pedido = pe.cod_pedido  
 LEFT JOIN cep pecep(NOLOCK) ON pe.cep = pecep.cep  
 WHERE p.cod_pedido = @cod_pedido_aux  
   
 WHILE @avaliar_feriado <> 0  
 BEGIN  
  SET @avaliar_feriado = 0  
   
  IF DATEPART(WEEKDAY, @data_auxiliar) = 1 --domingo  
  BEGIN  
   SET @data_auxiliar = ISNULL(DATEADD(day, (1), @data_auxiliar), GETDATE()) -- adiciona 1 dia à entrega  
   SET @dias_a_mais = @dias_a_mais + 1  
  END  
  ELSE IF DATEPART(WEEKDAY, @data_auxiliar) = 7 --sábado  
  BEGIN  
   SET @data_auxiliar = ISNULL(DATEADD(day, (2), @data_auxiliar), GETDATE()) -- adiciona 2 dias à entrega  
   SET @dias_a_mais = @dias_a_mais + 2  
  END  
   
  IF EXISTS (  
    SELECT 1  
    FROM feriado f  
    LEFT JOIN municipio m ON m.id_municipio = f.id_municipio  
     AND m.sigla_estado = f.sigla_estado  
    WHERE (f.data = @data_auxiliar OR (f.anual = 1 AND DAY(f.data) = DAY(@data_auxiliar) AND MONTH(f.data) = MONTH(@data_auxiliar))) -- se (feriado for igual a data) ou (se for recorrente com dia e mês iguais)  
     AND id_pais = 1  
     AND (  
      (f.sigla_estado = @sigla_estado_entrega)  
      OR (  
       f.sigla_estado = @sigla_estado_entrega  
       AND m.nome = @municipio_entrega  
       )  
      OR (f.sigla_estado IS NULL)  
      )  
    )  
  BEGIN  
   SET @data_auxiliar = ISNULL(DATEADD(day, (1), @data_auxiliar), GETDATE()) -- adiciona 1 dia à entrega  
   SET @dias_a_mais = @dias_a_mais + 1  
   SET @avaliar_feriado = 1  
  END  
 END  
   
 INSERT dias_entrega_ajustados (  
  cod_pedido  
  ,dias_entrega  
  )  
 VALUES (  
  @cod_pedido_aux  
  ,@dias_entrega + @dias_a_mais  
  )  
END;  
   
-- end obs@Jorge#29/01/2017  
WITH itens_volume (  
 cod_pedido  
 ,volume  
 ,itens  
 ,esteira  
 )  
AS (  
 SELECT p.cod_pedido  
  ,pv.volume  
  ,SUM(piv.quantidade)  
  ,dbo.GetEnderecoDivDescr(MAX(piv.id_endereco_origem))  
 --select *    
 FROM #pedidos peds  
 INNER JOIN -- on peds.cod_pedido = piv.cod_pedido AND peds.volume = piv.volume     
  pedido p(NOLOCK) ON p.cod_pedido = peds.cod_pedido  
 LEFT JOIN pedido_volume pv(NOLOCK) ON pv.cod_pedido = p.cod_pedido  
  AND pv.volume = peds.volume  
 LEFT JOIN vw_pedido_item_volume piv(NOLOCK) ON p.cod_pedido = piv.cod_pedido  
  AND piv.volume = pv.volume  
 GROUP BY p.cod_pedido  
  ,pv.volume  
 )  
 ,  
 --volumes_onda(cod_onda, volumes_onda)      
 --AS      
 --(      
 -- SELECT cod_onda, SUM(piv.quantidade)      
 --  FROM pedido p INNER JOIN      
 --   vw_pedido_item_volume piv (NOLOCK) ON p.cod_pedido = piv.cod_pedido INNER JOIN    
 -- #pedidos peds on peds.cod_pedido = piv.cod_pedido    
 --  GROUP BY p.cod_onda      
volumes_onda (  
 cod_onda  
 ,volumes_onda  
 )  
AS (  
 SELECT cod_onda  
  ,count(pv.volume)  
 FROM pedido p(NOLOCK)  
 INNER JOIN pedido_volume pv(NOLOCK) ON p.cod_pedido = pv.cod_pedido  
 WHERE p.cod_onda IN (  
   SELECT DISTINCT ped.cod_onda  
   FROM pedido ped(NOLOCK)  
    ,#pedidos peds  
   WHERE ped.cod_pedido = peds.cod_pedido  
   )  
 GROUP BY p.cod_onda  
 )  
 ,endereco_produto_volume (  
 volume  
 ,cod_pedido  
 ,endereco_completo  
 )  
AS (  
 -- amanda validar    
 SELECT piv.volume  
  ,p.cod_pedido  
  ,isnull(min(endereco), '_') AS endereco  
 FROM pedido p  
 LEFT JOIN vw_pedido_item_volume piv(NOLOCK) ON p.cod_pedido = piv.cod_pedido  
 INNER JOIN entidade_produto_endereco epe(NOLOCK) ON piv.cod_produto = epe.cod_produto  
 INNER JOIN #pedidos peds ON peds.cod_pedido = piv.cod_pedido  
  AND peds.volume = piv.volume  
 WHERE epe.cod_entidade = p.cod_entidade  
 GROUP BY piv.volume  
  ,p.cod_pedido  
 )  
 ,iten_controlado (cod_pedido)  
AS (  
 SELECT p.cod_pedido  
 FROM pedido p  
 LEFT JOIN vw_pedido_item_volume piv(NOLOCK) ON p.cod_pedido = piv.cod_pedido  
 INNER JOIN produto prod(NOLOCK) ON piv.cod_produto = prod.cod_produto  
 INNER JOIN SubGrupo s(NOLOCK) ON prod.cod_subgrupo = s.cod_subgrupo  
  AND s.controlado = 1  
 INNER JOIN #pedidos peds ON peds.cod_pedido = piv.cod_pedido  
  AND peds.volume = piv.volume  
 GROUP BY p.cod_pedido  
 )  
 ,iten_termolabeL (cod_pedido)  
AS (  
 SELECT p.cod_pedido  
 FROM pedido p  
 LEFT JOIN vw_pedido_item_volume piv(NOLOCK) ON p.cod_pedido = piv.cod_pedido  
 INNER JOIN produto prod(NOLOCK) ON piv.cod_produto = prod.cod_produto  
 INNER JOIN SubGrupo s(NOLOCK) ON prod.cod_subgrupo = s.cod_subgrupo  
  AND s.cod_subgrupo = 163 /*TERMOLABEIS*/  
 WHERE p.cod_prenota >= @cod_prenota_ini  
  AND p.cod_prenota <= @cod_prenota_fim  
  AND (  
   piv.volume >= @volume_ini  
   OR @volume_ini IS NULL  
   )  
  AND (  
   piv.volume <= @volume_fim  
   OR @volume_fim IS NULL  
   )  
 GROUP BY p.cod_pedido  
 )  
--declare    
--@cod_prenota_ini int = 1299,    
--@cod_prenota_fim int = 1299,    
--@volume_ini int = 1,    
--@volume_fim int = 2,    
--@cod_operacao_logistica int = 1,    
--@cod_distribuicao int = null,    
--@situacao int = null    
SELECT ped.cod_pedido AS id_pedido  
 ,ped.cod_pedido * 10 + dbo.calcDigitoMod11(ped.cod_pedido) AS cod_pedido  
 ,ped.cod_prenota AS id_picking  
 ,RIGHT('0000000' + convert(VARCHAR, ped.cod_prenota * 10 + dbo.calcDigitoMod11(ped.cod_prenota)), 7) AS cod_picking  
 ,substring(ped.cod_pedido_polo, 5, 8) AS cod_pedido_legado_reduzido  
 ,ped.cod_pedido_polo AS cod_pedido_legado  
 ,(substring(ped.cod_pedido_polo, 3, 2) + '/' + substring(ped.cod_pedido_polo, 5, 8) + '/' + substring(ped.cod_pedido_polo, 13, 2)) AS cod_pedido_legado_custon  
 ,right('0000' + convert(VARCHAR, (  
    SELECT COUNT(*)  
    FROM pedido_volume pv2  
    WHERE pv2.cod_pedido = ped.cod_pedido  
    )), 4) AS volumes  
 ,ent.cod_entidade AS id_entidade  
 ,ent.cod_entidade * 10 + dbo.calcDigitoMod11(ent.cod_entidade) AS cod_entidade  
 ,CASE   
  WHEN ped.cod_origem_ped = 9 /*VanRorry*/  
   THEN '2034 - OEC - TAMBORE'  
  WHEN ped.operacao = 5 /*Mov_Endereco*/  
   THEN '2034 - OEC - TAMBORE'  
  ELSE ent.fantasia  
  END AS fantasia  
 ,ent.razao_social  
 ,ee.endereco  
 ,ee.endereco AS endereco_custom_1  
 ,  
 -- CASE --WHEN ped.cod_origem_ped = 9 /*VanRorry*/ THEN 'Delivery'     
 --WHEN ped.operacao = 5 /*Mov_Endereco*/ THEN 'Delivery'     
 --      ELSE ee.cod_rota END AS rota,    
 CASE   
  WHEN r_trans.cod_rota IS NOT NULL  
   THEN RIGHT('0000' + CONVERT(VARCHAR(4), r_trans.cod_rota), 4)  
  ELSE ISNULL(ee.cod_rota, '_')  
  END AS rota  
 ,CASE   
  WHEN r_trans.cod_rota IS NOT NULL  
   THEN SUBSTRING(r_trans.descricao, 1, 3)  
  ELSE ISNULL(r.descricao, '_')  
  END AS rota_descricao  
 ,CASE   
  WHEN r_trans.cod_rota IS NOT NULL  
   THEN RIGHT('0000' + CONVERT(VARCHAR(4), r_trans.cod_rota), 4)  
  ELSE ISNULL(ee.cod_rota, '_')  
  END AS rota_custom_1  
 ,CASE   
  WHEN r_trans.cod_rota IS NOT NULL  
   THEN SUBSTRING(r_trans.descricao, 1, 3)  
  ELSE ISNULL(r.descricao, '_')  
  END AS rota_descricao_custom_1  
 ,  
 --r.descricao as rota_descricao,     
 ee.bairro  
 ,ee.cep  
 ,cep.cidade  
 ,cep.sigla_estado AS estado  
 ,CONVERT(VARCHAR(10), getdate(), 103) AS emissao  
 ,right('0000' + convert(VARCHAR, pv.volume), 4) AS volume  
 ,CASE   
  WHEN pv.tipo_caixa IS NULL  
   THEN 'CAIXA FECHADA'  
  ELSE CONVERT(VARCHAR(5), pv.tipo_caixa)  
  END AS tipo_caixa  
 ,'7' + RIGHT('0000000' + CONVERT(VARCHAR(7), ped.cod_prenota * 10 + dbo.calcDigitoMod11(ped.cod_prenota)), 7) + RIGHT('0000' + CONVERT(VARCHAR(4), pv.volume), 4) AS cod_barra_PN  
 ,CONVERT(VARCHAR, termino_digitacao, 103) AS data_pedido  
 ,CONVERT(VARCHAR, termino_digitacao, 103) AS data_pedido_custom_1  
 ,  
 --  CONVERT(VARCHAR(16), ped.termino_digitacao + '04:00:00', 120)  AS entrega_maxima,      
 (  
  CASE   
   WHEN ped.obs_liberacao <> '' /*Programado*/  
    THEN replace(ped.obs_liberacao, 'é', 'e')  
   WHEN ped.cod_modalidade IN (  
     3  
     ,6  
     ) /*D+1*/  
    THEN 'Pedido D+1'  
   WHEN dsub.cod_suboperacao IN (  
     1  
     ,11  
     ,14  
     ) /*Correio*/  
    THEN '_'  
   ELSE 'Entr. Max: ' + CONVERT(VARCHAR, termino_digitacao, 103) + ' ' + substring(CONVERT(VARCHAR, ped.termino_digitacao + '04:00:00', 108), 1, 5)  
   END  
  ) AS entrega_maxima  
 ,ee.caminho  
 ,CASE   
  WHEN ap.cod_tipo_atributo = 1  
   THEN 'CARIMBAGEM'  
  ELSE '_'  
  END AS carimbagem  
 ,CONVERT(VARCHAR, ped.digitacao, 103) AS digitacao  
 ,CONVERT(VARCHAR, GETDATE(), 103) + ' ' + SUBSTRING(CONVERT(VARCHAR, GETDATE(), 108), 1, 5) AS data_impressao  
 ,  
 /*CONVERT(VARCHAR, ped_entrega.data_prevista_entrega, 103) as data_prevista_entrega,*/ ISNULL(ped.cod_onda, '') AS cod_onda  
 ,SUBSTRING(ent.razao_social, 1, 21) + ' (' + CONVERT(VARCHAR, ent.cod_entidade * 10 + dbo.calcDigitoMod11(ent.cod_entidade)) + ')' AS ent_c_cod  
 ,--retorna entidade com o cod      
 CONVERT(VARCHAR, ee.bairro + ' - ' + cep.cidade + ' - ' + cep.sigla_estado) AS bairro_cid_uf  
 ,-- Retorna o bairro + cidade + UF      
 CONVERT(VARCHAR, CASE   
   WHEN ee.observacao IS NULL  
    THEN 'CEP '  
   ELSE ee.observacao + '- CEP '  
   END + ee.cep) AS obs_cep  
 ,-- Retorna obs do endereço + cep      
 CASE   
  WHEN transportadora.cod_entidade IS NOT NULL  
   THEN transportadora.fantasia  
  ELSE ISNULL(ent_transp.fantasia, '_')  
  END AS transportadora  
 ,CASE   
  WHEN transportadora.cod_entidade IS NOT NULL  
   THEN transportadora.fantasia  
  ELSE ISNULL(ent_transp.fantasia, '_')  
  END AS transportadora_custom_1  
 ,CASE   
  WHEN ee.complemento IS NULL  
   THEN ' . '  
  ELSE dbo.RemoveAcentos(ee.complemento)  
  END AS complemento  
 ,CASE   
  WHEN ee.complemento IS NULL  
   THEN ' . '  
  ELSE dbo.RemoveAcentos(ee.complemento)  
  END AS complemento_custom_1  
 ,CONVERT(VARCHAR(6), CONVERT(VARCHAR, CONVERT(INT, ISNULL(iv.itens, 0))) + ' ITENS') AS itens  
 ,CONVERT(VARCHAR(6), CONVERT(INT, ISNULL(ionda.volumes_onda, 0))) AS volumes_onda  
 ,'000' + '>5' + RIGHT('000000000000' + CONVERT(VARCHAR(12), ped.cod_pedido_polo), 12) + right('00' + CONVERT(VARCHAR, pv.volume), 4) + right('00' + CONVERT(VARCHAR, (  
    SELECT COUNT(*)  
    FROM pedido_volume pv2  
    WHERE pv2.cod_pedido = ped.cod_pedido  
    )), 4) + REPLACE(ee.cep, '-', '') + '>60' AS EAN_jequiti  
 ,RIGHT('000000000' + CONVERT(VARCHAR(9), ped.cod_pedido_polo), 9) + RIGHT('00' + CONVERT(VARCHAR, pv.volume), 3) AS picking_volume_custom_1  
 ,  
 --CONVERT(VARCHAR,pv.volume) + '/' +CONVERT(VARCHAR,(SELECT COUNT(*) FROM pedido_volume pv2 WHERE pv2.cod_pedido = ped.cod_pedido)) AS volume_volumes,     
 CASE   
  WHEN peds_emb.cod_pedido = ped.cod_pedido  
   THEN (CONVERT(VARCHAR, peds_emb.volumes) + '/' + CONVERT(VARCHAR, peds_emb.volume))  
  ELSE CONVERT(VARCHAR, pv.volume) + '/' + CONVERT(VARCHAR, (  
     SELECT COUNT(*)  
     FROM pedido_volume pv2  
     WHERE pv2.cod_pedido = ped.cod_pedido  
     ))  
  END AS volume_volumes  
 ,CASE   
  WHEN peds_emb.cod_pedido = ped.cod_pedido  
   THEN (CONVERT(VARCHAR, peds_emb.volumes) + '/' + CONVERT(VARCHAR, peds_emb.volume))  
  ELSE CONVERT(VARCHAR, pv.volume) + '/' + CONVERT(VARCHAR, (  
     SELECT COUNT(*)  
     FROM pedido_volume pv2  
     WHERE pv2.cod_pedido = ped.cod_pedido  
     ))  
  END AS volume_volumes_custom_1  
 ,CONVERT(VARCHAR, GETDATE(), 103) AS data_impressao_sem_horas  
 ,CASE   
  WHEN r.descricao LIKE '%.%'  
   THEN SUBSTRING(r.descricao, CHARINDEX('.', r.descricao) + 1, LEN(r.descricao)) + '.'  
  ELSE '__'  
  END AS sub_rota  
 ,ISNULL(RIGHT(pv.cod_pedido_rel, 4), 0) AS cod_pedido_rel  
 ,CASE   
  WHEN ped.operacao = 5 /*Mov_Endereco*/  
   THEN 'PEDIDOS AGRUPADOS'  
  ELSE iv.esteira  
  END AS setor  
 ,ce.descricao  
 ,CASE   
  WHEN ped.cod_origem_ped = 9 /*VanRorry*/  
   THEN '_'  
  WHEN ped.operacao = 5 /*Mov_Endereco*/  
   THEN '_'  
  ELSE isnull(pev.endereco_completo, '_')  
  END AS endereco_completo  
 ,(  
  CASE   
   WHEN ped.urgente = 1  
    THEN 'PR'  
   WHEN ped.urgente = 0  
    THEN '01'  
   WHEN ped.urgente IS NULL  
    THEN 'BB'  
   END  
  ) AS classificacao  
 ,(  
  CASE   
   WHEN ped.obs_liberacao <> '' /*Programado*/  
    THEN 'ENTREGA AGENDADA'  
   ELSE isnull(dmp.descritivo, 'SEM MODALIDADE')  
   END  
  ) AS modalidade  
 ,replace(cast(ped.valor_total AS DECIMAL(10, 4)), '.', '') AS valor_total  
 ,CASE   
  WHEN isnull(ped.obs_PN, '') = ''  
   THEN '_'  
  ELSE ped.obs_PN  
  END AS obs_PN  
 ,(  
  CASE   
   WHEN dsub.descricao = 'Nota Fiscal'  
    THEN 'NF'  
   WHEN dsub.descricao = 'Nota Fiscal\Troco'  
    THEN 'NFT'  
   WHEN dsub.descricao = 'Troco'  
    THEN 'T'  
   WHEN dsub.descricao = 'Nota Fiscal\Devolucao'  
    THEN 'NFD'  
   WHEN dsub.descricao = 'Devolucao'  
    THEN 'D'  
   WHEN dsub.descricao = 'Troco\Devolucao'  
    THEN 'TD'  
   WHEN dsub.descricao = 'Nota Fiscal\Troco\Devolucao'  
    THEN 'NFTD'  
   ELSE ' . '  
   END  
  ) AS suboperacao  
 ,CASE   
  WHEN ic.cod_pedido <> ''  
   THEN 'RETIRAR RECEITA'  
  ELSE '_'  
  END AS Obs_3  
 ,CASE   
  WHEN it.cod_pedido <> ''  
   THEN 'GEL/TB'  
  ELSE '_'  
  END AS Obs_4  
 ,isnull(t.chave_acesso, '_') AS NFe  
 ,  
 -- CASE WHEN ep.data_de_entrega_prevista is null THEN CONVERT(VARCHAR,ISNULL(DATEADD(day, dias_entrega, data_saida_transp),getdate()),103)    
 --ELSE CONVERT(VARCHAR, ep.data_de_entrega_prevista, 103) END AS data_prevista_entrega    
 --CONVERT(VARCHAR,ISNULL(DATEADD(day, dias_entrega, data_saida_transp),getdate()),103) as data_prevista_entrega     
 CASE   
  WHEN ped.obs_liberacao <> '' /*Entrega Agendada*/  
   THEN ped.obs_liberacao  
  ELSE CONVERT(VARCHAR, ISNULL(DATEADD(day, (dea.dias_entrega), data_saida_transp), getdate()), 103)  
  END AS data_prevista_entrega  
 ,ISNULL(ps.sigla, '000') AS sigla  
 ,ISNULL(ps.cod_externo, '000') AS cod_externo  
FROM pedido ped(NOLOCK)  
INNER JOIN operacao_logistica ol(NOLOCK) ON ol.cod_operacao_logistica = ped.cod_operacao_logistica  
LEFT JOIN pedido_volume pv(NOLOCK) ON ped.cod_pedido = pv.cod_pedido  
LEFT JOIN endereco_produto_volume pev(NOLOCK) ON pv.cod_pedido = pev.cod_pedido  
 AND pv.Volume = pev.volume  
LEFT JOIN caixa_esteira ce(NOLOCK) ON ce.id_caixa = pv.tipo_caixa  
LEFT JOIN -- ALAN    
 itens_volume iv(NOLOCK) ON ped.cod_pedido = iv.cod_pedido  
 AND pv.Volume = iv.volume  
LEFT JOIN entidade ent(NOLOCK) ON ped.cod_entidade = ent.cod_entidade  
LEFT JOIN entidade_ender ee(NOLOCK) ON ent.cod_entidade = ee.cod_entidade  
 AND ee.principal = - 1  
LEFT JOIN rota r(NOLOCK) ON r.cod_rota = ee.cod_rota  
LEFT JOIN cep(NOLOCK) ON ee.cep = cep.cep  
LEFT JOIN transportadora_rota tr(NOLOCK) ON ee.cod_rota = tr.cod_rota  
 AND tr.transportadora_principal = 1  
LEFT JOIN pedido_ender pe(NOLOCK) ON ped.cod_pedido = pe.cod_pedido  
LEFT JOIN rota r_trans(NOLOCK) ON pe.cod_rota = r_trans.cod_rota  
LEFT JOIN entidade transportadora(NOLOCK) ON ped.cod_transportadora = transportadora.cod_entidade  
LEFT JOIN  
 --AND tr.transportadora_principal = 1 INNER JOIN      
 entidade ent_transp(NOLOCK) ON tr.cod_transportadora = ent_transp.cod_entidade  
INNER JOIN param_operacao po(NOLOCK) ON po.cod_distribuicao = ol.cod_distribuicao  
 AND po.operacao = ped.operacao  
LEFT JOIN atributo_pedido ap ON ped.cod_pedido = ap.cod_pedido  
 AND ap.cod_tipo_atributo = 1  
LEFT JOIN --Produto com venda proibida para Varejoa - somente hostipais      
 volumes_onda ionda(NOLOCK) ON ped.cod_onda = ionda.cod_onda  
LEFT JOIN def_modalidade_pedido dmp(NOLOCK) ON ped.cod_modalidade = dmp.cod_modalidade  
LEFT JOIN def_suboperacao dsub(NOLOCK) ON ped.cod_suboperacao = dsub.cod_suboperacao  
LEFT JOIN iten_controlado ic(NOLOCK) ON ped.cod_pedido = ic.cod_pedido  
LEFT JOIN iten_termolabel it(NOLOCK) ON ped.cod_pedido = it.cod_pedido  
INNER JOIN dias_entrega_ajustados dea(NOLOCK) ON ped.cod_pedido = dea.cod_pedido  
INNER JOIN #pedidos peds ON peds.cod_pedido = ped.cod_pedido  
 AND peds.volume = pv.volume  
LEFT JOIN #pedidos_embarque peds_emb ON peds.cod_pedido = peds_emb.cod_pedido  
LEFT JOIN  
 --#ped_prevista_entrega ped_entrega ON ped_entrega.cod_pedido = ped.cod_pedido LEFT JOIN    
 pedido_titulo pt(NOLOCK) ON ped.cod_pedido = pt.cod_pedido  
LEFT JOIN titulo t(NOLOCK) ON pt.cod_titulo = t.cod_titulo  
LEFT JOIN ecommerce_previsto ep ON ped.cod_pedido_polo = convert(VARCHAR(20), ep.pedido)  
LEFT JOIN #pedido_sigla ps ON ped.cod_pedido = ps.cod_pedido  
WHERE (  
  ped.cod_operacao_logistica = @cod_operacao_logistica  
  OR @cod_operacao_logistica IS NULL  
  )  
 --AND ped.cod_prenota >= @cod_prenota_ini      
 --AND ped.cod_prenota <= @cod_prenota_fim      
 AND po.cod_etiqueta_fracao IS NOT NULL  
 --AND (pv.volume >= @volume_ini or @volume_ini is null)      
 --AND (pv.volume <= @volume_fim or @volume_fim is null)      
 AND (  
  ped.cod_situacao = @situacao  
  OR @situacao IS NULL  
  )  
 AND (  
  ol.cod_distribuicao = @cod_distribuicao  
  OR @cod_distribuicao IS NULL  
  )  
--AND ((pv.tipo_caixa IS NOT NULL AND @caixa_fechada = 0) OR (pv.tipo_caixa IS NULL AND @caixa_fechada = -1) OR (@caixa_fechada IS NULL))      
ORDER BY ISNULL(pv.cod_pedido_rel, '')  
 ,ped.cod_prenota  
 ,pv.volume  
   
DROP TABLE #pedidos  
DROP TABLE #dias_entrega_ajustados  
DROP TABLE #pedidos_embarque  
DROP TABLE #pedido_endereco  
DROP TABLE #pedido_sigla  