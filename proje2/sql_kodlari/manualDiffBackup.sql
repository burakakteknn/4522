BACKUP DATABASE AdventureWorks2022
TO DISK = 'C:\Backups\Diff\AW_Diff.bak'
WITH DIFFERENTIAL,
     NAME = 'AdventureWorks2022 - Differential Backup',
     STATS = 10;