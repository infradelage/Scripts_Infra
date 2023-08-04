
-- disbbyweb@2019-12-30 17:22:56: <comentário>
CREATE PROCEDURE [stp_inv_conferido]    
    
@cod_operacao_logistica int = 1,               
@data_inicial smalldatetime = NULL,                
@data_final smalldatetime = NULL,    
@uf char(2) = NULL,                  
@id_origem_venda int = NULL,                  
@id_supervisor int = NULL,                  
@id_vendedor int = NULL,                  
@id_fornecedor int = NULL,                  
@id_produto int = NULL,                  
@cod_condicao varchar(50) = NULL,                  
@id_cliente int = NULL,                  
@id_grupo int = NULL,                  
@id_subgrupo int = NULL,                  
@id_atributo int = NULL,                  
@id_opcao int = NULL                  
    
AS    
    
SELECT ISNULL(iic.cod_produto * 10 + dbo.CalcDigitoMod11(iic.cod_produto),0) AS Cod_Produto,   --ooik  
    ISNULL(p.descricao, '') AS Descricao_Produto,       --ok  
    ISNULL(ic.cod_conf, 0) AS Cod_Conferencia,  
    ISNULL(ic.cod_situacao, 0) AS Cod_Situacao_Conf,  --ok  
    ISNULL(dsi.descricao, 0) AS Descricao_Situacao_Conf,  --ok  
    ISNULL(i.cod_inventario, 0) AS Cod_Inventario,    
    ISNULL(e.endereco_completo, '') AS Endereco_Completo,  --ok  
    ISNULL(def_es.descricao, '') AS Setor,    
    ISNULL(iic.lote, '') as Lote,    
    ISNULL(ent.fantasia,'') AS Conferente,  --ook  
    ISNULL(iic.estoque, 0) AS Saldo_Inicial, --ook  
    ISNULL(iic.conferido, 0) AS Saldo_Contagem, --ook  
    CONVERT(VARCHAR(10), iic.data_cadastro, 103) AS Data_Inventario,  
    ISNULL((SELECT sequencia   
     FROM inventario_conf ic2   
    WHERE ic2.cod_conf = ic.cod_conf), 0) Quantidade_Contagem, --ok  
    CASE   
  WHEN iic.conferido IS NULL THEN 'Não' ELSE 'Sim' END Conferido  
  FROM inventario i(NOLOCK) INNER JOIN    
       inventario_conf ic(NOLOCK) ON i.cod_inventario = ic.cod_inventario INNER JOIN    
    def_situacao_inventario dsi (NOLOCK) on ic.cod_situacao = dsi.cod_situacao INNER JOIN  
       inventario_item_conf iic(NOLOCK) ON ic.cod_conf = iic.cod_conf INNER JOIN    
       endereco e(NOLOCK) ON iic.id_endereco = e.id_endereco INNER JOIN    
       produto p(NOLOCK) ON iic.cod_produto = p.cod_produto LEFT JOIN    
    entidade ent(NOLOCK) ON iic.cod_entidade = ent.cod_entidade LEFT JOIN  
       def_endereco_setor def_es(NOLOCK) ON e.id_def_endereco_setor = def_es.id_def_endereco_setor  
       WHERE i.data_geracao >= @data_inicial AND   
          i.data_geracao < dateadd(day,1,@data_final)  
      AND e.cod_situacao_endereco = 1  
 ORDER BY i.cod_inventario, ic.cod_conf
