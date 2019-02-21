CREATE TABLE [dbo].[Table5]
(
	[id] INT NOT NULL PRIMARY KEY, 
    [course] INT NOT NULL DEFAULT 0, 
    [module] INT NOT NULL DEFAULT 0, 
    [instance] INT NOT NULL DEFAULT 0, 
    [section] INT NOT NULL DEFAULT 0, 
    [idnumber] CHAR(100) NULL, 
    [added] INT NOT NULL DEFAULT 0, 
    [score] INT NOT NULL DEFAULT 0, 
    [indent] INT NOT NULL DEFAULT 0, 
    [visible] INT NOT NULL DEFAULT 1, 
    [visibleold] INT NOT NULL DEFAULT 1, 
    [groupmode] INT NOT NULL DEFAULT 0, 
    [groupingid] INT NOT NULL DEFAULT 0, 
    [completion] INT NOT NULL DEFAULT 0, 
    [completiongradeitemnumber] INT NULL, 
    [completionview] INT NOT NULL DEFAULT 0, 
    [completionexpected] INT NOT NULL DEFAULT 0, 
    [showdescription] INT NOT NULL DEFAULT 0, 
    [availability] TEXT NULL
)
