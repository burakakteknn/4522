/*
    FULL BACKUP
*/

USE msdb;
GO

EXEC sp_add_job @job_name = N'Full Backup - AdventureWorks2022';

EXEC sp_add_jobstep
    @job_name = N'Full Backup - AdventureWorks2022',
    @step_name = N'Full Backup Al',
    @command = N'DECLARE @path NVARCHAR(500);
SET @path = N''C:\Backups\Full\AW_Full_'' + CONVERT(VARCHAR,GETDATE(),112) + ''_'' + REPLACE(CONVERT(VARCHAR,GETDATE(),108),'':'','''') + ''.bak'';
BACKUP DATABASE AdventureWorks2022 TO DISK = @path
WITH INIT, COMPRESSION, STATS = 10;';

EXEC sp_add_schedule
    @schedule_name = N'Her Gece 02:00',
    @freq_type = 4,
    @freq_interval = 1,
    @active_start_time = 020000;

EXEC sp_attach_schedule
    @job_name = N'Full Backup - AdventureWorks2022',
    @schedule_name = N'Her Gece 02:00';

EXEC sp_add_jobserver
    @job_name = N'Full Backup - AdventureWorks2022';
GO