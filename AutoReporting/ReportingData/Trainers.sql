CREATE TABLE [dbo].[Trainers]
(
	[Id] INT NOT NULL PRIMARY KEY, 
    [firstname] TEXT NOT NULL, 
    [lastname] TEXT NOT NULL, 
    [reportname] TEXT NOT NULL, 
    [email] TEXT NOT NULL, 
    [facultyhead] TEXT NULL, 
    [away] BIT NOT NULL DEFAULT 0
)
