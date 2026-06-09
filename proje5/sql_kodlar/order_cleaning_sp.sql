CREATE OR ALTER PROCEDURE sp_ETL_Transform_Orders
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @StartTime DATETIME = GETDATE();
    DECLARE @RecordsIn INT, @RecordsOut INT, @RecordsRej INT = 0;

    SELECT @RecordsIn = COUNT(*) FROM SalesSource_Dirty.dbo.Orders_Raw;

    DROP TABLE IF EXISTS #Orders_Staging;

    SELECT
        OrderID,
        CustomerID,
        LTRIM(RTRIM(ISNULL(ProductName, '')))                AS ProductName,
        -- 'NULL' string'ini de yakala, sonra TRY_CAST uygula
        TRY_CAST(
            CASE WHEN LTRIM(RTRIM(ISNULL(Quantity,''))) = 'NULL' 
                 THEN NULL 
                 ELSE LTRIM(RTRIM(Quantity)) 
            END AS INT
        )                                                    AS Quantity,
        -- Virgül→nokta, 'NULL' string, para birimi temizle
        TRY_CAST(
            REPLACE(
                REPLACE(
                    CASE WHEN LTRIM(RTRIM(ISNULL(UnitPrice,''))) = 'NULL'
                         THEN NULL
                         ELSE LTRIM(RTRIM(UnitPrice))
                    END,
                ',', '.'),   -- virgülü noktaya çevir
            'TL', '')        -- TL harflerini sil
        AS DECIMAL(10,2))                                    AS UnitPrice,
        CASE
            WHEN OrderDate LIKE '[0-9][0-9]/[0-9][0-9]/[0-9][0-9][0-9][0-9]'
                THEN TRY_CONVERT(DATE, OrderDate, 101)
            WHEN OrderDate LIKE '[0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]'
                THEN TRY_CONVERT(DATE, OrderDate, 120)
            WHEN OrderDate LIKE '[0-9][0-9].[0-9][0-9].[0-9][0-9][0-9][0-9]'
                THEN TRY_CONVERT(DATE, OrderDate, 104)
            WHEN OrderDate LIKE '[0-9][0-9][0-9][0-9]/[0-9][0-9]/[0-9][0-9]'
                THEN TRY_CONVERT(DATE, REPLACE(OrderDate,'/','-'), 120)
            ELSE NULL
        END                                                  AS OrderDate,
        CASE UPPER(LTRIM(RTRIM(ISNULL(Status,''))))
            WHEN 'COMPLETED'   THEN 'Completed'
            WHEN 'TAMAMLANDI'  THEN 'Completed'
            WHEN 'PENDING'     THEN 'Pending'
            WHEN 'SHIPPED'     THEN 'Shipped'
            WHEN 'CANCELLED'   THEN 'Cancelled'
            WHEN 'CANCELED'    THEN 'Cancelled'
            ELSE 'Unknown'
        END                                                  AS Status,
        ROW_NUMBER() OVER (
            PARTITION BY OrderID
            ORDER BY OrderID
        )                                                    AS RowNum
    INTO #Orders_Staging
    FROM SalesSource_Dirty.dbo.Orders_Raw;

    -- ============================================================
    -- REJECT kontrolleri — hepsi dönüştürülmüş staging'den
    -- ============================================================

    -- 1) Quantity dönüştürülemedi
    INSERT INTO ETL_Rejected_Records (SourceTable, SourceData, RejectReason)
    SELECT 'Orders_Raw',
           CONCAT('OrderID=', OrderID, ', Qty=', ISNULL(CAST(Quantity AS VARCHAR),'NULL')),
           'Quantity sayıya dönüştürülemedi veya NULL'
    FROM #Orders_Staging
    WHERE Quantity IS NULL;

    -- 2) Sıfır veya negatif Quantity
    INSERT INTO ETL_Rejected_Records (SourceTable, SourceData, RejectReason)
    SELECT 'Orders_Raw',
           CONCAT('OrderID=', OrderID, ', Qty=', CAST(Quantity AS VARCHAR)),
           'Quantity sıfır veya negatif'
    FROM #Orders_Staging
    WHERE Quantity IS NOT NULL AND Quantity <= 0;

    -- 3) Negatif, sıfır veya dönüştürülemeyen UnitPrice
    INSERT INTO ETL_Rejected_Records (SourceTable, SourceData, RejectReason)
    SELECT 'Orders_Raw',
           CONCAT('OrderID=', OrderID, ', Price=', ISNULL(CAST(UnitPrice AS VARCHAR),'NULL')),
           'UnitPrice geçersiz (sıfır, negatif veya dönüştürülemedi)'
    FROM #Orders_Staging
    WHERE ISNULL(UnitPrice, 0) <= 0;

    -- 4) Orphan CustomerID
    INSERT INTO ETL_Rejected_Records (SourceTable, SourceData, RejectReason)
    SELECT 'Orders_Raw',
           CONCAT('OrderID=', o.OrderID, ', CustomerID=', o.CustomerID),
           'CustomerID hedef tabloda bulunamadı (orphan)'
    FROM #Orders_Staging o
    WHERE NOT EXISTS (
        SELECT 1 FROM SalesTarget_Clean.dbo.Customers_Clean c
        WHERE c.CustomerID = o.CustomerID
    );

    -- 5) Geçersiz Status
    INSERT INTO ETL_Rejected_Records (SourceTable, SourceData, RejectReason)
    SELECT 'Orders_Raw',
           CONCAT('OrderID=', OrderID, ', Status=', ISNULL(Status,'NULL')),
           'Tanımlanamayan sipariş durumu'
    FROM #Orders_Staging
    WHERE Status = 'Unknown';

    -- 6) NULL veya boş ürün adı
    INSERT INTO ETL_Rejected_Records (SourceTable, SourceData, RejectReason)
    SELECT 'Orders_Raw',
           CONCAT('OrderID=', OrderID, ', Product=', ISNULL(ProductName,'NULL')),
           'ProductName NULL veya boş'
    FROM #Orders_Staging
    WHERE ISNULL(ProductName, '') = '';

    -- 7) Duplicate sipariş
    INSERT INTO ETL_Rejected_Records (SourceTable, SourceData, RejectReason)
    SELECT 'Orders_Raw',
           CONCAT('OrderID=', OrderID),
           'Duplicate sipariş kaydı'
    FROM #Orders_Staging
    WHERE RowNum > 1;

    -- ============================================================
    -- Temiz kayıtları yükle
    -- ============================================================
    INSERT INTO SalesTarget_Clean.dbo.Orders_Clean
        (OrderID, CustomerID, ProductName, Quantity, UnitPrice, OrderDate, Status)
    SELECT
        OrderID, CustomerID, ProductName, Quantity, UnitPrice, OrderDate, Status
    FROM #Orders_Staging o
    WHERE RowNum = 1
      AND ISNULL(Quantity, 0)     > 0
      AND ISNULL(UnitPrice, 0)    > 0
      AND ISNULL(ProductName, '') <> ''
      AND Status                  <> 'Unknown'
      AND EXISTS (
            SELECT 1 FROM SalesTarget_Clean.dbo.Customers_Clean c
            WHERE c.CustomerID = o.CustomerID)
      AND NOT EXISTS (
            SELECT 1 FROM SalesTarget_Clean.dbo.Orders_Clean oc
            WHERE oc.OrderID = o.OrderID);

    SELECT @RecordsOut = COUNT(*) FROM SalesTarget_Clean.dbo.Orders_Clean;
    SELECT @RecordsRej = COUNT(*) 
    FROM SalesTarget_Clean.dbo.ETL_Rejected_Records 
    WHERE SourceTable = 'Orders_Raw';

    INSERT INTO SalesTarget_Clean.dbo.ETL_Log 
        (StepName, RecordsIn, RecordsOut, RecordsRej, StartTime, EndTime, Status)
    VALUES 
        ('Transform_Orders', @RecordsIn, @RecordsOut, @RecordsRej, @StartTime, GETDATE(), 'SUCCESS');

    PRINT '=== Sipariş ETL Tamamlandı ===';
    PRINT 'Gelen kayıt    : ' + CAST(@RecordsIn  AS VARCHAR);
    PRINT 'Yüklenen kayıt : ' + CAST(@RecordsOut AS VARCHAR);
    PRINT 'Reddedilen     : ' + CAST(@RecordsRej AS VARCHAR);
END;
GO