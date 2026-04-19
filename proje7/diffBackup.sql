/*
    DIFF BACKUP
*/

USE msdb;
GO

EXEC sp_add_job @job_name = N'Diff Backup - AdventureWorks2022';

EXEC sp_add_jobstep
    @job_name = N'Diff Backup - AdventureWorks2022',
    @step_name = N'Diff Backup Al',
    @command = N'DECLARE @path NVARCHAR(500);
SET @path = N''C:\Backups\Diff\AW_Diff_'' + CONVERT(VARCHAR,GETDATE(),112) + ''_'' + REPLACE(CONVERT(VARCHAR,GETDATE(),108),'':'','''') + ''.bak'';
BACKUP DATABASE AdventureWorks2022 TO DISK = @path
WITH DIFFERENTIAL, INIT, COMPRESSION, STATS = 10;';

EXEC sp_add_schedule
    @schedule_name = N'Her 6 Saatte Bir',
    @freq_type = 4,
    @freq_interval = 1,
    @freq_subday_type = 8,
    @freq_subday_interval = 6,
    @active_start_time = 000000;

EXEC sp_attach_schedule
    @job_name = N'Diff Backup - AdventureWorks2022',
    @schedule_name = N'Her 6 Saatte Bir';

EXEC sp_add_jobserver
    @job_name = N'Diff Backup - AdventureWorks2022';
GO