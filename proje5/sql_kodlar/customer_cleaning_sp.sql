USE SalesTarget_Clean;
GO

CREATE OR ALTER PROCEDURE sp_ETL_Transform_Customers
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @StartTime DATETIME = GETDATE();
    DECLARE @RecordsIn INT, @RecordsOut INT, @RecordsRej INT = 0;

    SELECT @RecordsIn = COUNT(*) FROM SalesSource_Dirty.dbo.Customers_Raw;

-----------------------------------------------------------------------------------------------------------------

    DROP TABLE IF EXISTS #Customers_Staging;

    SELECT
        CustomerID,
        -- Baştaki/sondaki boşlukları temizle, ismi Title Case yap
        LTRIM(RTRIM(FirstName))                         AS FirstName,
        LTRIM(RTRIM(LastName))                          AS LastName,
        -- Email: küçük harfe çevir, boşluk temizle
        LOWER(LTRIM(RTRIM(Email)))                      AS Email,
        -- Telefon: sadece rakam bırak, başa 0 ekle
        '0' + RIGHT(REPLACE(REPLACE(REPLACE(REPLACE(
            Phone, '-', ''), ' ', ''), '(', ''), ')', ''), 10) AS Phone,
        -- Tarih: farklı formatları dönüştür
        CASE
            WHEN BirthDate LIKE '[0-9][0-9]/[0-9][0-9]/[0-9][0-9][0-9][0-9]'
                THEN TRY_CONVERT(DATE, BirthDate, 103)  -- DD/MM/YYYY
            WHEN BirthDate LIKE '[0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]'
                THEN TRY_CONVERT(DATE, BirthDate, 120)  -- YYYY-MM-DD
            WHEN BirthDate LIKE '[0-9][0-9].[0-9][0-9].[0-9][0-9][0-9][0-9]'
                THEN TRY_CONVERT(DATE, BirthDate, 104)  -- DD.MM.YYYY
            ELSE NULL
        END                                             AS BirthDate,
        -- Şehir: Title Case
        UPPER(LEFT(LTRIM(RTRIM(City)),1))
            + LOWER(SUBSTRING(LTRIM(RTRIM(City)),2,100)) AS City,
        -- Ülke: standart değere çevir
        CASE UPPER(LTRIM(RTRIM(Country)))
            WHEN 'TR'      THEN 'Turkey'
            WHEN 'TURKEY'  THEN 'Turkey'
            WHEN 'TÜRKİYE' THEN 'Turkey'
            WHEN 'TURKİYE' THEN 'Turkey'
            ELSE LTRIM(RTRIM(Country))
        END                                             AS Country,
        TRY_CONVERT(DATE, CreatedAt, 120)               AS CreatedAt,
        -- Duplicate tespiti için sıra numarası
        ROW_NUMBER() OVER (
            PARTITION BY LOWER(LTRIM(RTRIM(Email)))
            ORDER BY CustomerID
        )                                               AS RowNum
    INTO #Customers_Staging
    FROM SalesSource_Dirty.dbo.Customers_Raw;


-----------------------------------------------------------------------------------------------------------------

    -- 1) FirstName NULL veya boş
    INSERT INTO ETL_Rejected_Records (SourceTable, SourceData, RejectReason)
    SELECT 'Customers_Raw',
           CONCAT('CustomerID=', CustomerID, ', Name=', ISNULL(FirstName,'NULL')),
           'FirstName NULL veya boş'
    FROM #Customers_Staging
    WHERE ISNULL(FirstName, '') = '';

    -- 2) LastName NULL veya boş
    INSERT INTO ETL_Rejected_Records (SourceTable, SourceData, RejectReason)
    SELECT 'Customers_Raw',
           CONCAT('CustomerID=', CustomerID, ', LastName=', ISNULL(LastName,'NULL')),
           'LastName NULL veya boş'
    FROM #Customers_Staging
    WHERE ISNULL(LastName, '') = '' AND ISNULL(FirstName,'') <> '';

    -- 3) Geçersiz email formatı
    INSERT INTO ETL_Rejected_Records (SourceTable, SourceData, RejectReason)
    SELECT 'Customers_Raw',
           CONCAT('CustomerID=', CustomerID, ', Email=', ISNULL(Email,'NULL')),
           'Geçersiz veya boş email formatı'
    FROM #Customers_Staging
    WHERE Email NOT LIKE '%_@_%.__%' OR ISNULL(Email,'') = '';

    -- 4) Duplicate kayıtlar (aynı email, 2. ve sonrası)
    INSERT INTO ETL_Rejected_Records (SourceTable, SourceData, RejectReason)
    SELECT 'Customers_Raw',
           CONCAT('CustomerID=', CustomerID, ', Email=', Email),
           'Duplicate kayıt (aynı email)'
    FROM #Customers_Staging
    WHERE RowNum > 1;

    -- 5) Mantıksız doğum tarihi (18 yaşından küçük veya 100 yaşından büyük)
    INSERT INTO ETL_Rejected_Records (SourceTable, SourceData, RejectReason)
    SELECT 'Customers_Raw',
           CONCAT('CustomerID=', CustomerID, ', BirthDate=', ISNULL(BirthDate,'NULL')),
           'Mantıksız doğum tarihi (18 yaş altı veya 100 yaş üstü)'
    FROM #Customers_Staging
    WHERE BirthDate IS NOT NULL
      AND (DATEDIFF(YEAR, BirthDate, GETDATE()) < 18
        OR DATEDIFF(YEAR, BirthDate, GETDATE()) > 100);

-----------------------------------------------------------------------------------------------------------------

    INSERT INTO Customers_Clean
        (CustomerID, FirstName, LastName, Email, Phone, BirthDate, City, Country, CreatedAt)
    SELECT
        CustomerID, FirstName, LastName, Email, Phone, BirthDate, City, Country, CreatedAt
    FROM #Customers_Staging s
    WHERE RowNum = 1                            -- duplicate değil
      AND ISNULL(FirstName,'')  <> ''           -- isim var
      AND ISNULL(LastName,'')   <> ''           -- soyisim var
      AND Email LIKE '%_@_%.__%'                -- email geçerli
      AND (BirthDate IS NULL                    -- tarih yoksa geç
           OR (DATEDIFF(YEAR, BirthDate, GETDATE()) BETWEEN 18 AND 100))
      AND NOT EXISTS (                          -- hedefte zaten yoksa
            SELECT 1 FROM Customers_Clean c
            WHERE c.CustomerID = s.CustomerID);

    SELECT @RecordsOut = COUNT(*) FROM Customers_Clean;
    SELECT @RecordsRej = COUNT(*) FROM ETL_Rejected_Records WHERE SourceTable = 'Customers_Raw';

-----------------------------------------------------------------------------------------------------------------

    INSERT INTO ETL_Log (StepName, RecordsIn, RecordsOut, RecordsRej, StartTime, EndTime, Status)
    VALUES ('Transform_Customers', @RecordsIn, @RecordsOut, @RecordsRej, @StartTime, GETDATE(), 'SUCCESS');

    PRINT '=== Müşteri ETL Tamamlandı ===';
    PRINT 'Gelen kayıt    : ' + CAST(@RecordsIn  AS VARCHAR);
    PRINT 'Yüklenen kayıt : ' + CAST(@RecordsOut AS VARCHAR);
    PRINT 'Reddedilen     : ' + CAST(@RecordsRej AS VARCHAR);
END;
GO