-- Red sebepleri
SELECT
    SourceTable                         AS [Kaynak Tablo],
    RejectReason                        AS [Red Sebebi],
    COUNT(*)                            AS [Kayıt Sayısı],
    CAST(COUNT(*) * 100.0 / 
        SUM(COUNT(*)) OVER (PARTITION BY SourceTable) 
        AS DECIMAL(5,1))                AS [Tablo İçi Oran %]
FROM ETL_Rejected_Records
GROUP BY SourceTable, RejectReason
ORDER BY SourceTable, COUNT(*) DESC;