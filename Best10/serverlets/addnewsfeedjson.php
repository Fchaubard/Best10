<?php

//	addnewsfeedjson.php
//	adds a new entry to the newsfeed
	
	include("../headers/config_wolfpack.php");
	$sessid = $_REQUEST['session'];
	//$message = $_REQUEST['message'];
	//$cat = $_REQUEST['category'];
	//$users = $_REQUEST['users']; //Not needed
	if($sessid==0){
		echo "not valid session";
		return;
	}
	
	//Is this a security feature???
	$sql="SELECT * FROM users WHERE sessid LIKE '$sessid' LIMIT 1";
	$result=mysql_query($sql);
	$row=mysql_fetch_array($result);

	//if username exists GRABS CURRENT USER INFO.
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
	
	$chat = $_SESSION['chatid'];
	//	Figuring out the list of people involved in the message:
	$peopleInTheChat = "SELECT * FROM users WHERE chatid=$chat";
	$result_peopleInTheChat = mysql_query($peopleInTheChat);
	$i=mysql_num_rows($result_peopleInTheChat);
	$size = $i;
	$peopleInTheChat_Text = "";
	$users = "";
	while ($i>0) {
		$row_result_peopleInTheChat = mysql_fetch_assoc($result_peopleInTheChat);
		$firstName = $row_result_peopleInTheChat['fname'];
		$phoneNumber = $row_result_peopleInTheChat['phone'];
		if($size>2){
			
			if($i==2){
				$peopleInTheChat_Text = $peopleInTheChat_Text.$firstName.", and ";
				$users = $users.$phoneNumber.",";
			}
			elseif($i==1){
				$peopleInTheChat_Text = $peopleInTheChat_Text.$firstName." chatted over their hunger! And you missed it! ";
				$users = $users.$phoneNumber;
			}
			else{
				$peopleInTheChat_Text = $peopleInTheChat_Text.$firstName.", ";
				$users = $users.$phoneNumber.",";
			}
		}
		elseif($size==2){
			
			if($i==2){
				$peopleInTheChat_Text = $peopleInTheChat_Text.$firstName." and ";
				$users = $users.$phoneNumber.",";
			}
			else{
				$peopleInTheChat_Text = $peopleInTheChat_Text.$firstName." chatted over their hunger! And you missed it! ";
				$users = $users.$phoneNumber;
			}
		}
		//else{
			
		//	$peopleInTheChat_Text = $peopleInTheChat_Text.$firstName." was around to chat but no one else was there! :(  ";
		//}
				
		$i=$i-1;
	}
	
	//[bob] and [jane] chatted over their hunger! And you missed it!
	//echo $peopleInTheChat_Text;
		
	$message = $peopleInTheChat_Text;
	//echo "Message: ".$message;
	//echo "Users: ".$users;
	
	//	Real work of the PHP file in ADDING to the NEWSFEED:
	$messageInsert = "INSERT INTO newsfeedmessages (message) VALUES ('$message')";
	$result_messageInsert=mysql_query($messageInsert);
	
	
	
	$getMessageNumber = "SELECT MAX(messageNumber) AS maxMessageNumber FROM newsfeedmessages";
	$result_getMessageNumber=mysql_query($getMessageNumber);
	$row_getMessageNumber=mysql_fetch_array($result_getMessageNumber);
	if(mysql_num_rows($result_getMessageNumber)>0){
		$messageNumber .= $row_getMessageNumber['maxMessageNumber'];
	}
	//echo "Max Message Number: ".$messageNumber."\n";
	
	
	
	$posters = split(',',$users);
	//Create Values String:
	$valueString = "";
	foreach($posters as $value) {
		//echo "Value: ".$value."\n";
		$valueString = $valueString. "(".$value.", ".$messageNumber.")";
	}
	$valueString = str_replace(")(","),(",$valueString);
	
	//echo "Value String: ".$valueString;
  
  	$mappingInsert = "INSERT INTO newsfeedmapping (phoneNumber,newsfeednumber) VALUES $valueString";
  	$result_mappingInsert = mysql_query($mappingInsert);
  	if (!$result_mappingInsert) { //	UNSuccessful INSERT
    	echo 0;
	}
	else{//	Successful INSERT
		echo 1;
	}
	
	
	
	

?>