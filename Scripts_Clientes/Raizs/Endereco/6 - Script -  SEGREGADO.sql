
DECLARE @id_def INT 
DECLARE @id_tipo INT 

set @id_def = 0 
set @id_tipo = 0 

BEGIN
	SELECT @id_tipo = id_tipo
	  FROM def_tipo_endereco 
	 WHERE descricao = 'Segregado'
	 
	SELECT @id_def = id_def
	  FROM def_endereco
	 WHERE descricao = 'CLASSIF.' AND id_tipo = @id_tipo
END

IF not exists (select 1 from endereco where endereco = 'SEGREGADO' and endereco_completo = 'SEGREGADO' and endereco_completo_3D='SEGREGADO') 
BEGIN
	INSERT endereco (id_def,nivel,endereco,id_pai,qtd_caixa,endereco_completo,id_lote_classificacao,permite_inventario,id_tipo_volume,id_tipo_acesso_endereco,id_tipo_Armazenamento,endereco_completo_3D,id_endereco_completo,endereco_completo_pai,refugo,id_def_endereco_setor,GetEnderecoPaiNivel,cod_situacao_endereco,id_endereco_div,id_endereco_detalha_nivel) 
	VALUES (@id_def,1,'SEGREGADO',NULL,NULL,'SEGREGADO',1,-1,NULL,NULL,NULL,'SEGREGADO',NULL,NULL,0,NULL,NULL,1,NULL,NULL)
END


