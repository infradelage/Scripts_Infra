--Ajustar a def_endereco para incluir o novo nivel

SELECT * FROM def_endereco WHERE ID_DEF =2

ALTER TABLE endereco NOCHECK CONSTRAINT ALL

DELETE def_endereco where id_def = 2 and nivel > 1

INSERT def_endereco(id_def, nivel, descricao, id_tipo, divide_volume, validacao, msgerro, separador, compoe_endereco, endereco_movel)
--FLOWRACK
--SELECT 1, 1, 'CLASSIF.', 3, 0, NULL, NULL, NULL, 0, 0 UNION
SELECT 2, 2, 'AGRUPAMENTO', 3, 0, NULL, NULL, NULL, 0, 0 UNION
SELECT 2, 3, 'LINHA', 3, 1, NULL, NULL, '.', 1, 0 UNION
SELECT 2, 4, 'MODULO', 3, 0, NULL,NULL, '.', 1, 0 UNION
SELECT 2, 5, 'NIVEL',   3, 0, NULL, NULL,NULL, 1, 0 UNION
SELECT 2, 6, 'POSICAO', 3, 0, NULL, NULL, NULL, 1, 0 


ALTER TABLE endereco CHECK CONSTRAINT ALL
GO

-- Posteriormente alterei os níveis para que fosse ajustado igual a DEF_ENDERECO
	
UPDATE ENDERECO SET nivel = 6 where id_def = 2 and nivel =5
UPDATE ENDERECO SET nivel = 5 where id_def = 2 and nivel =4
UPDATE ENDERECO SET nivel = 4 where id_def = 2 and nivel =3 
UPDATE ENDERECO SET nivel = 3 where id_def = 2 and nivel =2 AND id_endereco not in (150636)

--No final fiz os ajustes do id_pai das linhas para colocar como pai cada novo agrupamento  criado

SELECT * FROM ENDERECO WHERE ID_DEF =2 and nivel =2

select * from endereco where endereco in ('ATB','BG1','BG2','L11','L12','L21','L22','L31','L32','L41','L42','L51','L52','L61','L62','L71','L72','PSC','TRM')
and ID_DEF =2 and nivel =3

update endereco set id_pai = 150636 where endereco in ('ATB')
and ID_DEF =2 and nivel =3

update endereco set id_pai = 150637 where endereco in ('BG1','L11','L21','L31','L41','L51','L61','L71')
and ID_DEF =2 and nivel =3

update endereco set id_pai = 150638 where endereco in ('BG2','L12','L22','L32','L42','L52','L62','L72')
and ID_DEF =2 and nivel =3

update endereco set id_pai = 150639 where endereco in ('PSC')
and ID_DEF =2 and nivel =3

update endereco set id_pai = 150640 where endereco in ('TRM')
and ID_DEF =2 and nivel =3