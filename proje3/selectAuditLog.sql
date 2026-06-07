SELECT 
    event_time AS [Tarih ve Saat], 
    server_principal_name AS [Kullanıcı], 
    database_name AS [Veritabanı], 
    object_name AS [Tablo], 
    statement AS [Çalıştırılan Sorgu]
FROM sys.fn_get_audit_file('C:\SQL_Audit_Logs\*.sqlaudit', DEFAULT, DEFAULT);