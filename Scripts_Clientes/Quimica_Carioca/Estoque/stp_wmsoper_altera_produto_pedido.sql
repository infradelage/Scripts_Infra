-- disbbyweb@2023-04-21 13:32:38: <comentário>      
-- david.borba@2023-04-03 15:21:20: <Altera produto do pedido de saida com o status liberado>         
CREATE PROCEDURE [stp_wmsoper_altera_produto_pedido]          
@cod_operacao_logistica_polo VARCHAR(20)      
, @cod_pedido_rel VARCHAR(20)      
, @origem_ped VARCHAR(20) = NULL      
, @operationId INT = 1      
, @cod_produto_origem VARCHAR(20)      
, @cod_produto_destino VARCHAR(20)        
      
AS          
        
DECLARE @cod_pedido_aux INT = NULL          
  , @cod_produto_origem_aux INT = NULL                        
  , @cod_produto_destino_aux INT = NULL       
  , @cod_operacao_logistica INT = NULL      
  , @cod_origem_ped INT = NULL      
  , @cod_pendencia INT = NULL                        
  , @pendencia VARCHAR(100) = NULL  
  , @quantidade_aux INT = NULL  
  , @soma_item INT = NULL  
  
SET @quantidade_aux = 1  
SET @soma_item = 0  
  
IF @origem_ped IS NOT NULL                                
 SELECT @cod_origem_ped = cod_origem_ped                                
   FROM dbo.def_origem_ped (NOLOCK)                                
 WHERE descricao = @origem_ped                                
                                 
IF @cod_origem_ped IS NULL                                
 SELECT @cod_origem_ped = cod_origem_ped                                
   FROM dbo.def_origem_ped (NOLOCK)                                
 WHERE principal = 1       
        
SELECT @cod_operacao_logistica = cod_entidade                                
  FROM dbo.entidade_relacionada (NOLOCK)                                
WHERE cod_entidade_rel = @cod_operacao_logistica_polo                                
  AND cod_tipo IN (9, 14)                                
                                 
IF @cod_operacao_logistica IS NULL                                
 SELECT @cod_operacao_logistica = e.cod_entidade                                
   FROM dbo.entidade_doc ed (NOLOCK)                                
   INNER JOIN dbo.entidade e(NOLOCK) ON e.cod_entidade = ed.cod_entidade                                
 WHERE ed.numero = @cod_operacao_logistica_polo                                
   AND e.cod_tipo IN (9, 14)                                
                            
                                 
IF ISNULL(@cod_pendencia, 0) < 200000 AND NOT EXISTS (SELECT 1      
                FROM dbo.operacao_logistica (NOLOCK)                                
              WHERE cod_operacao_logistica = @cod_operacao_logistica)                                
 BEGIN                                
  SELECT @cod_pendencia = 201003      
    , @pendencia = 'Operação logística inválida.'                                
 END        
ELSE       
 BEGIN      
  SELECT @cod_pedido_aux = cod_pedido                        
    FROM dbo.pedido (NOLOCK)                       
  WHERE cod_pedido_polo = @cod_pedido_rel       
    AND cod_operacao_logistica = @cod_operacao_logistica      
    AND cod_origem_ped = @cod_origem_ped      
    AND operacao = @operationId       
    AND cod_situacao IN (1)       
 END      
      
IF @cod_pedido_aux IS NULL      
 BEGIN                        
  SELECT @cod_pendencia = 200001                        
    , @pendencia = 'Pedido invalido. Só é permitido esse procedimento em pedidos de saida cuja situação esteja em aberto, no WMS!'                        
 END      
ELSE      
 BEGIN      
  SELECT @cod_produto_origem_aux = cod_produto                        
    FROM dbo.produto_relacionado (NOLOCK)                       
  WHERE cod_produto_rel = @cod_produto_origem      
 END      
      
IF @cod_produto_origem_aux IS NULL       
 BEGIN                        
  SELECT @cod_pendencia = 200002      
    , @pendencia = 'Produto Origem invalido!'                        
 END       
ELSE      
 BEGIN      
  SELECT @cod_produto_destino_aux = cod_produto                        
    FROM dbo.produto_relacionado (NOLOCK)                        
  WHERE cod_produto_rel = @cod_produto_destino      
 END      
      
IF @cod_produto_destino_aux IS NULL      
 BEGIN                        
  SELECT @cod_pendencia = 200002                        
    , @pendencia = 'Produto Destino invalido!'                        
 END       
ELSE      
 IF EXISTS(SELECT 1       
      FROM dbo.pedido_item pi (NOLOCK)      
    WHERE cod_pedido = @cod_pedido_aux       
     AND cod_produto = @cod_produto_destino_aux)      
  BEGIN                        
   --SELECT @cod_pendencia = 200003  , @pendencia = 'Produto Destino ja consta no pedido!'  
   SET @soma_item = 1  
  END        
      
IF @cod_pendencia < 200000 AND EXISTS(SELECT 1       
            FROM dbo.pedido_item pi (NOLOCK)      
          WHERE cod_pedido = @cod_pedido_aux       
           AND cod_produto = @cod_produto_origem_aux)      
        BEGIN                        
         SELECT @cod_pendencia = 200003                        
           , @pendencia = 'Produto Origem Não consta no pedido!'                        
        END       
        
IF @soma_item = 0  
BEGIN  
IF ISNULL(@cod_pendencia, 0) < 200000   
 BEGIN        
  SELECT cod_pedido      
    , @cod_produto_destino_aux AS cod_produto      
    , quantidade      
    , separado      
    , cod_motivo      
    , numero_item      
    , quem_cortou      
    , obs      
    , ordem_conf      
    , validade_minima      
    , cod_produto_KIT      
    , estimativa_corte_qtd      
    , estimativa_corte_data      
    , corta_kit_total      
    , erro_alocacao      
    , medida_padrao      
    , quantidade_variavel      
    , separado_variavel      
    , id_pedido_item_multivolume      
    , origem      
    , destino      
    , tipo_armazenamento      
    , tirar_cod_barras      
    , obs_item_inventario      
    , @cod_pendencia AS cod_pendencia      
    , @pendencia AS pendencia       
          
    INTO #Pi        
      
    FROM dbo.pedido_item (NOLOCK)      
  WHERE cod_pedido = @cod_pedido_aux        
    AND cod_produto = @cod_produto_origem_aux        
        
  INSERT pedido_item (cod_pedido,cod_produto,quantidade,separado,cod_motivo,numero_item,quem_cortou,obs,ordem_conf,    
 validade_minima,cod_produto_KIT,estimativa_corte_qtd,estimativa_corte_data,corta_kit_total,erro_alocacao,medida_padrao,    
 quantidade_variavel,separado_variavel,id_pedido_item_multivolume,origem,destino,tipo_armazenamento,tirar_cod_barras,obs_item_inventario)         
  SELECT cod_pedido,cod_produto,quantidade,separado,cod_motivo,numero_item,quem_cortou,obs,ordem_conf,validade_minima,    
 cod_produto_KIT,estimativa_corte_qtd,estimativa_corte_data,corta_kit_total,erro_alocacao,medida_padrao,quantidade_variavel,    
 separado_variavel,id_pedido_item_multivolume,origem,destino,tipo_armazenamento,tirar_cod_barras,obs_item_inventario        
    FROM #Pi        
        
  DELETE pedido_item        
   WHERE cod_pedido = @cod_pedido_aux        
     AND cod_produto = @cod_produto_origem_aux        
        
  SELECT * FROM #Pi        
        
  DROP TABLE #Pi        
        
 END                        
ELSE      
 BEGIN                        
  SELECT @cod_pendencia AS cod_pendencia      
    , @pendencia AS pendencia                      
END  
  
END  
ELSE  
IF ISNULL(@cod_pendencia, 0) < 200000 --AND ISNULL(@quantidade_aux,0) > 0  
BEGIN  
 UPDATE pedido_item set   
 quantidade = @quantidade_aux + quantidade,   
 separado = @quantidade_aux + separado  
    WHERE cod_pedido = @cod_pedido_aux        
   AND cod_produto = @cod_produto_destino_aux  
  
  DELETE pedido_item        
   WHERE cod_pedido = @cod_pedido_aux        
     AND cod_produto = @cod_produto_origem_aux     
  
 SELECT *,  @cod_pendencia AS cod_pendencia, @pendencia AS pendencia     
 FROM pedido_item  
 WHERE cod_pedido = @cod_pedido_aux        
 AND cod_produto = @cod_produto_destino_aux  
END                        
ELSE      
 BEGIN                        
  SELECT @cod_pendencia AS cod_pendencia      
    , @pendencia AS pendencia                      
END  
  