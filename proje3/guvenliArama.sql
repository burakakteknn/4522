CREATE PROCEDURE GuvenliArama (@Soyad NVARCHAR(100))
AS
BEGIN
    SELECT FirstName, LastName FROM Person.Person WHERE LastName = @Soyad;
END