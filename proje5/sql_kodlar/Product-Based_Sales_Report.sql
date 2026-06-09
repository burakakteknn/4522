-- Ürün Bazlı Satış Raporu

SELECT
    ProductName                                             AS [Ürün],
    COUNT(*)                                                AS [Sipariş Adedi],
    SUM(Quantity)                                           AS [Toplam Adet],
    CAST(AVG(UnitPrice) AS DECIMAL(10,2))                   AS [Ort. Fiyat (TL)],
    CAST(SUM(Quantity * UnitPrice) AS DECIMAL(12,2))        AS [Toplam Ciro (TL)]
FROM Orders_Clean
GROUP BY ProductName
ORDER BY SUM(Quantity * UnitPrice) DESC;