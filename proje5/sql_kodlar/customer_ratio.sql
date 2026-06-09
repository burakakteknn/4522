-- Şehir Bazlı Müşteri Dağılımı

SELECT TOP 10
    City                        AS [Şehir],
    COUNT(*)                    AS [Müşteri Sayısı],
    CAST(COUNT(*) * 100.0 / 
        (SELECT COUNT(*) FROM Customers_Clean) 
        AS DECIMAL(5,1))        AS [Oran %]
FROM Customers_Clean
GROUP BY City
ORDER BY COUNT(*) DESC;