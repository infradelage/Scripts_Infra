select * from entidade_relacionada where cod_tipo = 14

select * from entidade where cod_entidade in (1,292)

select * from operacao_logistica

select * from entidade_operacao_logistica where cod_operacao_logistica = 1
select * from produto_operacao_logistica where cod_operacao_logistica = 1

insert produto_operacao_logistica (cod_operacao_logistica,cod_produto,nao_confere_cf,confirma_lote_separacao_cf,
separar_somente_flowrack,enderecamento_dinamico,bloqueio_digitacao_conferencia,obrigada_digitacao_laudo
)
select 292,pp.cod_produto,pp.nao_confere_cf,pp.confirma_lote_separacao_cf,
pp.separar_somente_flowrack,pp.enderecamento_dinamico,pp.bloqueio_digitacao_conferencia,pp.obrigada_digitacao_laudo
from produto_operacao_logistica pp
where cod_operacao_logistica = 1
and not exists (select 1 from produto_operacao_logistica p where p.cod_operacao_logistica =  292 and p.cod_produto = pp.cod_produto)

insert entidade_operacao_logistica (cod_entidade, cod_operacao_logistica)
select pp.cod_entidade, 292
from entidade_operacao_logistica pp
where cod_operacao_logistica = 1
and not exists (select 1 from entidade_operacao_logistica p where p.cod_operacao_logistica =  292 and p.cod_entidade = pp.cod_entidade)

insert LPN (numero,data_cadastro,cod_usuario,cod_operacao_logistica,id_endereco,id_LPN_pai,id_def_tipo_lpn,id_def_situacao_lpn,id_caixa,id_contrato,numero_slot,cod_entidade,cod_rota
)
select l.numero,l.data_cadastro,l.cod_usuario,292,3,l.id_LPN_pai,l.id_def_tipo_lpn,l.id_def_situacao_lpn,l.id_caixa,l.id_contrato,l.numero_slot,l.cod_entidade,l.cod_rota
from lpn l
where cod_operacao_logistica = 1
and not exists (select 1 from lpn p where p.cod_operacao_logistica =  292 and p.cod_operacao_logistica = l.cod_operacao_logistica)
and l.id_LPN = 2

insert def_lpn (descricao,prefixo,prox_numero,cod_operacao_logistica,usa_digito_verificador,quantidade_slots,principal,cod_grupo_operacao_logistica,permite_multiplos)
select l.descricao,'000292','00000000000001', 292,l.usa_digito_verificador,l.quantidade_slots,l.principal,l.cod_grupo_operacao_logistica,l.permite_multiplos
from  def_lpn l
where cod_operacao_logistica = 1
and not exists (select 1 from def_lpn p where p.cod_operacao_logistica =  292 and p.cod_operacao_logistica = l.cod_operacao_logistica)

insert caixa_esteira_operacao_logistica values(15,292)
insert caixa_esteira_operacao_logistica values(16,292)
insert caixa_esteira_operacao_logistica values(17,292)
