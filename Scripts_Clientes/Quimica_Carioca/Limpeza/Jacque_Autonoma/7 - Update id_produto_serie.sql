UPDATE cod_produto_serie
SET id_produto_serie = (SELECT MAX(id_produto_serie)+1 FROM produto_serie)