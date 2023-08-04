

begin tran a


--ALTERAR O TIPO DA ENTIDADE PARA OL
SELECT * FROM entidade where cod_tipo = 14
update entidade set cod_tipo = 14 where cod_entidade = 41099

SELECT * FROM entidade_relacionada where cod_tipo = 14
update entidade_relacionada set cod_tipo = 14,cod_entidade_rel = 20 where cod_entidade = 41099

--CRIAR A OPERACAO LOGISTICA
insert operacao_logistica values (41099,1,1,1,null,null,null,0)
update operacao_logistica set principal = 0 where cod_operacao_logistica = 41099

-- INSERIR A ENTIDADE OPERACAO LOGISTICA
insert entidade_operacao_logistica
select eo.cod_entidade, 41099 
from entidade_operacao_logistica eo
where not exists (select 1 from entidade_operacao_logistica e where e.cod_entidade = eo.cod_entidade and e.cod_operacao_logistica = 41099)

-- INSERIR A PRODUTO OPERACAO LOGISTICA
insert produto_operacao_logistica (cod_operacao_logistica, cod_produto, nao_confere_cf, confirma_lote_separacao_cf,separar_somente_flowrack,
									enderecamento_dinamico)
select 41099, cod_produto, nao_confere_cf, confirma_lote_separacao_cf,separar_somente_flowrack,
									enderecamento_dinamico
from produto_operacao_logistica eo
where not exists (select 1 from produto_operacao_logistica e where e.cod_produto = eo.cod_produto and e.cod_operacao_logistica = 41099)

-- INSERIR A PRODUTO RELACIONADO
ALTER TABLE produto_relacionado NOCHECK CONSTRAINT UQ_produto_relacionado_cod_produto_rel;  
insert produto_relacionado (cod_produto, cod_produto_rel, cod_operacao_logistica)
select cod_produto, cod_produto_rel, 41099 
from produto_relacionado eo
where not exists (select 1 from produto_relacionado e where e.cod_produto = eo.cod_produto and e.cod_operacao_logistica = 41099) 



--AJUSTE LPN--
insert def_lpn (descricao, prefixo, prox_numero, cod_operacao_logistica, usa_digito_verificador, quantidade_slots, principal)
select descricao, prefixo, prox_numero, 41099, usa_digito_verificador, quantidade_slots, principal 
from def_lpn



declare @id_lpn int


insert LPN (numero,data_cadastro,cod_usuario,cod_operacao_logistica,id_endereco,id_LPN_pai,id_def_tipo_lpn,id_def_situacao_lpn,id_caixa,id_contrato,numero_slot,cod_entidade,cod_rota
)
select l.numero,l.data_cadastro,l.cod_usuario,41099,3,l.id_LPN_pai,l.id_def_tipo_lpn,l.id_def_situacao_lpn,l.id_caixa,l.id_contrato,l.numero_slot,l.cod_entidade,l.cod_rota
from lpn l
where cod_operacao_logistica = 1
and not exists (select 1 from lpn p where p.cod_operacao_logistica =  41099 and p.cod_operacao_logistica = l.cod_operacao_logistica)
and l.id_LPN = 1


select @id_lpn = @@identity

insert param_LPN values(@id_lpn,null,41099,0,0)


-- FIM AJUSTE LPN --

commit tran a

