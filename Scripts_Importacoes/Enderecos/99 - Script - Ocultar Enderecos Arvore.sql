--Executamos o select com o nome do endereço para descobrir id do endereço que queremos excluir o id pai
SELECT * FROM  ENDERECO WHERE ENDERECO  LIKE '%PU CONTROLADO%'

-- Com este update passamos como null o campo Id_Pai para o endereço selecionado acima
BEGIN TRAN PULMAO
UPDATE ENDERECO SET  ID_PAI = NULL WHERE ID_ENDERECO = 15420 AND  ID_DEF = 1 AND NIVEL = 2
 
-- Com o comando abaixo confirmamos as alterações ou desfazemos as alterações
ROLLBACK TRAN PULMAO
COMMIT TRAN PULMAO