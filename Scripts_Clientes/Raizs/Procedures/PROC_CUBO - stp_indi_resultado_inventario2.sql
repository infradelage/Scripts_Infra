-- GRANT EXECUTE ON stp_indi_resultado_inventario2 TO PUBLIC            
CREATE PROCEDURE stp_indi_resultado_inventario2                   
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
--@cod_operacao_logistica int = 1,                     
--@data_inicial smalldatetime = '05/25/2017',                    
--@data_final smalldatetime= '05/25/2017'               
                    
select CONVERT(VARCHAR(10), i.data_geracao, 3) as Data_Inventario,        
       ISNULL(CONVERT(VARCHAR(30),iic.cod_produto * 10 + p.digito), '') Codigo_Produto,     
    i.cod_inventario Codigo_Inventario,     
    i.descricao as Nome_Inventario,     
    ic.sequencia Contagem,    
    ISNULL((iic.estoque),0) as previsto,          
       ISNULL((iic.conferido),0) as conferido,          
       ISNULL (((iic.estoque) -  (iic.conferido)),0) as diferenca,       
       ISNULL(p.descricao,'') Produto, ISNULL(e.fantasia,'') Quem_Contou, ISNULL(e.razao_social,'') Quem_Contou_Nome,     
    ISNULL(dsi.descricao,'') Situacao_Inventario, ISNULL(dsii.descricao,'') Situacao_item, ISNULL(ender.endereco_completo,'') Endereco,                
       DATEDIFF(mi, ic.data_inicio, ic.data_fim)/CASE WHEN (select COUNT(*)                 
                                                    from inventario_conf ic2 inner join                
                                                         inventario_item_conf iic2 on ic2.cod_conf = iic2.cod_conf                
                                                   where ic2.cod_inventario = ic.cod_inventario and ic2.cod_conf = ic.cod_conf) = 0 THEN 1    
               ELSE (select COUNT(*)                 
                                                    from inventario_conf ic2 inner join                
                                                         inventario_item_conf iic2 on ic2.cod_conf = iic2.cod_conf                
                                                   where ic2.cod_inventario = ic.cod_inventario and ic2.cod_conf = ic.cod_conf) END Duracao,     
               ISNULL(tipo.descricao,'') Tipo_Inventario,               
                                                   case when dte.id_tipo = 1 then 'Pulmão' else ISNULL(dte.descricao,'') end Tipo_Endereco                
INTO #T                                                                  
FROM inventario i (nolock)left join                    
  inventario_item ii (nolock) on i.cod_inventario = ii.cod_inventario inner join                
  inventario_conf IC (nolock) on ic.cod_inventario = i.cod_inventario left join                    
  inventario_item_conf IIC (nolock) ON IIC.cod_conf = IC.cod_conf and                
                              iic.cod_produto = ii.cod_produto  left join                
  produto p (nolock) on iic.cod_produto = p.cod_produto inner join                
  entidade e (nolock) on e.cod_entidade = ic.cod_entidade left join                
  def_situacao_inventario dsi (nolock) on dsi.cod_situacao = i.cod_situacao left join                
  def_situacao_inventario_item dsii (nolock) on dsii.cod_situacao = ii.cod_situacao left join                
  def_tipo_inventario tipo (nolock) on tipo.cod_tipo = i.cod_tipo left outer join                
  endereco ender (nolock) on ender.id_endereco = iic.id_endereco left join                
            
  def_endereco d (nolock) on d.id_def = ender.id_def and                
                    d.nivel = ender.nivel left join                
  def_tipo_endereco dte (nolock) on dte.id_tipo = d.id_tipo   
WHERE I.data_geracao >= @data_inicial                 
  AND I.data_geracao < dateadd(d,1, @data_final)                
--AND (@cod_operacao_logistica is null OR I.cod_operacao_logistica = @cod_operacao_logistica)             
  --and p.cod_produto = 10060 and i.cod_inventario = 74577           
  --AND i.cod_tipo = 3     
  AND ISNULL(ender.endereco_completo,'') <> ''    
order by i.data_geracao, iic.cod_produto,i.cod_inventario, ic.sequencia                 
    
    
select distinct CONVERT(VARCHAR(10), i.data_geracao, 3) as Data_Inventario,        
       ISNULL(CONVERT(VARCHAR(30),ii.cod_produto * 10 + p.digito), '') Codigo_Produto,     
    i.cod_inventario Codigo_Inventario,     
    i.descricao as Nome_Inventario,     
    IC.sequencia as Contagem,    
    0 as previsto,          
      0 as conferido,          
       0 as diferenca,       
       ISNULL(p.descricao,'') Produto, ISNULL(e.fantasia,'') Quem_Contou, ISNULL(e.razao_social,'') Quem_Contou_Nome,     
    ISNULL(dsi.descricao,'') Situacao_Inventario, ISNULL(dsii.descricao,'') Situacao_item, ISNULL(ender.endereco_completo,'') Endereco,                
       DATEDIFF(mi, ic.data_inicio, ic.data_fim)/CASE WHEN (select COUNT(*)                 
                                                    from inventario_conf ic2 inner join                
                                                         inventario_item_conf iic2 on ic2.cod_conf = iic2.cod_conf                
                                                   where ic2.cod_inventario = ic.cod_inventario and ic2.cod_conf = ic.cod_conf) = 0 THEN 1    
               ELSE (select COUNT(*)                 
                                                    from inventario_conf ic2 inner join                
                                                         inventario_item_conf iic2 on ic2.cod_conf = iic2.cod_conf                
                                                   where ic2.cod_inventario = ic.cod_inventario and ic2.cod_conf = ic.cod_conf) END Duracao,     
               ISNULL(tipo.descricao,'') Tipo_Inventario,               
                                                   case when dte.id_tipo = 1 then 'Pulmão' else ISNULL(dte.descricao,'') end Tipo_Endereco,    
               ender.id_endereco    
                   
INTO #T2    
FROM inventario i (nolock)left join                    
  inventario_item ii (nolock) on i.cod_inventario = ii.cod_inventario inner join                
  inventario_conf IC (nolock) on ic.cod_inventario = i.cod_inventario left join                                
  produto p (nolock) on ii.cod_produto = p.cod_produto inner join                
  entidade e (nolock) on e.cod_entidade = ic.cod_entidade left join                
  def_situacao_inventario dsi (nolock) on dsi.cod_situacao = i.cod_situacao left join                
  def_situacao_inventario_item dsii (nolock) on dsii.cod_situacao = ii.cod_situacao left join                
  def_tipo_inventario tipo (nolock) on tipo.cod_tipo = i.cod_tipo left outer join    
  inventario_endereco ie (nolock) on i.cod_inventario = ie.cod_inventario left join    
  endereco ender (nolock) on ie.id_endereco = ender.id_endereco inner join   
  --endereco ender (nolock) on ender.id_endereco = iic.id_endereco left join                
   
  inventario_conf_endereco ice (nolock) on IC.cod_conf = ice.cod_conf  
                    and ender.id_endereco = ice.id_endereco left join  
  def_endereco d (nolock) on d.id_def = ender.id_def and                
                    d.nivel = ender.nivel left join                
  def_tipo_endereco dte (nolock) on dte.id_tipo = d.id_tipo   
   
WHERE  I.data_geracao >= @data_inicial                 
  AND I.data_geracao < dateadd(d,1, @data_final)  
AND NOT EXISTS (SELECT 1   
FROM inventario_item_conf IIC (nolock)     
  WHERE IIC.cod_conf = IC.cod_conf   
  and iic.cod_produto = ii.cod_produto  
  AND IIC.id_endereco = ender.id_endereco)       
  
  
--AND (@cod_operacao_logistica is null OR I.cod_operacao_logistica = @cod_operacao_logistica)         
  --and p.cod_produto = 10060 and i.cod_inventario = 74577           
  --AND i.cod_tipo = 3  
    
  
  
       
DELETE #T WHERE Tipo_Inventario = 'ENTRADA' and Codigo_Produto = ''    
DELETE #T2 WHERE Tipo_Inventario = 'ENTRADA' and Codigo_Produto = ''    
    
UPDATE t SET    
T.Endereco = ender2.endereco_completo,    
t.Tipo_Endereco = replace(dte.descricao,'Caixa Fechada','Pulmão')    
--select 1    
FROM #T2 t      
--inner join inventario_endereco ie (nolock) on t.Codigo_Inventario = ie.cod_inventario     
inner join endereco ender2 (nolock) on t.id_endereco = ender2.id_endereco     
inner join def_endereco d (nolock) on d.id_def = ender2.id_def and                
                    d.nivel = ender2.nivel     
inner join def_tipo_endereco dte on dte.id_tipo = d.id_tipo       
-- encontrei assim WHERE t.Endereco = ''    
WHERE t.Endereco != ''     
            
SELECT Data_inventario, Codigo_Produto, Codigo_Inventario, Nome_Inventario, Contagem, SUM(conferido) as Conferido,    
        SUM(previsto) as previsto,SUM(diferenca) as diferenca, Produto, Quem_Contou, Quem_Contou_Nome, Situacao_Inventario,            
       Situacao_item, Endereco, Duracao, Tipo_Inventario, Tipo_Endereco            
FROM #T            
GROUP BY Data_inventario, Codigo_Produto, Codigo_Inventario, Nome_Inventario,Contagem, Produto, Quem_Contou, Quem_Contou_Nome, Situacao_Inventario,            
       Situacao_item, Endereco, Duracao, Tipo_Inventario, Tipo_Endereco            
UNION    
SELECT Data_inventario, Codigo_Produto, Codigo_Inventario, Nome_Inventario, Contagem, SUM(conferido) as Conferido,    
        SUM(previsto) as previsto,SUM(diferenca) as diferenca, Produto, Quem_Contou, Quem_Contou_Nome, Situacao_Inventario,            
       Situacao_item, Endereco, Duracao, Tipo_Inventario, Tipo_Endereco            
FROM #T2            
GROUP BY Data_inventario, Codigo_Produto, Codigo_Inventario, Nome_Inventario,Contagem, Produto, Quem_Contou, Quem_Contou_Nome, Situacao_Inventario,            
       Situacao_item, Endereco, Duracao, Tipo_Inventario, Tipo_Endereco         
-- drop table #t     
order by 3 