-- banco de dados
IF NOT EXISTS (
	select name
	from sys.databases 
	where name = 'DBA'
)
BEGIN
	CREATE DATABASE DBA;
END
GO
ALTER DATABASE DBA SET RECOVERY SIMPLE;
go

-- Operador

USE [msdb]

GO

IF NOT EXISTS (
	select * 
	from msdb.dbo.sysoperators
	where name = 'Operador_BD'
)
BEGIN
	EXEC [msdb].[dbo].[sp_add_operator]
		@name = N'Operador_BD',
		@enabled = 1,
		@pager_days = 0,
		@email_address = N'E-chamado@jpconsultoria.net.br'	-- Altere este campo com o e-mail que irá receber os alertas. Para colocar mais destinatarios, basta separar os e-mails com ponto e vírgula ";"
END

GO

--- Tabelas


USE [DBA]
GO

/****** Object:  Table [dbo].[Tb_Alertas]    Script Date: 10/18/2018 10:35:44 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [dbo].[Tb_Alertas](
	[Id_Alerta] [int] IDENTITY(1,1) NOT NULL,
	[Nm_Alerta] [varchar](200) NULL,
	[Ds_Mensagem] [varchar](2000) NULL,
	[Fl_Tipo] [tinyint] NULL,
	[Dt_Alerta] [datetime] NULL,
PRIMARY KEY CLUSTERED 
(
	[Id_Alerta] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO

ALTER TABLE [dbo].[Tb_Alertas] ADD  DEFAULT (getdate()) FOR [Dt_Alerta]
GO

use dba
go
Create Table dba.dbo.Tb_Emails
(
ID_Email smallint identity(1,1),
E_Mail  varchar(100),
Data_Limite_Recebimento datetime,
FlagChamado bit,
FlagCheckList bit);

alter table dba.dbo.Tb_Emails add constraint PK_Tb_Emails primary key clustered(ID_Email);

insert into Tb_Emails(E_Mail, Data_Limite_Recebimento, FlagChamado, FlagCheckList)
values
('alerta@jpconsultoria.net.br', getdate()+30,1,1), -- este tipo de e-mail abre chamado e recebe checklist
('chamado@jpconsultoria.net.br', getdate()+30,0,0); -- este tipo de e-mail nao abre chamado e nao recebe checklist

--('cliente@cliente.com.br', '2050-12-31',1,0) -- este tipo de e-mail nao abre chamado.
go

if object_id('Tb_BaseDados') is not null
	drop table Tb_BaseDados;

if object_id('Tb_Tabelas') is not null
	drop table Tb_Tabelas;

if object_id('Tb_Servidor') is not null
	drop table Tb_Servidor;
	
CREATE TABLE [dbo].[Tb_BaseDados] (
	[Id_BaseDados] [int] IDENTITY(1,1) NOT NULL,
	[Nm_Database] [varchar](500) NULL,
	CONSTRAINT [PK_BaseDados] PRIMARY KEY CLUSTERED (Id_BaseDados)
) ON [PRIMARY];

CREATE TABLE [dbo].[Tb_Tabelas] (
	[Id_Tabela] [int] IDENTITY(1,1) NOT NULL,
	[Nm_Tabela] [varchar](1000) NULL,
	CONSTRAINT [PK_Tabela] PRIMARY KEY CLUSTERED (
		[Id_Tabela] ASC
	) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY];

CREATE TABLE [dbo].[Tb_Servidor] (
	[Id_Servidor] [int] IDENTITY(1,1) NOT NULL,
	[Nm_Servidor] [varchar](100) NOT NULL,
	CONSTRAINT [PK_Servidor] PRIMARY KEY CLUSTERED (
		[Id_Servidor] ASC
	) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY];

GO	

--- Funções

USE [DBA]
GO
/****** Object:  UserDefinedFunction [dbo].[fncRetornaEmails]    Script Date: 10/18/2018 10:30:40 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
Create Function [dbo].[fncRetornaEmails] 
(@FlagChamado bit) --0 nao trazer email que abre chamado
returns varchar(max)
as
Begin
   DECLARE @Emails VARCHAR(MAX);
   if @FlagChamado = 0
   
   SELECT @Emails = COALESCE(@Emails + '; ', '') + E_Mail
     FROM dba.dbo.Tb_Emails
    where Data_Limite_Recebimento > getdate()
    and FlagChamado <> @FlagChamado;
   else 
   SELECT @Emails = COALESCE(@Emails + '; ', '') + E_Mail
     FROM dba.dbo.Tb_Emails
    where Data_Limite_Recebimento > getdate();
          

   Return @Emails
End
GO
USE [DBA]
GO
/****** Object:  UserDefinedFunction [dbo].[fncRetornaEmails]    Script Date: 10/29/2018 11:50:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create Function [dbo].[fncRetornaEmailsCheckList] ()
returns varchar(max)
as
Begin
   DECLARE @Emails VARCHAR(MAX);
   SELECT @Emails = COALESCE(@Emails + '; ', '') + E_Mail
     FROM dba.dbo.Tb_Emails
    where Data_Limite_Recebimento > getdate()
    and FlagCheckList = 1;

   Return @Emails
End
GO

-- Procedures

USE [DBA]
GO
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[Proc_Exporta_Tabela_HTML]
    @Ds_Tabela [varchar](max),
    @Fl_Aplica_Estilo_Padrao BIT = 1,
    @Ds_Saida VARCHAR(MAX) OUTPUT
WITH EXECUTE AS CALLER
AS
BEGIN
   
    SET NOCOUNT ON
    DECLARE
        @query NVARCHAR(MAX),
        @Database sysname,
        @Nome_Tabela sysname

    
    
    IF (LEFT(@Ds_Tabela, 1) = '#')
    BEGIN
        SET @Database = 'tempdb.'
        SET @Nome_Tabela = @Ds_Tabela
    END
    ELSE BEGIN
        SET @Database = LEFT(@Ds_Tabela, CHARINDEX('.', @Ds_Tabela))
        SET @Nome_Tabela = SUBSTRING(@Ds_Tabela, LEN(@Ds_Tabela) - CHARINDEX('.', REVERSE(@Ds_Tabela)) + 2, LEN(@Ds_Tabela))
    END
    
    SET @query = '
    SELECT ORDINAL_POSITION, COLUMN_NAME, DATA_TYPE, CHARACTER_MAXIMUM_LENGTH, NUMERIC_PRECISION, NUMERIC_SCALE
    FROM ' + @Database + 'INFORMATION_SCHEMA.COLUMNS 
    WHERE TABLE_NAME = ''' + @Nome_Tabela + '''
    ORDER BY ORDINAL_POSITION'
    
    IF (OBJECT_ID('tempdb..#Colunas') IS NOT NULL) DROP TABLE #Colunas
    CREATE TABLE #Colunas (
        ORDINAL_POSITION int, 
        COLUMN_NAME sysname, 
        DATA_TYPE nvarchar(128), 
        CHARACTER_MAXIMUM_LENGTH int,
        NUMERIC_PRECISION tinyint, 
        NUMERIC_SCALE int
    )

    INSERT INTO #Colunas
    EXEC(@query)

    IF (@Fl_Aplica_Estilo_Padrao = 1)
    BEGIN
    
    SET @Ds_Saida = '<html>
<head>
    <title>Titulo</title>
    <style type="text/css">
        table { padding:10; border-spacing: 2; border-collapse: collapse; }
        thead { background: #851089; border: 4px solid #ddd; }
		tfoot { background: ##FFFFFF; border: 4px;  font-size: 90%; align: right; }
        th { padding: 10px; font-weight: bold; border: 2px solid #000; color: #fff; }
        tr { padding: 0; }
        td { padding: 5px; border: 2px solid #cacaca; margin:0; }
    </style>
</head>'
    
    END
    
    SET @Ds_Saida = ISNULL(@Ds_Saida, '') + '
<table>
    <thead>
        <tr>'

    -- Cabeçalho da tabela
    DECLARE 
        @contadorColuna INT = 1, 
        @totalColunas INT = (SELECT COUNT(*) FROM #Colunas), 
        @nomeColuna sysname,
        @tipoColuna sysname

    WHILE(@contadorColuna <= @totalColunas)
    BEGIN

        SELECT @nomeColuna = COLUMN_NAME
        FROM #Colunas
        WHERE ORDINAL_POSITION = @contadorColuna

        SET @Ds_Saida = ISNULL(@Ds_Saida, '') + '
            <th>' + @nomeColuna + '</th>'

        SET @contadorColuna = @contadorColuna + 1
    END
    SET @Ds_Saida = ISNULL(@Ds_Saida, '') + '
        </tr>
    </thead>
    <tbody>'

    -- Conteúdo da tabela

    DECLARE @saida VARCHAR(MAX)

    SET @query = '
SELECT @saida = (
    SELECT '
    SET @contadorColuna = 1
    WHILE(@contadorColuna <= @totalColunas)
    BEGIN
        SELECT 
            @nomeColuna = COLUMN_NAME,
            @tipoColuna = DATA_TYPE
        FROM 
            #Colunas
        WHERE 
            ORDINAL_POSITION = @contadorColuna
			
        IF (@tipoColuna IN ('int', 'bigint', 'float', 'numeric', 'decimal', 'bit', 'tinyint', 'smallint', 'integer'))
        BEGIN
            SET @query = @query + '
    ISNULL(CAST([' + @nomeColuna + '] AS VARCHAR(MAX)), '''') AS [td]'
        END
        ELSE BEGIN
            SET @query = @query + '
    ISNULL([' + @nomeColuna + '], '''') AS [td]'
        END
        IF (@contadorColuna < @totalColunas)
            SET @query = @query + ','
        SET @contadorColuna = @contadorColuna + 1
    END
    SET @query = @query + '
FROM ' + @Ds_Tabela + '
FOR XML RAW(''tr''), Elements
)'
    EXEC tempdb.sys.sp_executesql
        @query,
        N'@saida NVARCHAR(MAX) OUTPUT',
        @saida OUTPUT
    -- Identação
    SET @saida = REPLACE(@saida, '<tr>', '
        <tr>')
    SET @saida = REPLACE(@saida, '<td>', '
            <td>')
    SET @saida = REPLACE(@saida, '</tr>', '
        </tr>')
    SET @Ds_Saida = ISNULL(@Ds_Saida, '') + @saida
    SET @Ds_Saida = ISNULL(@Ds_Saida, '') + '
    </tbody>
	<tfoot><tr><td colspan=' + convert(varchar(10),@totalColunas) + '>JPS Consultoria e Treinamentos</td></tr></tfoot>

</table>'
END

GO
