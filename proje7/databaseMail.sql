EXEC sp_configure 'show advanced options', 1;
RECONFIGURE;
EXEC sp_configure 'Database Mail XPs', 1;
RECONFIGURE;

EXEC msdb.dbo.sysmail_add_profile_sp
    @profile_name = 'SQLMailProfile',
    @description = 'SQL Server Mail Profili';

EXEC msdb.dbo.sysmail_add_account_sp
    @account_name = 'GmailAccount',
    @email_address = @gmail_address,
    @display_name = 'SQL Server Alert',
    @mailserver_name = 'smtp.gmail.com',
    @port = 587,
    @enable_ssl = 1,
    @username = @gmail_address,
    @password = @gmail_password;

EXEC msdb.dbo.sysmail_add_profileaccount_sp
    @profile_name = 'SQLMailProfile',
    @account_name = 'GmailAccount',
    @sequence_number = 1;

EXEC msdb.dbo.sysmail_add_principalprofile_sp
    @profile_name = 'SQLMailProfile',
    @principal_name = 'public',
    @is_default = 1;