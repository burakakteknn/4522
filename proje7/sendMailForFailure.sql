USE msdb;
GO

EXEC sp_add_operator
    @name = N'sendMail',
    @email_address = N'destination mail';


EXEC sp_update_job
    @job_name = N'Full Backup - AdventureWorks2022',
    @notify_level_email = 2,       
    @notify_email_operator_name = N'sendMail';

EXEC sp_update_job
    @job_name = N'Diff Backup - AdventureWorks2022',
    @notify_level_email = 2,
    @notify_email_operator_name = N'sendMail';

EXEC sp_update_job
    @job_name = N'Log Backup - AdventureWorks2022',
    @notify_level_email = 2,
    @notify_email_operator_name = N'sendMail';