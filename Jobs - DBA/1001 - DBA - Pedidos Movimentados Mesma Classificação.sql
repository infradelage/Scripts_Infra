USE [msdb]
GO

/****** Object:  Job [WMSRX - Pedidos Movimentados Mesma Classificação]    Script Date: 18/01/2022 18:19:47 ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [[Uncategorized (Local)]]    Script Date: 18/01/2022 18:19:47 ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'WMSRX - Pedidos Movimentados Mesma Classificação', 
		@enabled=1, 
		@notify_level_eventlog=0, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'Pedidos de movimentacao que fazem movimentacao com o mesmo lote e mesmo grupo de classificacao mas que nao são integrados.', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'disbbyweb', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [1 - Pedidos Movimentados]    Script Date: 18/01/2022 18:19:47 ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'1 - Pedidos Movimentados', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'SELECT * 
   INTO #vw_edi_pedidos_mov_envolve_segregado    
    FROM vw_edi_pedidos_mov_envolve_segregado    


    SELECT DISTINCT p.cod_pedido   
	 INTO #ped_movimentado_concluido      
      FROM pedido p (NOLOCK)  

      INNER JOIN def_situacao s (NOLOCK) ON s.cod_situacao = p.cod_situacao  
           AND s.exporta = -1   
      INNER JOIN operacao_logistica ol (NOLOCK) ON p.cod_operacao_logistica = ol.cod_operacao_logistica    

      INNER JOIN param_operacao po (NOLOCK) ON ol.cod_distribuicao = po.cod_distribuicao      

          AND p.operacao = po.operacao    

    WHERE p.data_exportacao IS NULL   
      AND p.operacao IN (3,4,5)        
	  and NOT EXISTS (SELECT 1 
	                    FROM #vw_edi_pedidos_mov_envolve_segregado  fn (NOLOCK) 
					   WHERE p.cod_pedido = fn.cod_pedido)
        



UPDATE p SET
p.data_exportacao = getdate(),
p.cod_situacao = 4
FROM PEDIDO P INNER JOIN #ped_movimentado_concluido PED on p.cod_pedido = PED.cod_pedido
WHERE p.cod_situacao = 3 -- MOVIMENTADO
AND p.operacao IN (3,4,5) -- MOV. ENDERECO


drop table #vw_edi_pedidos_mov_envolve_segregado
drop table #ped_movimentado_concluido', 
		@database_name=N'WMSRX', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'1 vez ao dia, as 04:00', 
		@enabled=1, 
		@freq_type=4, 
		@freq_interval=1, 
		@freq_subday_type=1, 
		@freq_subday_interval=30, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=0, 
		@active_start_date=20161014, 
		@active_end_date=99991231, 
		@active_start_time=40000, 
		@active_end_time=235959, 
		@schedule_uid=N'de291df0-d118-4112-8578-5648dbe52e14'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:

GO


