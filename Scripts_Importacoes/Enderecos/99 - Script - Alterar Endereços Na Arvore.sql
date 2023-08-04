-- Utiliza esste select para descobrir o id que deve ser alterado
select * from endereco where endereco_completo in ('40.14', '40.15','40.16')
select * from endereco where endereco_completo like '%40.14%'

-- executa este select para validar se o ID encontrado acima corresponde
select * from endereco where id_def = 2 and nivel = 4 and id_pai = 1206

Id	 Descricao	   Id	Descricao
1200 PRATELEIRA	> 1205	RUA 40
1201 TI			> 1206	RUA 40

-- No upadate setamos o novo ID_PAI 
UPDATE endereco SET id_pai = 1206 where id_def = 2 and nivel = 4 and id_pai = 1205

-- Este Update ajuste o campo id_endereco_div
UPDATE e
SET id_endereco_div = dbo.GetEnderecoDivID(id_endereco)
FROM endereco e
WHERE e.id_def = 2
AND e.nivel > (select nivel from def_endereco where id_def = 2 and divide_volume = 1)

-- Este update ajusta o endereco_completo_3D passando o novo ID
UPDATE endereco
SET endereco_completo_3D = dbo.getEnderecoCompleto3D(id_endereco),
id_endereco_completo = dbo.getEnderecoCompletoID(id_endereco)



select pe.cod_produto,p.digito,p.descricao, e.endereco_completo from produto_endereco pe
inner join produto p on p.cod_produto = pe.cod_produto
inner join endereco e on e.id_endereco = pe.id_endereco
where pe.id_endereco in (1690,1910,2124,2337,2434,1694,1913,2127,2339,2436,
1696,1914,2128,2340,2354,2368,2382,2437,2451,2465,2479) order by e.endereco_completo

select * from produto_endereco where id_endereco in (1690,1910,2124,2337,2434,1694,1913,2127,2339,2436,
1696,1914,2128,2340,2354,2368,2382,2437,2451,2465,2479)
