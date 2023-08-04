-- Tabelas

--------------------------------------------------------------------------------------------------------------------------------
-- Criação das tabelas dos Contadores.
--------------------------------------------------------------------------------------------------------------------------------
use DBA
go
if OBJECT_ID('Tb_Contadores') is not null
	drop table Tb_Contadores;

if OBJECT_ID('Tb_Registro_Contadores') is not null
	drop table Tb_Registro_Contadores;

CREATE TABLE [dbo].[Tb_Contadores] (
	Id_Contador INT identity, 
	Nm_Contador VARCHAR(50) 
);
go
INSERT INTO Tb_Contadores (Nm_Contador)
SELECT 'BatchRequests'
INSERT INTO Tb_Contadores (Nm_Contador)
SELECT 'User_Connection'
INSERT INTO Tb_Contadores (Nm_Contador)
SELECT 'CPU'
INSERT INTO Tb_Contadores (Nm_Contador)
SELECT 'Page Life Expectancy'
go
-- SELECT * FROM Contador

CREATE TABLE [dbo].[Tb_Registro_Contadores] (
	[Id_Registro_Contador] [int] IDENTITY(1,1) NOT NULL,
	[Dt_Log] [datetime] NULL,
	[Id_Contador] [int] NULL,
	[Valor] [int] NULL
) ON [PRIMARY];
go

-- Procedure
use DBA
go
if OBJECT_ID('Proc_Carga_ContadoresSQL') is not null
	drop procedure Proc_Carga_ContadoresSQL

GO

CREATE PROCEDURE [dbo].[Proc_Carga_ContadoresSQL]
AS
BEGIN
	DECLARE @BatchRequests INT,@User_Connection INT, @CPU INT, @PLE int

	DECLARE @RequestsPerSecondSample1	BIGINT
	DECLARE @RequestsPerSecondSample2	BIGINT

	SELECT @RequestsPerSecondSample1 = cntr_value FROM sys.dm_os_performance_counters WHERE counter_name = 'Batch Requests/sec'
	WAITFOR DELAY '00:00:05'
	SELECT @RequestsPerSecondSample2 = cntr_value FROM sys.dm_os_performance_counters WHERE counter_name = 'Batch Requests/sec'
	SELECT @BatchRequests = (@RequestsPerSecondSample2 - @RequestsPerSecondSample1)/5

	select @User_Connection = cntr_Value
	from sys.dm_os_performance_counters
	where counter_name = 'User Connections'
								
	SELECT  TOP(1) @CPU  = (SQLProcessUtilization + (100 - SystemIdle - SQLProcessUtilization ) )
	FROM ( 
			  SELECT	record.value('(./Record/@id)[1]', 'int') AS record_id, 
						record.value('(./Record/SchedulerMonitorEvent/SystemHealth/SystemIdle)[1]', 'int') AS [SystemIdle], 
						record.value('(./Record/SchedulerMonitorEvent/SystemHealth/ProcessUtilization)[1]', 'int') AS [SQLProcessUtilization], 
						[timestamp] 
			  FROM ( 
						SELECT [timestamp], CONVERT(xml, record) AS [record] 
						FROM sys.dm_os_ring_buffers 
						WHERE	ring_buffer_type = N'RING_BUFFER_SCHEDULER_MONITOR' 
								AND record LIKE '%<SystemHealth>%'
					) AS x
		  ) AS y
		  
	SELECT @PLE = cntr_value 
	FROM sys.dm_os_performance_counters
	WHERE	counter_name = 'Page life expectancy'
			AND object_name like '%Buffer Manager%'

	insert INTO dba.dbo.Tb_Registro_Contadores(Dt_Log, Id_Contador, Valor)
	Select GETDATE(), 1, @BatchRequests
	insert INTO dba.dbo.Tb_Registro_Contadores(Dt_Log, Id_Contador, Valor)
	Select GETDATE(), 2, @User_Connection
	insert INTO dba.dbo.Tb_Registro_Contadores(Dt_Log, Id_Contador, Valor)
	Select GETDATE(), 3, @CPU
	insert INTO dba.dbo.Tb_Registro_Contadores(Dt_Log, Id_Contador, Valor)
	Select GETDATE(), 4, @PLE
END

GO

-- Job

--------------------------------------------------------------------------------------------------------------------------------
-- JOB: DBA - Carga Contadores SQL Server.
--------------------------------------------------------------------------------------------------------------------------------
-- Se o job já existe, exclui para criar novamente.
IF EXISTS (SELECT job_id 
            FROM msdb.dbo.sysjobs_view 
            WHERE name = N'DBA - Carga Contadores SQL Server')
EXEC msdb.dbo.sp_delete_job @job_name=N'DBA - Carga Contadores SQL Server'  , @delete_unused_schedule=1

USE [msdb]

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
			@job_name = N'DBA - Carga Contadores SQL Server', 
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
	-- Cria o Step 1 do JOB - Carga Contadores
	------------------------------------------------------------------------------------------------------------------------------------
	EXEC @ReturnCode = msdb.dbo.sp_add_jobstep 
			@job_id = @jobId, 
			@step_name = N'DBA - Carga Contadores', 
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
			@command = N'exec Proc_Carga_ContadoresSQL', 
			@database_name = N'DBA', 
			@flags=0
		
	IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
	
	EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
	
	IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
	
	------------------------------------------------------------------------------------------------------------------------------------	
	-- Cria o Schedule do JOB
	------------------------------------------------------------------------------------------------------------------------------------
	declare @Dt_Atual varchar(8) = convert(varchar(8), getdate(), 112)
	
	EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule 
			@job_id = @jobId, 
			@name = N'Contadores SQL', 
			@enabled = 1, 
			@freq_type = 4, 
			@freq_interval = 1, 
			@freq_subday_type = 4, 
			@freq_subday_interval = 1, 
			@freq_relative_interval = 0, 
			@freq_recurrence_factor = 0, 
			@active_start_date = @Dt_Atual,
			@active_end_date = 99991231, 
			@active_start_time = 32, 
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