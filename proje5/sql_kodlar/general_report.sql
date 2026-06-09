--Genel ETL Özet Raporu

USE SalesTarget_Clean;
GO

SELECT 
    StepName                                            AS [ETL Adımı],
    RecordsIn                                           AS [Gelen Kayıt],
    RecordsOut                                          AS [Yüklenen Kayıt],
    RecordsRej                                          AS [Reddedilen Kayıt],
    CAST(RecordsOut * 100.0 / RecordsIn AS DECIMAL(5,1)) AS [Başarı Oranı %],
    CAST(RecordsRej * 100.0 / RecordsIn AS DECIMAL(5,1)) AS [Red Oranı %],
    DATEDIFF(MILLISECOND, StartTime, EndTime)           AS [Süre (ms)],
    Status                                              AS [Durum],
    CONVERT(VARCHAR, StartTime, 120)                    AS [Çalışma Zamanı]
FROM ETL_Log
ORDER BY LogID;