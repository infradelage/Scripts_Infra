-- Cria a tabela temporaria 
drop table #grupo_subgrupo
create table grupo_subgrupo (cod_produto varchar(100),descricao varchar(100),	grupo varchar(100),	subgrupo varchar(100))

-- Cria a tabela temporaria #produto
Insert #grupo_subgrupo Values ( '0110 - ISCAS E ARMADILHAS','0119 - ARMADILHAS')
Insert #grupo_subgrupo Values ( '0110 - ISCAS E ARMADILHAS','0119 - ARMADILHAS')

-- VALIDA SE TODOS OS PRODUTOS EXISTE NA BASE
select cod_produto,descricao from grupo_subgrupo
where cod_produto /10  not in (select cod_produto from produto)

-- VALIDA SE EXISTE ALGUM GRUPO QUE JÀ ESTEJA CADASTRADO
select distinct grupo from grupo_subgrupo
where grupo not in (select descricao from grupo)

-- VALIDA SE EXISTE ALGUM SUBGRUPO QUE JÀ ESTEJA CADASTRADO
select distinct subgrupo from grupo_subgrupo
where subgrupo not in (select descricao from subgrupo)


-- INSERT NA TABELA GRUPO 
-- EXEMPLO DE SUBTRING CASO PRECISE SUBSTRING(GRUPO,7,LEN(GRUPO))
insert Grupo
select distinct grupo from grupo_subgrupo
where grupo not in (select descricao from grupo)


-- INSERT NA TABELA SUBGRUPO 
insert SubGrupo
select distinct g.cod_grupo, p.subgrupo, 0, null,0,0
from grupo_subgrupo p
inner join Grupo g on p.grupo = g.descricao
where p.subgrupo <> ''  -- ignora os dados vazios
group by g.cod_grupo, p.subgrupo


--UPDATE ABAIXO NÂOD EVE SER USADO CASO ESTEJA AJUSTENDO SOMENTE O GRUPO E SUBGRUPO SEM AJUSTE DE PRODUTO
--update p set p.cod_subgrupo = sg.cod_subgrupo
----select distinct  p.*
-- from produto p
--inner join grupo_subgrupo gs on gs.cod_produto /10 = p.cod_produto
--inner join SubGrupo sg on gs.subgrupo = sg.descricao
--inner join grupo g on gs.grupo = g.descricao and sg.cod_grupo = g.cod_grupo












