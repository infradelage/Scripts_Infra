/*-------------------------------------------------------------------
-												 -
-- Criação da árvore de endereço - SEGREGADO - COM 1 NIVEL FINAL	-
-																	-
--					endereco_completo								-	
--                  FALTAS											-
-- FALTAS	- MOTIVO												-
--																	-
-------------------------------------------------------------------*/

-- REDEFINE NIVEIS DE ENDEREÇAMENTO
ALTER TABLE endereco NOCHECK CONSTRAINT ALL

DELETE def_endereco where id_def = 5 and nivel > 1

INSERT def_endereco(id_def, nivel, descricao, id_tipo, divide_volume, validacao, msgerro, separador, compoe_endereco, endereco_movel)
-- PULMÃO
--SELECT 5, 1, 'CLASSIF.', 2, 0, NULL, NULL, NULL, 0, 0 UNION
SELECT 5, 2, 'MOTIVO', 6, 0, NULL, NULL, NULL, 1, 0

ALTER TABLE endereco CHECK CONSTRAINT ALL
GO

--TABELA PARA TRABALHAR E NO FIM DELETAR
select * INTO mig_segregado_trabalho  from mig_segregado

/*CURINGA! Se alguma columa estiver como float basta alterar ela para varchar! 
Exemplo abaixo:
alter table mig_segregado_trabalho alter column palete varchar(30)
*/


--AJUSTES CASO PRECISEM--
--ACESSO--
--select * from def_tipo_acesso_endereco where id_tipo_endereco = 2
update def_tipo_acesso_endereco set descricao = 'A PÉ (SEGREGADO)' where descricao like '%A PÉ%' and id_tipo_endereco = 6 --SEGREGADO

--select * from mig_segregado_trabalho
update mig_segregado_trabalho set tipo_de_acesso = 'A PÉ (SEGREGADO)' where tipo_de_acesso like '%A PÉ%'
--FIM AJUSTES


--select * from mig_segregado_trabalho
update mig_segregado_trabalho set tipo_volume = 'PALLET PADRAO' where tipo_volume like '%PALLET%'
--FIM AJUSTES


--ATENCAO AQUI--NAO PODE RETORNAR NENHUMA LINHA AQUI. SE RETORNAR DEVOLVER A PLANILHA
select * from mig_segregado_trabalho where endereco_completo is null


--INSERÇÕES EM DEFs CASO PRECISE--
--SETOR
insert def_endereco_setor
select distinct setor,2 from mig_segregado_trabalho
where setor not in (select descricao from def_endereco_setor where descricao = setor and id_tipo = 6)

--ACESSO
insert def_tipo_acesso_endereco (descricao, id_tipo_endereco)
select distinct tipo_de_acesso,4 from mig_segregado_trabalho
where  tipo_de_acesso not in 
(select tipo_de_acesso from def_tipo_acesso_endereco where descricao = tipo_de_acesso)


--VOLUME 
-->SOLICITAR REVISAO POSTERIOR NAS QUANTIDADE DE CAIXAS E DIMENSSOES VIA SISTEMA<--
insert def_tipo_volume_endereco
select distinct tipo_volume, 1, 1,1,1,0,null,0,0,0 from mig_segregado_trabalho
where  tipo_volume not in 
(select tipo_volume from def_tipo_volume_endereco where descricao = tipo_volume)
--FIM INSERÇÕES


--DELETE ENDERECO DE FLOW PARA COMEÇAR DO PRIMEIRO NIVEL E ACERTAR O IDENTITY
DELETE endereco
WHERE nivel > 1 and id_def = 5
DECLARE @max_endereco int
set @max_endereco = (select max(id_endereco) from endereco)
DBCC CHECKIDENT (endereco, RESEED, @max_endereco)

---AQUI INICIA A IMPORTACAO DOS ENDERECOS DE FATO--
--NIVEL 2 - 
insert endereco(id_def, nivel, endereco, id_pai, qtd_caixa, endereco_completo, id_lote_classificacao, cod_situacao_endereco,
id_tipo_acesso_endereco, id_tipo_Armazenamento, id_tipo_volume)
select distinct 5, 2, m1.endereco_completo, m2.id_endereco, null, m1.endereco_completo, dlc.id_lote_classificacao,1,
dtac.id_tipo_acesso_endereco, dtae.id_tipo_armazenamento_endereco,dtve.id_tipo_volume_endereco
from mig_segregado_trabalho m1, endereco m2, def_lote_classificacao dlc, def_tipo_acesso_endereco dtac, def_tipo_volume_endereco dtve, 
def_tipo_armazenamento_endereco dtae
where  m2.endereco_completo = m1.classificacao
and m1.classificacao_endereco = dlc.descricao
and dtac.id_tipo_endereco = 6 -- SEGREGADO
and dtve.descricao =  m1.tipo_volume
and dtae.descricao = m1.tipo_de_armazenamento
AND NOT EXISTS (SELECT 1 FROM ENDERECO E WHERE E.endereco_completo = m1.endereco_completo AND id_def = 5 AND NIVEL = 2)
and m2.id_def = 5
and m2.nivel = 1




--FIM IMPORTACAO DOS ENDERECOS 
				   

--UPDATES ADICIONAIS DEPOIS DE IMPORTADO OS ENDERECOS--		   
UPDATE endereco
   SET  endereco_completo_3D = dbo.getEnderecoCompleto3D(id_endereco),
	   id_endereco_completo = dbo.getEnderecoCompletoID(id_endereco),
	   id_endereco_div = dbo.GetEnderecoDivID(id_endereco)

UPDATE E
   SET E.endereco_completo_pai = PAI.endereco_completo
  FROM endereco E INNER JOIN
       endereco PAI ON PAI.id_endereco = E.id_pai

UPDATE endereco
   SET  GetEnderecoPaiNivel = dbo.GetEnderecoPaiNivel(id_endereco,nivel)   

UPDATE e set
e.id_def_endereco_setor = def.id_def_endereco_setor
from endereco e
inner join mig_segregado_trabalho m1 on e.endereco_completo = m1.endereco_completo
inner join def_endereco_setor def on def.descricao = m1.setor
where e.id_def = 4 and def.id_tipo = 6--SEGREGADO

--FIM UPDATES ADICIONAIS


/*
Validacoes

 SELECT count(1) as enderecos_a_migrar from mig_segregado_trabalho
 SELECT count(1) as enderecos_migrados from endereco where id_def = 5 and nivel = (select max(nivel) from def_endereco where id_def = 5)

 SELECT * FROM endereco WHERE id_def = 4 AND nivel =5
 and id_tipo_Armazenamento is  null
 
 SELECT * FROM endereco WHERE id_def = 4 AND nivel =5
 and id_tipo_acesso_endereco is  null
  
 SELECT * FROM endereco WHERE id_def =1 AND nivel =5
 and id_def_endereco_setor is  null
   
 SELECT * FROM endereco WHERE id_def = 4 AND nivel =5
 and id_tipo_volume is  null
  
*/
 

