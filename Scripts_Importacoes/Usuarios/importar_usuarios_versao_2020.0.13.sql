/*-------------------------------------------------------------------
-												                    -
-- IMPORTAÇÃO DE USUARIOS EM CASO DO CADASTROS DE USUARIOS      	-
-  NÃO VIR VIA IMPORTAÇÃO											-
--		VERSÂO 2020.0.13	                                        -	
--																	-
-------------------------------------------------------------------*/

-- VERIFICA SE A FUNCAO DA MIG EXISTE NO BANCO, CASO NÃO EXISTA FAÇA O INSERT
insert funcao (nome,cria_ordem_movimentacao,altera_emb_compra) 
select distinct funcao,'0',null from mig_usuarios
where  funcao not in 
(select nome from funcao where nome = funcao)

-- VERIFICA SE A TIPO ENDITADE DA MIG EXISTE NO BANCO, CASO NÃO EXISTA FAÇA O INSERT
insert def_tipo_entidade (cod_tipo,descricao,cod_tipo_pessoa,valida_imp_cnpj) 
select distinct '18',tipo,'2',null from mig_usuarios
where  tipo not in 
(select descricao from def_tipo_entidade where descricao = tipo)

-- VERIFICA SE A FUNCAO DA MIG EXISTE NO BANCO, CASO NÃO EXISTA FAÇA O INSERT
insert def_subtipo_entidade (cod_tipo,descricao,separa_somente_flowrack) 
select distinct '3',subtipo,null from mig_usuarios
where  subtipo not in 
(select descricao from def_subtipo_entidade where descricao = subtipo)

-- VERIFICA SE O GRUPO DA MIG EXISTE NO BANCO, CASO NÃO EXISTA FAÇA O INSERT
insert grupo_usuario (descricao,data_cadastro,ativo) 
select distinct grupo,getdate(),'1' from mig_usuarios
where  grupo not in 
(select descricao from grupo_usuario where descricao = grupo)


-- INSERT DOS USUARIOS MIG_USUARIOS
INSERT INTO ENTIDADE (razao_social,fantasia,cod_tipo,cod_subtipo,cod_situacao,obs,data_cadastro,ult_alteracao,cod_matriz,cod_bandeira,cod_tipo_pessoa,confere_palete,confere_fracao,id_def_shelf_life_entidade,identityID/*,cod_grupo_transportadora,id_def_grupo_cliente,id_def_grupo_destinatario,libera_traza_automatico*/)
select distinct mu.nome,mu.login,dte.cod_tipo,dste.cod_subtipo,'1','',getdate(),getdate(),NULL,NULL,'2','0','0',NULL,NULL/*,NULL,NULL,NULL,'0'*/
From MIG_USUARIOS MU, def_tipo_entidade dte, def_subtipo_entidade dste
where
dte.descricao = MU.tipo
AND dste.descricao = MU.subtipo
AND not exists (select 1 from ENTIDADE ee where ee.razao_social = mu.nome)

--UPDATE TABELA ENTIDADE CAMPO COD_MATRIZ 
UPDATE e set e.cod_matriz = e.cod_entidade
--select distinct e.cod_entidade
FROM ENTIDADE e, mig_usuarios mu
where  
e.razao_social = mu.nome AND
convert(varchar, data_cadastro, 103) = '03/06/2022' --DATA DO CADASTRO 
AND  exists (select 1 from ENTIDADE ee where ee.razao_social = mu.nome)

--INSERT TABELA FUNCIONARIOS 
INSERT INTO FUNCIONARIO (cod_entidade,cod_funcao,cod_supervisor)
select distinct e.cod_entidade,f.cod_funcao,null
FROM ENTIDADE e, mig_usuarios mu, funcao f
where  
f.nome = mu.funcao AND
e.razao_social = mu.login AND
convert(varchar, data_cadastro, 103) = '03/06/2022' --DATA DO CADASTRO 
AND not exists (select 1 from funcionario f where f.cod_entidade = e.cod_entidade)


--INSERT TABELA ENTIDADE_DOC 
INSERT INTO entidade_doc (cod_entidade,cod_tipo_doc,numero,emissor,emissao,vencimento)
select distinct e.cod_entidade,'4','',null,null,null
FROM ENTIDADE e, mig_usuarios mu
where  
e.razao_social = mu.login AND
convert(varchar, data_cadastro, 103) = '03/06/2022'--DATA DO CADASTRO 
AND not exists (select 1 from entidade_doc f where f.cod_entidade = e.cod_entidade)

-- INSERT GRUPO
insert into grupo_usuario_entidade (id_grupo_usuario,cod_entidade)
select distinct gu.id_grupo_usuario,e.cod_entidade
FROM ENTIDADE e, mig_usuarios mu, grupo_usuario gu
where  
e.razao_social = mu.login AND
gu.descricao = mu.grupo and
convert(varchar, e.data_cadastro, 103) = '03/06/2022' --DATA DO CADASTRO 
AND not exists (select 1 from grupo_usuario_entidade f where f.cod_entidade = e.cod_entidade)






