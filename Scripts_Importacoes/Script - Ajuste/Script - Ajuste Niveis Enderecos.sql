-- Faz se a validação da rua em relação ao nivel e ao ID_DEF
select * from endereco where endereco = '24' AND id_def = 2 AND NIVEL =  3

-- Com este select identifico qual ID_ENDERECO devera te seu ID_PAI alterado
select * from endereco where id_pai = 3058 

--Fazemos o update no ID_PAI
UPDATE endereco SET id_pai = 3066  WHERE id_pai IN (3058,3059,3060,3063)
UPDATE endereco SET id_pai = 3066  WHERE id_pai IN (3067)
UPDATE endereco SET id_pai = 3068  WHERE id_pai IN (3069)
UPDATE endereco SET id_pai = 3072  WHERE id_pai IN (3071)
UPDATE endereco SET id_pai = 3074  WHERE id_pai IN (3073)