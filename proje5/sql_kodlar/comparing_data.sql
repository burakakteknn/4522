-- Kaynak vs Hedef Karşılaştırması

SELECT
    'Customers' AS [Tablo],
    (SELECT COUNT(*) FROM SalesSource_Dirty.dbo.Customers_Raw)  AS [Kaynak Kayıt],
    (SELECT COUNT(*) FROM Customers_Clean)                       AS [Temiz Kayıt],
    (SELECT COUNT(*) FROM ETL_Rejected_Records 
     WHERE SourceTable = 'Customers_Raw')                        AS [Reddedilen],
    (SELECT COUNT(*) FROM SalesSource_Dirty.dbo.Customers_Raw) -
    (SELECT COUNT(*) FROM Customers_Clean) -
    (SELECT COUNT(*) FROM ETL_Rejected_Records 
     WHERE SourceTable = 'Customers_Raw')                        AS [Fark]
UNION ALL
SELECT
    'Orders',
    (SELECT COUNT(*) FROM SalesSource_Dirty.dbo.Orders_Raw),
    (SELECT COUNT(*) FROM Orders_Clean),
    (SELECT COUNT(*) FROM ETL_Rejected_Records 
     WHERE SourceTable = 'Orders_Raw'),
    (SELECT COUNT(*) FROM SalesSource_Dirty.dbo.Orders_Raw) -
    (SELECT COUNT(*) FROM Orders_Clean) -
    (SELECT COUNT(*) FROM ETL_Rejected_Records 
     WHERE SourceTable = 'Orders_Raw');