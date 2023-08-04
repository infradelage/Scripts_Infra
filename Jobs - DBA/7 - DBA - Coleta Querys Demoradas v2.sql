--------------------------------------------------------------------------------------------------------------------------------
--	Criação da tabela de Tb_Traces.
--------------------------------------------------------------------------------------------------------------------------------
use dba
go

if OBJECT_ID('Tb_Traces') is not null
	drop table Tb_Traces
	
CREATE TABLE [dbo].[Tb_Traces](
	[TextData] varchar(max) NULL,
	[NTUserName] [varchar](128) NULL,
	[HostName] [varchar](128) NULL,
	[ApplicationName] [varchar](128) NULL,
	[LoginName] [varchar](128) NULL,
	[SPID] [int] NULL,
	[Duration] [numeric](15, 2) NULL,
	[StartTime] [datetime] NULL,
	[EndTime] [datetime] NULL,
	[ServerName] [varchar](128) NULL,
	[Reads] [int] NULL,
	[Writes] [int] NULL,
	[CPU] [int] NULL,
	[DataBaseName] [varchar](128) NULL,
	[RowCounts] [int] NULL,
	[SessionLoginName] [varchar](128) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]        

GO

--------------------------------------------------------------------------------------------------------------------------------
-- Criando a procedure que irá criar o Trace.
--------------------------------------------------------------------------------------------------------------------------------
use dba

if OBJECT_ID('Proc_Create_Trace') is not null
	drop procedure Proc_Create_Trace
GO

CREATE  Procedure [dbo].[Proc_Create_Trace]
AS

/*******************************************************************************************************************************
-- Created by: SQL Server Profiler 2005
-- Date: 09/09/2008  14:44:14
*******************************************************************************************************************************/
-- Create a Queue.
declare @rc int
declare @TraceID int
declare @maxfilesize bigint
set @maxfilesize = 50

/*******************************************************************************************************************************
-- ATENÇÃO!!!
-- Alterar esse Caminho, caso necessário !!!
*******************************************************************************************************************************/
exec @rc = sp_trace_create @TraceID output, 0, N'C:\dba\duracao', @maxfilesize, NULL 

if (@rc != 0) goto error

-- Client side File and Table cannot be scripted.

-- Set the events.
declare @on bit
set @on = 1

-- 10 RPC:Completed Ocorre quando uma RPC (chamada de procedimento remoto) é concluída. 
exec sp_trace_setevent @TraceID, 10, 1, @on		-- TextData: Valor de texto dependente da classe de evento capturada no rastreamento.
exec sp_trace_setevent @TraceID, 10, 6, @on		-- NTUserName: Nome de usuário do Microsoft Windows. 
exec sp_trace_setevent @TraceID, 10, 8, @on		-- HostName: Nome do computador cliente que originou a solicitação. 
exec sp_trace_setevent @TraceID, 10, 10, @on	-- ApplicationName: Nome do aplicativo cliente que criou a conexão com uma instância do SQL Server.
												-- Essa coluna é populada com os valores passados pelo aplicativo e não com o nome exibido do programa.
exec sp_trace_setevent @TraceID, 10, 11, @on	-- LoginName: Nome de logon do cliente no SQL Server.
exec sp_trace_setevent @TraceID, 10, 12, @on	-- SPID: ID de processo de servidor atribuída pelo SQL Server ao processo associado ao cliente.
exec sp_trace_setevent @TraceID, 10, 13, @on	-- Duration: Tempo decorrido (em milhões de segundos) utilizado pelo evento. 
												-- Esta coluna de dados não é populada pelo evento Hash Warning.
exec sp_trace_setevent @TraceID, 10, 14, @on	-- StartTime: Horário de início do evento, quando disponível.
exec sp_trace_setevent @TraceID, 10, 15, @on	-- EndTime: Horário em que o evento foi encerrado. Esta coluna não é populada para classes de evento
												-- iniciais, como SQL:BatchStarting ou SP:Starting. Também não é populada pelo evento Hash Warning.
exec sp_trace_setevent @TraceID, 10, 16, @on	-- Reads: Número de leituras lógicas do disco executadas pelo servidor em nome do evento. 
												-- Esta coluna não é populada pelo evento Lock:Released.
exec sp_trace_setevent @TraceID, 10, 17, @on	-- Writes: Número de gravações no disco físico executadas pelo servidor em nome do evento.
exec sp_trace_setevent @TraceID, 10, 18, @on	-- CPU: Tempo da CPU (em milissegundos) usado pelo evento.
exec sp_trace_setevent @TraceID, 10, 19, @on	-- CPU: Tempo da CPU (em milissegundos) usado pelo evento.
exec sp_trace_setevent @TraceID, 10, 26, @on	-- ServerName: Nome da instância do SQL Server, servername ou servername\instancename, 
												-- que está sendo rastreada
exec sp_trace_setevent @TraceID, 10, 35, @on	-- DatabaseName: Nome do banco de dados especificado na instrução USE banco de dados.
exec sp_trace_setevent @TraceID, 10, 40, @on	-- DBUserName: Nome de usuário do banco de dados do SQL Server do cliente.
exec sp_trace_setevent @TraceID, 10, 48, @on	-- RowCounts: Número de linhas no lote.
exec sp_trace_setevent @TraceID, 10, 64, @on	-- SessionLoginName: O nome de logon do usuário que originou a sessão. Por exemplo, se você 
												-- se conectar ao SQL Server usando Login1 e executar uma instrução como Login2, SessionLoginName
												-- irá exibir Login1, enquanto que LoginName exibirá Login2. Esta coluna de dados exibe logons
												-- tanto do SQL Server, quanto do Windows.

exec sp_trace_setevent @TraceID, 12, 1,  @on	-- TextData: Valor de texto dependente da classe de evento capturada no rastreamento.
exec sp_trace_setevent @TraceID, 12, 6,  @on	-- NTUserName: Nome de usuário do Microsoft Windows. 
exec sp_trace_setevent @TraceID, 12, 8,  @on	-- HostName: Nome do computador cliente que originou a solicitação. 
exec sp_trace_setevent @TraceID, 12, 10, @on	-- ApplicationName: Nome do aplicativo cliente que criou a conexão com uma instância do SQL Server. 
												-- Essa coluna é populada com os valores passados pelo aplicativo e não com o nome exibido do programa.
exec sp_trace_setevent @TraceID, 12, 11, @on	-- LoginName: Nome de logon do cliente no SQL Server.
exec sp_trace_setevent @TraceID, 12, 12, @on	-- SPID: ID de processo de servidor atribuída pelo SQL Server ao processo associado ao cliente.
exec sp_trace_setevent @TraceID, 12, 13, @on	-- Duration: Tempo decorrido (em milhões de segundos) utilizado pelo evento. Esta coluna de dados não
												-- é populada pelo evento Hash Warning.
exec sp_trace_setevent @TraceID, 12, 14, @on	-- StartTime: Horário de início do evento, quando disponível.
exec sp_trace_setevent @TraceID, 12, 15, @on	-- EndTime: Horário em que o evento foi encerrado. Esta coluna não é populada para classes de evento
												-- iniciais, como SQL:BatchStarting ou SP:Starting. Também não é populada pelo evento Hash Warning.
exec sp_trace_setevent @TraceID, 12, 16, @on	-- Reads: Número de leituras lógicas do disco executadas pelo servidor em nome do evento. 
												-- Esta coluna não é populada pelo evento Lock:Released.
exec sp_trace_setevent @TraceID, 12, 17, @on	-- Writes: Número de gravações no disco físico executadas pelo servidor em nome do evento.
exec sp_trace_setevent @TraceID, 12, 18, @on	-- CPU: Tempo da CPU (em milissegundos) usado pelo evento.
exec sp_trace_setevent @TraceID, 12, 26, @on	-- ServerName: Nome da instância do SQL Server, servername ou servername\instancename, 
												-- que está sendo rastreada
exec sp_trace_setevent @TraceID, 12, 35, @on	-- DatabaseName: Nome do banco de dados especificado na instrução USE banco de dados.
exec sp_trace_setevent @TraceID, 12, 40, @on	-- DBUserName: Nome de usuário do banco de dados do SQL Server do cliente.
exec sp_trace_setevent @TraceID, 12, 48, @on	-- RowCounts: Número de linhas no lote.
exec sp_trace_setevent @TraceID, 12, 64, @on	-- SessionLoginName: O nome de logon do usuário que originou a sessão. Por exemplo, se você se
												-- conectar ao SQL Server usando Login1 e executar uma instrução como Login2, SessionLoginName
												-- irá exibir Login1, enquanto que LoginName exibirá Login2. Esta coluna de dados exibe logons
												-- tanto do SQL Server, quanto do Windows.

-- Set the Filters.
declare @intfilter int
declare @bigintfilter bigint

exec sp_trace_setfilter @TraceID, 10, 0, 7, N'SQL Server Profiler - 4d8f4bca-f08c-4755-b90c-6ec17a6f1275'
exec sp_trace_setfilter @TraceID, 10, 0, 7, N'DatabaseMail90%'

/*******************************************************************************************************************************
-- Configura o tempo mínimo para as queries demoradas em 3 segundos.
*******************************************************************************************************************************/
set @bigintfilter = 3000000 

exec sp_trace_setfilter @TraceID, 13, 0, 4, @bigintfilter

set @bigintfilter = null
exec sp_trace_setfilter @TraceID, 13, 0, 1, @bigintfilter

exec sp_trace_setfilter @TraceID, 1, 0, 7, N'NO STATS%'

exec sp_trace_setfilter @TraceID, 1, 0, 7, N'NULL%'

-- Set the trace status to start.
exec sp_trace_setstatus @TraceID, 1

-- Display trace id for future references.
select TraceID = @TraceID

goto finish

error: 
	select ErrorCode = @rc

finish: 
go

USE [msdb]
GO

/****** Object:  Job [DBA - Coleta Querys Demoradas]    Script Date: 10/26/2018 10:44:06 AM ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [Database Maintenance]    Script Date: 10/26/2018 10:44:06 AM ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'Database Maintenance' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'Database Maintenance'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'DBA - Coleta Querys Demoradas', 
		@enabled=1, 
		@notify_level_eventlog=0, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'No description available.', 
		@category_name=N'Database Maintenance', 
		@owner_login_name=N'sa', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [DBA - Desabilita o Trace]    Script Date: 10/26/2018 10:44:06 AM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'DBA - Desabilita o Trace', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=3, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'
declare @Traceid int;

set @Traceid = 0;

select @Traceid = traceid
from fn_trace_getinfo (null)
where cast(value as varchar(100)) like ''%Duracao%'';

if @Traceid <> 0
begin
exec sp_trace_setstatus  @Traceid ,  @status = 0
exec sp_trace_setstatus  @Traceid ,  @status = 2
end



', 
		@database_name=N'master', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Insere registros Tb_Traces]    Script Date: 10/26/2018 10:44:06 AM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Insere registros Tb_Traces', 
		@step_id=2, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=3, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'Insert Into dba.dbo.Tb_Traces(TextData, NTUserName, HostName, ApplicationName, LoginName, SPID, Duration, StartTime, 
EndTime,  Reads, Writes, CPU, ServerName,DataBaseName, RowCounts, SessionLoginName)

Select TextData,NTUserName, HostName, ApplicationName, LoginName, SPID, 
cast(Duration /1000/1000.00 as numeric(15,2)) Duration, StartTime,
EndTime, Reads,Writes, CPU, ServerName, DataBaseName, RowCounts, SessionLoginName
FROM :: fn_trace_gettable(''C:\dba\Duracao.trc'', default)
where Duration is not null
	and rowcounts < 900000000
	and TextData not like ''%exec stpCarga_ContadoresSQL%''
	and TextData not like ''%stpBackup_Log_Todas_Databases%''
	and TextData not like ''%stpCarga_Historico_Waits_Stats%''
	and reads < 900000000', 
		@database_name=N'DBA', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Exclui o arquivo de trace antigo]    Script Date: 10/26/2018 10:44:06 AM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Exclui o arquivo de trace antigo', 
		@step_id=3, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=3, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'CmdExec', 
		@command=N'Del "C:\dba\Duracao.trc" /Q', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Cria o Trace]    Script Date: 10/26/2018 10:44:06 AM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Cria o Trace', 
		@step_id=4, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'exec dba.dbo.Proc_Create_Trace', 
		@database_name=N'DBA', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'DBA - Tb_Traces Banco de Dados', 
		@enabled=1, 
		@freq_type=4, 
		@freq_interval=1, 
		@freq_subday_type=4, 
		@freq_subday_interval=5, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=0, 
		@active_start_date=20181026, 
		@active_end_date=99991231, 
		@active_start_time=100, 
		@active_end_time=235959, 
		@schedule_uid=N'95dd857d-0d90-4de7-9fa0-6bb041bc0176'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO

-- Rodar o script pela primeira vez
USE dba

GO

EXEC dba.[dbo].[Proc_Create_Trace]