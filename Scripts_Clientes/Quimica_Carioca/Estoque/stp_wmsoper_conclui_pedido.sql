-- disbbyweb@2023-05-12 10:49:37: <comentário>    
-- disbbyweb@2016-10-25 15:43:03: <adicionado para concluir pedido de exportação antecipada>              
CREATE PROCEDURE [dbo].[stp_wmsoper_conclui_pedido]              
@cod_pedido  INT = NULL,              
@cod_pedido_polo varchar(20) = NULL,              
@cod_operacao_logistica_polo varchar(20) = NULL,    
@origem_ped VARCHAR(20) = NULL ,     
@operationId INT = 1 ,     
@emMassa BIT = 1 -- Campo informado somente na ultima versão do WebService      
AS              
  
DECLARE @cod_pendencia INT, @cod_operacao_logistica INT, @cod_situacao INT, @operacao INT, @cod_status_exportacao INT, @cod_exportado INT, @cod_reexportado INT    
  , @cod_aguardando_export INT, @cod_corte INT, @pendencia VARCHAR(255), @cod_pedido_com_digito VARCHAR(20), @cod_pedido_sem_digito VARCHAR(20)     
   , @ok BIT,  @cod_origem_ped INT = NULL   
  
IF @origem_ped IS NOT NULL                                
 SELECT @cod_origem_ped = cod_origem_ped                                
   FROM dbo.def_origem_ped (NOLOCK)                                
 WHERE descricao = @origem_ped                                
                                 
IF @cod_origem_ped IS NULL                                
 SELECT @cod_origem_ped = cod_origem_ped                                
   FROM dbo.def_origem_ped (NOLOCK)                                
 WHERE principal = 1      
   
IF @cod_operacao_logistica_polo IS NOT NULL              
 BEGIN              
  SET @cod_operacao_logistica = NULL              
                  
        SELECT @cod_operacao_logistica = cod_entidade              
    FROM dbo.entidade_relacionada (NOLOCK)            
  WHERE cod_entidade_rel = @cod_operacao_logistica_polo              
    AND cod_tipo IN (9,14)              
               
  IF @cod_operacao_logistica IS NULL              
   BEGIN              
    SELECT @cod_operacao_logistica = cod_entidade              
      FROM dbo.entidade_doc (NOLOCK)    
    WHERE numero = @cod_operacao_logistica_polo              
   END                         
    END              
             
               
IF @cod_pedido_polo IS NOT NULL               
 BEGIN              
  IF (SELECT COUNT(cod_pedido)     
     FROM dbo.pedido (NOLOCK)     
   WHERE cod_pedido_polo = @cod_pedido_polo     
    AND cod_operacao_logistica = @cod_operacao_logistica     
    AND data_Exportacao IS NULL) = 1              
   BEGIN              
    SELECT @cod_pedido = cod_pedido     
      FROM dbo.pedido (NOLOCK)     
    WHERE cod_pedido_polo = @cod_pedido_polo     
     AND cod_operacao_logistica = @cod_operacao_logistica      
     AND data_Exportacao IS NULL            
        
    SET @cod_pedido_sem_digito = @cod_pedido              
   END              
 END              
                  
IF @cod_pedido_sem_digito IS NULL              
 BEGIN              
  SELECT @cod_pedido_com_digito = CONVERT(VARCHAR(20),@cod_pedido)              
    , @cod_pedido_sem_digito =LEFT(@cod_pedido_com_digito, LEN(@cod_pedido_com_digito)-1)              
 END              
               
              
SELECT @cod_situacao = cod_situacao    
  , @operacao = operacao    
  , @cod_status_exportacao = cod_status_exportacao    
  FROM dbo.pedido (NOLOCK)    
WHERE cod_pedido = @cod_pedido_sem_digito              
             
               
UPDATE dbo.vw_pedido_item_volume_lote              
   SET qtd_exportada = ISNULL(qtd_exportada,0) + ISNULL(qtd_exportar,0)    
  , qtd_exportar = NULL              
 WHERE cod_pedido = @cod_pedido_sem_digito              
   AND qtd_exportar IS NOT NULL              
               
IF @cod_situacao IN (SELECT cod_situacao FROM def_situacao WHERE exporta=-1)     
  AND NOT EXISTS (SELECT 1               
        FROM dbo.vw_pedido_item_volume_lote (NOLOCK)           
      WHERE cod_pedido = @cod_pedido_sem_digito              
        AND quantidade > ISNULL(qtd_exportada,0)          
        AND NOT EXISTS (SELECT 1     
        FROM dbo.pedido_exportacao_log pel (NOLOCK)              
      WHERE pel.cod_pedido = @cod_pedido_sem_digito          
      ))      --    and data_exportacao is null       
 BEGIN      
               
  SELECT @cod_exportado = cod_exportado     
    , @cod_reexportado = cod_reexportado    
    , @cod_aguardando_export = cod_aguardando_export    
    , @cod_corte = cod_corte    
    FROM dbo.param_status_exportacao (NOLOCK)                  
     
  UPDATE dbo.pedido              
           SET cod_situacao = CASE WHEN cod_situacao IN(5, 7) THEN cod_situacao ELSE 4 END     
    , data_exportacao = GETDATE()    
    , cod_status_exportacao = CASE @cod_status_exportacao    
           WHEN @cod_aguardando_export THEN    
            @cod_exportado    
           WHEN @cod_exportado THEN    
            @cod_reexportado    
           WHEN @cod_corte THEN    
            @cod_reexportado    
           ELSE    
            cod_status_exportacao    
           END    
   WHERE cod_pedido = @cod_pedido_sem_digito              
           AND cod_situacao IN(3, 5, 7)                
               
  IF @@ROWCOUNT = 0      
   BEGIN    
      SELECT @cod_pendencia = 0      
      , @pendencia = 'CONCLUSÃO DO PEDIDO REALIZADA COM SUCESSO'    
      , @ok = 0    
   END    
  ELSE      
   BEGIN    
      SELECT @cod_pendencia = 0      
      , @pendencia = 'CONCLUSÃO DO PEDIDO REALIZADA COM SUCESSO'    
      , @ok = 1    
   END    
 END                       
     
ELSE IF @cod_situacao IS NULL              
 BEGIN              
  SELECT @cod_pendencia = 200001      
  , @pendencia = 'NÂO FOI POSSIVEL REALIZAR A CONCLUSÃO DO PEDIDO: PEDIDO NÃO ENCONTRADO.'      
  , @ok = 0                
 END              
ELSE IF @operacao NOT IN (3,4,5)              
 BEGIN              
    SELECT @cod_pendencia = 200002      
  , @pendencia = 'NÂO FOI POSSIVEL REALIZAR A CONCLUSÃO DO PEDIDO: TENTATIVA DE CONCLUIR O PEDIDO COM SITUACAO ' + CONVERT(VARCHAR, @cod_situacao)                
  , @ok = 0            
 END              
              
               
IF @emMassa = 0            
 BEGIN    
  SELECT @ok    
 END    
ELSE    
 BEGIN    
  SELECT ISNULL(@cod_pedido, @cod_pedido_com_digito) AS cod_pedido      
     , @cod_pedido_polo AS cod_pedido_polo      
     , @cod_operacao_logistica_polo AS cod_operacao_logistica_polo      
     , @cod_pendencia AS cod_pendencia      
     , @pendencia AS pendencia    
 END 