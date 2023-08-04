--  grant execute on stp_rs_relacao_enderecos_inventarios to public    
CREATE PROCEDURE stp_rs_relacao_enderecos_inventarios       
 @filial INT = NULL,      
 @data_inicial DATETIME = NULL,      
 @data_final DATETIME = NULL,      
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
DECLARE @id_tipo_pulmao INT,      
 @id_tipo_flowrack INT      
      
SELECT @id_tipo_pulmao = id_tipo_pulmao,      
 @id_tipo_flowrack = id_tipo_flowrack      
FROM param_def_tipo_endereco      
      
CREATE TABLE #inventario_endereco (id_endereco INT, cod_inventario int, cod_situacao int)      
      
INSERT INTO #inventario_endereco      
SELECT ie.id_endereco, i.cod_inventario, i.cod_situacao      
FROM inventario i(NOLOCK)      
INNER JOIN inventario_endereco ie(NOLOCK) ON i.cod_inventario = ie.cod_inventario      
WHERE i.data_geracao >= ISNULL(@data_inicial, GETDATE()-1)      
 AND i.data_geracao < DATEADD(DAY, 1, ISNULL(@data_final, GETDATE()))      
 AND i.cod_tipo = 3      
  
--select * from #inventario_endereco  
      
SELECT e.id_endereco,      
 e.endereco_completo,      
 CASE       
  WHEN de.id_tipo = @id_tipo_pulmao      
   THEN 'PULM�O'      
  ELSE 'FLOWRACK'      
  END AS tipo_endereco,      
 CASE       
  WHEN EXISTS (      
    SELECT 1      
    FROM #inventario_endereco      
    WHERE id_endereco = e.id_endereco      
    )      
   THEN 'SIM'      
  ELSE 'N�O'      
  END AS possui_inventario,   dse.cod_situacao_endereco AS Cod_situacao ,dse.descricao AS Descricao_Situacao,   
 ISNULL(def_setor.descricao, 'EM PICKING') AS setor2,      
 ISNULL(qtd_caixa, 0) AS qtd_caixa,   
  
  
 (      
  SELECT endereco_completo      
  FROM endereco e2      
  WHERE e2.id_endereco = (      
    SELECT [dbo].[GetEnderecoPaiNivel](e.id_endereco, 2)      
    )      
  ) AS setor,  
dst.descricao as situacao_inventario,  
convert(varchar,ie.cod_inventario) as inventario      
FROM endereco e(NOLOCK)      
INNER JOIN def_endereco de(NOLOCK) ON e.id_def = de.id_def      
 AND e.nivel = de.nivel  
left join #inventario_endereco ie on e.id_endereco = ie.id_endereco  
left join def_situacao_inventario dst on ie.cod_situacao = dst.cod_situacao      
INNER JOIN def_lote_classificacao dlc(NOLOCK) ON e.id_lote_classificacao = dlc.id_lote_classificacao      
LEFT JOIN def_endereco_setor def_setor(NOLOCK) ON def_setor.id_def_endereco_setor = e.id_def_endereco_setor    
inner join def_situacao_endereco dse (NOLOCK) ON  e.cod_situacao_endereco =dse.cod_situacao_endereco  
WHERE dlc.le_estoque_segregado = 0      
 AND (      
  (      
   de.id_tipo = @id_tipo_pulmao      
   AND e.nivel = (      
    SELECT MAX(nivel)      
    FROM def_endereco defe      
    WHERE defe.id_tipo = @id_tipo_pulmao      
    )      
   )      
  OR (      
   de.id_tipo = @id_tipo_flowrack      
   AND e.nivel = (      
    SELECT MAX(nivel)      
    FROM def_endereco defe      
    WHERE defe.id_tipo = @id_tipo_flowrack      
    )      
   )      
  )      
ORDER BY e.id_def,      
 e.endereco_completo      
      
DROP TABLE #inventario_endereco   
  
  