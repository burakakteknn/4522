USE AdventureWorks2022;
CREATE TABLE dbo.TestFelaketi (
    Id INT IDENTITY PRIMARY KEY,
    Mesaj NVARCHAR(100),
    Tarih DATETIME DEFAULT GETDATE()
);
INSERT INTO dbo.TestFelaketi (Mesaj) VALUES ('Bu veri kurtarılacak!');