USE msdb;
GO

EXEC sp_add_job @job_name = N'Yedekleme Durum Raporu';

EXEC sp_add_jobstep
    @job_name = N'Yedekleme Durum Raporu',
    @step_name = N'Rapor Olustur',
    @subsystem = N'CmdExec',
    @command = N'sqlcmd -S localhost -E -Q "EXEC msdb.dbo.sp_BackupRaporu" -o "C:\Backups\rapor.txt"';

EXEC sp_add_schedule
    @schedule_name = N'Her Sabah 06:00',
    @freq_type = 4,
    @freq_interval = 1,
    @active_start_time = 060000;

EXEC sp_attach_schedule
    @job_name = N'Yedekleme Durum Raporu',
    @schedule_name = N'Her Sabah 06:00';

EXEC sp_add_jobserver
    @job_name = N'Yedekleme Durum Raporu';
GO