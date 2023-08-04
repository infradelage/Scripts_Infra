USE master;  
GO  

ALTER DATABASE WMSRX_Netsuite SET OFFLINE WITH ROLLBACK IMMEDIATE 
GO

-- Primeiro determine o número e os nomes dos arquivos no backup.
-- BKP_PROD_09062022 é o nome do dispositivo de backup. 
RESTORE FILELISTONLY  
   FROM DISK = 'E:\Backup\Daki\DB01$DAKI\WMSRXDaki\FULL\JOKR-BD01_WMSRX_DAKI_FULL20230515_105000.BAK' 
--Restaurar os arquivos para WMSRX_TESTE. 
RESTORE DATABASE WMSRX_Netsuite  
   FROM DISK = 'E:\Backup\Daki\DB01$DAKI\WMSRXDaki\FULL\JOKR-BD01_WMSRX_DAKI_FULL20230515_105000.BAK'
   WITH RECOVERY,REPLACE,  
   MOVE 'DisbbyBase_Data' TO 'F:\data\Daki\WMSRX_Netsuite.mdf',
   MOVE 'DisbbyBase_Log' TO 'G:\log\Daki\WMSRX_Netsuite_0.ldf', 
   STATS = 10 --Stats = 10 indica que ele mostrará o progresso da restauração
GO  

ALTER DATABASE WMSRX_Netsuite SET ONLINE
GO
