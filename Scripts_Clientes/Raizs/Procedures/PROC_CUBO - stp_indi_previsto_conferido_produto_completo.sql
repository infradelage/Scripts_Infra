  
-- GRANT EXECUTE ON stp_indi_previsto_conferido_produto_completo TO PUBLIC        
        
CREATE PROCEDURE stp_indi_previsto_conferido_produto_completo               
@cod_operacao_logistica int = null,                 
@data_inicial smalldatetime = null,                
@data_final smalldatetime= null,                
@uf char(2) = null,                
@id_origem_venda int = null,                
@id_supervisor int = null,                
@id_vendedor int = null,                
@id_fornecedor int = null,                
@id_produto int = null,                
@cod_condicao varchar(50) = null,                
@id_cliente int = null,                
@id_grupo int =null,                
@id_subgrupo int = null,                
@id_atributo int = null,                
@id_opcao int = null                
as    
    
    
--declare    
--@data_inicial date = '2017-04-06',    
--@data_final date = '2017-04-06'    
    
SELECT CONVERT(VARCHAR (10), i.data_geracao, 3) as data_inventario,  
       i.cod_inventario, 
	   d.descricao as tipo,
       i.descricao as nome_inventario,    
       iic.cod_produto,    
       MAX(ic.cod_conf) as cod_conf    
INTO #p    
FROM inventario i (nolock)    
inner join inventario_conf ic (nolock) on i.cod_inventario = ic.cod_inventario    
inner join inventario_item_conf iic (nolock) on ic.cod_conf = iic.cod_conf    
inner join endereco e (nolock) on e.id_endereco = iic.id_endereco   
inner join def_tipo_inventario d on d.cod_tipo = i.cod_tipo --alanfreire 28/07/2020 
WHERE I.data_geracao >= @data_inicial             
  AND I.data_geracao < dateadd(d,1, @data_final)    
  --AND i.cod_tipo = 1    
  AND i.cod_situacao = 4    
  --and i.cod_inventario = 82414 and iic.cod_produto = 38878    
GROUP BY i.data_geracao,  
         i.cod_inventario,
		 d.descricao,
         i.descricao,    
         iic.cod_produto    
             
    
    
    
    
SELECT p.data_inventario,  
       p.cod_inventario as codigo_inventario,    
       p.nome_inventario,
	   p.tipo,
	   sg.descricao as subgrupo,
       pr.cod_produto * 10 + pr.digito as codigo_produto,    
       pr.descricao,    
       e.endereco_completo as endereco,    
       ISNULL(SUM(iic.estoque),'') as previsto,    
       ISNULL(SUM (iic.conferido),'') as conferido,    
       ISNULL ((SUM(iic.estoque) -  SUM (iic.conferido)),'') as diferenca    
--select     
--ISNULL(SUM(iic.estoque),'') as previsto,    
--ISNULL(SUM (iic.conferido),'') as conferido,    
--ISNULL ((SUM(iic.estoque) -  SUM (iic.conferido)),'') as diferenca    
FROM #p p (nolock)    
inner join inventario_item_conf iic (nolock) on p.cod_conf = iic.cod_conf and iic.cod_produto = p.cod_produto    
inner join produto pr (nolock) on pr.cod_produto = p.cod_produto    
inner join endereco e (nolock) on e.id_endereco = iic.id_endereco 
left join SubGrupo sg (nolock) on sg.cod_subgrupo = pr.cod_subgrupo
GROUP BY p.data_inventario,  
         p.cod_inventario, 
         p.nome_inventario,
		 p.tipo,
		 sg.descricao,
         p.cod_produto,    
         e.endereco_completo,    
         pr.cod_produto,    
         pr.digito,    
         pr.descricao  
           
-- drop table #p  
