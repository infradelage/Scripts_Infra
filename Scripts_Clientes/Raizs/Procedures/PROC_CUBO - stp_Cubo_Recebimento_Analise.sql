CREATE OR ALTER PROCEDURE [dbo].[stp_Cubo_Recebimento_Analise]          
@cod_operacao_logistica INT,           
@data_inicial SMALLDATETIME,          
@data_final SMALLDATETIME,          
@UF CHAR(2) = NULL,          
@id_origem_venda INT = NULL,          
@id_supervisor INT = NULL,          
@id_vendedor INT = NULL,          
@id_fornecedor INT = NULL,          
@id_produto INT = NULL,          
@cod_condicao VARCHAR(50) = NULL,          
@id_cliente INT = NULL,          
@id_grupo INT = NULL,          
@id_subgrupo INT = NULL,          
@id_atributo INT = NULL,          
@id_opcao INT = NULL          
AS          
          
select oper.fantasia Operação,        
       YEAR(ped.termino_digitacao) Ano,        
       MONTH(ped.termino_digitacao) Mês,        
       DAY(ped.termino_digitacao) Dia,        
       ped.cod_pedido * 10 + dbo.CalcDigitoMod11(ped.cod_pedido) Codigo_Pedido,        
       p.cod_produto * 10 + p.digito Codigo_Produto,         
       dbo.GetEnderecoDivDescr(pe.id_endereco) Setor,        
       p.descricao Produto,        
       pi.quantidade Quantidade,        
       pi.separado Conferido,        
       isnull(DATEDIFF(mi, ped.termino_digitacao, i.data_geracao), 0) Iniciar_Conf,        
       isnull(DATEDIFF(mi, i.data_geracao, isnull(ped.encerramento_PN, ped.encerramento_PN)), 0) Concluir_Conf,        
       isnull(DATEDIFF(mi, isnull(ic.data_fim, ped.encerramento_PN), dbo.GetPrimeiraMovimentacaoDoca(pi.cod_produto, ic.data_fim)), 0) Parado_Doca,        
       isnull(DATEDIFF(mi, ped.termino_digitacao, ped.data_exportacao), 0) Retorno_PS        
  from pedido ped (nolock) inner join        
       pedido_item pi (nolock) on pi.cod_pedido = ped.cod_pedido inner join        
       inventario_pedido ip (nolock) on ip.cod_pedido = ped.cod_pedido inner join        
       inventario i (nolock) on i.cod_inventario = ip.cod_inventario inner join        
       inventario_conf ic (nolock) on ic.cod_inventario = i.cod_inventario INNER join        
       vw_inventario_item_sequencia iis (nolock) on iis.cod_inventario = ip.cod_inventario and        
                                           iis.sequencia = ic.sequencia and        
                                           iis.cod_produto = pi.cod_produto inner join    
       produto p (nolock) on p.cod_produto = pi.cod_produto left outer join                
       produto_endereco pe (nolock) on pe.cod_produto = p.cod_produto inner join        
       entidade oper (nolock) on oper.cod_entidade = ped.cod_operacao_logistica        
 where ped.cod_operacao_logistica = isnull(@cod_operacao_logistica, ped.cod_operacao_logistica)        
   --and ped.termino_digitacao >= @data_inicial        
   --and ped.termino_digitacao < dateadd(dd, 1, @data_final)      
   --and ped.cod_situacao in (4)        
   and ped.cod_origem_ped in (1, 2)        
   and (i.cod_situacao = 4 or (i.cod_situacao = 3))-- and i.quem_cancelou is not null)) 

