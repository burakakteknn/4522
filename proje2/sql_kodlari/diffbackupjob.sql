USE msdb;
EXEC sp_add_job @job_name = 'AW - Daily Diff Backup';

EXEC sp_add_jobstep
    @job_name = 'AW - Daily Diff Backup',
    @step_name = 'Diff Backup Al',
    @command = '
        DECLARE @path NVARCHAR(500);
        SET @path = ''C:\Backups\Diff\AW_Diff_''
            + CONVERT(VARCHAR,GETDATE(),112) + ''.bak'';
        BACKUP DATABASE AdventureWorks2022
        TO DISK = @path
        WITH DIFFERENTIAL, STATS = 10;';

EXEC sp_add_schedule
    @schedule_name = 'Günlük 03:00',
    @freq_type = 4,          -- Günlük
    @freq_interval = 1,
    @active_start_time = 30000;  -- 03:00

EXEC sp_attach_schedule
    @job_name = 'AW - Daily Diff Backup',
    @schedule_name = 'Günlük 03:00';

EXEC sp_add_jobserver @job_name = 'AW - Daily Diff Backup';