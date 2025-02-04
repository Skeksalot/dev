﻿CREATE TABLE [dbo].[Table2]
(
	[id] INT NOT NULL PRIMARY KEY, 
    [category] INT NOT NULL DEFAULT 0, 
    [sortorder] INT NOT NULL DEFAULT 0, 
    [fullname] CHAR(254) NOT NULL, 
    [shortname] CHAR(255) NOT NULL, 
    [idnumber] CHAR(100) NOT NULL, 
    [summary] TEXT NULL, 
    [summaryformat] INT NOT NULL DEFAULT 0, 
    [format] CHAR(21) NOT NULL DEFAULT 'topics', 
    [showgrades] INT NOT NULL DEFAULT 1, 
    [newsitems] INT NOT NULL DEFAULT 1, 
    [startdate] INT NOT NULL DEFAULT 0, 
    [marker] INT NOT NULL DEFAULT 0, 
    [maxbytes] INT NOT NULL DEFAULT 0, 
    [legacyfiles] INT NOT NULL DEFAULT 0, 
    [showreports] INT NOT NULL DEFAULT 0, 
    [visible] INT NOT NULL DEFAULT 1, 
    [visibleold] INT NOT NULL DEFAULT 1, 
    [groupmode] INT NOT NULL DEFAULT 0, 
    [groupmodeforce] INT NOT NULL DEFAULT 0, 
    [defaultgroupingid] INT NOT NULL DEFAULT 0, 
    [lang] CHAR(30) NOT NULL, 
    [calendartype] CHAR(30) NOT NULL, 
    [theme] CHAR(50) NOT NULL, 
    [timecreated] INT NOT NULL DEFAULT 0, 
    [timemodified] INT NOT NULL DEFAULT 0, 
    [requested] INT NOT NULL DEFAULT 0, 
    [enablecompletion] INT NOT NULL DEFAULT 0, 
    [completionnotify] INT NOT NULL DEFAULT 0, 
    [cacherev] INT NOT NULL DEFAULT 0
)
