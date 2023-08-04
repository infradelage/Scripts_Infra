USE WMSRX
GO

begin tran a


--ALTERAR O TIPO DA ENTIDADE PARA OL
SELECT * FROM entidade where cod_tipo = 14 
update entidade set cod_tipo = 14 where cod_entidade = 41099

--VALIDA TIPO DA ENTIDADE PARA OL
SELECT * FROM entidade where cod_tipo = 14

-- ENTIDADE REALCIONADA
SELECT * FROM entidade_relacionada where cod_entidade in (1,4,5,6,7)
update entidade_relacionada set cod_tipo = 14,cod_entidade_rel = 116 where cod_entidade in (1)
--INSERT entidade_relacionada (cod_entidade,cod_tipo,cod_entidade_rel) VALUES ('1','14','116')
INSERT entidade_relacionada (cod_entidade,cod_tipo,cod_entidade_rel) VALUES ('4','14','1')
INSERT entidade_relacionada (cod_entidade,cod_tipo,cod_entidade_rel) VALUES ('5','14','4')
INSERT entidade_relacionada (cod_entidade,cod_tipo,cod_entidade_rel) VALUES ('6','14','3')
INSERT entidade_relacionada (cod_entidade,cod_tipo,cod_entidade_rel) VALUES ('7','14','5')

-- VALIDA ENTIDADE RELCAIONADA CRIADA
SELECT * FROM entidade_relacionada where cod_tipo = 14

--CRIAR A OPERACAO LOGISTICA
insert operacao_logistica values (1,1,1,1,null,null,null,0)
update operacao_logistica set principal = 1 where cod_operacao_logistica = 1
insert operacao_logistica values (4,1,0,1,null,null,null,0)
insert operacao_logistica values (5,1,0,1,null,null,null,0)
insert operacao_logistica values (6,1,0,1,null,null,null,0)
insert operacao_logistica values (7,1,0,1,null,null,null,0)

-- VALIDA OPERACAO LOGISTICA CRIADA
SELECT * FROM operacao_logistica

-- INSERIR A ENTIDADE OPERACAO LOGISTICA
--delete from entidade_operacao_logistica
insert entidade_operacao_logistica
select e.cod_entidade, 1 
from entidade e
where e.cod_tipo <> 14 
AND not exists (select 1 from entidade_operacao_logistica eol where eol.cod_entidade = e.cod_entidade and eol.cod_operacao_logistica = 1 )

insert entidade_operacao_logistica
select e.cod_entidade, 4 
from entidade e
where e.cod_tipo <> 14 
AND not exists (select 1 from entidade_operacao_logistica eol where eol.cod_entidade = e.cod_entidade and eol.cod_operacao_logistica = 4 )

insert entidade_operacao_logistica
select e.cod_entidade, 5 
from entidade e
where e.cod_tipo <> 14 
AND not exists (select 1 from entidade_operacao_logistica eol where eol.cod_entidade = e.cod_entidade and eol.cod_operacao_logistica = 5 )

insert entidade_operacao_logistica
select e.cod_entidade, 6 
from entidade e
where e.cod_tipo <> 14 
AND not exists (select 1 from entidade_operacao_logistica eol where eol.cod_entidade = e.cod_entidade and eol.cod_operacao_logistica = 6 )

insert entidade_operacao_logistica
select e.cod_entidade, 7 
from entidade e
where e.cod_tipo <> 14 
AND not exists (select 1 from entidade_operacao_logistica eol where eol.cod_entidade = e.cod_entidade and eol.cod_operacao_logistica = 7 )

-- INSERIR A PRODUTO OPERACAO LOGISTICA
insert produto_operacao_logistica (cod_operacao_logistica, cod_produto, nao_confere_cf, confirma_lote_separacao_cf,separar_somente_flowrack,
									enderecamento_dinamico,bloqueio_digitacao_conferencia,obrigada_digitacao_laudo)
select 4, cod_produto, 0,0,NULL,NULL,0,0
from produto p
where not exists (select 1 from produto_operacao_logistica e where e.cod_produto = p.cod_produto and e.cod_operacao_logistica = 4)

insert produto_operacao_logistica (cod_operacao_logistica, cod_produto, nao_confere_cf, confirma_lote_separacao_cf,separar_somente_flowrack,
									enderecamento_dinamico,bloqueio_digitacao_conferencia,obrigada_digitacao_laudo)
select 5, cod_produto, 0,0,NULL,NULL,0,0
from produto p
where not exists (select 1 from produto_operacao_logistica e where e.cod_produto = p.cod_produto and e.cod_operacao_logistica = 5)

insert produto_operacao_logistica (cod_operacao_logistica, cod_produto, nao_confere_cf, confirma_lote_separacao_cf,separar_somente_flowrack,
									enderecamento_dinamico,bloqueio_digitacao_conferencia,obrigada_digitacao_laudo)
select 6, cod_produto, 0,0,NULL,NULL,0,0
from produto p
where not exists (select 1 from produto_operacao_logistica e where e.cod_produto = p.cod_produto and e.cod_operacao_logistica = 6)

insert produto_operacao_logistica (cod_operacao_logistica, cod_produto, nao_confere_cf, confirma_lote_separacao_cf,separar_somente_flowrack,
									enderecamento_dinamico,bloqueio_digitacao_conferencia,obrigada_digitacao_laudo)
select 7, cod_produto, 0,0,NULL,NULL,0,0
from produto p
where not exists (select 1 from produto_operacao_logistica e where e.cod_produto = p.cod_produto and e.cod_operacao_logistica = 7)


-- INSERIR A PRODUTO RELACIONADO
ALTER TABLE produto_relacionado NOCHECK CONSTRAINT UQ_produto_relacionado_cod_produto_rel;  
insert produto_relacionado (cod_produto, cod_produto_rel, cod_operacao_logistica)
select cod_produto, cod_produto_rel, 4 
from produto_relacionado eo
where not exists (select 1 from produto_relacionado e where e.cod_produto = eo.cod_produto and e.cod_operacao_logistica = 4) 

insert produto_relacionado (cod_produto, cod_produto_rel, cod_operacao_logistica)
select cod_produto, cod_produto_rel, 5 
from produto_relacionado eo
where cod_operacao_logistica in (1)
and not exists (select 1 from produto_relacionado e where e.cod_produto = eo.cod_produto and e.cod_operacao_logistica = 5)

insert produto_relacionado (cod_produto, cod_produto_rel, cod_operacao_logistica)
select cod_produto, cod_produto_rel, 6
from produto_relacionado eo
where cod_operacao_logistica in (1)
and not exists (select 1 from produto_relacionado e where e.cod_produto = eo.cod_produto and e.cod_operacao_logistica = 6)


insert produto_relacionado (cod_produto, cod_produto_rel, cod_operacao_logistica)
select cod_produto, cod_produto_rel, 7
from produto_relacionado eo
where cod_operacao_logistica in (1)
and not exists (select 1 from produto_relacionado e where e.cod_produto = eo.cod_produto and e.cod_operacao_logistica = 7)



--AJUSTE DEF LPN--
insert def_lpn (descricao, prefixo, prox_numero, cod_operacao_logistica, usa_digito_verificador, quantidade_slots, principal)
select descricao, prefixo, prox_numero, 4, usa_digito_verificador, quantidade_slots, principal 
from def_lpn

insert def_lpn (descricao, prefixo, prox_numero, cod_operacao_logistica, usa_digito_verificador, quantidade_slots, principal)
select descricao, prefixo, prox_numero, 5, usa_digito_verificador, quantidade_slots, principal 
from def_lpn where cod_operacao_logistica = 4

insert def_lpn (descricao, prefixo, prox_numero, cod_operacao_logistica, usa_digito_verificador, quantidade_slots, principal)
select descricao, prefixo, prox_numero, 6, usa_digito_verificador, quantidade_slots, principal 
from def_lpn where cod_operacao_logistica = 4

insert def_lpn (descricao, prefixo, prox_numero, cod_operacao_logistica, usa_digito_verificador, quantidade_slots, principal)
select descricao, prefixo, prox_numero, 7, usa_digito_verificador, quantidade_slots, principal 
from def_lpn where cod_operacao_logistica = 4


--AJUSTE LPN OL 4--
declare @id_lpn int


insert LPN (numero,data_cadastro,cod_usuario,cod_operacao_logistica,id_endereco,id_LPN_pai,id_def_tipo_lpn,id_def_situacao_lpn,id_caixa,id_contrato,numero_slot,cod_entidade,cod_rota
)
select l.numero,l.data_cadastro,l.cod_usuario,4,3,l.id_LPN_pai,l.id_def_tipo_lpn,l.id_def_situacao_lpn,l.id_caixa,l.id_contrato,l.numero_slot,l.cod_entidade,l.cod_rota
from lpn l
where cod_operacao_logistica = 1
and not exists (select 1 from lpn p where p.cod_operacao_logistica = 4 and p.cod_operacao_logistica = l.cod_operacao_logistica)
and l.id_LPN = 1


select @id_lpn = @@identity

insert param_LPN values(@id_lpn,null,4,0,0)

--AJUSTE LPN OL 5--
declare @id_lpn int


insert LPN (numero,data_cadastro,cod_usuario,cod_operacao_logistica,id_endereco,id_LPN_pai,id_def_tipo_lpn,id_def_situacao_lpn,id_caixa,id_contrato,numero_slot,cod_entidade,cod_rota
)
select l.numero,l.data_cadastro,l.cod_usuario,5,3,l.id_LPN_pai,l.id_def_tipo_lpn,l.id_def_situacao_lpn,l.id_caixa,l.id_contrato,l.numero_slot,l.cod_entidade,l.cod_rota
from lpn l
where cod_operacao_logistica = 1
and not exists (select 1 from lpn p where p.cod_operacao_logistica = 5 and p.cod_operacao_logistica = l.cod_operacao_logistica)
and l.id_LPN = 1


select @id_lpn = @@identity

insert param_LPN values(@id_lpn,null,5,0,0)

--AJUSTE LPN OL 6--
declare @id_lpn int


insert LPN (numero,data_cadastro,cod_usuario,cod_operacao_logistica,id_endereco,id_LPN_pai,id_def_tipo_lpn,id_def_situacao_lpn,id_caixa,id_contrato,numero_slot,cod_entidade,cod_rota
)
select l.numero,l.data_cadastro,l.cod_usuario,6,3,l.id_LPN_pai,l.id_def_tipo_lpn,l.id_def_situacao_lpn,l.id_caixa,l.id_contrato,l.numero_slot,l.cod_entidade,l.cod_rota
from lpn l
where cod_operacao_logistica = 1
and not exists (select 1 from lpn p where p.cod_operacao_logistica = 6 and p.cod_operacao_logistica = l.cod_operacao_logistica)
and l.id_LPN = 1


select @id_lpn = @@identity

insert param_LPN values(@id_lpn,null,6,0,0)

--AJUSTE LPN OL 7--
declare @id_lpn int


insert LPN (numero,data_cadastro,cod_usuario,cod_operacao_logistica,id_endereco,id_LPN_pai,id_def_tipo_lpn,id_def_situacao_lpn,id_caixa,id_contrato,numero_slot,cod_entidade,cod_rota
)
select l.numero,l.data_cadastro,l.cod_usuario,7,3,l.id_LPN_pai,l.id_def_tipo_lpn,l.id_def_situacao_lpn,l.id_caixa,l.id_contrato,l.numero_slot,l.cod_entidade,l.cod_rota
from lpn l
where cod_operacao_logistica = 1
and not exists (select 1 from lpn p where p.cod_operacao_logistica = 7 and p.cod_operacao_logistica = l.cod_operacao_logistica)
and l.id_LPN = 1


select @id_lpn = @@identity

insert param_LPN values(@id_lpn,null,7,0,0)


-- FIM AJUSTE LPN --

commit tran a

