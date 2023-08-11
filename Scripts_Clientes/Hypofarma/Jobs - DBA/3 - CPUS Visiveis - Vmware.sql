----------------------------------------------------------------------------------------------------------------
-- CPU VISIABLE ONLINE CHECK
----------------------------------------------------------------------------------------------------------------
DECLARE @OnlineCpuCount int
DECLARE @LogicalCpuCount int

SELECT @OnlineCpuCount = COUNT(*) FROM sys.dm_os_schedulers WHERE status = 'VISIBLE ONLINE'
SELECT @LogicalCpuCount = cpu_count FROM sys.dm_os_sys_info 

SELECT @LogicalCpuCount AS 'ASSIGNED ONLINE CPU #', @OnlineCpuCount AS 'VISIBLE ONLINE CPU #',
   CASE 
     WHEN @OnlineCpuCount < @LogicalCpuCount 
     THEN 'You are not using all CPU assigned to O/S! If it is VM, review your VM configuration to make sure you are not maxout Socket'
     ELSE 'You are using all CPUs assigned to O/S. GOOD!' 
   END as 'CPU Usage Desc'
----------------------------------------------------------------------------------------------------------------
GO

SELECT scheduler_id, cpu_id, status, is_online FROM sys.dm_os_schedulers 
GO

--https://www.mssqltips.com/sqlservertip/4801/sql-server-does-not-use-all-assigned-cpus-on-vm/


-- ultimo restart 
SELECT sqlserver_start_time
FROM sys.dm_os_sys_info