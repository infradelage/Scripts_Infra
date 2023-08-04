-- DELAGE\claudio.lopes@2022-07-25 11:12:59: <Nao retornando as etiquetas de volume que nao retorna os dados>            
-- DELAGE\claudio.lopes@2022-07-22 12:16:27: <Faltava uma query para nao retorna dados se na param_endereco_div nao estiver configurado pra imprimir volume>              
-- DELAGE\claudio.lopes@2022-07-18 15:59:54: <Fazndo o merge das duas ultimas mudancas>                
-- DELAGE@2022-07-15 16:34:02: <Alteracao tamanho do campo cep e estado>                  
-- DELAGE\claudio.lopes@2022-07-14 11:20:12: <Nao retorna dados se na param_endereco_div nao estiver configurado pra imprimir volume>                
-- DELAGE\joao.silveira@2022-05-30 15:24:25: <Imprimindo apenas multi-item (filhos) no batch-picking>                  
-- DELAGE\jean.francisquini@2022-05-02 14:07:43: <Adicionando campo reimpressao>                    
-- DELAGE\camila.souza@2022-01-04 17:17:27: <valida��o de @exibe_informacao_produto_etiqueta>                    
-- DELAGE\samuel.oliveira@2021-10-21 12:54:00: <add ender_completo, obs_liberacao, transp e ObsPN, codProdutoRel>                    
-- DELAGE\samuel.oliveira@2021-10-20 15:24:00: <add codigo_produto, lote, quantidade e descProduto>                    
-- DELAGE\jean.francisuqini@2020-06-04 16:08:53: <add cnpj>                    
-- DELAGE\carlos.oliveira@2019-03-14 17:52:00: <ajuste no campo bairro_cid_uf uso do RTRIM>                              
-- DELAGE\carlos.oliveira@2019-02-25 17:26:12: <enviada pelo Ronaldo campo cid_bairro>                              
-- DELAGE\alan.oliveira@2018-12-04 14:39:45: <AND (p.cod_onda = @cod_onda OR @cod_onda = 0)>                              
-- DELAGE\jorge.moreira@2018-06-26 13:26:32: <altera��o no c�clulo do dia de entrega com base nos feriados para incluir feriados anualmente recorrentes>                              
-- DELAGE\jonathan.muniz@2018-01-30 14:39:13: <tratativa do cep da sigla>                              
-- DELAGE\jonathan.muniz@2018-01-29 13:37:15: <tratativa da sigla_transportadora>                              
-- DELAGE\jorge.moreira@2018-01-22 17:35:03: <ajuste de data_prevista_entrega com feriados e finais de semana>                                
-- DELAGE\jorge.moreira@2017-11-13 15:27:42: <retorno de data_prevista_entrega>                                
-- disbbyweb@2017-04-06 17:29:06: <inclu�do #pedidos, nova forma de pegar os pedidos, agora exibe o pedido master e pedidos filhos com base no parametro>                     
CREATE OR ALTER PROCEDURE stp_WMS_etiqueta_le_pedido_volume
@cod_prenota_ini INT = NULL,                                                    
@cod_prenota_fim INT = NULL,                                                    
@cod_operacao_logistica  INT = NULL,                                                    
@situacao INT = NULL,                                                    
@caixa_fechada SMALLINT = NULL,                                                    
@volume_ini int = null,                                                    
@volume_fim int = null,                                                    
@cod_distribuicao INT = NULL,                                                    
@operacao INT = NULL,                                                    
@cod_onda INT = NULL,          
@imprime_volume BIT = 0,    
@onda_ini INT = NULL,    
@onda_fim INT = NULL,    
@transportadora VARCHAR(MAX) = NULL     
AS                                                             
             
             
--DECLARE @tipo_somente_pallet INT            
             
--SELECT @tipo_somente_pallet = pallet FROM param_def_modelo_etiqueta            
                                     
IF @cod_onda is null                          
 BEGIN                          
 SET @cod_onda = 0                          
 END                           
                                                     
                                               
DECLARE @imprime_etiqueta_pedido_filho BIT                      
DECLARE @exibe_informacao_produto_etiqueta BIT                     
        
SELECT @imprime_etiqueta_pedido_filho = ISNULL(imprime_etiqueta_pedido_filho, 1)                                              
FROM param_agrupamento_volume(NOLOCK)                     
                     
SELECT @exibe_informacao_produto_etiqueta = ISNULL(exibe_informacao_produto_etiqueta, 1)                                              
FROM param_estoque(NOLOCK)                    
                                               
CREATE TABLE #pedidos (                                              
 cod_pedido INT                                        
 ,volume INT                                              
 )                                              
                      
                      
INSERT #pedidos (                                              
 cod_pedido                                              
 ,volume                                              
 )                         
SELECT p.cod_pedido                                              
 ,pv.volume                                              
FROM pedido p(NOLOCK)                                              
LEFT JOIN vw_pedido_item_volume piv(NOLOCK) ON p.cod_pedido = piv.cod_pedido                                              
INNER JOIN pedido_volume pv(NOLOCK) ON pv.cod_pedido = p.cod_pedido                                                                       
WHERE   (p.cod_prenota >= @cod_prenota_ini OR @cod_prenota_ini IS NULL)                                                  
  AND (p.cod_prenota <= @cod_prenota_fim OR @cod_prenota_fim IS NULL)                                        
                                        
 AND (                                              
  pv.volume >= @volume_ini                                              
  OR @volume_ini IS NULL                     
  )                                              
 AND (                                              
  pv.volume <= @volume_fim                                              
  OR @volume_fim IS NULL                                  
  )                                              
 AND (                                              
  (                                              
   pv.cod_pedido_rel IS NOT NULL                                          
   AND @imprime_etiqueta_pedido_filho = 1                                              
   )                                              
  OR pv.cod_pedido_rel IS NULL                                           
  )                                              
 AND (p.cod_onda = @cod_onda OR @cod_onda = 0)                     
GROUP BY p.cod_pedido                                              
 ,pv.volume                                              
                                               
UNION                                              
                                               
SELECT ped.cod_pedido                                              
 ,pv2.volume                                              
FROM pedido p(NOLOCK)                                              
LEFT JOIN vw_pedido_item_volume piv(NOLOCK) ON p.cod_pedido = piv.cod_pedido                                              
INNER JOIN pedido_volume pv(NOLOCK) ON pv.cod_pedido = p.cod_pedido                                                                 
INNER JOIN pedido ped(NOLOCK) ON ped.cod_pedido = pv.cod_pedido_rel                                              
LEFT JOIN vw_pedido_item_volume piv2(NOLOCK) ON ped.cod_pedido = piv2.cod_pedido                                    
INNER JOIN pedido_volume pv2(NOLOCK) ON pv2.cod_pedido = ped.cod_pedido                                                                      
WHERE   (p.cod_prenota >= @cod_prenota_ini OR @cod_prenota_ini IS NULL)                                                  
  AND (p.cod_prenota <= @cod_prenota_fim OR @cod_prenota_fim IS NULL)                                           
 AND (              
  pv.volume >= @volume_ini                                              
  OR @volume_ini IS NULL                                              
  )                            
 AND (                                              
  pv.volume <= @volume_fim                                              
  OR @volume_fim IS NULL                                              
  )                                              
 AND (p.cod_onda = @cod_onda OR @cod_onda = 0)                        
GROUP BY ped.cod_pedido                                              
 ,pv2.volume;                                              
           -- Tratativa de Sigla da Transportadora -- INICIO                                              
CREATE TABLE #pedido_endereco (                                              
 cod_pedido INT                                              
 ,cod_transportadora INT                                              
,cep CHAR(90)                                              
 ,id_pais INT                                           
 ,estado CHAR(20)                                              
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
WHERE   (p.cod_prenota >= @cod_prenota_ini OR @cod_prenota_ini IS NULL)                                                  
  AND (p.cod_prenota <= @cod_prenota_fim OR @cod_prenota_fim IS NULL)                                           
 AND (                                              
  ceppe.cep IS NOT NULL                      
  OR cepee.cep IS NOT NULL                                              
  )                                              
 AND (p.cod_onda = @cod_onda OR @cod_onda = 0)                                              
                                               
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
 AND sigla_pais.cep_inicial IS NULL                                              
 AND sigla_pais.cep_final IS NULL                                              
LEFT JOIN sigla_transportadora sigla_estado ON pe.cod_transportadora = sigla_estado.cod_transportadora                                              
 AND pe.id_pais = sigla_estado.id_pais                                              
 AND pe.estado = sigla_estado.sigla_estado                                              
 AND pe.id_municipio IS NULL                                              
    AND sigla_pais.cep_inicial IS NULL                     
 AND sigla_pais.cep_final IS NULL                                              
LEFT JOIN sigla_transportadora sigla_municipio ON pe.cod_transportadora = sigla_municipio.cod_transportadora                                              
 AND pe.id_pais = sigla_municipio.id_pais                                              
 AND pe.estado = sigla_municipio.sigla_estado                                              
 AND pe.id_municipio = sigla_municipio.id_municipio                               
 AND sigla_pais.cep_inicial IS NULL                                              
AND sigla_pais.cep_final IS NULL                                              
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
--Tratativa de Finais de Semana e Feriados (Dias de Entrega) -- INICIO                                              
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
                                               
WHILE EXISTS (                                              
  SELECT 1                                              
  FROM #pedidos p                                              
  LEFT JOIN dias_entrega_ajustados d ON p.cod_pedido = d.cod_pedido                                            
  WHERE d.cod_pedido IS NULL                                              
  )                                              
BEGIN                                      
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
   SET @data_auxiliar = ISNULL(DATEADD(day, (1), @data_auxiliar), GETDATE())                                              
   SET @dias_a_mais = @dias_a_mais + 1                                              
  END                                              
  ELSE IF DATEPART(WEEKDAY, @data_auxiliar) = 7 --s�bado                                              
  BEGIN                            
   SET @data_auxiliar = ISNULL(DATEADD(day, (2), @data_auxiliar), GETDATE())                                              
   SET @dias_a_mais = @dias_a_mais + 2                                              
  END                                              
                                               
  IF EXISTS (                                              
    SELECT 1                                              
    FROM feriado f                                              
    LEFT JOIN municipio m ON m.id_municipio = f.id_municipio                                              
     AND m.sigla_estado = f.sigla_estado                                              
    WHERE (f.data = @data_auxiliar OR (f.anual = 1 AND DAY(f.data) = DAY(@data_auxiliar) AND MONTH(f.data) = MONTH(@data_auxiliar))) -- se (feriado for igual a data) ou (se for recorrente com dia e m�s iguais)                                             
 
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
   SET @data_auxiliar = ISNULL(DATEADD(day, (1), @data_auxiliar), GETDATE())                                              
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
                     
 IF @exibe_informacao_produto_etiqueta = 1                     
 BEGIN                     
--Tratativa de Finais de Semana e Feriados (Dias de Entrega) -- INICIO                                             
WITH itens_volume (                                              
 cod_pedido                                          
 ,volume                                              
 ,itens           
 ,esteira                                              
 )                                              
AS (                                              
 SELECT p.cod_pedido                                              
  ,piv.volume                                              
  ,SUM(piv.quantidade)                                              
  ,dbo.GetEnderecoDivDescr(MAX(piv.id_endereco_origem))                                              
 FROM pedido p(NOLOCK)                                              
 LEFT JOIN vw_pedido_item_volume piv(NOLOCK) ON p.cod_pedido = piv.cod_pedido                                              
 INNER JOIN #pedidos peds ON peds.cod_pedido = piv.cod_pedido                                              
  AND peds.volume = piv.volume                                              
 GROUP BY p.cod_pedido                                              
  ,piv.volume                                  
 )                                              
 ,itens_onda (                                              
 cod_onda                                             
 ,itens_onda                                              
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
 SELECT piv.volume                                              
  ,p.cod_pedido                                              
  ,isnull(min(endereco), '_') AS endereco                                              
 FROM pedido p(NOLOCK)                                LEFT JOIN vw_pedido_item_volume piv(NOLOCK) ON p.cod_pedido = piv.cod_pedido                                              
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
 FROM pedido p(NOLOCK)                                              
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
 FROM pedido p(NOLOCK)                                              
 LEFT JOIN vw_pedido_item_volume piv(NOLOCK) ON p.cod_pedido = piv.cod_pedido                                              
 INNER JOIN produto prod(NOLOCK) ON piv.cod_produto = prod.cod_produto                            
 INNER JOIN SubGrupo s(NOLOCK) ON prod.cod_subgrupo = s.cod_subgrupo                                              
  AND s.cod_subgrupo = 163 /*TERMOLABEIS*/                                              
WHERE   (p.cod_prenota >= @cod_prenota_ini OR @cod_prenota_ini IS NULL)                                                  
  AND (p.cod_prenota <= @cod_prenota_fim OR @cod_prenota_fim IS NULL)                                             
  AND (                                              
   piv.volume >= @volume_ini                                              
   OR @volume_ini IS NULL                                              
   )                                              
  AND (                                              
   piv.volume <= @volume_fim                                              
   OR @volume_fim IS NULL                                              
   )                                              
  AND (p.cod_onda = @cod_onda OR @cod_onda = 0)                                              
 GROUP BY p.cod_pedido                                              
 )                     
                     
                                    
SELECT ped.cod_pedido AS id_pedido                         
 ,ped.cod_pedido * 10 + dbo.calcDigitoMod11(ped.cod_pedido) AS cod_pedido              
 --,'teste' AS cod_pedido                                     
 ,ped.cod_prenota AS id_picking                                     
 ,RIGHT('0000000' + convert(VARCHAR, ped.cod_prenota * 10 + dbo.calcDigitoMod11(ped.cod_prenota)), 7) AS cod_picking                                              
 ,ISNULL(ped.cod_pedido_polo, '00000000000') AS cod_pedido_legado                                              
 ,right('0000' + convert(VARCHAR, (                                              
    SELECT COUNT(*)                                              
    FROM pedido_volume pv2(NOLOCK)                                              
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
 ,CASE                                               
  WHEN pe.endereco <> ''                                              
   THEN dbo.RemoveAcentos(pe.endereco)                                              
  ELSE dbo.RemoveAcentos(ee.endereco)                                              
  END AS endereco                                              
 ,CASE                                               
  WHEN pe.bairro <> ''                                              
   THEN dbo.RemoveAcentos(pe.bairro)                                              
  ELSE dbo.RemoveAcentos(ee.bairro)                                              
  END AS bairro                                              
 ,CASE                                               
  WHEN pe.bairro <> ''                                              
   THEN dbo.RemoveAcentos(pe.bairro)                                              
  ELSE dbo.RemoveAcentos(ee.bairro)                                          END AS bairro                                              
 ,CASE                                               
  WHEN pe.bairro <> ''                                              
   THEN isnull(dbo.RemoveAcentos(pe.complemento), ' . ')                                              
  ELSE isnull(dbo.RemoveAcentos(ee.complemento), ' . ')                                              
  END AS complemento                                              
 ,CASE                                               
  WHEN pe.cep <> ''                                              
   THEN pe.cep                                              
  ELSE ee.cep                                              
  END AS cep                                              
 ,CASE                                               
  WHEN pe.cep <> ''                                           
   THEN (                                              
     SELECT dbo.RemoveAcentos(cepe.cidade)                                              
   FROM cep cepe                                       
     WHERE cepe.cep = pe.cep                                              
     )                                              
  ELSE dbo.RemoveAcentos(cep.cidade)                               
  END AS cidade                                           
 ,CASE                                               
  WHEN pe.cep <> ''            
   THEN (                                              
     SELECT cepe.sigla_estado                                              
     FROM cep cepe                                              
     WHERE cepe.cep = pe.cep                                              
     )                                              
  ELSE cep.sigla_estado                                              
  END AS estado                                              
 ,CASE                                               
  WHEN pe.bairro <> ''                                              
   THEN dbo.RemoveAcentos(CONVERT(VARCHAR, RTRIM(pe.bairro) + ' - ' + (                                              
       SELECT RTRIM(cepe.cidade)                                              
       FROM cep cepe                                              
       WHERE cepe.cep = pe.cep                    
       ) + ' - ' + (                                
       SELECT RTRIM(cepe.sigla_estado)                                              
       FROM cep cepe                                              
       WHERE cepe.cep = pe.cep                                              
       )))                              
  ELSE dbo.RemoveAcentos(CONVERT(VARCHAR(MAX), RTRIM(ee.bairro) + ' - ' + RTRIM(cep.cidade) + ' - ' + RTRIM(cep.sigla_estado)))                                              
  END AS bairro_cid_uf                                              
 ,-- Retorna o bairro + cidade + UF                                                  
 CASE                                               
  WHEN pe.cep <> ''                                              
   THEN CONVERT(VARCHAR, CASE                                               
      WHEN pe.observacao IS NULL                                              
       THEN 'CEP '                                              
      ELSE '- CEP '                                              
      END + pe.cep)                                              
  ELSE CONVERT(VARCHAR, CASE                                               
    WHEN ee.observacao IS NULL                                              
      THEN 'CEP '                                              
     ELSE '- CEP '                                              
     END + ee.cep)                                              
  END AS obs_cep                                          
 ,-- Retorna obs do endere�o + cep                                                  
 CASE                                               
  WHEN r_trans.cod_rota IS NOT NULL                                            
   THEN RIGHT('0000' + CONVERT(VARCHAR(4), r_trans.cod_rota), 4)                                              
  ELSE ISNULL(ee.cod_rota, '_')                                              
  END AS rota        ,                                        
   CASE WHEN pe.id_pedido_ender IS NOT NULL THEN                                        
       r_trans.descricao                                                     
    ELSE                                                     
       r.descricao                                          
    END AS rota_descricao,                                            
 CONVERT(VARCHAR(10), getdate(), 103) AS emissao                                              
                                       
                           
 ,CONVERT(VARCHAR(4),replicate('0',4 - len(convert(varchar(4),pv.volume))) + convert(varchar(4),pv.volume)) as volume                                      
 ,CASE                                               
  WHEN pv.tipo_caixa IS NULL                                              
   THEN 'CAIXA FECHADA'                                              
  ELSE CONVERT(VARCHAR(20), ce.descricao)                                              
  END AS tipo_caixa                                              
 ,'7' + RIGHT('0000000' + CONVERT(VARCHAR(7), ped.cod_prenota * 10 + dbo.calcDigitoMod11(ped.cod_prenota)), 7) + RIGHT('0000' + CONVERT(VARCHAR(4), pv.volume), 4) AS cod_barra_PN                                              
 ,CONVERT(VARCHAR(10), ped.termino_digitacao, 103) AS data_pedido                                              
 ,                                              
 --  CONVERT(VARCHAR(16), ped.termino_digitacao + '04:00:00', 120)  AS entrega_maxima,                                                  
 (                                              
  CASE                                               
   WHEN ped.obs_liberacao <> '' /*Programado*/                                              
    THEN replace(ped.obs_liberacao, '�', 'e')                                              
   WHEN ped.cod_modalidade = 3 /*D+1*/                                              
    THEN 'Pedido D+1'                                              
   WHEN dsub.cod_suboperacao IN (                                              
     1                                              
     ,11                                           
     ,14                                              
     ) /*Correio*/                                              
    THEN '_'                                             
   ELSE 'Entr. Max: ' + CONVERT(VARCHAR(16), ped.termino_digitacao + '04:00:00', 120)                                              
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
 ,ISNULL(ped.cod_onda, '') AS cod_onda                                              
 ,SUBSTRING(ent.razao_social, 1, 21) + ' (' + CONVERT(VARCHAR, ent.cod_entidade * 10 + dbo.calcDigitoMod11(ent.cod_entidade)) + ')' AS ent_c_cod                          
 ,--retorna entidade com o cod                                                  
 -- dbo.RemoveAcentos(CONVERT(VARCHAR, ee.bairro + ' - ' + cep.cidade + ' - ' + cep.sigla_estado)) AS bairro_cid_uf, -- Retorna o bairro + cidade + UF                                                  
 CONVERT(VARCHAR, CASE                                               
   WHEN ee.observacao IS NULL                                              
    THEN 'CEP '                                       
   ELSE '- CEP '                                              
   END + ee.cep) AS obs_cep                                              
 ,-- Retorna obs do endere�o + cep                                                  
 CASE                                               
  WHEN transportadora.cod_entidade IS NOT NULL                                              
   THEN transportadora.fantasia                 
  ELSE dbo.RemoveAcentos(ISNULL(ent_transp.fantasia, '_'))                                              
  END AS transportadora                                              
 ,CONVERT(VARCHAR(10), CONVERT(VARCHAR, CONVERT(INT, ISNULL(iv.itens, 0))) + ' ITENS') AS itens                                              
 ,CONVERT(VARCHAR(7), CONVERT(INT, ISNULL(ionda.itens_onda, 0))) + ' CX' AS itens_onda                                              
 ,'0000' + '>5' + RIGHT('00000000000' + CONVERT(VARCHAR(12), ped.cod_pedido_polo), 12) + right('00' + CONVERT(VARCHAR, pv.volume), 4) + right('00' + CONVERT(VARCHAR, (                                          
    SELECT COUNT(*)                                              
    FROM pedido_volume pv2(NOLOCK)                  
    WHERE pv2.cod_pedido = ped.cod_pedido                          
    )), 3) + REPLACE(ee.cep, '-', '') + '>50' AS EAN_jequiti                                              
 ,RIGHT('000000000' + CONVERT(VARCHAR(9), ped.cod_pedido_polo), 9) + RIGHT('000' + CONVERT(VARCHAR, pv.volume), 3) AS picking_volume_jequiti                               
 ,CONVERT(VARCHAR, pv.volume) + '/' + CONVERT(VARCHAR, (                                           
   SELECT COUNT(*)                                              
   FROM pedido_volume pv2(NOLOCK)                                              
   WHERE pv2.cod_pedido = ped.cod_pedido                                              
   )) AS volume_volumes                                              
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
  END AS setor  ,                                      
                                          
   case when ol.cod_operacao_logistica = 1 then 'DMD'                                            
      when ol.cod_operacao_logistica = 2 then 'VTP'              when ol.cod_operacao_logistica = 3 then 'TFM' end as oper_logisttica-- Alan incluiu a opera��o logistica 19-12-2019 -- ajuste aqui pr n�o existe 2019-12-19                                  
  
    
      
        
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
    THEN 'ENTREGA PROGRAMADA'                                              
   ELSE isnull(dmp.descritivo, 'SEM MODALIDADE')                                             
   END                                              
  ) AS modalidade                                              
 --,replace(cast(ped.valor_total AS DECIMAL(10, 4)), '.', '') AS valor_total                                              
,ped.valor_total       
 ,(                                              
  CASE                                               
   WHEN ped.obs_PN = ''                                              
    THEN '_'                                
   END                                              
  ) AS obs_PN                                              
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
 ,CONVERT(VARCHAR, ISNULL(DATEADD(day, (dea.dias_entrega), data_saida_transp), getdate()), 103) AS data_prevista_entrega                                                  
 ,ISNULL(ISNULL(UPPER(pe.observacao), UPPER(ee.observacao)), UPPER(ent.razao_social)) as razao_ou_destinatario,                                               
    LEFT(CONVERT(VARCHAR, cep.cidade + ' - ' + ee.bairro), 35) AS cid_bairro,                                    
 entt.cod_entidade * 10 + entt.digito AS cod_operacao_logistica,                                    
 entt_rel.cod_entidade_rel AS cod_relacionado_operacao_logistica ,                                                  
 entt.razao_social AS razao_social_operacao_logistica,                                    
 entt.fantasia AS fantasia_operacao_logistica                                
 ,edoc.numero AS cnpj_cliente                                     
 ,prod.cod_produto * 10 + dbo.calcDigitoMod11(prod.cod_produto) AS codigo_produto                                         
 ,l.lote AS lote                                  
 ,piv.quantidade AS quantidade                                  
 ,prod.descricao AS descProduto                                  
 ,isnull(e.endereco_completo, 'ND') AS ender_completo                                  
 ,ped.obs_liberacao AS obs_liberacao                                  
 ,                                   
 CASE                                                         
  WHEN entt.cod_entidade IS NOT NULL                                                        
  THEN entt.fantasia                                                        
  ELSE dbo.RemoveAcentos(ISNULL(entt.fantasia, '_'))                                                        
END AS transp                                   
 ,ped.obs_PN AS ObsPN                                  
 ,ISNULL(prel.cod_produto_rel, '') AS cod_produto_rel                            
                                  
FROM pedido ped(NOLOCK)                
INNER JOIN dias_entrega_ajustados dea(NOLOCK) ON ped.cod_pedido = dea.cod_pedido                                              
INNER JOIN operacao_logistica ol(NOLOCK) ON ol.cod_operacao_logistica = ped.cod_operacao_logistica                                         
INNER JOIN                                           
  entidade eoli on eoli.cod_entidade = ol.cod_operacao_logistica                                           
INNER JOIN pedido_volume pv(NOLOCK) ON ped.cod_pedido = pv.cod_pedido                                              
LEFT JOIN #pedido_sigla ps(NOLOCK) ON ped.cod_pedido = ps.cod_pedido                                              
LEFT JOIN endereco_produto_volume pev(NOLOCK) ON pv.cod_pedido = pev.cod_pedido                                              
 AND pv.Volume = pev.volume                                              
LEFT JOIN caixa_esteira ce(NOLOCK) ON ce.id_caixa = pv.tipo_caixa                                              
LEFT JOIN -- ALAN                                                
 itens_volume iv(NOLOCK) ON ped.cod_pedido = iv.cod_pedido                                              
 AND pv.Volume = iv.volume                                              
INNER JOIN entidade ent(NOLOCK) ON ped.cod_entidade = ent.cod_entidade                          
LEFT JOIN entidade_ender ee(NOLOCK) ON ent.cod_entidade = ee.cod_entidade                                              
 AND ee.principal = - 1                                              
LEFT JOIN rota r(NOLOCK) ON r.cod_rota = ee.cod_rota                                              
LEFT JOIN cep(NOLOCK) ON ee.cep = cep.cep                                              
LEFT JOIN transportadora_rota tr(NOLOCK) ON ee.cod_rota = tr.cod_rota                                              
 AND tr.cod_transportadora = ped.cod_transportadora                                              
LEFT JOIN                                              
 --AND tr.transportadora_principal = 1 INNER JOIN                                                    
 pedido_ender pe(NOLOCK) ON ped.cod_pedido = pe.cod_pedido                                              
LEFT JOIN rota r_trans(NOLOCK) ON pe.cod_rota = r_trans.cod_rota                                              
LEFT JOIN entidade transportadora(NOLOCK) ON ped.cod_transportadora = transportadora.cod_entidade                                              
LEFT JOIN entidade ent_transp(NOLOCK) ON tr.cod_transportadora = ent_transp.cod_entidade                               
INNER JOIN param_operacao po(NOLOCK) ON po.cod_distribuicao = ol.cod_distribuicao                                              
 AND po.operacao = ped.operacao                                              
LEFT JOIN atributo_pedido ap(NOLOCK) ON ped.cod_pedido = ap.cod_pedido                                
 AND ap.cod_tipo_atributo = 1                                              
LEFT JOIN --Produto com venda proibida para Varejoa - somente hostipais                                                  
 itens_onda ionda(NOLOCK) ON ped.cod_onda = ionda.cod_onda                                              
LEFT JOIN def_modalidade_pedido dmp(NOLOCK) ON ped.cod_modalidade = dmp.cod_modalidade                                              
LEFT JOIN def_suboperacao dsub(NOLOCK) ON ped.cod_suboperacao = dsub.cod_suboperacao                                              
LEFT JOIN iten_controlado ic(NOLOCK) ON ped.cod_pedido = ic.cod_pedido                                              
LEFT JOIN iten_termolabel it(NOLOCK) ON ped.cod_pedido = it.cod_pedido                                       
LEFT JOIN  entidade entt (NOLOCK) ON ol.cod_operacao_logistica = entt.cod_entidade                                     
LEFT JOIN entidade_relacionada entt_rel ON entt.cod_entidade = entt_rel.cod_entidade AND entt.cod_tipo = entt_rel.cod_tipo                                     
                                      
INNER JOIN #pedidos peds ON peds.cod_pedido = ped.cod_pedido                                              
                  
 AND peds.volume = pv.volume                                              
LEFT JOIN entidade_doc edoc (NOLOCK) ON ent.cod_entidade = edoc.cod_entidade                                    
          AND cod_tipo_doc IN (1,3)                                    
                                  
INNER JOIN pedido_item_lote_endereco pile(NOLOCK) ON ped.cod_pedido = pile.cod_pedido                                  
INNER JOIN produto prod(NOLOCK) ON pile.cod_produto = prod.cod_produto                                  
INNER JOIN pedido_item_volume piv(NOLOCK) ON pile.id_pedido_item_lote_endereco = piv.id_pedido_item_lote_endereco                                              
 AND pv.volume = piv.volume                                              
LEFT JOIN pedido_item_volume_lote PIVL(NOLOCK) ON PIVL.id_pedido_item_volume = PIV.id_pedido_item_volume                                   
LEFT JOIN lote l(NOLOCK) ON ISNULL(PIVL.id_lote_dest, piv.id_lote_dest) = l.id_lote                                   
                                               
LEFT JOIN endereco e(NOLOCK) ON piv.id_endereco_origem = e.id_endereco                              
LEFT JOIN produto_relacionado prel (NOLOCK) ON prod.cod_produto = prel.cod_produto and ol.cod_operacao_logistica = prel.cod_operacao_logistica                            
LEFT JOIN param_endereco_div pediv (NOLOCK) ON pv.id_param_endereco_div = pediv.id_param_endereco_div                                    
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
 AND (                                              
  (                                              
   pv.tipo_caixa IS NOT NULL                                              
   AND @caixa_fechada = 0                                              
   )                                              
  OR (                                              
   pv.tipo_caixa IS NULL                                              
   AND @caixa_fechada = - 1                                              
   )                         
  OR (@caixa_fechada IS NULL)                                              
  )              
 --  AND (                
 -- pediv.id_param_endereco_div IS NULL                
 -- OR (pediv.id_modelo_etiqueta NOT IN (@tipo_somente_pallet)           
 -- OR @imprime_volume = 1 )             
 --)                
ORDER BY e.endereco_completo                              
 ,ISNULL(pv.cod_pedido_rel, '')                                              
 ,ped.cod_prenota                                              
 ,pv.volume                     
 END                    
 ELSE                     
 BEGIN                    
 WITH itens_volume (                              
 cod_pedido                               ,volume                              
 ,itens                              
 ,esteira                              
 )                              
AS (                              
 SELECT p.cod_pedido                              
  ,piv.volume                              
  ,SUM(piv.quantidade)                              
  ,dbo.GetEnderecoDivDescr(MAX(piv.id_endereco_origem))                              
 FROM pedido p(NOLOCK)                     
 LEFT JOIN vw_pedido_item_volume piv(NOLOCK) ON p.cod_pedido = piv.cod_pedido                              
 INNER JOIN #pedidos peds ON peds.cod_pedido = piv.cod_pedido                              
  AND peds.volume = piv.volume                              
 GROUP BY p.cod_pedido                              
  ,piv.volume                              
 )                              
 ,itens_onda (                              
 cod_onda                              
 ,itens_onda                              
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
 SELECT piv.volume                              
  ,p.cod_pedido                              
  ,isnull(min(endereco), '_') AS endereco                              
 FROM pedido p(NOLOCK)                              
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
 FROM pedido p(NOLOCK)                              
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
 FROM pedido p(NOLOCK)                              
 LEFT JOIN vw_pedido_item_volume piv(NOLOCK) ON p.cod_pedido = piv.cod_pedido                              
 INNER JOIN produto prod(NOLOCK) ON piv.cod_produto = prod.cod_produto                              
 INNER JOIN SubGrupo s(NOLOCK) ON prod.cod_subgrupo = s.cod_subgrupo                              
  AND s.cod_subgrupo = 163 /*TERMOLABEIS*/                              
WHERE   (p.cod_prenota >= @cod_prenota_ini OR @cod_prenota_ini IS NULL)                                  
  AND (p.cod_prenota <= @cod_prenota_fim OR @cod_prenota_fim IS NULL)                             
  AND (                              
   piv.volume >= @volume_ini                              
   OR @volume_ini IS NULL                              
   )                              
  AND (                              
   piv.volume <= @volume_fim                              
   OR @volume_fim IS NULL                              
   )                              
  AND (p.cod_onda = @cod_onda OR @cod_onda = 0)                              
 GROUP BY p.cod_pedido                              
 )                              
                     
SELECT ped.cod_pedido AS id_pedido                              
-- ,ped.cod_pedido * 10 + dbo.calcDigitoMod11(ped.cod_pedido) AS cod_pedido        
 ,t1.numero_titulo AS cod_pedido                              
 ,ped.cod_prenota AS id_picking                              
 ,RIGHT('0000000' + convert(VARCHAR, ped.cod_prenota * 10 + dbo.calcDigitoMod11(ped.cod_prenota)), 7) AS cod_picking                              
 ,ISNULL(ped.cod_pedido_polo, '00000000000') AS cod_pedido_legado                              
 ,right('0000' + convert(VARCHAR, (                              
    SELECT COUNT(*)                              
    FROM pedido_volume pv2(NOLOCK)                              
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
 ,CASE                               
  WHEN pe.endereco <> ''                              
   THEN dbo.RemoveAcentos(pe.endereco)                              
  ELSE dbo.RemoveAcentos(ee.endereco)                      
  END AS endereco                              
 ,CASE                         
  WHEN pe.bairro <> ''                              
   THEN dbo.RemoveAcentos(pe.bairro)                              
 ELSE dbo.RemoveAcentos(ee.bairro)                              
  END AS bairro                              
 ,CASE                               
  WHEN pe.bairro <> ''                              
   THEN dbo.RemoveAcentos(pe.bairro)                       
  ELSE dbo.RemoveAcentos(ee.bairro)                              
  END AS bairro                              
 ,CASE                               
  WHEN pe.bairro <> ''                              
   THEN isnull(dbo.RemoveAcentos(pe.complemento), ' . ')                              
  ELSE isnull(dbo.RemoveAcentos(ee.complemento), ' . ')                              
  END AS complemento                              
 ,CASE                               
  WHEN pe.cep <> ''                              
   THEN pe.cep                              
  ELSE ee.cep                              
  END AS cep                              
 ,CASE                               
  WHEN pe.cep <> ''                              
   THEN (                              
     SELECT dbo.RemoveAcentos(cepe.cidade)                              
   FROM cep cepe                              
     WHERE cepe.cep = pe.cep                              
     )                              
  ELSE dbo.RemoveAcentos(cep.cidade)                              
  END AS cidade                              
 ,CASE   
  WHEN pe.cep <> ''                              
   THEN (                              
     SELECT cepe.sigla_estado                              
     FROM cep cepe                              
     WHERE cepe.cep = pe.cep                              
     )                              
  ELSE cep.sigla_estado                              
  END AS estado                              
 ,CASE                               
  WHEN pe.bairro <> ''                              
   THEN dbo.RemoveAcentos(CONVERT(VARCHAR, RTRIM(pe.bairro) + ' - ' + (                              
       SELECT RTRIM(cepe.cidade)                              
       FROM cep cepe                              
       WHERE cepe.cep = pe.cep                              
       ) + ' - ' + (                              
       SELECT RTRIM(cepe.sigla_estado)                              
       FROM cep cepe                              
       WHERE cepe.cep = pe.cep                              
       )))                              
  ELSE dbo.RemoveAcentos(CONVERT(VARCHAR(MAX), RTRIM(ee.bairro) + ' - ' + RTRIM(cep.cidade) + ' - ' + RTRIM(cep.sigla_estado)))                              
  END AS bairro_cid_uf                              
,-- Retorna o bairro + cidade + UF                                  
 CASE                               
  WHEN pe.cep <> ''            
   THEN CONVERT(VARCHAR, CASE                               
      WHEN pe.observacao IS NULL                              
       THEN 'CEP '                              
      ELSE '- CEP '                              
      END + pe.cep)                              
  ELSE CONVERT(VARCHAR, CASE                               
     WHEN ee.observacao IS NULL                     
      THEN 'CEP '                              
     ELSE '- CEP '                              
     END + ee.cep)                              
  END AS obs_cep                              
 ,-- Retorna obs do endere�o + cep                                  
 CASE                               
  WHEN r_trans.cod_rota IS NOT NULL                              
   THEN RIGHT('0000' + CONVERT(VARCHAR(4), r_trans.cod_rota), 4)                              
  ELSE ISNULL(ee.cod_rota, '_')                              
  END AS rota        ,                        
   CASE WHEN pe.id_pedido_ender IS NOT NULL THEN                                     
       r_trans.descricao                                     
    ELSE                                     
       r.descricao                          
    END AS rota_descricao,                            
 CONVERT(VARCHAR(10), getdate(), 103) AS emissao                              
                       
                       
 ,CONVERT(VARCHAR(4),replicate('0',4 - len(convert(varchar(4),pv.volume))) + convert(varchar(4),pv.volume)) as volume                      
 ,CASE                               
  WHEN pv.tipo_caixa IS NULL                              
   THEN 'CAIXA FECHADA'                              
  ELSE CONVERT(VARCHAR(20), ce.descricao)                              
  END AS tipo_caixa                              
 ,'7' + RIGHT('0000000' + CONVERT(VARCHAR(7), ped.cod_prenota * 10 + dbo.calcDigitoMod11(ped.cod_prenota)), 7) + RIGHT('0000' + CONVERT(VARCHAR(4), pv.volume), 4) AS cod_barra_PN                              
 ,CONVERT(VARCHAR(10), ped.termino_digitacao, 103) AS data_pedido                              
 ,                              
 --  CONVERT(VARCHAR(16), ped.termino_digitacao + '04:00:00', 120)  AS entrega_maxima,                              
 (                              
  CASE                               
 WHEN ped.obs_liberacao <> '' /*Programado*/                              
    THEN replace(ped.obs_liberacao, '�', 'e')                              
   WHEN ped.cod_modalidade = 3 /*D+1*/                              
    THEN 'Pedido D+1'                              
WHEN dsub.cod_suboperacao IN (                              
     1     
     ,11                              
     ,14                              
     ) /*Correio*/                              
    THEN '_'                             
   ELSE 'Entr. Max: ' + CONVERT(VARCHAR(16), ped.termino_digitacao + '04:00:00', 120)                              
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
 ,ISNULL(ped.cod_onda, '') AS cod_onda                              
 ,SUBSTRING(ent.razao_social, 1, 21) + ' (' + CONVERT(VARCHAR, ent.cod_entidade * 10 + dbo.calcDigitoMod11(ent.cod_entidade)) + ')' AS ent_c_cod                              
 ,--retorna entidade com o cod                                  
 -- dbo.RemoveAcentos(CONVERT(VARCHAR, ee.bairro + ' - ' + cep.cidade + ' - ' + cep.sigla_estado)) AS bairro_cid_uf, -- Retorna o bairro + cidade + UF                                  
 CONVERT(VARCHAR, CASE                               
   WHEN ee.observacao IS NULL                              
    THEN 'CEP '                              
   ELSE '- CEP '                              
   END + ee.cep) AS obs_cep                              
 ,-- Retorna obs do endere�o + cep                                  
 CASE                               
  WHEN transportadora.cod_entidade IS NOT NULL                              
   THEN transportadora.fantasia             
  ELSE dbo.RemoveAcentos(ISNULL(ent_transp.fantasia, '_'))                              
  END AS transportadora                              
 ,CONVERT(VARCHAR(10), CONVERT(VARCHAR, CONVERT(INT, ISNULL(iv.itens, 0))) + ' ITENS') AS itens                              
 ,CONVERT(VARCHAR(7), CONVERT(INT, ISNULL(ionda.itens_onda, 0))) + ' CX' AS itens_onda                              
 ,'0000' + '>5' + RIGHT('00000000000' + CONVERT(VARCHAR(12), ped.cod_pedido_polo), 12) + right('00' + CONVERT(VARCHAR, pv.volume), 4) + right('00' + CONVERT(VARCHAR, (                              
    SELECT COUNT(*)                              
    FROM pedido_volume pv2(NOLOCK)                              
    WHERE pv2.cod_pedido = ped.cod_pedido                              
    )), 3) + REPLACE(ee.cep, '-', '') + '>50' AS EAN_jequiti                              
 ,RIGHT('000000000' + CONVERT(VARCHAR(9), ped.cod_pedido_polo), 9) + RIGHT('000' + CONVERT(VARCHAR, pv.volume), 3) AS picking_volume_jequiti                              
 ,CONVERT(VARCHAR, pv.volume) + '/' + CONVERT(VARCHAR, (                              
   SELECT COUNT(*)                              
   FROM pedido_volume pv2(NOLOCK)                              
   WHERE pv2.cod_pedido = ped.cod_pedido                              
   )) AS volume_volumes                              
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
  END AS setor  ,                      
                          
   case when ol.cod_operacao_logistica = 1 then 'DMD'        
      when ol.cod_operacao_logistica = 2 then 'VTP'              when ol.cod_operacao_logistica = 3 then 'TFM' end as oper_logisttica-- Alan incluiu a opera��o logistica 19-12-2019 -- ajuste aqui pr n�o existe 2019-12-19                          
 ,ce.descricao              
 ,concat( replicate ('0',6 - len (rank() over (partition by iif( ce.descricao is null,0,1) order by  ISNULL(pv.cod_pedido_rel, '') desc  ,ped.cod_prenota  desc  ,pv.volume  desc )))      
   , rank() over (partition by iif( ce.descricao is null,0,1) order by   ISNULL(pv.cod_pedido_rel, '') desc  ,ped.cod_prenota  desc  ,pv.volume  desc   ))  contador           
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
    THEN 'ENTREGA PROGRAMADA'                              
   ELSE isnull(dmp.descritivo, 'SEM MODALIDADE')                              
   END                              
  ) AS modalidade                              
 --,replace(cast(ped.valor_total AS DECIMAL(10, 4)), '.', '') AS valor_total               
,ped.valor_total                             
 ,(                              
  CASE                               
   WHEN ped.obs_PN = ''                              
    THEN '_'                              
   END                              
  ) AS obs_PN                              
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
 ,CONVERT(VARCHAR, ISNULL(DATEADD(day, (dea.dias_entrega), data_saida_transp), getdate()), 103) AS data_prevista_entrega                                  
 ,ISNULL(ISNULL(UPPER(pe.observacao), UPPER(ee.observacao)), UPPER(ent.razao_social)) as razao_ou_destinatario,                               
        LEFT(CONVERT(VARCHAR, cep.cidade + ' - ' + ee.bairro), 35) AS cid_bairro,                    
 entt.cod_entidade * 10 + entt.digito AS cod_operacao_logistica,                    
 entt_rel.cod_entidade_rel AS cod_relacionado_operacao_logistica ,                                  
 entt.razao_social AS razao_social_operacao_logistica,                    
 entt.fantasia AS fantasia_operacao_logistica                    
 ,edoc.numero AS cnpj_cliente                    
 ,0 AS codigo_produto                                         
 ,'_' AS lote                                  
 ,NULL AS quantidade                                  
 ,'_' AS descProduto                            
 ,'_' AS ender_completo                                  
 ,ped.obs_liberacao AS obs_liberacao                                  
 ,                                   
 CASE                                                         
  WHEN entt.cod_entidade IS NOT NULL                                                        
  THEN entt.fantasia                                                        
  ELSE dbo.RemoveAcentos(ISNULL(entt.fantasia, '_'))                                                        
END AS transp                                   
 ,ped.obs_PN AS ObsPN                                  
 ,'_' AS cod_produto_rel                     
 , Case WHEN isnull(PV.reimpressao,0) = 0 THEN 'N'                                
   ELSE 'S' END as reimpressao                   
FROM pedido ped(NOLOCK)                              
INNER JOIN dias_entrega_ajustados dea(NOLOCK) ON ped.cod_pedido = dea.cod_pedido                              
INNER JOIN operacao_logistica ol(NOLOCK) ON ol.cod_operacao_logistica = ped.cod_operacao_logistica                         
INNER JOIN                           
  entidade eoli on eoli.cod_entidade = ol.cod_operacao_logistica                           
INNER JOIN pedido_volume pv(NOLOCK) ON ped.cod_pedido = pv.cod_pedido                              
LEFT JOIN #pedido_sigla ps(NOLOCK) ON ped.cod_pedido = ps.cod_pedido                              
LEFT JOIN endereco_produto_volume pev(NOLOCK) ON pv.cod_pedido = pev.cod_pedido                              
 AND pv.Volume = pev.volume                              
LEFT JOIN caixa_esteira ce(NOLOCK) ON ce.id_caixa = pv.tipo_caixa                              
LEFT JOIN -- ALAN                                
 itens_volume iv(NOLOCK) ON ped.cod_pedido = iv.cod_pedido                              
 AND pv.Volume = iv.volume                              
INNER JOIN entidade ent(NOLOCK) ON ped.cod_entidade = ent.cod_entidade                              
LEFT JOIN entidade_ender ee(NOLOCK) ON ent.cod_entidade = ee.cod_entidade                              
 AND ee.principal = - 1                              
LEFT JOIN rota r(NOLOCK) ON r.cod_rota = ee.cod_rota                        
LEFT JOIN cep(NOLOCK) ON ee.cep = cep.cep                     
LEFT JOIN transportadora_rota tr(NOLOCK) ON ee.cod_rota = tr.cod_rota                              
 AND tr.cod_transportadora = ped.cod_transportadora                              
LEFT JOIN                              
 --AND tr.transportadora_principal = 1 INNER JOIN                                    
 pedido_ender pe(NOLOCK) ON ped.cod_pedido = pe.cod_pedido                              
LEFT JOIN rota r_trans(NOLOCK) ON pe.cod_rota = r_trans.cod_rota                              
LEFT JOIN entidade transportadora(NOLOCK) ON ped.cod_transportadora = transportadora.cod_entidade                              
LEFT JOIN entidade ent_transp(NOLOCK) ON tr.cod_transportadora = ent_transp.cod_entidade                              
INNER JOIN param_operacao po(NOLOCK) ON po.cod_distribuicao = ol.cod_distribuicao                              
 AND po.operacao = ped.operacao                              
LEFT JOIN atributo_pedido ap(NOLOCK) ON ped.cod_pedido = ap.cod_pedido                              
 AND ap.cod_tipo_atributo = 1                              
LEFT JOIN --Produto com venda proibida para Varejoa - somente hostipais                                  
 itens_onda ionda(NOLOCK) ON ped.cod_onda = ionda.cod_onda                              
LEFT JOIN def_modalidade_pedido dmp(NOLOCK) ON ped.cod_modalidade = dmp.cod_modalidade                              
LEFT JOIN def_suboperacao dsub(NOLOCK) ON ped.cod_suboperacao = dsub.cod_suboperacao                              
LEFT JOIN iten_controlado ic(NOLOCK) ON ped.cod_pedido = ic.cod_pedido                              
LEFT JOIN iten_termolabel it(NOLOCK) ON ped.cod_pedido = it.cod_pedido                       
LEFT JOIN  entidade entt (NOLOCK) ON ol.cod_operacao_logistica = entt.cod_entidade                     
LEFT JOIN entidade_relacionada entt_rel ON entt.cod_entidade = entt_rel.cod_entidade AND entt.cod_tipo = entt_rel.cod_tipo                                
                      
INNER JOIN #pedidos peds ON peds.cod_pedido = ped.cod_pedido                              
                               
 AND peds.volume = pv.volume                              
LEFT JOIN entidade_doc edoc (NOLOCK) ON ent.cod_entidade = edoc.cod_entidade                    
          AND cod_tipo_doc IN (1,3)                
LEFT JOIN param_endereco_div pediv (NOLOCK) ON pv.id_param_endereco_div = pediv.id_param_endereco_div                            
left join pedido_titulo pt (nolock) on ped.cod_pedido = pt.cod_pedido      
left join titulo t1 (nolock) on pt.cod_titulo = t1.cod_titulo           
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
 AND (                              
  (                              
   pv.tipo_caixa IS NOT NULL                              
   AND @caixa_fechada = 0                              
   )                              
  OR (                              
   pv.tipo_caixa IS NULL                              
   AND @caixa_fechada = - 1                              
   )                              
  OR (@caixa_fechada IS NULL)                              
  )                  
  AND(                
   pv.id_onda_volume IS NULL                
   OR (PV.id_onda_volume IS NOT NULL AND pv.cod_pedido_rel IS NULL)                
  )                
 --AND (                
 -- pediv.id_param_endereco_div IS NULL                
 -- OR (pediv.id_modelo_etiqueta NOT IN (@tipo_somente_pallet)           
 -- OR @imprime_volume = 1 )            
 --)                
ORDER BY     
ped.cod_pedido,    
--,id_pedido    
ISNULL(pv.cod_pedido_rel, '')                              
 ,ped.cod_prenota                              
 ,pv.volume                     
                     
 END                    
              
DROP TABLE #pedidos                                              
                                               
DROP TABLE #pedido_endereco                                              
                                               
DROP TABLE #pedido_sigla                                              
                                               
DROP TABLE #dias_entrega_ajustados 