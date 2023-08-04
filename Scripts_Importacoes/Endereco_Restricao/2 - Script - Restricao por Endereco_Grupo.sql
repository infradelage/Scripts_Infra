-- Restricao por endereço
-- o campo id_def_grupo_produto_restricao esta ligado a tabela def_grupo_produto_restricao
-- o campo id_endereco_grupo esta ligado a tabela def_tipo_endereco_restricao
-- procedure exec stp_endereco_restricao_grava Null, 2900, 1, 21, 0



insert ENDERECO_RESTRICAO (id_endereco,id_endereco_grupo,id_def_grupo_produto_restricao,excecao)
select e.id_endereco,dter.id_endereco_grupo,dgpr.id_def_grupo_produto_restricao,0
FROM mig_endereco_restricao mre
inner join endereco e on mre.endereco_completo = e.endereco_completo
inner join def_tipo_endereco_restricao dter on dter.descricao = mre.classif_endereco_grupo
inner join def_grupo_produto_restricao dgpr on dgpr.descricao = mre.grupo_produto_restricao