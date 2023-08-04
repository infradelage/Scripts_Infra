select endereco_completo, count(1)
from mig_pulmao_trabalho
group by endereco_completo
having count(1) > 1