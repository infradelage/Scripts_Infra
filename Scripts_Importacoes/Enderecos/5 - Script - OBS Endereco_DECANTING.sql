-- Primeiro deve se validar na def_tipo_endereco qual o id_tipo referene ao DECANTING, geralmente é o 15
SELECT * FROM def_tipo_endereco 

--Após identificar o id_tipo do DECANTING, válida se na param_def_tipo_endereco o id_tipo_decanting está com o mesmo id_tipo
-- senão alterar para o que está na def_tipo_endereco
SELECT id_tipo_decanting FROM param_def_tipo_endereco

-- Na defe endereço deve conter os nivel com id_def igual a 18 e id_tipo igual a 15
SELECT * FROM def_endereco where id_tipo = 15

-- Na endereço senão houver o nível primeiro de decanting devemos cria-lo com o insert abaixo

INSERT endereco (id_def,nivel,endereco,id_pai,qtd_caixa,endereco_completo,id_lote_classificacao,permite_inventario,id_tipo_volume,id_tipo_acesso_endereco,id_tipo_Armazenamento,endereco_completo_3D,id_endereco_completo,endereco_completo_pai,refugo,id_def_endereco_setor,GetEnderecoPaiNivel,cod_situacao_endereco,id_endereco_div,id_endereco_detalha_nivel)
    VALUES (18,1,'DECANTING',NULL,NULL,'DECANTING',5,-1,NULL,NULL,NULL,'DECANTING',NULL,NULL,0,NULL,NULL,1,NULL,NULL)

--Após a importação da arvore os nível de decanting não estiverem aparecendo copie a procedure a scienza que está atualizada para o decanting
SP_HELPTEXT STP_WMS_ENDERECO_NIVEL_LE