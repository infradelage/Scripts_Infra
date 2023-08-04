create table [dbo].mig_param_endereco_distancia(
	endere�o_flow [nvarchar](255) null,
	endere�o_fixo  [nvarchar](255) null
) on [primary]
go


delete param_endereco_distancia DBCC CHECKIDENT (param_endereco_distancia, RESEED, 0)


insert param_endereco_distancia (id_endereco_origem, id_endereco_destino, distancia,caixas,quantidade_cx_reabastecimento)
select e.id_endereco,e2.id_endereco, 1 , 0, 0
from mig_param_endereco_distancia m
inner join endereco e on e.endereco_completo = m.endereco_fixo
inner join endereco e2 on e2.endereco_completo = m.endereco_flowrack


-- Verifica se tem endereços inexistentes entre param_endereco_distancia e a endereço
select e.id_endereco,ped.id_endereco_origem from param_endereco_distancia ped
left join endereco e on e.id_endereco = ped.id_endereco_origem
where e.id_endereco is null


-- Faz um param_endereco_distancia
select * into param_endereco_distancia_bkp_070723 from param_endereco_distancia


--Delete da param_endereco_distancia dos endereços inexistentes entre param_endereco_distancia e a endereço
begin tran delete_ped
delete ped
--select e.id_endereco,ped.id_endereco_origem 
from param_endereco_distancia ped
left join endereco e on e.id_endereco = ped.id_endereco_origem
where e.id_endereco is null

--commit tran delete_ped
--rollback tran delete_ped