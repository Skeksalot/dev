SELECT CONCAT( u.firstname, ' ', u.lastname ) Sender, CONCAT( u2.firstname, ' ', u2.lastname ) Receiver,
	Message.subject, Message.fullmessage, Message.fullmessagehtml,
	FROM_UNIXTIME(Message.timecreated) Time_Sent,
	FROM_UNIXTIME(Message.timeread) Time_Read,
	CASE
		WHEN Message.timeusertodeleted IS NULL THEN ''
		WHEN Message.timeusertodeleted = 0 THEN ''
		ELSE FROM_UNIXTIME(Message.timeuserfromdeleted)
	END Sender_Deleted,
	CASE
		WHEN Message.timeusertodeleted IS NULL THEN ''
		WHEN Message.timeusertodeleted = 0 THEN ''
		ELSE FROM_UNIXTIME(Message.timeusertodeleted)
	END Receiver_Deleted
	
FROM (
	SELECT m.useridfrom, m.useridto, m.subject, m.fullmessage, m.fullmessagehtml, m.timecreated, m.timeread, m.timeuserfromdeleted, m.timeusertodeleted
	FROM prefix_message_read m
	WHERE ( m.useridfrom = 20574 OR m.useridto = 20574 )
) Message
JOIN prefix_user u ON u.id = Message.useridfrom
JOIN prefix_user u2 ON u2.id = Message.useridto

ORDER BY Message.timecreated DESC