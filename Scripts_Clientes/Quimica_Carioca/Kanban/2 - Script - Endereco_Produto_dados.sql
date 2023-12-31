-- VALIDA SE OS PRODUTOS EXISTEM NA PRODUTO_RELACIONADO
SELECT P.COD_PRODUTO,PR.*
FROM PRODUTO P (NOLOCK)
INNER JOIN PRODUTO_RELACIONADO PR (NOLOCK) ON P.COD_PRODUTO = PR.COD_PRODUTO
--INNER JOIN MIG_KANBAN_TRABALHO MK (NOLOCK) ON TRY_CONVERT(BIGINT, PR.COD_PRODUTO_REL) = TRY_CONVERT(BIGINT, MK.COD_SKU)
INNER JOIN MIG_KANBAN_TRABALHO MK (NOLOCK) ON PR.COD_PRODUTO_REL = MK.cod_prod_daki


--VALIDA ENDERECOS QUE EXISTE
SELECT E.ENDERECO_COMPLETO 
FROM ENDERECO E
INNER JOIN MIG_KANBAN_TRABALHO MK ON MK.ENDERECO_COMPLETO = E.ENDERECO_COMPLETO

--VALIDA ENDERECOS QUE NÃO EXISTE
SELECT * FROM MIG_KANBAN_TRABALHO MK
WHERE NOT EXISTS (SELECT 1 FROM ENDERECO E WHERE E.ENDERECO_COMPLETO = MK.ENDERECO_COMPLETO)

-- EM CASO DE ATUALIZAÇÂO DO KANBAN NÂO EXECUTAR O SCRIPT DE DELETE GERAL DA PRODUTO_TIPO_ARMAZENAGEM_ENDERECO
-- USE ESTE ABAIXO QUE SO DELETA O QUE ESTA NA MIG
 DELETE PRODUTO_ENDERECO WHERE COD_PRODUTO IN ( 
  SELECT P.COD_PRODUTO
    FROM PRODUTO P
  INNER JOIN PRODUTO_RELACIONADO PR ON P.COD_PRODUTO = PR.COD_PRODUTO
  --INNER JOIN MIG_KANBAN_TRABALHO MK ON TRY_CONVERT(BIGINT, PR.COD_PRODUTO_REL) = TRY_CONVERT(BIGINT, MK.COD_SKU))
  INNER JOIN MIG_KANBAN_TRABALHO MK (NOLOCK) ON PR.COD_PRODUTO_REL = MK.cod_prod_daki

-- INICIA ASSOCIAÇÃO PRODUTO ENDEREÇO
--DELETE FROM PRODUTO_ENDERECO
INSERT PRODUTO_ENDERECO (COD_PRODUTO, ID_ENDERECO, COD_OPERACAO_LOGISTICA, QUANTIDADE)
SELECT DISTINCT PR.COD_PRODUTO, E.ID_ENDERECO, 1, MK.MULTIPLO
FROM PRODUTO_RELACIONADO PR
--INNER JOIN MIG_KANBAN_TRABALHO MK ON TRY_CONVERT(BIGINT, PR.COD_PRODUTO_REL) = TRY_CONVERT(BIGINT, MK.COD_SKU)
INNER JOIN MIG_KANBAN_TRABALHO MK (NOLOCK) ON PR.COD_PRODUTO_REL = MK.cod_prod_daki
INNER JOIN ENDERECO E ON MK.ENDERECO_COMPLETO = E.ENDERECO_COMPLETO AND E.ID_DEF = 2

--- FINALIZA ASSOCIAÇÃO PRODUTO ENDEREÇO