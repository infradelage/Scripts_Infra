select kb.cod_produto as Mig ,pr.cod_produto as Prod_Rel,ptae.cod_produto as Prod_Tipo_Armz,p.cod_produto as Produto from mig_kanban kb
	LEFT JOIN produto_relacionado pr on pr.cod_produto_rel = kb.cod_produto
	LEFT JOIN produto_tipo_armazenagem_endereco ptae on ptae.cod_produto = pr.cod_produto
    LEFT JOIN produto p on  p.cod_produto = ptae.cod_produto
WHERE cod_produto_rel is null