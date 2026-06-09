BACKUP LOG AdventureWorks2022
TO DISK = 'C:\Backups\Log\AW_Log.trn'
WITH NAME = 'AdventureWorks2022 - Log Backup',
     STATS = 10;