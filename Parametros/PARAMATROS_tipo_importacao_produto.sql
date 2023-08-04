-- tipo_importacao_produto = 1 > Com isso o código do ERP e o WMS ficam diferentes
-- tipo_importacao_produto = 2 > Com isso o código do ERP e o WMS ficam iguais mas o digito diferente
-- tipo_importacao_produto = 3 > Tira o ultimo digito do codigo do cliente e grava o codigo do produto mas tendo um digito no WMS

select tipo_importacao_produto,* from parametros



