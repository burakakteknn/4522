-- Temiz Sipariş Verisi Kalite Kontrolü

SELECT
    COUNT(*)                                                AS [Toplam Sipariş],
    COUNT(DISTINCT CustomerID)                              AS [Sipariş Veren Müşteri],
    COUNT(DISTINCT ProductName)                             AS [Farklı Ürün],
    SUM(Quantity)                                           AS [Toplam Adet],
    CAST(SUM(Quantity * UnitPrice) AS DECIMAL(12,2))        AS [Toplam Ciro (TL)],
    CAST(AVG(UnitPrice) AS DECIMAL(10,2))                   AS [Ortalama Birim Fiyat],
    MIN(UnitPrice)                                          AS [Min Fiyat],
    MAX(UnitPrice)                                          AS [Max Fiyat],
    MIN(OrderDate)                                          AS [İlk Sipariş],
    MAX(OrderDate)                                          AS [Son Sipariş]
FROM Orders_Clean;