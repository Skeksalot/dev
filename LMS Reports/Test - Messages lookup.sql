/*
https://lms.upskilled.edu.au/blocks/configurable_reports/editcomp.php?id=208
*/
SELECT Sender, Receiver, Subject, Full_Message, Time_Sent, Time_Read, Sender_Deleted, Receiver_Deleted
FROM (
(
	SELECT CONCAT( u.firstname, ' ', u.lastname ) Sender, CONCAT( u2.firstname, ' ', u2.lastname ) Receiver,
		Messages.subject Subject, Messages.fullmessage Full_Message,
		FROM_UNIXTIME(Messages.timecreated) Time_Sent,
		'' Time_Read,
		CASE
			WHEN Messages.timeuserfromdeleted IS NULL THEN ''
			WHEN Messages.timeuserfromdeleted = 0 THEN ''
			ELSE FROM_UNIXTIME(Messages.timeuserfromdeleted)
		END Sender_Deleted,
		CASE
			WHEN Messages.timeusertodeleted IS NULL THEN ''
			WHEN Messages.timeusertodeleted = 0 THEN ''
			ELSE FROM_UNIXTIME(Messages.timeusertodeleted)
		END Receiver_Deleted
		
	FROM (
		SELECT m.useridfrom, m.useridto, m.subject, m.fullmessage, m.fullmessagehtml, m.timecreated, m.timeuserfromdeleted, m.timeusertodeleted
		FROM (
			SELECT u.id
			FROM prefix_user u
			WHERE u.id = 4680
		) User
		JOIN prefix_message m ON ( m.useridfrom = User.id OR m.useridto = User.id )
	) Messages
	JOIN prefix_user u ON u.id = Messages.useridfrom
	JOIN prefix_user u2 ON u2.id = Messages.useridto
)
UNION
(
	SELECT CONCAT( u.firstname, ' ', u.lastname ) Sender, CONCAT( u2.firstname, ' ', u2.lastname ) Receiver,
		Messages.subject Subject, Messages.fullmessage Full_Message,
		FROM_UNIXTIME(Messages.timecreated) Time_Sent,
		FROM_UNIXTIME(Messages.timeread) Time_Read,
		CASE
			WHEN Messages.timeuserfromdeleted IS NULL THEN ''
			WHEN Messages.timeuserfromdeleted = 0 THEN ''
			ELSE FROM_UNIXTIME(Messages.timeuserfromdeleted)
		END Sender_Deleted,
		CASE
			WHEN Messages.timeusertodeleted IS NULL THEN ''
			WHEN Messages.timeusertodeleted = 0 THEN ''
			ELSE FROM_UNIXTIME(Messages.timeusertodeleted)
		END Receiver_Deleted
		
	FROM (
		SELECT m.useridfrom, m.useridto, m.subject, m.fullmessage, m.fullmessagehtml, m.timecreated, m.timeread, m.timeuserfromdeleted, m.timeusertodeleted
		FROM (
			SELECT u.id
			FROM prefix_user u
			WHERE u.id = 4680
		) User
		JOIN prefix_message_read m ON ( m.useridfrom = User.id OR m.useridto = User.id )
	) Messages
	JOIN prefix_user u ON u.id = Messages.useridfrom
	JOIN prefix_user u2 ON u2.id = Messages.useridto
)
) Merged

ORDER BY Merged.Time_Sent DESC