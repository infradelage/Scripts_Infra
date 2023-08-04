-- Tabelas
use dba

--------------------------------------------------------------------------------------------------------------------------------
-- Criação das tabelas dos Wait Stats.
--------------------------------------------------------------------------------------------------------------------------------
if object_id('Tb_Historico_Waits_Stats') is not null
	drop table Tb_Historico_Waits_Stats
	
GO

CREATE TABLE [dbo].[Tb_Historico_Waits_Stats](
	[Id_Historico_Waits_Stats] [int] IDENTITY(1,1) NOT NULL,
	[Dt_Referencia] [datetime] NULL default(getdate()),
	[WaitType] [varchar](60) NOT NULL,
	[Wait_S] [decimal](14, 2) NULL,
	[Resource_S] [decimal](14, 2) NULL,
	[Signal_S] [decimal](14, 2) NULL,
	[WaitCount] [bigint]  NULL,
	[Percentage] [decimal](4, 2) NULL,
	[Id_Coleta] int
) ON [PRIMARY]

GO

--------------------------------------------------------------------------------------------------------------------------------
-- Criação da procedure que realiza a carga dos Wait Stats.
--------------------------------------------------------------------------------------------------------------------------------
if object_id('Proc_Carga_Historico_Waits_Stats') is not null
	drop procedure Proc_Carga_Historico_Waits_Stats
	
GO

CREATE PROCEDURE [dbo].[Proc_Carga_Historico_Waits_Stats]
AS
BEGIN
	-- Seleciona o último wait por WaitType.
	declare @Waits_Before table (WaitType varchar(60), WaitCount bigint, Id_Coleta int)
	declare @Id_Coleta int

	-- Seleciona o Id_Coleta da última coleta de dados.
	select @Id_Coleta = Id_Coleta
	from Tb_Historico_Waits_Stats A
		join	(
					select max(Id_Historico_Waits_Stats) AS Id_Historico_Waits_Stats
					from Tb_Historico_Waits_Stats
				) B on A.Id_Historico_Waits_Stats = B.Id_Historico_Waits_Stats

	insert into @Waits_Before
	select A.WaitType, A.WaitCount, A.Id_Coleta
	from Tb_Historico_Waits_Stats A
		join	(
					select [WaitType], max(Id_Historico_Waits_Stats) Id_Historico_Waits_Stats
					from Tb_Historico_Waits_Stats
					group by [WaitType] 
				) B on A.Id_Historico_Waits_Stats = B.Id_Historico_Waits_Stats
			
	;WITH Waits AS
		(
			SELECT
				wait_type,
				wait_time_ms / 1000.0 AS WaitS,
				(wait_time_ms - signal_wait_time_ms) / 1000.0 AS ResourceS,
				signal_wait_time_ms / 1000.0 AS SignalS,
				waiting_tasks_count AS WaitCount,
				100.0 * wait_time_ms / SUM (wait_time_ms) OVER() AS Percentage,
				ROW_NUMBER() OVER(ORDER BY wait_time_ms DESC) AS RowNum
			FROM sys.dm_os_wait_stats
			WHERE wait_type NOT IN (
				'CLR_SEMAPHORE', 'LAZYWRITER_SLEEP', 'RESOURCE_QUEUE', 'SLEEP_TASK', 'SLEEP_SYSTEMTASK', 'SQLTRACE_BUFFER_FLUSH', 'WAITFOR', 
				'CHECKPOINT_QUEUE', 'REQUEST_FOR_DEADLOCK_SEARCH', 'XE_TIMER_EVENT', 'BROKER_TO_FLUSH', 'BROKER_TASK_STOP', 'CLR_MANUAL_EVENT',
				'CLR_AUTO_EVENT', 'DISPATCHER_QUEUE_SEMAPHORE', 'FT_IFTS_SCHEDULER_IDLE_WAIT', 'XE_DISPATCHER_WAIT', 'XE_DISPATCHER_JOIN', 
				'BROKER_EVENTHANDLER', 'TRACEWRITE', 'FT_IFTSHC_MUTEX', 'SQLTRACE_INCREMENTAL_FLUSH_SLEEP', 'BROKER_RECEIVE_WAITFOR', 
				'DBMIRROR_EVENTS_QUEUE', 'DBMIRRORING_CMD', 'BROKER_TRANSMITTER', 'SQLTRACE_WAIT_ENTRIES', 'SLEEP_BPOOL_FLUSH', 'SQLTRACE_LOCK', 
				'QDS_CLEANUP_STALE_QUERIES_TASK_MAIN_LOOP_SLEEP', 'QDS_PERSIST_TASK_MAIN_LOOP_SLEEP', 'HADR_FILESTREAM_IOMGR_IOCOMPLETION',
				'DIRTY_PAGE_POLL', 'SP_SERVER_DIAGNOSTICS_SLEEP', 'ONDEMAND_TASK_QUEUE','LOGMGR_QUEUE')
		)
			
	INSERT INTO Tb_Historico_Waits_Stats(WaitType,Wait_S,Resource_S,Signal_S,WaitCount,Percentage,Id_Coleta)
	SELECT
		W1.wait_type AS WaitType, 
		CAST (W1.WaitS AS DECIMAL(14, 2)) AS Wait_S,
		CAST (W1.ResourceS AS DECIMAL(14, 2)) AS Resource_S,
		CAST (W1.SignalS AS DECIMAL(14, 2)) AS Signal_S,
		W1.WaitCount AS WaitCount,
		CAST (W1.Percentage AS DECIMAL(4, 2)) AS Percentage, isnull(@Id_Coleta,0) + 1
		--CAST ((W1.WaitS / W1.WaitCount) AS DECIMAL (14, 4)) AS AvgWait_S,
	   -- CAST ((W1.ResourceS / W1.WaitCount) AS DECIMAL (14, 4)) AS AvgRes_S,
		--CAST ((W1.SignalS / W1.WaitCount) AS DECIMAL (14, 4)) AS AvgSig_S
	FROM Waits AS W1
		INNER JOIN Waits AS W2 ON W2.RowNum <= W1.RowNum
	GROUP BY W1.RowNum, W1.wait_type, W1.WaitS, W1.ResourceS, W1.SignalS, W1.WaitCount, W1.Percentage
	HAVING SUM (W2.Percentage) - W1.Percentage < 95 -- percentage threshold
	OPTION (RECOMPILE); 

	-- Verifica se o valor Wait_S diminuiu para algum WaitType.
	if exists	(
					select null
					from Tb_Historico_Waits_Stats A
					join	(	
								select [WaitType], max(Id_Historico_Waits_Stats) Id_Historico_Waits_Stats
								from Tb_Historico_Waits_Stats
								group by [WaitType] 
							) B on A.Id_Historico_Waits_Stats = B.Id_Historico_Waits_Stats
					join @Waits_Before C on A.WaitType = C.WaitType and A.WaitCount < C.WaitCount 
											and isnull(A.Id_Coleta,0)  = isnull(C.Id_Coleta,0) + 1 
				)
	BEGIN
		INSERT INTO Tb_Historico_Waits_Stats(WaitType)
		values('RESET WAITS STATS')
	END
END
GO

--------------------------------------------------------------------------------------------------------------------------------
-- Criação da procedure que retorna o historico dos Wait Stats.
--------------------------------------------------------------------------------------------------------------------------------
use dba
go
if object_id('Proc_Historico_Waits_Stats') is not null
	drop procedure Proc_Historico_Waits_Stats
GO
CREATE procedure [dbo].[Proc_Historico_Waits_Stats] @Dt_Inicial datetime, @Dt_Final datetime
AS
BEGIN
	--declare @Dt_Inicial datetime, @Dt_Final datetime
	--select @Dt_Inicial = '20110505 12:00',@Dt_Final = '20110505 13:00'
	 
	declare @Wait_Stats table(WaitType varchar(60), Min_Id int, Max_Id int, Menor_Data datetime)
	 
	insert into @Wait_Stats(WaitType, Min_Id,Max_Id, Menor_Data)
	select WaitType, min(Id_Historico_Waits_Stats) AS Min_Id, max(Id_Historico_Waits_Stats) AS Max_Id, min(Dt_Referencia) AS Menor_Data
	from Tb_Historico_Waits_Stats (nolock)
	where Dt_Referencia >= @Dt_Inicial and Dt_Referencia < @Dt_Final
	group by WaitType
	 
	-- Tratamento de erro simples para o caso de uma limpeza das estatísticas
	if exists (select null from @Wait_Stats where WaitType = 'RESET WAITS STATS')
	begin
		select	'Foi realizada uma limpeza dos WaitStats' AS WaitType, getdate() AS Min_Log, getdate() AS Max_Log, 0 AS DIf_Wait_S,
				0 AS DIf_Resource_S, 0 AS DIf_Signal_S, 0 AS DIf_WaitCount, 0 AS DIf_Percentage, 0 AS Last_Percentage
			
		/*
		select 'Houve uma limpeza das Waits Stats após a coleta do dia: ' + cast(Menor_Data as varchar) +
		' | Favor alterar o período para que não inclua essa limpeza.'
		from @Wait_Stats where WaitType = 'RESET WAITS STATS'
		*/
		 
		return
	End

	-- Procurar o menor id depois da última limpeza antes do intervalo final e utilizar
	--tratar caso da limpeza da estatistica
	select	A.WaitType, B.Dt_Referencia Min_Log, C.Dt_Referencia Max_Log, C.Wait_S - B.Wait_S DIf_Wait_S,
			C.Resource_S - B.Resource_S DIf_Resource_S, C.Signal_S - B.Signal_S DIf_Signal_S, C.WaitCount - B.WaitCount DIf_WaitCount,
			C.Percentage - B.Percentage DIf_Percentage, B.Percentage Last_Percentage
	from @Wait_Stats A
		join Tb_Historico_Waits_Stats B on A.Min_Id = B.Id_Historico_Waits_Stats -- Primeiro
		join Tb_Historico_Waits_Stats C on A.Max_Id = C.Id_Historico_Waits_Stats -- Último 
END

GO

--------------------------------------------------------------------------------------------------------------------------------
-- Criação de índice para o Historico dos Wait Stats.
--------------------------------------------------------------------------------------------------------------------------------
use DBA

CREATE NONCLUSTERED INDEX [IDX_N_Historico_Waits_Stats_001] ON [DBA].[dbo].[Tb_Historico_Waits_Stats] ([Id_Historico_Waits_Stats]) 
INCLUDE ([WaitType], [WaitCount], [Id_Coleta]) with(fillfactor = 90)

GO


--------------------------------------------------------------------------------------------------------------------------------
-- JOB: DBA - Carga Wait Stats.
--------------------------------------------------------------------------------------------------------------------------------
USE [msdb]
GO

-- Se o job já existe, exclui para criar novamente.
IF EXISTS (SELECT job_id 
            FROM msdb.dbo.sysjobs_view 
            WHERE name = N'DBA - Carga Wait Stats')
EXEC msdb.dbo.sp_delete_job @job_name=N'DBA - Carga Wait Stats'  , @delete_unused_schedule=1

GO

BEGIN TRANSACTION
	DECLARE @ReturnCode INT
	SELECT @ReturnCode = 0
	
	------------------------------------------------------------------------------------------------------------------------------------	
	-- Seleciona a Categoria do JOB
	------------------------------------------------------------------------------------------------------------------------------------
	IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name = N'Database Maintenance' AND category_class = 1)
	BEGIN
		EXEC @ReturnCode = msdb.dbo.sp_add_category @class = N'JOB', @type = N'LOCAL', @name = N'Database Maintenance'
		
		IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
	END

	DECLARE @jobId BINARY(16)
	EXEC @ReturnCode =  msdb.dbo.sp_add_job 
			@job_name = N'DBA - Carga Wait Stats', 
			@enabled = 1, 
			@notify_level_eventlog = 0, 
			@notify_level_email = 0, 
			@notify_level_netsend = 0, 
			@notify_level_page = 0, 
			@delete_level = 0, 
			@description = N'No description available.', 
			@category_name = N'Database Maintenance', 
			@owner_login_name = N'sa', 
			@job_id = @jobId OUTPUT
			
	IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

	------------------------------------------------------------------------------------------------------------------------------------	
	-- Cria o Step 1 do JOB - Carga Wait Stats
	------------------------------------------------------------------------------------------------------------------------------------
	EXEC @ReturnCode = msdb.dbo.sp_add_jobstep 
			@job_id = @jobId, 
			@step_name = N'DBA - Carga Wait Stats', 
			@step_id = 1, 
			@cmdexec_success_code = 0, 
			@on_success_action = 1, 
			@on_success_step_id = 0, 
			@on_fail_action = 2, 
			@on_fail_step_id = 0, 
			@retry_attempts = 0, 
			@retry_interval = 0, 
			@os_run_priority = 0, 
			@subsystem = N'TSQL', 
			@command = N'exec Proc_Carga_Historico_Waits_Stats', 
			@database_name = N'DBA', 
			@flags = 0
			
	IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
	
	EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
	
	IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

	------------------------------------------------------------------------------------------------------------------------------------	
	-- Cria o Schedule do JOB
	------------------------------------------------------------------------------------------------------------------------------------
	declare @Dt_Atual varchar(8) = convert(varchar(8), getdate(), 112)

	EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule 
			@job_id = @jobId, 
			@name = N'Histórico Wait', 
			@enabled = 1, 
			@freq_type = 4, 
			@freq_interval = 1, 
			@freq_subday_type = 4, 
			@freq_subday_interval = 30, 
			@freq_relative_interval = 0, 
			@freq_recurrence_factor = 0, 
			@active_start_date = @Dt_Atual, 
			@active_end_date = 99991231, 
			@active_start_time = 707, 
			@active_end_time = 235959
			
	IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
	
	EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
	
	IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

COMMIT TRANSACTION

GOTO EndSave

QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
    
EndSave:

GO

