DECLARE @cod_produto INT = 4733

SET NOCOUNT ON

print '> PRODUTO'
SELECT 
	p.cod_produto,
	p.digito,
	p.descricao,
	dsp.Descricao AS situacao,
	p.emb_compra,
	p.data_cadastro,
	p.ult_alteracao,
	p.altura,
	p.largura,
	p.comprimento,
	p.altura * p.largura * p.comprimento AS volume_total_uma_unidade,
	p.peso
FROM 
	produto p
	JOIN def_situacao_produto dsp ON dsp.cod_situacao = p.cod_situacao
	JOIN SubGrupo sg ON p.cod_subgrupo = sg.cod_subgrupo
WHERE cod_produto = @cod_produto
print ''; print ''; print '';



print '> ORDENS DO KANBAN EXISTENTES PARA O PRODUTO'
SELECT 	
	p.cod_pedido,
	p.digitacao,
	do.descricao AS operacao,
	piv.quantidade,

	end_origem.endereco_completo_3D AS endereco_origem,
	tipo_armazenamento_origem.descricao AS tipo_armazenamento_origem,

	end_destino.endereco_completo_3D AS endereco_destino,
	tipo_armazenamento_dest.descricao AS tipo_armazenamento_destino

FROM vw_pedido_item_volume piv
	JOIN pedido p ON p.cod_pedido = piv.cod_pedido
	JOIN def_operacao do ON p.operacao = do.operacao

	JOIN endereco end_origem ON end_origem.id_endereco = piv.id_endereco_origem
	JOIN def_tipo_Armazenamento_endereco tipo_armazenamento_origem ON tipo_armazenamento_origem.id_tipo_armazenamento_endereco = end_origem.id_tipo_Armazenamento

	JOIN endereco end_destino ON end_destino.id_endereco = piv.id_endereco_dest
	JOIN def_tipo_Armazenamento_endereco tipo_armazenamento_dest ON tipo_armazenamento_dest.id_tipo_armazenamento_endereco = end_destino.id_tipo_Armazenamento

WHERE 
	p.cod_origem_ped = 5
	AND piv.cod_produto = @cod_produto
	and p.cod_situacao < 3
ORDER BY digitacao DESC
print ''; print ''; print '';




print '> FLOWRACKS E ENDERECOS ASSOCIADOS AO PRODUTO'
SELECT e.endereco_completo_3D AS endereco,
	   pe.cod_operacao_logistica,
	   pe.quantidade AS quanto_cabe_por_caixa_bin,
	   dtve.quantidade_caixas AS quantidade_caixas_bin,
	   dtve.quantidade_caixas * pe.quantidade AS quantas_unidades_cabem_no_total,
	   dse.descricao AS situacao_endereco,
	   dtae.descricao AS tipo_armazenamento,
	   dtve.descricao AS tipo_volume,
	   dtve.quantidade_caixas AS quantidade_caixas
FROM produto_endereco pe 
	JOIN endereco e ON e.id_endereco = pe.id_endereco 
	JOIN def_situacao_endereco dse ON e.cod_situacao_endereco = dse.cod_situacao_endereco
	JOIN def_tipo_volume_endereco dtve ON e.id_tipo_volume = dtve.id_tipo_volume_endereco
	JOIN def_tipo_armazenamento_endereco dtae ON e.id_tipo_Armazenamento = dtae.id_tipo_armazenamento_endereco
WHERE cod_produto = @cod_produto
print ''; print ''; print '';



print '> FIXOS DOS FLOWRACKS DO PRODUTO'
SELECT 
	endereco_origem.endereco_completo_3D AS endereco_origem,
	tipo_armazenamento_origem.descricao AS tipo_armazenamento_origem,
	endereco_destino.endereco_completo_3D AS endereco_destino,
	tipo_armazenamento_destino.descricao AS tipo_armazenamento_destino,
	ped.caixas,
	ped.quantidade_cx_reabastecimento
FROM param_endereco_distancia ped 
	JOIN endereco endereco_origem on ped.id_endereco_origem = endereco_origem.id_endereco
	JOIN def_tipo_Armazenamento_endereco tipo_armazenamento_origem ON tipo_armazenamento_origem.id_tipo_armazenamento_endereco = endereco_origem.id_tipo_Armazenamento

	JOIN endereco endereco_destino on ped.id_endereco_destino = endereco_destino.id_endereco
	JOIN def_tipo_Armazenamento_endereco tipo_armazenamento_destino ON tipo_armazenamento_destino.id_tipo_armazenamento_endereco = endereco_destino.id_tipo_Armazenamento

WHERE ped.id_endereco_destino = (SELECT id_endereco FROM produto_endereco WHERE cod_produto = @cod_produto)
print ''; print ''; print '';



print '> ARMAZENAMENTOS MIN MAX MULTIPLO'
SELECT 
		dtae.descricao,
		ptae.minimo,
		ptae.maximo,
		ptae.multiplo,
		dtca.descricao AS tipo_controle
FROM produto_tipo_armazenagem_endereco ptae
	JOIN def_tipo_controle_armazenagem dtca ON dtca.id_def_tipo_controle_armazenagem = ptae.id_def_tipo_controle_armazenagem
	JOIN def_tipo_armazenamento_endereco dtae ON dtae.id_tipo_armazenamento_endereco = ptae.id_tipo_armazenamento_endereco
WHERE ptae.cod_produto = @cod_produto
print ''; print ''; print '';



print '> ONDE TEM ESTOQUE DO PRODUTO NO CD'
SELECT
		e.endereco_completo_3D,
		le.cod_operacao_logistica,
		le.id_lote,
	    le.estoque,
	    le.sequencia,
	    dlc.descricao AS lote_classificacao,
		dse.descricao AS situacao_endereco,
		dtae.descricao AS tipo_armazenamento,
		dtve.descricao AS tipo_volume,
		dtve.altura,
		dtve.largura,
		dtve.comprimento,
		dtve.altura * dtve.largura * dtve.comprimento AS volume_total,
		dtve.peso_maximo,
		dtve.quantidade_caixas
	    
FROM vw_lote_estoque le
	JOIN endereco e ON e.id_endereco = le.id_endereco
	JOIN def_situacao_endereco dse ON e.cod_situacao_endereco = dse.cod_situacao_endereco
	JOIN def_tipo_volume_endereco dtve ON e.id_tipo_volume = dtve.id_tipo_volume_endereco
	JOIN def_lote_classificacao dlc ON le.id_lote_classificacao = dlc.id_lote_classificacao
	JOIN def_tipo_armazenamento_endereco dtae ON e.id_tipo_Armazenamento = dtae.id_tipo_armazenamento_endereco
WHERE le.cod_produto = @cod_produto
ORDER BY e.endereco_completo_3D
print ''; print ''; print '';




print '> PEDIDOS EM ABERTOS QUE CONTEM O PRODUTO'
SELECT
	p.cod_pedido,
	dop.descricao AS origem_pedido,
	do.descricao AS operacao, 
	p.digitacao,
	piv.quantidade,
	piv.id_lote,
	end_origem.endereco_completo_3D AS endereco_origem,
	end_destino.endereco_completo_3D AS endereco_destino
FROM vw_pedido_item_volume piv 
	INNER JOIN pedido p ON p.cod_pedido = piv.cod_pedido 
	INNER JOIN def_operacao do ON p.operacao = do.operacao
	INNER JOIN def_origem_ped dop ON p.cod_origem_ped = dop.cod_origem_ped
	INNER JOIN endereco end_origem ON end_origem.id_endereco = piv.id_endereco_origem
	INNER JOIN endereco end_destino ON end_destino.id_endereco = piv.id_endereco_dest
WHERE piv.cod_produto = @cod_produto and p.cod_situacao = 2
