
/*    Formula do insert no excel 
="Insert #Fixo Values('"& &"','"& &"','"& &"','"& &"')"      */

/*Objetivo do script
ASSOCIAR OS ENDEREÇOS DE FIXO AO ENDEREÇO DE FLOWRACK*/

--validadar o insert do exell

--drop table #Fixo
--drop table #Log

/*Criação da tabela

1- Criando #Fixo

2- criando um #Log para retorno de problemas ao cliente

3- contar quantos endere�os foram inseridos em #fixo

4- contar osduplicados 

5- testar se existe endere�os de fixo ou flowrack inexistentes

*/



--drop table #fixo

create table #Fixo ( endereco_fixo varchar (50), endereco_flowrack varchar (50),cod_produto varchar (50) , id int)

create table #Log  (endereco_fixo varchar (50),endereco_flowrack varchar (50),cod_produto varchar (50),  descricao_log varchar(100))

--Formula do insert no excel 
--="Insert #Fixo Values('"& &"','"& &"','"& &"','"& &"')"

--TESTAR SE EXISTE ENDERECOS DE FIXO OU FLOWRACK INEXISTENTES
select f.endereco_flowrack as end_#fixo, e.endereco_completo from endereco e
inner join #fixo f on f.endereco_fixo = e.endereco_completo where e.endereco_completo is null

select f.endereco_flowrack as end_#fixoFlow, e.endereco_completo from endereco e
right join #fixo f on f.endereco_flowrack = e.endereco_completo where e.endereco_completo is null

--VERIFICAR QUANTIDADE DE LINHAS INSERIDAS 
select COUNT(*) from #Fixo

-- VERIFICAR INFORMA��ES DUPLICADAS
select count(*), endereco_flowrack, endereco_fixo
from #fixo
group by endereco_flowrack, endereco_fixo
having count(*) > 1


begin tran a
while exists(select 1 from #fixo)
  begin
       declare @id int = null, @cod_produto int = null, 
	   @endereco_fixo varchar (50) = null, @endereco_flowrack varchar (50) = null , 
	   @id_endereco_ori int = null, @id_endereco_dest int = null, @cod_produto_rel int
			  

	   select @id = min(id)
	   From #fixo


	   select @endereco_fixo = endereco_fixo, @endereco_flowrack= endereco_flowrack, @cod_produto_rel = cod_produto
	   from #fixo
	   where id = @id

	   select @id_endereco_ori = id_endereco
	   from endereco where endereco_completo = @endereco_fixo
	   
	   select @id_endereco_dest = id_endereco
	   from endereco where endereco_completo = @endereco_flowrack

	   select @cod_produto = cod_produto
	   from produto_relacionado
	   where cod_produto_rel = @cod_produto_rel
	  
	   
	   if  @id_endereco_ori is null
	    begin
		     insert into #log
			 values (@endereco_fixo,@endereco_flowrack , @cod_produto, 'ENDERECO FIXO INEXISTENTE')

		END

	   if @id_endereco_dest is null
	    begin
		     insert into #log
			 values (@endereco_fixo,@endereco_flowrack , @cod_produto, 'ENDERECO FLOWRACK INEXISTENTE')

		END


	 

	  if @id_endereco_ori is not null and @id_endereco_dest is not null 
	  begin 
	  if not exists (select * from produto_endereco
	                     where cod_produto = @cod_produto
						 and id_endereco = @id_endereco_dest) 	

						 begin
						 
						    insert produto_endereco (cod_produto, id_endereco, cod_operacao_logistica, quantidade,qtd_max_itens,ruptura)
							values (@cod_produto, @id_endereco_dest, 1 , 0, 0 ,0 )

						END

	
	 if not exists (select * from param_endereco_distancia
	                     where id_endereco_origem = @id_endereco_ori
						 and id_endereco_destino = @id_endereco_dest) 	
						

						 begin
						 
						    insert param_endereco_distancia (id_endereco_origem, id_endereco_destino, distancia,
						    caixas,quantidade_cx_reabastecimento)
							values (@id_endereco_ori, @id_endereco_dest, 1 , 0, 0)

						END
	 end
	 	
	 delete from #Fixo
	 where id = @id

	 END

select * from #Fixo
select * from #log
select * from param_endereco_distancia  



rollback tran a





--commit tran aa

