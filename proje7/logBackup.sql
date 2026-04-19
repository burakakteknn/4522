/*
    LOG BACKUP
*/

USE msdb;
GO

EXEC sp_add_job @job_name = N'Log Backup - AdventureWorks2022';

EXEC sp_add_jobstep
    @job_name = N'Log Backup - AdventureWorks2022',
    @step_name = N'Log Backup Al',
    @command = N'DECLARE @path NVARCHAR(500);
SET @path = N''C:\Backups\Log\AW_Log_'' + CONVERT(VARCHAR,GETDATE(),112) + ''_'' + REPLACE(CONVERT(VARCHAR,GETDATE(),108),'':'','''') + ''.trn'';
BACKUP LOG AdventureWorks2022 TO DISK = @path
WITH INIT, COMPRESSION, STATS = 10;';

EXEC sp_add_schedule
    @schedule_name = N'Her 1 Saatte Bir',
    @freq_type = 4,
    @freq_interval = 1,
    @freq_subday_type = 8,
    @freq_subday_interval = 1,
    @active_start_time = 000000;

EXEC sp_attach_schedule
    @job_name = N'Log Backup - AdventureWorks2022',
    @schedule_name = N'Her 1 Saatte Bir';

EXEC sp_add_jobserver
    @job_name = N'Log Backup - AdventureWorks2022';
GO