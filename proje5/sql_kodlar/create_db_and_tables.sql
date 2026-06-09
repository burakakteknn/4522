
CREATE DATABASE SalesSource_Dirty;
GO

USE SalesSource_Dirty;
GO


CREATE TABLE Customers_Raw (
    CustomerID      INT,
    FirstName       NVARCHAR(100),
    LastName        NVARCHAR(100),
    Email           NVARCHAR(200),
    Phone           NVARCHAR(50),
    BirthDate       NVARCHAR(50),   -- Kasıtlı: DATE değil VARCHAR (format hatası için)
    City            NVARCHAR(100),
    Country         NVARCHAR(100),
    CreatedAt       NVARCHAR(50)    -- Kasıtlı: VARCHAR
);


CREATE TABLE Orders_Raw (
    OrderID         INT,
    CustomerID      INT,
    ProductName     NVARCHAR(200),
    Quantity        NVARCHAR(50),   -- Kasıtlı: sayı olması gerekirken VARCHAR
    UnitPrice       NVARCHAR(50),   -- Kasıtlı: VARCHAR
    OrderDate       NVARCHAR(50),
    Status          NVARCHAR(50)
);