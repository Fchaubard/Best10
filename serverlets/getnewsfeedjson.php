<?php

//	getnewsfeedjson.php
//	fetches the newsfeed entries for a user.
	
	include("../headers/config_wolfpack.php");
	$sessid = $_REQUEST['session'];
	if($sessid==0){
		echo "not valid session";
		return;
	}
	$sql="SELECT * FROM users WHERE sessid LIKE '$sessid' LIMIT 1";
	$result=mysql_query($sql);
	$row=mysql_fetch_array($result);

	//if username exists
	if(mysql_num_rows($result)>0)
	{

			$_SESSION['phone']=$row['phone'];
			$_SESSION['fname']=$row['fname'];
			$_SESSION['lname']=$row['lname'];
			$_SESSION['adjective']=$row['adjective'];
			$_SESSION['status']=$row['status'];
			$_SESSION['lat']=$row['lat'];
			$_SESSION['long']=$row['long'];
			$_SESSION['chatid']=$row['chatid'];

	}
	else{
		echo "0"; //Invalid Login
		return;
	}
	
	//	Get a list of the 10 most recent newsfeed posts that a user would be intersted in
	//	Uses the DISTINCT and UNION MYSQL functions
	
	//Building the friendsPhoneNumberQueries string:
	$friendsPhoneNumberQueries = "";
	$phone = $_SESSION['phone'];
	$sql = "SELECT * FROM friendmapping WHERE myphone = $phone";  //grabs all the current user's friends
	$result=mysql_query($sql);
	while ($row = mysql_fetch_assoc($result)) {
		$phoneToAdd = $row['friendphone']; //grabs friend's phone number.
		$queryStringToAdd = "SELECT * FROM newsfeedmapping WHERE phoneNumber=$phoneToAdd ";
		$friendsPhoneNumberQueries = $friendsPhoneNumberQueries.$queryStringToAdd; //creates list of queries
	}
	
	//echo "News Feed Query: ".$friendsPhoneNumberQueries."\n";
	
	$friendsPhoneNumberQueries = str_replace(" SELECT"," UNION ALL SELECT",$friendsPhoneNumberQueries);
	
	$newsfeedquery = "SELECT DISTINCT newsfeednumber FROM ($friendsPhoneNumberQueries) newsfeedQueryTable ORDER BY newsfeednumber DESC LIMIT 10";
	
	//echo "News Feed Query: ".$newsfeedquery."\n";
	
	$newsfeed = array();
	$result = mysql_query($newsfeedquery);
	
	
	
	
	/*
	//Get a list of friends to search by:
	$phone = $_SESSION['phone']; //Current user's phone number.
	$friendListString = "phoneNumber = ".$phone;
	$sql = "SELECT * FROM friendmapping WHERE myphone = $phone";  //grabs all the current user's friends
	//echo "SQL QUERY: ".$sql."\n";
	$result=mysql_query($sql);
	while ($row = mysql_fetch_assoc($result)) {
		$phoneToAdd = $row['friendphone']; //grabs friend's phone number.
		//echo "Phone to Add: ".$phoneToAdd."\n";
		$friendListString = $friendListString." OR phoneNumber = ".$phoneToAdd; //creates list of numbers
	}
	//echo "Friend Phone Number String: ".$friendListString."\n";
	
	//	Initializing the newsfeed JSON data structure
	$newsfeed = array();

	$sql = "SELECT * FROM newsfeedmapping WHERE $friendListString ORDER BY newsfeednumber DESC LIMIT 10";
	//echo "SQL STATEMENT: ".$sql;
	
	$result=mysql_query($sql);
	*/
	
	$i = 0;
	while ($row = mysql_fetch_assoc($result)) {
		$messageNumber = $row['newsfeednumber'];
		//echo "Message Number: ".$messageNumber."\n";
		$nfmessagesql = "SELECT * FROM newsfeedmessages WHERE messageNumber = $messageNumber";
		$nfmessageresult = mysql_query($nfmessagesql);
		$messageExists = mysql_fetch_assoc($nfmessageresult);
		if($messageExists){
			$message = $messageExists['message'];
			//echo "Message: ".$message."\n";
			//	populate the newsfeed JSON data structure:
			$thisfeedmessage = (object) array('message'=>$message,
		'messageNumber'=>$messageNumber);
			
			$newsfeed[$i] = $thisfeedmessage; 
			$i++;
		}
	}
	
	echo json_encode($newsfeed);

?>