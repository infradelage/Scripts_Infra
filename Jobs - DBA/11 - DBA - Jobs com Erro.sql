-- Tabela

USE [DBA]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[TbAlertaJob](
	[Id_Alerta] [int] NULL,
	[Nome_Job] [sysname] NOT NULL,
	[Nome_Passo] [sysname] NOT NULL,
	[Data] [int] NULL,
	[Hora] [int] NULL,
	[Severidade] [int] NULL,
	[Mensagem] [nvarchar](4000) NULL,
	[Servidor] [sysname] NOT NULL
) ON [PRIMARY]

GO

use dba
go
Create Table Tb_Excecao_Job (
Cod_Job int not null,
Des_Job varchar(100) null);
go
Alter Table Tb_Excecao_Job add constraint PK_Tb_Excecao_Job primary key clustered (Cod_Job);
go

Insert into Tb_Excecao_Job values 
(1,'DBA - Status Serviços');
GO

-- PROCEDURE

USE [DBA]
GO
/****** Object:  StoredProcedure [dbo].[Proc_Alerta_Jobs_com_Erro]    Script Date: 11/02/2020 20:34:27 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create Proc [dbo].[Proc_Alerta_Jobs_com_Erro]
as
DECLARE @DataReferencia DATETIME,
        @Ano VARCHAR(4),
        @Mes VARCHAR(2),
        @MesPre VARCHAR(2),
        @Dia VARCHAR(2),
        @DiaPre VARCHAR(2),
        @DataFinal INT;

Declare @AlertaJobRaizHeader VARCHAR(MAX),
        @HTML VARCHAR(MAX),
        @Importance AS VARCHAR(6),
		@Subject VARCHAR(500),
		@EmailBody VARCHAR(MAX),
		@EmptyBodyEmail VARCHAR(MAX);

declare @emails varchar(max);
select  @emails = dba.dbo.[fncRetornaEmails](1); -- abrir chamado
		
CREATE TABLE #Alerta_Jobs(
	[instance_id] [int] NOT NULL,
	[name] [sysname] NOT NULL,
	[step_id] [int] NOT NULL,
	[step_name] [sysname] NOT NULL,
	[run_date] [int] NOT NULL,
	[run_time] [int] NOT NULL,
	[sql_severity] [int] NOT NULL,
	[message] [nvarchar](4000) NULL,
	[SERVER] [sysname] NOT NULL
) 

CREATE TABLE ##Alerta_Jobs2(
	[Nome Job] [sysname] NOT NULL,
	[Nome Passo] [sysname] NOT NULL,
	[Data Execucao] varchar(10)  NULL,
	[Hora Execucao] varchar(8)  NULL,
	[Erro] [nvarchar](4000) NULL,
	[Servidor] [sysname] NOT NULL
) 

SET @DataReferencia = DATEADD(dd, - 1, GETDATE()) -- 1 dia atras   
SET @Ano            = DATEPART(yyyy, @DataReferencia)
SET @MesPre         = CONVERT(VARCHAR(2), DATEPART(mm, @DataReferencia))
SET @Mes            = RIGHT(CONVERT(VARCHAR, (@MesPre + 1000000000)), 2)
SET @DiaPre         = CONVERT(VARCHAR(2), DATEPART(dd, @DataReferencia))
SET @Dia            = RIGHT(CONVERT(VARCHAR, (@DiaPre + 1000000000)), 2)
SET @DataFinal      = CAST(@Ano + @Mes + @Dia AS INT)

Insert into #Alerta_Jobs
    SELECT h.instance_id,
	       j.[name],
	       --s.step_name,
	       h.step_id,
	       h.step_name,
	       h.run_date,
	       h.run_time,
	       h.sql_severity,
	       h.message,
	       h.SERVER
	  FROM msdb.dbo.sysjobhistory h
INNER JOIN msdb.dbo.sysjobs j ON h.job_id = j.job_id
INNER JOIN msdb.dbo.sysjobsteps s ON j.job_id = s.job_id
       AND h.step_id = s.step_id
     WHERE h.run_status = 0 -- Failure  
       AND h.run_date > @DataFinal
	   and j.name collate SQL_Latin1_General_CP1_CI_AS not in (select Des_Job collate SQL_Latin1_General_CP1_CI_AS  from dba.dbo.Tb_Excecao_Job)
  ORDER BY h.instance_id DESC;

Delete #Alerta_Jobs
 Where  instance_id in (select Id_Alerta from DBA.[dbo].[TbAlertaJob]);

Insert into dba.dbo.TbAlertaJob (Id_Alerta, Nome_Job, Nome_Passo, Data, Hora, Severidade, Mensagem, Servidor)
Select instance_id, name, step_name, run_date, run_time, sql_severity, message, SERVER
  from #Alerta_Jobs
 
  
-- essa segunda tabela formatada sera usada para gerar o html
Insert into ##Alerta_Jobs2 ([Nome Job], [Nome Passo], [Data Execucao], [Hora Execucao], [Erro], [Servidor] )
Select a.name, 
       a.step_name, 
       right(a.run_date,2) + '/' + SUBSTRING(convert(varchar(10),a.run_date),5,2) + '/' + left(a.run_date,4),
	   case LEN(a.run_time)
	     when 5 then left(a.run_time,1) + ':' + substring(convert(varchar(10),a.run_time),2,2) + ':' + right(a.run_time,2)
		 else left(a.run_time,2) + ':' + substring(convert(varchar(10),a.run_time),3,2) + ':' + right(a.run_time,2)
	   End, 
	   a.message, a.SERVER
  from #Alerta_Jobs a
   
EXEC dba.dbo.Proc_Exporta_Tabela_HTML
     @Ds_Tabela = '##Alerta_Jobs2', 
     @Ds_Saida = @HTML OUT 

if exists (select 1 from #Alerta_Jobs)
begin
/*******************************************************************************************************************************
--	CRIA O EMAIL - ALERTA
*******************************************************************************************************************************/							
			
--------------------------------------------------------------------------------------------------------------------------------
--	ALERTA - HEADER - Job
--------------------------------------------------------------------------------------------------------------------------------
SET @AlertaJobRaizHeader = '<font color=black bold=true size=5>'			            
SET @AlertaJobRaizHeader = @AlertaJobRaizHeader + '<BR /> Atenção: Jobs com Erro desde a última checagem <BR />'
SET @AlertaJobRaizHeader = @AlertaJobRaizHeader + '</font>'

--------------------------------------------------------------------------------------------------------------------------------
--	ALERTA - BODY - RAIZ LOCK
--------------------------------------------------------------------------------------------------------------------------------

--------------------------------------------------------------------------------------------------------------------------------
-- Insere um Espaço em Branco no EMAIL
--------------------------------------------------------------------------------------------------------------------------------
SET @EmptyBodyEmail =	''
SET @EmptyBodyEmail =
		'<table cellpadding="5" cellspacing="5" border="0">' +
			'<tr>
				<th width="500">               </th>
			</tr>'
			+ REPLACE( REPLACE( ISNULL(@EmptyBodyEmail,''), '&lt;', '<'), '&gt;', '>')
		+ '</table>'


/*******************************************************************************************************************************
<			--	Seta as Variáveis do EMAIL
<*******************************************************************************************************************************/			              
SELECT	@Importance =	'High',
		@Subject =		'ALERTA: Existe(m) Jobs com Falha no Servidor: ' + @@SERVERNAME,
		@EmailBody =	@AlertaJobRaizHeader + @EmptyBodyEmail + @HTML 
				
/*******************************************************************************************************************************
--	ENVIA O EMAIL - ALERTA
*******************************************************************************************************************************/	
EXEC [msdb].[dbo].[sp_send_dbmail]
		@profile_name = 'Envia e-mail',
		@recipients =	@emails, --'alerta@jpconsultoria.net.br',
		@subject =		@Subject,
		@body =			@EmailBody,
		@body_format =	'HTML',
		@importance =	@Importance
End
drop table #Alerta_Jobs, ##Alerta_Jobs2
go
--- Job

USE [msdb]
GO

/****** Object:  Job [DBA - Jobs com Erro]    Script Date: 10/18/2018 10:46:31 ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [[Uncategorized (Local)]]]    Script Date: 10/18/2018 10:46:31 ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'DBA - Jobs com Erro', 
		@enabled=1, 
		@notify_level_eventlog=0, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'Monitora jobs com Erro e envia Email com os detalhes do problema.', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'sa', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Passo Verifica Jobs com Erros]    Script Date: 10/18/2018 10:46:32 ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Passo Verifica Jobs com Erros', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'Execute dba.dbo.Proc_Alerta_Jobs_com_Erro;', 
		@database_name=N'DBA', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'Agenda Agenda Jobs com Erros', 
		@enabled=1, 
		@freq_type=4, 
		@freq_interval=1, 
		@freq_subday_type=4, 
		@freq_subday_interval=15, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=0, 
		@active_start_date=20170502, 
		@active_end_date=99991231, 
		@active_start_time=0, 
		@active_end_time=235959, 
		@schedule_uid=N'a23de57f-de4b-405e-ab36-2a14f0075a38'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:

GO




