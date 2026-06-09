USE msdb;
EXEC sp_add_job @job_name = 'AW - Weekly Full Backup';

EXEC sp_add_jobstep
    @job_name = 'AW - Weekly Full Backup',
    @step_name = 'Full Backup Al',
    @command = N'DECLARE @path NVARCHAR(500);
               SET @path = N''C:\Backups\Full\AW_Full_'' + CONVERT(VARCHAR,GETDATE(),112) + ''_'' + REPLACE(CONVERT(VARCHAR,GETDATE(),108),'':'','''') + ''.bak'';
               BACKUP DATABASE AdventureWorks2022 TO DISK = @path
               WITH INIT, COMPRESSION, STATS = 10;';

EXEC sp_add_schedule
    @schedule_name = N'Her Pazar 02:00',
    @freq_type = 8,          -- Haftalık
    @freq_interval = 1,      -- Pazar
    @freq_recurrence_factor = 1, 
    @active_start_time = 20000;  -- 02:00

EXEC sp_attach_schedule
    @job_name = 'AW - Weekly Full Backup',
    @schedule_name = N'Her Pazar 02:00';

EXEC sp_add_jobserver @job_name = 'AW - Weekly Full Backup';