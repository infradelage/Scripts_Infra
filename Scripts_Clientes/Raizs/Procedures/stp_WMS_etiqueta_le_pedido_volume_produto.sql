-- GRUPOVOETUR\lucas.aquino@2023-02-16 12:00 <Inserido campo  LPN (4 últimos digitos)>    
-- GRUPOVOETUR\lucas.aquino@2023-02-03 10:55 <Ajustado a ordem de impressão por Pedido_Cliente, id_pedio e nº do volume>    
-- GRUPOVOETUR\lucas.aquino@2022-12-05 11:49 <Ajustado a ordem de impressão por nº do volume>      
-- DELAGE\Marcelo.Souza@2022-10-25 16:49 <Inserido os campos onda_ini, onda_fim, transportadora>     
-- GRUPOVOETUR\lucas.aquino@2022-10-25 15:16 <Inserido o campo numero_titulo>      
-- DELAGE\Matheus.Melo@2022-09-16 16:35 <Inserido o campo cod_barra da tabela caixa fechada>      
-- DELAGE\thiago.faria@2022-09-13 15:22: <Ajustado o campo quantidade para não trazer os zeros depois da virgula por exemplo 12,00 virou 12>         
-- DELAGE\claudio.lopes@2022-07-25 11:09:45: <Nao retornando as etiquetas de volume que nao retorna os dados>                  
-- DELAGE\renato.netto@2022-07-15 16:30:54: <tamanho campos estado e cep>                        
-- DELAGE\claudio.lopes@2022-05-09 17:23:12: <Add no grupo by os campos cod_entrega_rel e ordem_divisao_endereco >                        
-- DELAGE\claudio.lopes@2022-05-03 16:52:49: <Add retorno de transportador e sequencia>                          
-- DELAGE\jean.francisquini@2022-05-02 14:07:43: <Adicionando campo reimpressao>                            
-- DELAGE\claudio.lopes@2021-11-24 18:23:00: <Add cod_onda no group by>                            
-- DELAGE\samuel.oliveira@2020-06-04 16:08:53: <add cod_onda>                                    
-- DELAGE\jean.francisuqini@2020-06-04 16:08:53: <add cnpj>                                      
-- DELAGE\igor.couto@2020-01-31 16:00:43: <acrescimo da operacao logistica abreviada>                                      
-- DELAGE\Wesley@2019-02-18 11:23:18: <Distinct #pedidos>                                                        
-- DELAGE\Wesley@2019-02-18 11:23:18: <voltando com os filtros de volume no insert da #t>                                                        
-- DELAGE\alan.oliveira@2018-12-04 14:47:07: <AND (p.cod_onda = @cod_onda OR @cod_onda = 0)>                                                        
-- DELAGE\jorge.moreira@2018-06-26 13:29:14: <alteração no cáclulo do dia de entrega com base nos feriados para incluir feriados anualmente recorrentes>                                                        
-- DELAGE\jonathan.muniz@2018-01-30 14:29:54: <tratativa do CEP>                                                        
-- DELAGE\jonathan.muniz@2018-01-29 14:30:29: <tratativa da sigla_transportadora>                                                        
-- DELAGE\jorge.moreira@2018-01-29 13:44:05: <cálculo do dia de entrega com base nos feriados>                                                        
-- DELAGE\jorge.moreira@2017-11-16 16:05:14: <retorno de data_prevista_entrega>                                                          
-- DELAGE\carlos.oliveira@2017-05-25 10:51:59: <retornar também a HH:MM para campo emissao>                                                          
-- DELAGE\carlos.oliveira@2016-09-23 17:43:51: <cruzamento com a pedido_ender>                                           
CREATE OR ALTER PROCEDURE stp_WMS_etiqueta_le_pedido_volume_produto                        
  @cod_prenota_ini INT = NULL                                          
 ,@cod_prenota_fim INT = NULL                                          
 ,@cod_operacao_logistica INT = NULL                                          
 ,@situacao INT = NULL                                          
 ,@caixa_fechada SMALLINT = NULL                                        
 ,@volume_ini INT = NULL                                          
 ,@volume_fim INT = NULL                                          
 ,@cod_distribuicao INT = NULL                                          
 ,@operacao INT = NULL                                          
 ,@cod_onda INT = NULL              
 ,@imprime_volume BIT = 0    
 ,@onda_ini INT = NULL     
 ,@onda_fim INT = NULL    
 ,@transportadora VARCHAR(MAX) = NULL    
    
    
AS                                                                                                                                                                                                                                                             
              
--DECLARE @tipo_somente_pallet INT                  
                   
--SELECT @tipo_somente_pallet = pallet FROM param_def_modelo_etiqueta                  
                   
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
WHERE (                                        
  p.cod_prenota >= @cod_prenota_ini                                        
  OR @cod_prenota_ini IS NULL                                        
  )                                        
 AND (             
  p.cod_prenota <= @cod_prenota_fim                                        
  OR @cod_prenota_fim IS NULL                                        
  )                                        
 AND (                                        
  ceppe.cep IS NOT NULL                                        
  OR cepee.cep IS NOT NULL                                        
  )                                        
 AND (            
  p.cod_onda = @cod_onda                                        
  OR @cod_onda = 0                                        
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
 AND pe.cep BETWEEN sigla_cep.cep_inicial                                        
  AND sigla_cep.cep_final                                        
WHERE (                                        
  sigla_municipio.sigla IS NOT NULL                                 
  OR sigla_estado.sigla IS NOT NULL                                        
  OR sigla_pais.sigla IS NOT NULL                                        
  OR sigla_cep.sigla IS NOT NULL                                        
  )                                        
                                        
-- Tratativa de Sigla da Transportadora -- FIM                                                        
--begin obs@Jorge#29/01/2017: criação de tabelas para o cálculo do dia de entrega                                   
SELECT DISTINCT ped.cod_pedido, ped.obs_liberacao, ped.cod_onda                                       
INTO #pedidos                                        
FROM pedido ped                                        
INNER JOIN operacao_logistica ol(NOLOCK) ON ol.cod_operacao_logistica = ped.cod_operacao_logistica                                        
INNER JOIN param_estoque param(NOLOCK) ON param.cod_distribuicao = ol.cod_distribuicao                                        
INNER JOIN pedido_volume pv(NOLOCK) ON ped.cod_pedido = pv.cod_pedido                                        
WHERE (                                        
  ped.cod_operacao_logistica = @cod_operacao_logistica                                        
  OR @cod_operacao_logistica IS NULL                                        
  )                                        
 AND (                                        
  ped.cod_prenota >= @cod_prenota_ini                                        
 OR @cod_prenota_ini IS NULL                                        
  )                                        
 AND (                                        
  ped.cod_prenota <= @cod_prenota_fim                                        
  OR @cod_prenota_fim IS NULL                                        
  )                                        
 AND (                                        
  ped.cod_situacao = @situacao                                        
  OR @situacao IS NULL                                        
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
 AND (                                        
  pv.volume >= @volume_ini                                        
  OR @volume_ini IS NULL            
  )                                        
 AND (                                        
  pv.volume <= @volume_fim                                        
  OR @volume_fim IS NULL                                        
  )                                        
 AND (                                        
  ped.operacao = @operacao                                        
  OR @operacao IS NULL                                        
  )                                        
 AND (                                        
  ol.cod_distribuicao = @cod_distribuicao                                        
  OR @cod_distribuicao IS NULL                                        
  )                                        
 AND (                                        
  ped.cod_onda = @cod_onda                                        
  OR @cod_onda = 0                                        
  )                                      
                                        
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
  ELSE IF DATEPART(WEEKDAY, @data_auxiliar) = 7 --sábado                                                        
  BEGIN                                        
   SET @data_auxiliar = ISNULL(DATEADD(day, (2), @data_auxiliar), GETDATE())                                        
   SET @dias_a_mais = @dias_a_mais + 2                                        
  END                                        
                                        
  IF EXISTS (                                        
    SELECT 1                                        
    FROM feriado f                                        
    LEFT JOIN municipio m ON m.id_municipio = f.id_municipio                                        
     AND m.sigla_estado = f.sigla_estado                                        
    WHERE (                                       
      f.data = @data_auxiliar                                        
      OR (                                        
       f.anual = 1                                        
       AND DAY(f.data) = DAY(@data_auxiliar)                                        
       AND MONTH(f.data) = MONTH(@data_auxiliar)                                        
       )                                        
      ) -- se (feriado for igual a data) ou (se for recorrente com dia e mês iguais)                                                         
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
                              
-- end obs@Jorge#29/01/2017                                                        
SELECT identity(INT, 1, 1) contador                                        
 ,ped.cod_pedido AS id_pedido                               
 --,right('0000000' + convert(VARCHAR, ped.cod_pedido * 10 + dbo.calcDigitoMod11(ped.cod_pedido)), 7) AS cod_pedido         
 ,t1.numero_titulo AS cod_pedido                                        
 ,ped.cod_prenota AS id_picking                                        
 ,right('0000000' + convert(VARCHAR, ped.cod_prenota * 10 + dbo.calcDigitoMod11(ped.cod_prenota)), 7) AS cod_picking                                        
 ,ped.cod_pedido_polo AS cod_pedido_legado                                        
 ,right('0000' + convert(VARCHAR, (                                        
    SELECT COUNT(*)                                        
    FROM pedido_volume pv2                                        
    WHERE pv2.cod_pedido = ped.cod_pedido                                        
    )), 4) AS volumes                                        
 ,ent.cod_entidade AS id_entidade                                        
 ,ent.cod_entidade * 10 + dbo.calcDigitoMod11(ent.cod_entidade) AS cod_entidade                                        
 ,ent.fantasia                                        
 ,ent.razao_social                                        
 --,dbo.GetEnderecoDivDescr(MAX(Ender.id_endereco)) AS setor                                       
 ,def_setor.descricao as setor                                      
 ,                                        
 --ee.endereco as endereco_entidade,                                                           
 CASE                                         
  WHEN pe.id_pedido_ender IS NOT NULL                                        
   THEN pe.endereco                                        
  ELSE ee.endereco                               
  END AS endereco_entidade                            
 ,                                        
 --ee.cod_rota AS rota,                                                           
 CASE                        
  WHEN pe.id_pedido_ender IS NOT NULL                                        
   THEN pe.cod_rota                                        
  ELSE ee.cod_rota                                        
  END AS rota                                        
 ,                                        
 --ee.caminho AS caminho,                                                           
 CAST(CASE                                           
  WHEN pe.id_pedido_ender IS NOT NULL                                          
   THEN CONVERT(INT, pe.caminho)                                            
  ELSE CONVERT(INT, ee.caminho)                                          
  END as INT) AS caminho                                       
 ,                                        
 --ee.bairro,                                                           
 CASE                                         
  WHEN pe.id_pedido_ender IS NOT NULL                   
   THEN pe.bairro                                        
  ELSE ee.bairro                                        
  END AS bairro                                        
 ,                                        
 --ee.cep,                           
 CASE                                         
  WHEN pe.id_pedido_ender IS NOT NULL                                        
   THEN pe.cep                                        
  ELSE ee.cep                                        
  END AS cep                                        
 ,                                        
 --cep.cidade,                                                           
 CASE                                         
  WHEN pe.id_pedido_ender IS NOT NULL                                        
   THEN cep2.cidade                                        
  ELSE cep.cidade                                        
  END AS cidade                                        
 ,                                        
 --cep.sigla_estado as estado,                                                     
 CASE                                         
  WHEN pe.id_pedido_ender IS NOT NULL                                        
   THEN cep2.sigla_estado                                        
  ELSE cep.sigla_estado                                        
  END AS estado                                        
 ,                                            
   ol.abreviacao AS operacao_logistica_abreviada,                                           
                                              
 CONVERT(VARCHAR(10), getdate(), 103) + ' ' + substring(CONVERT(VARCHAR(10), getdate(), 8), 1, 5) AS emissao                                        
 ,CONVERT(VARCHAR(4), replicate('0', 4 - len(convert(VARCHAR(4), pv.volume))) + convert(VARCHAR(4), pv.volume)) AS volume                                        
 ,CASE                                         
  WHEN pv.tipo_caixa IS NULL                                        
   THEN 'CAIXA FECHADA'                                        
  ELSE CONVERT(VARCHAR(5), pv.tipo_caixa)                                        
  END AS tipo_caixa                                        
 ,NULL AS esteira                                        
 ,prod.cod_produto AS id_produto        
 ,prod.cod_produto * 10 + dbo.calcDigitoMod11(prod.cod_produto) AS codigo_produto                                        
 ,prod.descricao AS descricao                                        
 ,isnull(ef.endereco_completo, 'ND') AS endereco                                        
 ,l.id_lote                                        
 ,l.lote                                        
 ,l.validade                                        
 ,sum(CONVERT(decimal(10, 0),piv.quantidade)) AS quantidade                                        
 ,'7' + RIGHT('0000000' + CONVERT(VARCHAR(7), ped.cod_prenota * 10 + dbo.calcDigitoMod11(ped.cod_prenota)), 7) + RIGHT('0000' + CONVERT(VARCHAR(4), pv.volume), 4) AS cod_barra_PN                                        
 ,lp.descricao AS fantasia_fornecedor                                        
 ,MAX(Ender.endereco_completo) AS endereco1          
 ,'' lpn --RIGHT(lpn.numero,4) lpn  
 --,lpn.numero lpn  
  
 ,CONVERT(VARCHAR(10), ped.termino_digitacao, 103) AS data_pedido                             
 ,                                        
 --r.descricao as rota_descricao,                                                           
 CASE                     WHEN pe.id_pedido_ender IS NOT NULL                                        
THEN r2.descricao                                        
  ELSE r.descricao                                        
  END AS rota_descricao                                        
 ,er.cod_entidade_rel                                        
 --,CASE                                         
 -- WHEN ISNULL(ap.cod_tipo_atributo, 0) = 1                                        
 --  THEN 'CARIMBAGEM'                                        
 -- ELSE '_'                                        
 -- END AS carimbagem                                   
                                    
 ,(pv.cod_pedido_rel) AS cod_pedido_rel                                        
 ,                                        
 --LEFT(CONVERT(VARCHAR, cep.cidade + ' - ' + ee.bairro), 35) AS cid_bairro                               
 CASE                                         
  WHEN pe.id_pedido_ender IS NOT NULL                                        
   THEN LEFT(CONVERT(VARCHAR, cep2.cidade + ' - ' + pe.bairro), 35)                                        
  ELSE LEFT(CONVERT(VARCHAR, cep.cidade + ' - ' + ee.bairro), 35)                                        
  END AS cid_bairro                                        
 ,DATEADD(day, dea.dias_entrega, ped.data_saida_transp) AS data_prevista_entrega                                        
 ,                                        
 --,ISNULL(ps.sigla, '000') as sigla                                 --,ISNULL(ps.cod_externo, '000') as cod_externo                                           
 entt.cod_entidade * 10 + entt.digito AS cod_operacao_logistica                    
 ,entt_rel.cod_entidade_rel AS cod_relacionado_operacao_logistica                                        
 ,entt.razao_social AS razao_social_operacao_logistica                                        
 ,entt.fantasia AS fantasia_operacao_logistica           
 ,edoc.numero AS cnpj_cliente                                    
 ,p.obs_liberacao                                   
 ,ent_tran.razao_social as carimbagem                                  
                                
 ,ISNULL(ped.cod_onda, '') AS cod_onda                                 
 ,                                
 Case WHEN isnull(PV.reimpressao,0) = 0 THEN 'N'                                
   ELSE 'S' END as reimpressao                          
 ,re.cod_entrega_rel AS transportadora                          
 ,ov.volume AS sequencia                      
 ,'' AS linha      
 ,cxf.cod_barra      
 ,t1.numero_titulo      
INTO #T                                        
FROM #pedidos p                                        
INNER JOIN dias_entrega_ajustados dea(NOLOCK) ON p.cod_pedido = dea.cod_pedido                                        
INNER JOIN pedido ped(NOLOCK) ON p.cod_pedido = ped.cod_pedido                                        
INNER JOIN operacao_logistica ol(NOLOCK) ON ol.cod_operacao_logistica = ped.cod_operacao_logistica                                 
INNER JOIN entidade eoli ON eoli.cod_entidade = ol.cod_operacao_logistica                                        
INNER JOIN param_estoque param(NOLOCK) ON param.cod_distribuicao = ol.cod_distribuicao                                        
INNER JOIN pedido_volume pv(NOLOCK) ON ped.cod_pedido = pv.cod_pedido                                        
INNER JOIN pedido_item_lote_endereco pile(NOLOCK) ON ped.cod_pedido = pile.cod_pedido      
LEFT JOIN  caixa_fechada cxf(NOLOCK) ON cxf.cod_produto = pile.cod_produto and cxf.principal = -1      
INNER JOIN pedido_item_volume piv(NOLOCK) ON pile.id_pedido_item_lote_endereco = piv.id_pedido_item_lote_endereco                                        
 AND pv.volume = piv.volume                                        
LEFT JOIN pedido_item_volume_lote PIVL(NOLOCK) ON PIVL.id_pedido_item_volume = PIV.id_pedido_item_volume                                        
INNER JOIN endereco ender(NOLOCK) ON piv.id_endereco_origem = ender.id_endereco       
--left join  lpn (nolock) on ender.id_endereco = lpn.id_endereco     
INNER JOIN produto prod(NOLOCK) ON pile.cod_produto = prod.cod_produto                                    
LEFT JOIN linha_produto lp(NOLOCK) ON lp.id_linha_produto = prod.id_linha_produto                                        
LEFT JOIN entidade ent(NOLOCK) ON ped.cod_entidade = ent.cod_entidade                                        
LEFT JOIN entidade_ender ee(NOLOCK) ON ent.cod_entidade = ee.cod_entidade                                        
 AND ee.principal = - 1                                        
LEFT JOIN rota r(NOLOCK) ON r.cod_rota = ee.cod_rota                                        
LEFT JOIN cep(NOLOCK) ON ee.cep = cep.cep                                        
LEFT JOIN lote l(NOLOCK) ON ISNULL(PIVL.id_lote_dest, piv.id_lote_dest) = l.id_lote                                        
LEFT JOIN vw_produto_endereco_flowrack pef(NOLOCK) ON pef.cod_produto = prod.cod_produto                                        
 AND pef.cod_operacao_logistica = ol.cod_operacao_logistica                                        
LEFT JOIN endereco ef(NOLOCK) ON ef.id_endereco = pef.id_endereco                                    
LEFT OUTER JOIN entidade_relacionada er(NOLOCK) ON er.cod_entidade = ent.cod_entidade                                        
LEFT JOIN atributo_pedido ap ON ped.cod_pedido = ap.cod_pedido                                        
 AND ap.cod_tipo_atributo = 1                                        
LEFT JOIN --Produto com venda proibida para Varejoa - somente hostipais        
 pedido_ender pe(NOLOCK) ON pe.cod_pedido = ped.cod_pedido                                        
LEFT JOIN rota r2(NOLOCK) ON r2.cod_rota = pe.cod_rota                                        
LEFT JOIN cep cep2(NOLOCK) ON pe.cep = cep2.cep                                        
LEFT JOIN #pedido_sigla ps(NOLOCK) ON ped.cod_pedido = ps.cod_pedido                                        
LEFT JOIN entidade entt(NOLOCK) ON ol.cod_operacao_logistica = entt.cod_entidade                                        
LEFT JOIN entidade_relacionada entt_rel ON entt.cod_entidade = entt_rel.cod_entidade                                        
 AND entt.cod_tipo = entt_rel.cod_tipo                                        
LEFT JOIN entidade_doc edoc (NOLOCK) ON ent.cod_entidade = edoc.cod_entidade                                      
          AND cod_tipo_doc IN (1,3)                                   
LEFT JOIN def_endereco_setor def_setor (NOLOCK) on def_setor.id_def_endereco_setor = ender.id_def_endereco_setor                                  
LEFT JOIN entidade ent_tran (NOLOCK) on ped.cod_transportadora = ent_tran.cod_entidade                          
LEFT JOIN pedido_volume_carregamento pvc (NOLOCK) ON p.cod_pedido = pvc.cod_pedido AND pv.Volume = pvc.volume                            
LEFT JOIN romaneio_entrega re (NOLOCK) ON pvc.cod_entrega = re.cod_entrega              
LEFT JOIN param_endereco_div pediv (NOLOCK) ON pv.id_param_endereco_div = pediv.id_param_endereco_div                
LEFT JOIN onda_volume ov (NOLOCK) ON pv.id_onda_volume = ov.id_onda_volume                    
left join pedido_titulo pt (nolock) on ped.cod_pedido = pt.cod_pedido      
left join titulo t1 (nolock) on pt.cod_titulo = t1.cod_titulo                 
WHERE (                                        
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
 AND (                                        
  pv.volume >= @volume_ini                                        
  OR @volume_ini IS NULL                                        
  )                                        
 AND (                       
  pv.volume <= @volume_fim                                        
  OR @volume_fim IS NULL                                        
  )                    
 --AND (                      
 -- pediv.id_param_endereco_div IS NULL                      
 -- OR (pediv.id_modelo_etiqueta NOT IN (@tipo_somente_pallet)               
  --OR @imprime_volume = 1 )                    
 --)                      
--obs@Jorge#29/01/2018: clausula WHERE removida daqui porque já foi usada em #pedidos                                                         
GROUP BY                  
ped.cod_pedido                                    
 ,p.obs_liberacao                                         
 ,ped.cod_prenota                                        
 ,ped.cod_pedido_polo                                        
 ,ent.cod_entidade                                        
 ,ent.fantasia                                        
 ,ent.razao_social                                        
 ,pe.id_pedido_ender                                        
 ,pe.bairro                
 ,pe.caminho                
 ,ee.bairro                
 ,cep.cidade                                        
 ,cep2.cidade                                        
 ,pe.cod_rota                                        
 ,ee.cod_rota                                        
 ,eoli.fantasia                                        
 ,entt.cod_entidade * 10 + entt.digito                    
 ,entt.razao_social                                        
 ,def_setor.descricao                                   
 ,entt_rel.cod_entidade_rel                                     
 , ent_tran.razao_social                                  
 ,entt.fantasia                                        
 ,ped.cod_onda                              
 ,pv.reimpressao                            
 ,re.cod_entrega_rel                        
 ,pediv.ordem_divisao_endereco                        
 ,ov.volume             
 --,right(lpn.numero,4)  
 ,                
 --ps.sigla, ps.cod_externo,                                                        
 --ee.endereco,                                                           
 CASE                   
  WHEN pe.id_pedido_ender IS NOT NULL                                        
   THEN pe.endereco                                        
  ELSE ee.endereco                                        
  END                                        
 ,                                        
 --ee.cod_rota,                                                           
 CASE                                         
  WHEN pe.id_pedido_ender IS NOT NULL                                        
   THEN pe.cod_rota                                        
  ELSE ee.cod_rota                                        
  END                                        
 ,                                        
 --ee.bairro,                                                           
 CASE     
  WHEN pe.id_pedido_ender IS NOT NULL                                        
   THEN pe.bairro                                        
  ELSE ee.bairro                                        
  END                                        
 ,                                        
 --ee.cep,                                                     
 CASE                                         
  WHEN pe.id_pedido_ender IS NOT NULL                                        
   THEN pe.cep                                        
  ELSE ee.cep                                        
  END                                        
 ,                                        
 --cep.cidade,                                                           
 CASE                                         
  WHEN pe.id_pedido_ender IS NOT NULL                                        
   THEN cep2.cidade                                        
  ELSE cep.cidade                                        
  END                                        
 ,                                 
 --cep.sigla_estado,                                                           
 CASE               WHEN pe.id_pedido_ender IS NOT NULL                                        
   THEN cep2.sigla_estado                                        
  ELSE cep.sigla_estado            
  END                              
 ,pv.volume                                        
 ,pv.tipo_caixa                                        
 ,prod.cod_produto                                        
 ,prod.descricao                                        
 ,lp.descricao                                        
 ,l.id_lote                                        
 ,l.lote                                        
 ,l.validade                                        
 ,ef.endereco_completo                                        
 ,ped.termino_digitacao                                        
 ,OL.cod_distribuicao                                        
 ,OL.cod_operacao_logistica                                        
 ,param.orderm_imp_cf                                        
 ,                                        
 --r.descricao,                                           
 CASE                                         
  WHEN pe.id_pedido_ender IS NOT NULL                                        
   THEN r2.descricao                                        
  ELSE r.descricao                                        
  END                                        
 ,er.cod_entidade_rel                                        
 ,                                        
 --ee.caminho,                                                          
 CASE                                         
  WHEN pe.id_pedido_ender IS NOT NULL                                
   THEN pe.caminho                                        
  ELSE ee.caminho                   
  END                                        
 ,ap.cod_tipo_atributo                                        
 ,pv.cod_pedido_rel                                        
,DATEADD(day, dea.dias_entrega, ped.data_saida_transp)                                        
 ,ped.cod_operacao_logistica                                        
 ,ol.abreviacao                                        
 ,edoc.numero                      
 ,ender.endereco_completo_3D          
 ,cxf.cod_barra      
 ,t1.numero_titulo      
--ORDER BY prod.descricao, l.lote, sum(piv.quantidade)                                                   
ORDER BY   
OL.cod_distribuicao                                        
 ,OL.cod_operacao_logistica                                        
,ISNULL(pv.cod_pedido_rel, '')                                        
 ,                                        
 --CASE  when param.orderm_imp_cf in (2,3) then dbo.GetEnderecoDivDescr(MAX(Ender.id_endereco)) else EE.cod_rota end ,                                                           
 CASE                                         
  WHEN pe.id_pedido_ender IS NOT NULL                                        
   THEN CASE                                         
     WHEN param.orderm_imp_cf IN (         
       2                                        
       ,3                                        
       )                                        
      THEN dbo.GetEnderecoDivDescr(MAX(Ender.id_endereco))                                        
     ELSE pe.cod_rota                                        
     END                                        
  ELSE CASE                                         
    WHEN param.orderm_imp_cf IN (                                        
      2                                    
      ,3                                        
      )                                        
     THEN dbo.GetEnderecoDivDescr(MAX(Ender.id_endereco))                                        
    ELSE EE.cod_rota                                        
    END                                        
  END                                         
 ,pv.volume    desc  
                                      
 ,                                        
 --CASE  when param.orderm_imp_cf = 3 then MAX(Ender.endereco_completo) else EE.cod_rota end ,                                                           
 CASE                                         
  WHEN pe.id_pedido_ender IS NOT NULL                                        
   THEN CASE                                         
     WHEN param.orderm_imp_cf = 3                                        
      THEN MAX(Ender.endereco_completo)                                        
     ELSE pe.cod_rota                                    
     END                                       
  ELSE CASE                                         
    WHEN param.orderm_imp_cf = 3                                        
     THEN MAX(Ender.endereco_completo)                                        
    ELSE EE.cod_rota                                        
    END                                        
  END                                        
 ,                                        
 --EE.cod_rota ,                                                    
 CASE                                         
  WHEN pe.id_pedido_ender IS NOT NULL                                        
   THEN pe.cod_rota                                        
  ELSE ee.cod_rota                                        
  END                                        
 ,er.cod_entidade_rel                                        
 ,id_picking                                        
 ,CASE                                         
  WHEN param.orderm_imp_cf = 2                                        
   THEN MAX(Ender.endereco_completo)                                        
  ELSE right('00000' + CONVERT(VARCHAR, pv.volume), 5)                                        
  END               
                                    
                         
                                    
                                         
                                        
SELECT id_pedido                                        
 ,cod_pedido                                        
 ,id_picking                                        
 ,cod_picking                                        
 ,cod_pedido_legado                                        
 ,volumes                                        
 ,id_entidade                                        
 ,cod_entidade                                        
 ,fantasia                                        
 ,razao_social                                 --dbo.GetEnderecoDivDescr(MAX(Ender.id_endereco)) as setor                                      
 ,setor                                        
 ,endereco_entidade                                        
 ,rota                                        
 ,caminho                                        
 ,bairro                                        
 ,cep                               
 ,cidade                                        
 ,estado                                        
 ,emissao                                        
 ,volume                                        
 ,tipo_caixa                                        
 ,esteira                                        
 ,id_produto                                        
 ,codigo_produto                                       ,descricao                                        
 ,endereco                                        
 ,id_lote                                        
 ,lote                                        
 ,validade                                        
 ,quantidade                                        
 ,cod_barra_PN                                        
 ,fantasia_fornecedor                                        
 ,endereco1   
 ,lpn  
 ,data_pedido                                        
 ,cod_entidade_rel                                        
 ,convert(VARCHAR, GETDATE(), 3) data_impressao                      
 ,convert(VARCHAR, GETDATE(), 108) hora_impressao                      
 ,right('000000' + convert(VARCHAR, contador), 6) contador                                        
 ,cod_entidade_rel                                        
 ,carimbagem                                        
 ,rota_descricao                                        
 ,CASE                          
  WHEN rota_descricao LIKE '%.%'                                        
   THEN SUBSTRING(rota_descricao, CHARINDEX('.', rota_descricao) + 1, LEN(rota_descricao))                                        
  ELSE '__'                                        
  END AS sub_rota                                  
 ,cod_pedido_rel                    
 ,cid_bairro                                        
 -- data_prevista_entrega,                                             
 --  sigla ,cod_externo ,                                         
  operacao_logistica_abreviada                                        
 ,cod_operacao_logistica                                        
 ,cod_relacionado_operacao_logistica                                        
 ,razao_social_operacao_logistica                                        
 ,fantasia_operacao_logistica                                        
 ,cnpj_cliente                                    
 ,obs_liberacao                                  
 ,cod_onda                                
 ,reimpressao                          
 ,transportadora                          
 ,sequencia                      
 ,linha             
 ,cod_barra      
 ,numero_titulo      
FROM #t                                        
ORDER BY   
cod_pedido  
,id_pedido  
, contador DESC                                        
                                        
DROP TABLE #pedidos                                        
DROP TABLE #dias_entrega_ajustados                                        
DROP TABLE #pedido_endereco                                        
DROP TABLE #pedido_sigla                                    
DROP TABLE #t   