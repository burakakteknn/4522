CREATE DATABASE SalesTarget_Clean;
GO

USE SalesTarget_Clean;
GO

CREATE TABLE Customers_Clean (
    CustomerID   INT PRIMARY KEY,
    FirstName    NVARCHAR(100)  NOT NULL,
    LastName     NVARCHAR(100)  NOT NULL,
    Email        NVARCHAR(200)  NOT NULL,
    Phone        NVARCHAR(20),
    BirthDate    DATE,
    City         NVARCHAR(100),
    Country      NVARCHAR(50),
    CreatedAt    DATE,
    ETL_LoadDate DATETIME DEFAULT GETDATE()
);

CREATE TABLE Orders_Clean (
    OrderID      INT PRIMARY KEY,
    CustomerID   INT NOT NULL,
    ProductName  NVARCHAR(200) NOT NULL,
    Quantity     INT NOT NULL,
    UnitPrice    DECIMAL(10,2) NOT NULL,
    OrderDate    DATE,
    Status       NVARCHAR(20),
    ETL_LoadDate DATETIME DEFAULT GETDATE()
);

-- Hata/red tablosu (temizlenemeyen kayıtlar)
CREATE TABLE ETL_Rejected_Records (
    RejectedID   INT IDENTITY(1,1) PRIMARY KEY,
    SourceTable  NVARCHAR(100),
    SourceData   NVARCHAR(MAX),
    RejectReason NVARCHAR(500),
    RejectedAt   DATETIME DEFAULT GETDATE()
);

-- ETL Log tablosu
CREATE TABLE ETL_Log (
    LogID        INT IDENTITY(1,1) PRIMARY KEY,
    StepName     NVARCHAR(200),
    RecordsIn    INT,
    RecordsOut   INT,
    RecordsRej   INT,
    StartTime    DATETIME,
    EndTime      DATETIME,
    Status       NVARCHAR(20)
);