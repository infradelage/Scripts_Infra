-- alanfreire 15/07/2020      
CREATE PROCEDURE [dbo].[Stp_Cubo_Reserva]                                                 
@cod_operacao_logistica INT = NULL,                                    
@data_inicial SMALLDATETIME = NULL,                                    
@data_final SMALLDATETIME = NULL,                                    
@UF CHAR(2) = NULL,                                    
@id_origem_venda INT = NULL,                                    
@id_supervisor INT = NULL,                                    
@id_vendedor INT = NULL,                                    
@id_fornecedor INT = NULL,                                    
@id_produto INT = NULL,                                    
@cod_condicao varchar(50) = NULL,                                    
@id_cliente INT = NULL,                                    
@id_grupo INT =NULL,                                    
@id_subgrupo INT = NULL,                                    
@id_atributo INT = NULL,                                    
@id_opcao INT = NULL                                    
AS         
    
SELECT FIX.endereco_completo AS ENDERECO_RESERVA, FIXO.ENDERECO_FLOWRACK,       
    FIXO.COD_PROD, FIXO.PRODUTO, clas.estoque AS PULMAO, FIXO.SALDO_RESERVA  
FROM endereco FIX   
LEFT JOIN   
            (SELECT eo.endereco_completo AS ENDERECO_RESERVA, ed.endereco_completo AS ENDERECO_FLOWRACK,       
     pro.cod_produto, CONVERT(VARCHAR,pro.cod_produto * 10 + pro.digito) as COD_PROD,  
     PRO.descricao AS PRODUTO, sum(EST.estoque) AS SALDO_RESERVA    
     FROM param_endereco_distancia ped INNER JOIN        
     endereco eo (NOLOCK) ON eo.id_endereco = ped.id_endereco_origem INNER JOIN        
     endereco ed (NOLOCK) ON ed.id_endereco = ped.id_endereco_destino LEFT JOIN       
     produto_endereco PE (NOLOCK) ON PE.id_endereco = ED.id_endereco LEFT JOIN      
     PRODUTO PRO (NOLOCK) ON PRO.cod_produto = PE.cod_produto LEFT JOIN       
     vw_lote_estoque est (NOLOCK) ON EST.cod_produto = PRO.cod_produto AND EO.id_endereco = EST.id_endereco   
     group by eo.endereco_completo, ed.endereco_completo,pro.cod_produto, pro.cod_produto * 10 + pro.digito, PRO.descricao) AS FIXO ON FIXO.ENDERECO_RESERVA = FIX.endereco_completo  
LEFT JOIN  
         (SELECT D.id_lote_classificacao, d.descricao, lel.cod_produto, sum(lel.estoque) as estoque    
    FROM vw_lote_estoque lel (NOLOCK)  INNER JOIN          
     endereco ender(NOLOCK) ON lel.id_endereco = ender.id_endereco INNER JOIN     
     def_lote_classificacao d ON d.id_lote_classificacao = ender.id_lote_classificacao   
    WHERE d.id_lote_classificacao in (1)   
    GROUP BY d.id_lote_classificacao, d.descricao,lel.cod_produto) clas on clas.cod_produto = fixo.cod_produto  
WHERE FIX.id_def = 1 AND FIX.NIVEL= 7 AND FIX.id_tipo_Armazenamento = 7   
  
