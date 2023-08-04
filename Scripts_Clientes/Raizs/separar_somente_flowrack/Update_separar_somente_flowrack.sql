select * from produto_operacao_logistica

drop table mig_separa_so_flow
go

create table mig_separa_so_flow (
cod_produto VARCHAR(255) null,
cod_produto_rel VARCHAR(255) null
)

update pol set separar_somente_flowrack = 1
--select* 
from produto_operacao_logistica pol
inner join produto p on p.cod_produto = pol.cod_produto
inner join mig_separa_so_flow mig on mig.cod_produto =  p.cod_produto * 10 + p.digito
