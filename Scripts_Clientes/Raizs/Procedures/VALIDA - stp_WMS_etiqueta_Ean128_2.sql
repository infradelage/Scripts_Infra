exec stp_WMS_etiqueta_Ean128_2 @cod_produto=517,@id_lote=1455,
@cod_operacao_logistica=1,@emb_compra=1.0000,@lpn=N''


SELECT * FROM vw_pedido_item_volume where cod_pedido = 1628
cod_produto = 517
cod_pedido = 1716
ID_LOTE = 1455 AND cod_produto = 517 

SELECT cod_pedido*10 + dbo.calcDigitoMod11(cod_pedido) FROM PEDIDO where cod_pedido = 1823

select * from vw_lote_estoque where cod_produto = 5177

SELECT TOP 1     
 pile.id_lote_dest,
 P.cod_pedido,
 P.cod_pedido_polo,    
 P.digitacao,    
 P.obs_PN,    
 e.endereco_completo AS doca,       
    forn.fantasia fantasia_emitente     
       
FROM pedido P (NOLOCK)     
INNER JOIN pedido_item_lote_endereco PILE (NOLOCK) ON P.cod_pedido = PILE.cod_pedido    
INNER JOIN produto PROD (NOLOCK) ON PROD.cod_produto = PILE.cod_produto    
INNER JOIN def_unidade DU (NOLOCK) ON DU.cod_unidade = PROD.cod_unidade    
INNER JOIN endereco e (NOLOCK) ON e.id_endereco = pile.id_endereco_dest    
INNER JOIN entidade forn (NOLOCK) ON forn.cod_entidade = p.cod_entidade       
 WHERE P.operacao = 2        
   AND p.cod_origem_ped <> 3     
   AND P.cod_situacao IN (2, 3, 4)     
   AND PILE.id_lote_dest = 1455  
   AND P.cod_operacao_logistica = 1     
ORDER BY P.digitacao DESC, p.cod_pedido DESC   