-- Gera o exec passando rodos os dados para a produre stp_wmsoper_produto_grava
/*
select 'exec stp_wmsoper_produto_grava @cod_produto = 0, @ean13=''' + SUBSTRING(ean,1,20) + ''',@descricao=''' 
		+ descricao + ''',@emb_saida=1.0000,@emb_compra=1.0000, @cod_produto_polo=''' + cod_produto + ''',	
		@subgrupo=''' + subgrupo + ''',	@unidade=''' + unidade + ''',@comprimento=''' + comprimento + ''',@largura=''' + largura + ''',@altura=''' + altura + ''',
		@peso=''' + peso + ''',@preco_venda=''' + preco_venda + ''',@controle_lote=' + controle_lote + ',
		@atualiza=1, @casas_decimais = 4,@validade = 365'
from #produto
*/

-- Cria a tabela temporaria #produto
drop table #produto
create table #produto (cod_produto varchar(20),descricao varchar(400),ean varchar(50),unidade varchar(50), comprimento varchar(20), largura varchar(20), altura varchar(20),
peso varchar(20), preco_venda varchar(20), subgrupo varchar(400), grupo varchar(400), controle_lote varchar(20))

--Exemplo insert tabela temporaria #produto

Insert #produto Values ('0001395','AQUAPRO CONTROLADOR COM VÁLVULA 3/4','0001395','1', '5', '5', '1', '0,9', '276', '21',null, '-1')
