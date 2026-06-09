USE msdb;
EXEC sp_add_job @job_name = 'AW - Log Backup';

EXEC sp_add_jobstep
    @job_name = 'AW - Log Backup',
    @step_name = 'Log Backup Al',
    @command = '
        DECLARE @path NVARCHAR(500);
        SET @path = ''C:\Backups\Log\AW_Log_''
            + CONVERT(VARCHAR,GETDATE(),112)
            + REPLACE(CONVERT(VARCHAR(8),GETDATE(),108),'':'','''') + ''.trn'';
        BACKUP LOG AdventureWorks2022
        TO DISK = @path WITH STATS = 10;';

EXEC sp_add_schedule
    @schedule_name = '4 Saatte Bir',
    @freq_type = 4,
    @freq_interval = 1,
    @freq_subday_type = 8,   -- Saatlik aralık
    @freq_subday_interval = 4;

EXEC sp_attach_schedule
    @job_name = 'AW - Log Backup',
    @schedule_name = '4 Saatte Bir';

EXEC sp_add_jobserver @job_name = 'AW - Log Backup';