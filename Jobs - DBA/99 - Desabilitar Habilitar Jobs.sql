-- DESABILITAR/ HABILITAR JOB POR NOME
USE msdb ;  
GO  
EXEC dbo.sp_update_job  
    @job_name = N'DBA - Recicla Log dos Jobs Administrativos e Backup',  -- NOME
    @enabled = 0 ;  
GO  

-- DESABILITAR/HABILITAR TODOS OS  JOBS
USE MSDB;
GO
UPDATE dbo.sysjobs
--SET Enabled = 1 -- Enable All Jobs
SET Enabled = 0 -- Disable All Jobs
WHERE Enabled = 1;
GO