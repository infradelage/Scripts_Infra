--APAGA E CRIA A TABELA ONDE SERA INSERIDOS OS DADOS
drop table endereco_produto_dados
create table endereco_produto_dados (cod_produto_rel varchar(20), descricao varchar(100),endereco_completo varchar(20),qtd varchar(50) )

--  VALIDA ENDEREÇOS FALTANTES ENTEE A MIG E A PRODUTO_RELACIONADO
select pr.cod_produto
from produto_relacionado pr
inner join endereco_produto_dados epd on pr.cod_produto_rel = epd.cod_produto_rel
WHERE epd.cod_produto_rel NOT IN (SELECT cod_produto_rel FROM produto_relacionado)

--  VALIDA ENDEREÇOS FALTANTES ENTEE A MIG E A ENDERECO
select e.endereco_completo,epd.endereco_completo
from endereco e
right join endereco_produto_dados epd on e.endereco_completo = epd.endereco_completo
WHERE epd.endereco_completo not IN (SELECT endereco_completo FROM endereco)

select * into PRODUTO_ENDERECO_bkp220323 from PRODUTO_ENDERECO

--  EM CASO DE ATUALIZAR OS DADOS DE DETERMINADOS PRODUTOS EXECUTAR ESTE DELETE PARA LIMPAR
-- OS DADOS DE ACORDO COM A mig_kanban
---ALTER TABLE produto_endereco DISABLE TRIGGER ALL
delete produto_endereco where cod_produto in ( 
  select pe.cod_produto
    from PRODUTO_ENDERECO pe
  inner join produto_relacionado pr on pe.cod_produto = pr.cod_produto
  inner join endereco_produto_dados epd on pr.cod_produto_rel = epd.cod_produto_rel
  inner join endereco e on epd.endereco_completo = e.endereco_completo 
  
  )
--ALTER TABLE produto_endereco ENABLE TRIGGER ALL

-- INICIA ASSOCIAÇÃO PRODUTO ENDEREÇO

insert produto_endereco (cod_produto, id_endereco, cod_operacao_logistica, quantidade)
select pr.cod_produto, e.id_endereco, 1, 100
from produto_relacionado pr
inner join endereco_produto_dados epd on pr.cod_produto_rel = epd.cod_produto_rel
inner join endereco e on epd.endereco_completo = e.endereco_completo

--- FINALIZA ASSOCIAÇÃO PRODUTO ENDEREÇO