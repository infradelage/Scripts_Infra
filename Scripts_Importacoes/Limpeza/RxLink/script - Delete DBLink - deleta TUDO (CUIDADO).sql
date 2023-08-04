USE DBLink

--DELETA TUDO ATENCAO!!--
EXEC sp_MSForEachTable 'DISABLE TRIGGER ALL ON ?'
GO
EXEC sp_MSForEachTable 'ALTER TABLE ? NOCHECK CONSTRAINT ALL'
GO
EXEC sp_MSForEachTable 'DELETE FROM ?'
GO
EXEC sp_MSForEachTable 'ALTER TABLE ? CHECK CONSTRAINT ALL'
GO
EXEC sp_MSForEachTable 'ENABLE TRIGGER ALL ON ?'
GO
--FIM DELETE


---ACERTA OS IDENTITYs---
declare @tabelas table (idx int identity(1,1), tabela varchar(100))             
insert into @tabelas (tabela)                                    
select distinct t.name
from
    sys.tables t
inner join sys.columns c on c.object_id = t.object_id
where
    t.is_ms_shipped = 0   
    and c.is_identity = 1
order by
    name

declare @inicio int, @fim int             
declare @command varchar(1000)
declare @ident_aux int = 1
             
select @inicio = 1, @fim = max(idx) from @tabelas             

while @inicio <= @fim             
begin       
    select
        @command = 'dbcc checkident ( ' + tabela + ', ' + 'reseed' + ', ' + cast( @ident_aux as varchar(10) ) + ' ) '
    from
        @tabelas
    where
        idx = @inicio             
   
    EXEC( @command )             
    --print( @command )             
    --print('GO')
   
    set @inicio = @inicio + 1  
end
--FIM IDENTITYs
