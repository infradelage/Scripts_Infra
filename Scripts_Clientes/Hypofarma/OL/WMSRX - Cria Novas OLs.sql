





--ALTERAR O TIPO DA ENTIDADE PARA OL
SELECT * FROM entidade where cod_tipo = 37169
update entidade set cod_tipo = 37169 where cod_entidade = 41099

SELECT * FROM entidade_relacionada where cod_tipo = 37169
INSERT INTO entidade_relacionada (cod_entidade,cod_tipo,cod_entidade_rel) values (37169,37169,3)
INSERT INTO entidade_relacionada (cod_entidade,cod_tipo,cod_entidade_rel) values (37170,37169,2)
--update entidade_relacionada set cod_tipo = 37169,cod_entidade_rel = 20 where cod_entidade = 41099

--CRIAR A OPERACAO LOGISTICA
insert operacao_logistica values (37169,1,0,1,null,null,null,0) -- 37169 - MATRIZ ALMOXARIFADO
insert operacao_logistica values (37170,1,0,1,null,null,null,0) -- 37170 FILIAL GV
update operacao_logistica set principal = 1 where cod_operacao_logistica = 1

--delete from operacao_logistica where cod_operacao_logistica in (2,3)

-- INSERIR A ENTIDADE OPERACAO LOGISTICA
-- 37169 - MATRIZ ALMOXARIFADO
insert entidade_operacao_logistica
select eo.cod_entidade, 37169 
from entidade_operacao_logistica eo
where not exists (select 1 from entidade_operacao_logistica e where e.cod_entidade = eo.cod_entidade and e.cod_operacao_logistica = 37169)

 -- 37170 FILIAL GV
insert entidade_operacao_logistica
select distinct eo.cod_entidade, 37170
from entidade_operacao_logistica eo
where not exists (select 1 from entidade_operacao_logistica e where e.cod_entidade = eo.cod_entidade and e.cod_operacao_logistica = 37170)

-- INSERIR A PRODUTO OPERACAO LOGISTICA
-- 37169 - MATRIZ ALMOXARIFADO
insert produto_operacao_logistica (cod_operacao_logistica, cod_produto, nao_confere_cf, confirma_lote_separacao_cf,separar_somente_flowrack,
									enderecamento_dinamico)
select 37169, cod_produto, nao_confere_cf, confirma_lote_separacao_cf,separar_somente_flowrack,
									enderecamento_dinamico
from produto_operacao_logistica eo
where not exists (select 1 from produto_operacao_logistica e where e.cod_produto = eo.cod_produto and e.cod_operacao_logistica = 37169)

-- 37170 FILIAL GV
insert produto_operacao_logistica (cod_operacao_logistica, cod_produto, nao_confere_cf, confirma_lote_separacao_cf,separar_somente_flowrack,
									enderecamento_dinamico)
select distinct 37170, cod_produto, nao_confere_cf, confirma_lote_separacao_cf,separar_somente_flowrack,
									enderecamento_dinamico
from produto_operacao_logistica eo
where not exists (select 1 from produto_operacao_logistica e where e.cod_produto = eo.cod_produto and e.cod_operacao_logistica = 37170)

-- INSERIR A PRODUTO RELACIONADO
--ALTER TABLE produto_relacionado NOCHECK CONSTRAINT UQ_produto_relacionado_cod_produto_rel;
-- 37169 - MATRIZ ALMOXARIFADO
insert produto_relacionado (cod_produto, cod_produto_rel, cod_operacao_logistica)
select cod_produto, cod_produto_rel, 37169 
from produto_relacionado eo
where not exists (select 1 from produto_relacionado e where e.cod_produto = eo.cod_produto and e.cod_operacao_logistica = 37169) 

-- 37170 FILIAL GV
insert produto_relacionado (cod_produto, cod_produto_rel, cod_operacao_logistica)
select distinct cod_produto, cod_produto_rel, 37170
from produto_relacionado eo
where not exists (select 1 from produto_relacionado e where e.cod_produto = eo.cod_produto and e.cod_operacao_logistica = 37170) 

--ALTER TABLE produto_relacionado CHECK CONSTRAINT UQ_produto_relacionado_cod_produto_rel;

--AJUSTE LPN--
-- 37169 - MATRIZ ALMOXARIFADO
insert def_lpn (descricao, prefixo, prox_numero, cod_operacao_logistica, usa_digito_verificador, quantidade_slots, principal)
select descricao, prefixo, prox_numero, 37169, usa_digito_verificador, quantidade_slots, principal 
from def_lpn
UPDATE DEF_LPN set prefixo = '37169' , prox_numero = '200000000000001' where cod_operacao_logistica = 37169 and descricao ='Máscara Delage'
UPDATE DEF_LPN set prefixo = '037169', prox_numero = '0000000000001' where cod_operacao_logistica = 37169 and descricao ='MÃ¡scara Container'

declare @id_lpn int

SET IDENTITY_INSERT LPN ON  --Desabilita o IDENTITY
insert LPN (id_LPN,numero,data_cadastro,cod_usuario,cod_operacao_logistica,id_endereco,id_LPN_pai,id_def_tipo_lpn,id_def_situacao_lpn,id_caixa,id_contrato,numero_slot,cod_rota,cod_entidade
)
select 2,l.numero,l.data_cadastro,l.cod_usuario,37169,3,l.id_LPN_pai,l.id_def_tipo_lpn,l.id_def_situacao_lpn,l.id_caixa,l.id_contrato,l.numero_slot,l.cod_rota,l.cod_entidade
from lpn l
where cod_operacao_logistica = 1
and not exists (select 1 from lpn p where p.cod_operacao_logistica = 37169 and p.cod_operacao_logistica = l.cod_operacao_logistica)
and l.id_LPN = 1
SET IDENTITY_INSERT LPN OFF  --Habilita o IDENTITY

select @id_lpn = @@identity

insert param_LPN values(@id_lpn,null,37169,0,0)
update param_LPN set numero_prox_LPN = '3716900000000000002' where cod_operacao_logistica = 37169



-- 37170 FILIAL GV
insert def_lpn (descricao, prefixo, prox_numero, cod_operacao_logistica, usa_digito_verificador, quantidade_slots, principal)
select descricao, prefixo, prox_numero, 37170, usa_digito_verificador, quantidade_slots, principal 
from def_lpn
UPDATE DEF_LPN set prefixo = '37170' , prox_numero = '200000000000001' where cod_operacao_logistica = 37170 and descricao ='Máscara Delage'
UPDATE DEF_LPN set prefixo = '037170', prox_numero = '0000000000001' where cod_operacao_logistica = 37170 and descricao ='MÃ¡scara Container'

declare @id_lpn int

SET IDENTITY_INSERT LPN ON  --Desabilita o IDENTITY
insert LPN (id_LPN,numero,data_cadastro,cod_usuario,cod_operacao_logistica,id_endereco,id_LPN_pai,id_def_tipo_lpn,id_def_situacao_lpn,id_caixa,id_contrato,numero_slot,cod_rota,cod_entidade
)
select 3,l.numero,l.data_cadastro,l.cod_usuario,37170,3,l.id_LPN_pai,l.id_def_tipo_lpn,l.id_def_situacao_lpn,l.id_caixa,l.id_contrato,l.numero_slot,l.cod_rota,l.cod_entidade
from lpn l
where cod_operacao_logistica = 1
and not exists (select 1 from lpn p where p.cod_operacao_logistica = 37170 and p.cod_operacao_logistica = l.cod_operacao_logistica)
and l.id_LPN = 1
SET IDENTITY_INSERT LPN OFF  --Habilita o IDENTITY

select @id_lpn = @@identity

insert param_LPN values(@id_lpn,null,37170,0,0)
update param_LPN set numero_prox_LPN = '3717000000000000002' where cod_operacao_logistica = 37170

-- FIM AJUSTE LPN --

commit tran a

