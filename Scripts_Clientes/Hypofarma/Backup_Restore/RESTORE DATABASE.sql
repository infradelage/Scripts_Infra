USE master;  
GO  

ALTER DATABASE WMSRX_HML SET OFFLINE WITH ROLLBACK IMMEDIATE 
GO

-- Primeiro determine o n�mero e os nomes dos arquivos no backup.
-- BKP_PROD_09062022 � o nome do dispositivo de backup. 
RESTORE FILELISTONLY  
   FROM DISK = 'C:\Backup_SQL\RNSRV10\WMSRX\FULL\RNSRV10_WMSRX_FULL_20230808_110110.BAK'
--Restaurar os arquivos para WMSRX_TESTE. 
RESTORE DATABASE WMSRX_HML
   FROM DISK = 'C:\Backup_SQL\RNSRV10\WMSRX\FULL\RNSRV10_WMSRX_FULL_20230808_110110.BAK'
   WITH RECOVERY,REPLACE,  
   MOVE 'DisbbyBase_Data' TO 'C:\Program Files\Microsoft SQL Server\MSSQL15.MSSQLSERVER\MSSQL\DATA\WMSRX_HML.mdf',
   MOVE 'DisbbyBase_Log' TO 'C:\Program Files\Microsoft SQL Server\MSSQL15.MSSQLSERVER\MSSQL\DATA\WMSRX_HML_0.ldf', 
   STATS = 10 --Stats = 10 indica que ele mostrar� o progresso da restaura��o
GO  

ALTER DATABASE WMSRX_HML SET ONLINE
GO