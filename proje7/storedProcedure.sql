USE msdb;
GO

CREATE PROCEDURE sp_BackupRaporu
AS
BEGIN
    SELECT 
        database_name AS [Veritabanı],
        CASE type 
            WHEN 'D' THEN 'Full'
            WHEN 'I' THEN 'Differential'
            WHEN 'L' THEN 'Log'
        END AS [Yedek Tipi],
        backup_start_date AS [Başlangıç],
        backup_finish_date AS [Bitiş],
        CAST(backup_size/1024/1024 AS INT) AS [Boyut MB],
        CASE is_damaged 
            WHEN 0 THEN 'Sağlıklı'
            ELSE 'Hatalı'
        END AS [Durum]
    FROM backupset
    WHERE backup_start_date >= DATEADD(DAY,-1,GETDATE())
    ORDER BY backup_finish_date DESC;
END
GO