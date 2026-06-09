BACKUP DATABASE AdventureWorks2022
TO DISK = 'C:\Backups\Full\AW_Full.bak'
WITH FORMAT,
     NAME = 'AdventureWorks2022 - Full Backup',
     STATS = 10;