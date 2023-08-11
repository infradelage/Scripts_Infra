--0º utilize o reportsync para duplicar os relatorios desejados

--1º Passo deletrar tudo o que não for utilizado no clone 
--delete FROM DataSource where ItemID in (select ItemID FROM [ReportServer].[dbo].[Catalog]
--where [Path] like '%Tranf%'
--and [Name] not like '%_MA%'
--and Type <> 1)

--Delete FROM [ReportServer].[dbo].[Catalog]
--where [Path] like '%Tranf%'
--and [Name] not like '%_MA%'
--and Type <> 1

--2º passo alterar o PATH e o NAME dos relatorios

select * from [Catalog] where [Path] like '%Estoque_HML%' and Type = 1


UPDATE [Catalog] SET PATH = path + '_HML' where [Path] like '%Import%' and Type = 1 and ItemID NOT IN ('1B727DFB-4F4A-41DF-89B6-614931FA6159')

UPDATE [Catalog] SET NAME = NAME + '_HML' where [Path] like '%Import%' and Type = 1 and ItemID NOT IN ('1B727DFB-4F4A-41DF-89B6-614931FA6159')

--3º Setar a DataSource
--3.1 alterar um relatorios para a datasource desejada e depois
select Link from DataSource where ItemID = '85F8B6F7-ECC9-4D38-B06A-03F701D3A78E'

--3.2 Fazer o update para vincular o link com o link descoberto acima para todos os relatorios
update DataSource set Link = '10EDA724-84E8-4F8B-BA3A-318A3B84C0EF' where ItemID in (select ItemID FROM [ReportServer].[dbo].[Catalog]
where [Path] like '%Import%'
AND Type <> 1)
--and [Name] like '%_HML%')