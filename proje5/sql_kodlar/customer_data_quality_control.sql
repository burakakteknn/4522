-- Temiz Müşteri Verisi Kalite Kontrolü

SELECT
    COUNT(*)                                                AS [Toplam Müşteri],
    SUM(CASE WHEN Phone    IS NULL THEN 1 ELSE 0 END)       AS [Telefonsuz],
    SUM(CASE WHEN BirthDate IS NULL THEN 1 ELSE 0 END)      AS [Doğum Tarihi Yok],
    SUM(CASE WHEN City     IS NULL THEN 1 ELSE 0 END)       AS [Şehirsiz],
    COUNT(DISTINCT Country)                                 AS [Farklı Ülke Sayısı],
    COUNT(DISTINCT City)                                    AS [Farklı Şehir Sayısı],
    MIN(BirthDate)                                          AS [En Eski Doğum],
    MAX(BirthDate)                                          AS [En Genç Doğum],
    MIN(CreatedAt)                                          AS [İlk Kayıt Tarihi],
    MAX(CreatedAt)                                          AS [Son Kayıt Tarihi]
FROM Customers_Clean;