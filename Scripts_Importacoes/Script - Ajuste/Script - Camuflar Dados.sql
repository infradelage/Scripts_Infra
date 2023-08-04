select * into entidade_bkp_071621 from entidade 
select * into entidade_ender_bkp_071621 from entidade_ender
select * into entidade_doc_bkp_071621 from entidade_DOC

select * from def_tipo_entidade
select * from entidade_ender

update ENTIDADE_DOC set numero = '00000000/0001-00' where cod_tipo_doc = 3
update ENTIDADE_DOC set numero = 'ISENTO' where cod_tipo_doc = 4
update ENTIDADE_DOC set numero = '000000000-00' where cod_tipo_doc = 1

update entidade set 
razao_social =	'OPERADOR LOGISTICO DO CD ' + convert (varchar(100),cod_entidade),
FANTASIA =	'OL ' + convert (varchar(100),cod_entidade)
WHERE cod_tipo = 14

update entidade set 
razao_social =	'MOTORISTA DO CD ' + convert (varchar(100),cod_entidade),
FANTASIA =	'MOTORISTA ' + convert (varchar(100),cod_entidade)
WHERE cod_tipo = 16

update entidade set 
razao_social =	'TRANSPORTADORA DO CD ' + convert (varchar(100),cod_entidade),
FANTASIA =	'TRANSPORTADORA ' + convert (varchar(100),cod_entidade)
WHERE cod_tipo = 13

update entidade set 
razao_social =	'CLIENTE DO CD ' + convert (varchar(100),cod_entidade),
FANTASIA =	'CLIENTE ' + convert (varchar(100),cod_entidade)
WHERE cod_tipo = 1


update entidade set 
razao_social =	'FUNCIONARIO DO CD ' + convert (varchar(100),cod_entidade),
FANTASIA =	'FUNCIONARIO ' + convert (varchar(100),cod_entidade)
WHERE cod_tipo = 3

update entidade set 
razao_social =	'FORNECEDOR DO PRODUTO ' + convert (varchar(100),cod_entidade),
FANTASIA =	'FORNECEDOR ' + convert (varchar(100),cod_entidade)
WHERE cod_tipo = 2
