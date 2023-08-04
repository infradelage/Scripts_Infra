BEGIN TRAN DBCLEAN

DELETE FROM veiculo

go

DELETE p from param_ckeckout_aleatorio_entidade p
where not exists(select * from operacao_logistica ol where p.cod_entidade = ol.cod_operacao_logistica)
 and not exists(select * from entidade e where p.cod_entidade = e.cod_entidade and e.cod_tipo = 3)
GO


GO

DELETE p from grupo_usuario_entidade p
where not exists(select * from operacao_logistica ol where p.cod_entidade = ol.cod_operacao_logistica)
and not exists(select * from entidade e where p.cod_entidade = e.cod_entidade and e.cod_tipo = 3)
GO
 
 
 DELETE p from entidade_transportador p
where not exists(select * from operacao_logistica ol where p.cod_entidade = ol.cod_operacao_logistica)
and not exists(select * from entidade e where p.cod_entidade = e.cod_entidade and e.cod_tipo = 3)
GO

 DELETE p from entidade_relacionada p
where not exists(select * from operacao_logistica ol where p.cod_entidade = ol.cod_operacao_logistica)
and not exists(select * from entidade e where p.cod_entidade = e.cod_entidade and e.cod_tipo = 3)
GO



 DELETE p from entidade_permissao_operacao_logistica p
where not exists(select * from operacao_logistica ol where p.cod_entidade = ol.cod_operacao_logistica)
and not exists(select * from entidade e where p.cod_entidade = e.cod_entidade and e.cod_tipo = 3)
GO


 DELETE p from entidade_operacao_logistica p
where not exists(select * from operacao_logistica ol where p.cod_entidade = ol.cod_operacao_logistica)
and not exists(select * from entidade e where p.cod_entidade = e.cod_entidade and e.cod_tipo = 3)
GO

 DELETE p from entidade_ender p
where not exists(select * from operacao_logistica ol where p.cod_entidade = ol.cod_operacao_logistica)
and not exists(select * from entidade e where p.cod_entidade = e.cod_entidade and e.cod_tipo = 3)


 DBCC CHECKIDENT(entidade_ender, RESEED, 1)
GO

go

 DELETE p from entidade_doc p
where not exists(select * from operacao_logistica ol where p.cod_entidade = ol.cod_operacao_logistica)
and not exists(select * from entidade e where p.cod_entidade = e.cod_entidade and e.cod_tipo = 3)
 

GO





 DELETE p from funcionario p
where not exists(select * from operacao_logistica ol where p.cod_entidade = ol.cod_operacao_logistica)
and not exists(select * from entidade e where p.cod_entidade = e.cod_entidade and e.cod_tipo = 3)

GO

 DELETE p from entidade_transportador p
where not exists(select * from operacao_logistica ol where p.cod_entidade = ol.cod_operacao_logistica)
and not exists(select * from entidade e where p.cod_entidade = e.cod_entidade and e.cod_tipo = 3)

GO

 DELETE p from entidade p
where not exists(select * from operacao_logistica ol where p.cod_entidade = ol.cod_operacao_logistica)
  and cod_tipo <> 3

GO


delete FROM cep
WHERE  not EXISTS(SELECT * FROM ENTIDADE_ENDER EE WHERE CEP.cep = ee.cep)

GO

DELETE r FROM GRUPO_ROTA r
WHERE  not EXISTS(SELECT * FROM ENTIDADE_ENDER EE WHERE r.cod_rota = ee.cod_rota)
 

GO
DELETE r FROM rota r
WHERE  not EXISTS(SELECT * FROM ENTIDADE_ENDER EE WHERE r.cod_rota = ee.cod_rota)
 
 
 GO
 
 
DELETE FROM log_alteracao_dados

go
--COMMIT TRAN  DBCLEAN

--ROLLBACK TRAN DBCLEAN


/*
                                                                                                             



veiculo

SELECT * FROM ENTIDADE


select * from entidade where cod_tipo = 3
select * from entidade e inner join operacao_logistica ol on e.cod_entidade = ol.cod_operacao_logistica


51 
STP_WMS_DIVERGENCIA

SELECT t.[name], p.[rows]
FROM sys.schemas s
INNER JOIN sys.tables t
  ON t.[schema_id] = s.[schema_id]
INNER JOIN sys.indexes i
  ON i.[object_id] = t.[object_id]
  AND i.[type] IN (0,1)
INNER JOIN sys.partitions p
  ON p.[object_id] = t.[object_id]
  AND p.[index_id] = i.[index_id]
WHERE p.[rows] > 0
ORDER BY
  t.[name]
  
  SELECT * FROM entidade_permissao_operacao_logistica


SELECT * FROM motivos

SELECT * FROM grupo_usuario


*/


