-- Quando não estiver gerando caixa fechada mesmo quando o produto estiver parametrizado para caixa fechada.
select * 
from def_operacao_tipo_endereco_origem dote
inner join def_tipo_endereco dte on dote.id_tipo = dte.id_tipo
where dote.operacao = 1

UPDATE def_operacao_tipo_endereco_origem set separacao = 3 where operacao =1