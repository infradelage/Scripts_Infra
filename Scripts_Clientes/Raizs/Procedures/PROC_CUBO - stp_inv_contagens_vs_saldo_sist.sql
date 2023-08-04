-- disbbyweb@2019-12-30 17:22:38: <comentário>    
CREATE PROCEDURE [stp_inv_contagens_vs_saldo_sist]      
      
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
@id_grupo int =NULL,                    
@id_subgrupo int = NULL,                    
@id_atributo int = NULL,                    
@id_opcao int = NULL                    
      
AS      
      
SELECT      
 p.cod_produto * 10 + p.digito AS Cod_Produto,    
 i.cod_inventario AS Cod_Inv,      
 p.descricao AS Desc_Produto,      
 e.endereco_completo AS Endereco,     
 CONVERT(VARCHAR(10), iic.data_cadastro, 103) AS Data_Saldo_Sistemico,     
 iic.estoque AS Saldo_Sistemico,     
 CONVERT(VARCHAR(10), i.data_finalizacao, 103) AS Data_Inventario,     
 ent.fantasia AS Usu_Inv,    
 dti.descricao AS Tp_Inv,     
 iic.conferido AS Saldo_Inventario     
FROM       
 inventario i INNER JOIN      
 inventario_conf ic ON i.cod_inventario = ic.cod_inventario INNER JOIN       
 inventario_item_conf iic ON ic.cod_conf = iic.cod_conf INNER JOIN      
 produto p ON iic.cod_produto = p.cod_produto INNER JOIN      
 endereco e ON iic.id_endereco = e.id_endereco INNER JOIN      
 entidade ent ON iic.cod_entidade = ent.cod_entidade INNER JOIN      
 def_tipo_inventario dti ON i.cod_tipo = dti.cod_tipo      
WHERE       
 i.data_geracao >= @data_inicial AND       
 i.data_geracao < dateadd(day,1,@data_final) 