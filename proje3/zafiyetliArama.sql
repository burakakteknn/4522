CREATE PROCEDURE ZafiyetliArama (@Soyad NVARCHAR(100))
AS
BEGIN
    DECLARE @Sorgu NVARCHAR(MAX) = 'SELECT FirstName, LastName FROM Person.Person WHERE LastName = ''' + @Soyad + '''';
    EXEC(@Sorgu);
END;

