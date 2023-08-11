

-- PROCEDURE

USE [DBA]
GO
/****** Object:  StoredProcedure [dbo].[Proc_Alerta_Processo_Bloqueado]    Script Date: 10/18/2018 10:30:09 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*******************************************************************************************************************************
--	ALERTA: PROCESSO BLOQUEADO
*******************************************************************************************************************************/

create PROCEDURE [dbo].[Proc_Alerta_Processo_Bloqueado]
AS
BEGIN
	SET NOCOUNT ON

	-- Declara as variaveis
	DECLARE	@Subject NVARCHAR(500), @Fl_Tipo TINYINT, @Qtd_Segundos INT, @Consulta NVARCHAR(4000), @Importance AS NVARCHAR(6), @Dt_Atual DATETIME,
			@EmailBody NVARCHAR(MAX), @AlertaLockHeader NVARCHAR(MAX), @AlertaLockTable NVARCHAR(MAX), @EmptyBodyEmail NVARCHAR(MAX),
			@AlertaLockRaizHeader NVARCHAR(MAX), @AlertaLockRaizTable NVARCHAR(MAX), @Qt_Tempo_Lock INT, @Qt_Tempo_Raiz_Lock INT

	-- Quantidade em Minutos
	SELECT	@Qt_Tempo_Lock		= 2,	-- Query que esta sendo bloqueada (rodando a mais de 2 minutos)
			@Qt_Tempo_Raiz_Lock	= 1		-- Query que esta gerando o lock (rodando a mais de 1 minuto)

	--------------------------------------------------------------------------------------------------------------------------------
	--	Cria Tabela para armazenar os Dados da SP_WHOISACTIVE
	--------------------------------------------------------------------------------------------------------------------------------
	-- Cria a tabela que ira armazenar os dados dos processos
	IF ( OBJECT_ID('tempdb..#Resultado_WhoisActive') IS NOT NULL )
		DROP TABLE #Resultado_WhoisActive
		
	CREATE TABLE #Resultado_WhoisActive (		
		[dd hh:mm:ss.mss]		VARCHAR(20),
		[database_name]			NVARCHAR(128),		
		[login_name]			NVARCHAR(128),
		[host_name]				NVARCHAR(128),
		[start_time]			DATETIME,
		[status]				VARCHAR(30),
		[session_id]			INT,
		[blocking_session_id]	INT,
		[wait_info]				VARCHAR(MAX),
		[open_tran_count]		INT,
		[CPU]					VARCHAR(MAX),
		[reads]					VARCHAR(MAX),
		[writes]				VARCHAR(MAX),		
		[sql_command]			XML		
	)   
      

    -- Pega a lista de e-mails
	declare @emails NVARCHAR(max);
    select  @emails = dba.dbo.[fncRetornaEmails](0); -- nao abrir chamado

	-- Seta a hora atual
	SELECT @Dt_Atual = GETDATE()

	--------------------------------------------------------------------------------------------------------------------------------
	--	Carrega os Dados da SP_WHOISACTIVE
	--------------------------------------------------------------------------------------------------------------------------------
	-- Retorna todos os processos que estão sendo executados no momento
	EXEC [dbo].[sp_WhoIsActive]
			@get_outer_command =	1,
			@output_column_list =	'[dd hh:mm:ss.mss][database_name][login_name][host_name][start_time][status][session_id][blocking_session_id][wait_info][open_tran_count][CPU][reads][writes][sql_command]',
			@destination_table =	'#Resultado_WhoisActive'
				    
	-- Altera a coluna que possui o comando SQL
	ALTER TABLE #Resultado_WhoisActive
	ALTER COLUMN [sql_command] NVARCHAR(MAX)
	
	UPDATE #Resultado_WhoisActive
	SET [sql_command] = REPLACE( REPLACE( REPLACE( REPLACE( CAST([sql_command] AS NVARCHAR(1000)), '<?query --', ''), '--?>', ''), '&gt;', '>'), '&lt;', '')
	
	-- select * from #Resultado_WhoisActive
	
	-- Verifica se não existe nenhum processo em Execução
	IF NOT EXISTS ( SELECT TOP 1 * FROM #Resultado_WhoisActive )
	BEGIN
		INSERT INTO #Resultado_WhoisActive
		SELECT NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,NULL
	END

	-- Verifica o último Tipo do Alerta registrado -> 0: CLEAR / 1: ALERTA
	SELECT @Fl_Tipo = [Fl_Tipo]
	FROM [DBA].[dbo].[Tb_Alertas]
	WHERE [Id_Alerta] = (SELECT MAX(Id_Alerta) FROM [DBA].[dbo].[Tb_Alertas] WHERE [Nm_Alerta] = 'Processo Bloqueado' )
	
	/*******************************************************************************************************************************
	--	Verifica se existe algum Processo Bloqueado
	*******************************************************************************************************************************/	
	IF EXISTS	(
					SELECT NULL 
					FROM #Resultado_WhoisActive A
					JOIN #Resultado_WhoisActive B ON A.[blocking_session_id] = B.[session_id]
					WHERE	DATEDIFF(SECOND,A.[start_time], @Dt_Atual) > @Qt_Tempo_Lock * 60			-- A query que está sendo bloqueada está rodando a mais 2 minutos
							AND DATEDIFF(SECOND,B.[start_time], @Dt_Atual) > @Qt_Tempo_Raiz_Lock * 60	-- A query que está bloqueando está rodando a mais de 1 minuto
				)
	BEGIN	-- INICIO - ALERTA
		IF ISNULL(@Fl_Tipo, 0) = 0	-- Envia o Alerta apenas uma vez
		BEGIN
			--------------------------------------------------------------------------------------------------------------------------------
			--	Verifica a quantidade de processos bloqueados
			--------------------------------------------------------------------------------------------------------------------------------
			-- Declara a variavel e retorna a quantidade de Queries Lentas
			DECLARE @QtdProcessosBloqueados INT = (
										SELECT COUNT(*)
										FROM #Resultado_WhoisActive A
										JOIN #Resultado_WhoisActive B ON A.[blocking_session_id] = B.[session_id]
										WHERE	DATEDIFF(SECOND,A.[start_time], @Dt_Atual) > @Qt_Tempo_Lock	* 60
												AND DATEDIFF(SECOND,B.[start_time], @Dt_Atual) > @Qt_Tempo_Raiz_Lock * 60
									)

			DECLARE @QtdProcessosBloqueadosLocks INT = (
										SELECT COUNT(*)
										FROM #Resultado_WhoisActive A
										WHERE [blocking_session_id] IS NOT NULL
									)

			--------------------------------------------------------------------------------------------------------------------------------
			--	Verifica o Nivel dos Locks
			--------------------------------------------------------------------------------------------------------------------------------
			ALTER TABLE #Resultado_WhoisActive
			ADD Nr_Nivel_Lock TINYINT 

			-- Nivel 0
			UPDATE A
			SET Nr_Nivel_Lock = 0
			FROM #Resultado_WhoisActive A
			WHERE blocking_session_id IS NULL AND session_id IN ( SELECT DISTINCT blocking_session_id 
						FROM #Resultado_WhoisActive WHERE blocking_session_id IS NOT NULL)

			UPDATE A
			SET Nr_Nivel_Lock = 1
			FROM #Resultado_WhoisActive A
			WHERE	Nr_Nivel_Lock IS NULL
					AND blocking_session_id IN ( SELECT DISTINCT session_id FROM #Resultado_WhoisActive WHERE Nr_Nivel_Lock = 0)

			UPDATE A
			SET Nr_Nivel_Lock = 2
			FROM #Resultado_WhoisActive A
			WHERE	Nr_Nivel_Lock IS NULL
					AND blocking_session_id IN ( SELECT DISTINCT session_id FROM #Resultado_WhoisActive WHERE Nr_Nivel_Lock = 1)

			UPDATE A
			SET Nr_Nivel_Lock = 3
			FROM #Resultado_WhoisActive A
			WHERE	Nr_Nivel_Lock IS NULL
					AND blocking_session_id IN ( SELECT DISTINCT session_id FROM #Resultado_WhoisActive WHERE Nr_Nivel_Lock = 2)

			-- Tratamento quando não tem um Lock Raiz
			IF NOT EXISTS(select * from #Resultado_WhoisActive where Nr_Nivel_Lock IS NOT NULL)
			BEGIN
				UPDATE A
				SET Nr_Nivel_Lock = 0
				FROM #Resultado_WhoisActive A
				WHERE session_id IN ( SELECT DISTINCT blocking_session_id 
					FROM #Resultado_WhoisActive WHERE blocking_session_id IS NOT NULL)
          
				UPDATE A
				SET Nr_Nivel_Lock = 1
				FROM #Resultado_WhoisActive A
				WHERE	Nr_Nivel_Lock IS NULL
						AND blocking_session_id IN ( SELECT DISTINCT session_id FROM #Resultado_WhoisActive WHERE Nr_Nivel_Lock = 0)

				UPDATE A
				SET Nr_Nivel_Lock = 2
				FROM #Resultado_WhoisActive A
				WHERE	Nr_Nivel_Lock IS NULL
						AND blocking_session_id IN ( SELECT DISTINCT session_id FROM #Resultado_WhoisActive WHERE Nr_Nivel_Lock = 1)

				UPDATE A
				SET Nr_Nivel_Lock = 3
				FROM #Resultado_WhoisActive A
				WHERE	Nr_Nivel_Lock IS NULL
						AND blocking_session_id IN ( SELECT DISTINCT session_id FROM #Resultado_WhoisActive WHERE Nr_Nivel_Lock = 2)
			END

			/*******************************************************************************************************************************
			--	CRIA O EMAIL - ALERTA
			*******************************************************************************************************************************/							
			
			--------------------------------------------------------------------------------------------------------------------------------
			--	ALERTA - HEADER - RAIZ LOCK
			--------------------------------------------------------------------------------------------------------------------------------
			SET @AlertaLockRaizHeader = '<font color=black bold=true size=5>'			            
			SET @AlertaLockRaizHeader = @AlertaLockRaizHeader + '<BR /> TOP 50 - Processos em Lock a partir do Causador do Problema <BR />'
			SET @AlertaLockRaizHeader = @AlertaLockRaizHeader + '</font>'

			--------------------------------------------------------------------------------------------------------------------------------
			--	ALERTA - BODY - RAIZ LOCK
			--------------------------------------------------------------------------------------------------------------------------------
			
			SELECT	TOP 50 CAST(Nr_Nivel_Lock AS NVARCHAR)						AS [Nivel Lock],
						   ISNULL([dd hh:mm:ss.mss], '-')						AS [Tempo Executando em [dd hh:mm:ss.mss], 
						   ISNULL([database_name], '-')							AS [Banco de Dados],
						   ISNULL([login_name], '-')							AS [Login],
						   ISNULL([host_name], '-')								AS [Máquina],
						   ISNULL(CONVERT(VARCHAR(20), [start_time], 120), '-')	AS [Hora Início],
						   ISNULL([status], '-')								AS [Status],
						   ISNULL(CAST([session_id] AS NVARCHAR), '-')			AS [ID Sessão],
						   ISNULL(CAST([blocking_session_id] AS NVARCHAR), '-')	AS [ID Sessão Bloqueando],
						   ISNULL([wait_info], '-')								AS [Tipo Bloqueio],
						   ISNULL(CAST([open_tran_count] AS NVARCHAR), '-')		AS [Transações Abertas],
						   ISNULL([CPU], '-')									AS [CPU],
						   ISNULL([reads], '-')									AS [Leituras],
						   ISNULL([writes], '-')								AS [Escritas],
						   ISNULL(SUBSTRING([sql_command], 1, 300), '-')		AS [Comando Executado]
                       Into ##Resultado_WhoisActive2
					   FROM #Resultado_WhoisActive
					   WHERE Nr_Nivel_Lock IS NOT NULL
				   ORDER BY [Nr_Nivel_Lock], [start_time] 

			EXEC dba.dbo.Proc_Exporta_Tabela_HTML @Ds_Tabela = '##Resultado_WhoisActive2', @Ds_Saida = @AlertaLockRaizTable OUT 
			Drop Table ##Resultado_WhoisActive2;
			--------------------------------------------------------------------------------------------------------------------------------
			--	ALERTA - HEADER
			--------------------------------------------------------------------------------------------------------------------------------
			SET @AlertaLockHeader = '<font color=black bold=true size=5>'			            
			SET @AlertaLockHeader = @AlertaLockHeader + '<BR /> TOP 50 - Processos em Execução no Banco de Dados <BR />'
			SET @AlertaLockHeader = @AlertaLockHeader + '</font>'
			--------------------------------------------------------------------------------------------------------------------------------
			--	ALERTA - BODY
			--------------------------------------------------------------------------------------------------------------------------------
			SELECT	TOP 50 ISNULL([dd hh:mm:ss.mss], '-')						AS [Tempo Executando em [dd hh:mm:ss.mss], 
						   ISNULL([database_name], '-')							AS [Banco de Dados],
						   ISNULL([login_name], '-')							AS [Login],
						   ISNULL([host_name], '-')								AS [Máquina],
						   ISNULL(CONVERT(VARCHAR(20), [start_time], 120), '-')	AS [Hora Início],
						   ISNULL([status], '-')								AS [Status],
						   ISNULL(CAST([session_id] AS NVARCHAR), '-')			AS [ID Sessão],
						   ISNULL(CAST([blocking_session_id] AS NVARCHAR), '-')	AS [ID Sessão Bloqueando],
						   ISNULL([wait_info], '-')								AS [Tipo Bloqueio],
						   ISNULL(CAST([open_tran_count] AS NVARCHAR), '-')		AS [Transações Abertas],
						   ISNULL([CPU], '-')									AS [CPU],
						   ISNULL([reads], '-')									AS [Leituras],
						   ISNULL([writes], '-')								AS [Escritas],
						   ISNULL(SUBSTRING([sql_command], 1, 300), '-')		AS [Comando Executado]
					  into ##Alerta_Jobs2
				 	  FROM #Resultado_WhoisActive
				  ORDER BY [start_time];

			EXEC dba.dbo.Proc_Exporta_Tabela_HTML @Ds_Tabela = '##Alerta_Jobs2', @Ds_Saida = @AlertaLockTable OUT
			Drop Table ##Alerta_Jobs2;
            
			--------------------------------------------------------------------------------------------------------------------------------
			-- Insere um Espaço em Branco no EMAIL
			--------------------------------------------------------------------------------------------------------------------------------
			SET @EmptyBodyEmail =	''
			SET @EmptyBodyEmail =
					'<table cellpadding="0" cellspacing="0" border="0">' +
						'<tr>
							<th width="500">               </th>
						</tr>'
						+ REPLACE( REPLACE( ISNULL(@EmptyBodyEmail,''), '&lt;', '<'), '&gt;', '>')
					+ '</table>'

			/*******************************************************************************************************************************
			--	Seta as Variáveis do EMAIL
			*******************************************************************************************************************************/			              
			SELECT	@Importance =	'High',
					@Subject =		'ALERTA: Existe(m) ' + CAST(@QtdProcessosBloqueados AS NVARCHAR) + 
									' Processo(s) Bloqueado(s) a mais de ' +  CAST((@Qt_Tempo_Lock) AS NVARCHAR) + ' minuto(s)' +
									' em um total de ' + CAST(@QtdProcessosBloqueadosLocks AS NVARCHAR) +  ' Lock(s) no Servidor: ' + @@SERVERNAME,
					@EmailBody =	@AlertaLockRaizHeader + --@EmptyBodyEmail + 
					                @AlertaLockRaizTable --+ @EmptyBodyEmail
									+ @AlertaLockHeader + --@EmptyBodyEmail + 
									@AlertaLockTable							
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
					
			/*******************************************************************************************************************************
			-- Insere um Registro na Tabela de Controle dos Alertas -> Fl_Tipo = 1 : ALERTA
			*******************************************************************************************************************************/
			INSERT INTO [DBA].[dbo].[Tb_Alertas]( [Nm_Alerta], [Ds_Mensagem], [Fl_Tipo] )
			SELECT 'Processo Bloqueado', @Subject, 1			
		END
	END		-- FIM - ALERTA
	ELSE 
	BEGIN	-- INICIO - CLEAR				
		IF @Fl_Tipo = 1
		BEGIN

			/*******************************************************************************************************************************
			--	CRIA O EMAIL - CLEAR
			*******************************************************************************************************************************/
			--------------------------------------------------------------------------------------------------------------------------------
			--	CLEAR - HEADER
			--------------------------------------------------------------------------------------------------------------------------------
			SET @AlertaLockHeader = '<font color=black bold=true size=5>'			            
			SET @AlertaLockHeader = @AlertaLockHeader + '<BR /> Processos executando no Banco de Dados <BR />' 
			SET @AlertaLockHeader = @AlertaLockHeader + '</font>'
			--------------------------------------------------------------------------------------------------------------------------------
			--	CLEAR - BODY
			--------------------------------------------------------------------------------------------------------------------------------
			SELECT ISNULL([dd hh:mm:ss.mss], '-')						AS [Tempo Executando em [dd hh:mm:ss.mss], 
				   ISNULL([database_name], '-')							AS [Banco de Dados],
				   ISNULL([login_name], '-')							AS [Login],
				   ISNULL(CONVERT(VARCHAR(20), [start_time], 120), '-')	AS [Hora Início],
				   ISNULL([status], '-')								AS [Status],
				   ISNULL(CAST([session_id] AS NVARCHAR), '-')			AS [ID Sessão],
				   ISNULL(CAST([blocking_session_id] AS NVARCHAR), '-')	AS [ID Sessão Bloqueando],
				   ISNULL([wait_info], '-')								AS [Tipo Bloqueio],
			   	   ISNULL(CAST([open_tran_count] AS NVARCHAR), '-')		AS [Transações Abertas],
				   ISNULL([CPU], '-')									AS [CPU],
				   ISNULL([reads], '-')									AS [Leituras],
				   ISNULL([writes], '-')								AS [Gravações],
				   ISNULL(SUBSTRING([sql_command], 1, 300), '-')		AS [Comando Executado]
              into ##Alerta_Jobs2Clear
			  FROM #Resultado_WhoisActive;
							  
            EXEC dba.dbo.Proc_Exporta_Tabela_HTML @Ds_Tabela = '##Alerta_Jobs2Clear', @Ds_Saida = @AlertaLockTable OUT
			Drop Table ##Alerta_Jobs2Clear;
			--------------------------------------------------------------------------------------------------------------------------------
			-- Insere um Espaço em Branco no EMAIL
			--------------------------------------------------------------------------------------------------------------------------------
			SET @EmptyBodyEmail =	''
			SET @EmptyBodyEmail =
					'<table cellpadding="0" cellspacing="0" border="0">' +
						'<tr>
							<th width="500">               </th>
						</tr>'
						+ REPLACE( REPLACE( ISNULL(@EmptyBodyEmail,''), '&lt;', '<'), '&gt;', '>')
					+ '</table>'
			/*******************************************************************************************************************************
			--	Seta as Variáveis do EMAIL
			*******************************************************************************************************************************/
			SELECT	@Importance =	'High',
					@Subject =		'FIM ALERTA: Não existe mais nenhum Processo Bloqueado a mais de ' + 
									CAST((@Qt_Tempo_Lock) AS NVARCHAR) + ' minuto(s) no Servidor: ' + @@SERVERNAME,
					@EmailBody =	@AlertaLockHeader + --@EmptyBodyEmail + 
					                @AlertaLockTable
							
			/*******************************************************************************************************************************
			--	ENVIA O EMAIL - CLEAR
			*******************************************************************************************************************************/
			EXEC [msdb].[dbo].[sp_send_dbmail]
					@profile_name = 'Envia e-mail',
					@recipients =	@emails, --'alerta@jpconsultoria.net.br',
					@subject =		@Subject,
					@body =			@EmailBody,
					@body_format =	'HTML',
					@importance =	@Importance

			/*******************************************************************************************************************************
			-- Insere um Registro na Tabela de Controle dos Alertas -> Fl_Tipo = 0 : CLEAR
			*******************************************************************************************************************************/
			INSERT INTO [DBA].[dbo].[Tb_Alertas] ( [Nm_Alerta], [Ds_Mensagem], [Fl_Tipo] )
			SELECT 'Processo Bloqueado', @Subject, 0		
		END		
	END		-- FIM - CLEAR
END
go

-- Job

USE [msdb]
GO

/****** Object:  Job [DBA - Monitora Bloqueios]    Script Date: 10/18/2018 10:24:55 ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [[Uncategorized (Local)]]]    Script Date: 10/18/2018 10:24:55 ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'DBA - Monitora Bloqueios', 
		@enabled=1, 
		@notify_level_eventlog=0, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'Faz o Monitoramento de bloqueios entre sessões do banco de dados.', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'sa', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Passo Monitora Bloqueios]    Script Date: 10/18/2018 10:24:55 ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Passo Monitora Bloqueios', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'exec dba.dbo.Proc_Alerta_Processo_Bloqueado;', 
		@database_name=N'DBA', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'Agenda Monitora Bloqueios', 
		@enabled=1, 
		@freq_type=4, 
		@freq_interval=1, 
		@freq_subday_type=4, 
		@freq_subday_interval=1, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=0, 
		@active_start_date=20170502, 
		@active_end_date=99991231, 
		@active_start_time=0, 
		@active_end_time=235959, 
		@schedule_uid=N'12e162a1-ac81-40f9-864a-2f76d4a1c1e1'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:

GO


