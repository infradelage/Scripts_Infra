DECLARE 
@DISK VARCHAR(200)

SELECT @DISK = 'C:\Backup_SQL\RNSRV10\WMSRX_HML\FULL\'+'RNSRV10_WMSRX_HML_FULL_PRE_LIMPEZA_' 
+ CONVERT(NVARCHAR(20),GETDATE(),112) + '_' + REPLACE(CONVERT(NVARCHAR(20),GETDATE(),108),':','') + '.BAK' 

print @DISK

BACKUP DATABASE WMSRX_HML TO  DISK = @DISK WITH NOFORMAT, INIT,
NAME = N'WMSRX-Backup_RNSRV10_WMSRX_HML_FULL_PRE_LIMPEZA_', SKIP, NOREWIND, NOUNLOAD, STATS = 10
GO