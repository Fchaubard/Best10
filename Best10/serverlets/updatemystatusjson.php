<?php
	
	include("../headers/config_wolfpack.php");
	$session = $_REQUEST['session'];
	$adjective = $_REQUEST['adjective'];
	$lat = $_REQUEST['lat'];
	$long = $_REQUEST['long'];
	$status = $_REQUEST['status'];
	$statusUpdate = $_REQUEST['statusUpdate'];
	
	//Creating chatTime based on the server time:
	date_default_timezone_set("UTC");
	$chatTime = date('Y/m/d H:i:s');
	$chatTime = str_replace(" ","*",$chatTime);
	$chatTime = str_replace("/","-",$chatTime);
	//$chatTime = $_REQUEST['chatTime'];
	
	$status = str_replace('!!_____!_____!!', ' ', $status);
	
	if($session==0){
		echo "not valid session";
		return;
	}
	// Ensure email is not taken already
	$sql="SELECT * FROM users WHERE sessid LIKE '$session' LIMIT 1";
	$result=mysql_query($sql);
	
	
	//if email doesnt exist
	if(mysql_num_rows($result)>0)
	{
		$row = mysql_fetch_array($result);
	   	$chatid = $row['chatid'];
	   	$phone = $row['phone'];
	   	if(strcmp($statusUpdate,"no")){
		$sql="UPDATE  `wolfpack_ios`.`users` SET  `adjective` =  '$adjective', `lat` =  '$lat',`long` =  '$long',`status` =  '$status', `chatid` = '$phone', chatTime='$chatTime' WHERE `users`.`sessid` =  '$session' LIMIT 1";
	   	}
	   	else{
	   		$sql="UPDATE  `wolfpack_ios`.`users` SET  `adjective` =  '$adjective', `lat` =  '$lat',`long` =  '$long',`status` =  '$status', `chatid` = '$phone' WHERE `users`.`sessid` =  '$session' LIMIT 1";
	   	}
		$result=mysql_query($sql);
		
			
		if($adjective==0 && $chatid==$phone)
		{
			  echo "I am not (adjective)";
			  // need to look for others with this chatid and change them to the first persons phone number that also "had" that chatid.. 
			  $sql="SELECT * FROM users WHERE chatid LIKE '$chatid' AND phone NOT LIKE '$chatid'";
			  echo $sql;
			  $result = mysql_query($sql);
			  if(mysql_num_rows($result)>0)
			   {
					$row = mysql_fetch_array($result);
	 			  	$new_chatid = $row['phone'];
	 			  	// update the users that are still in the chat to a new chat id
	 			  	$sql="UPDATE  users SET chatid = '$new_chatid' WHERE chatid LIKE '$chatid' AND phone NOT LIKE '$chatid'";
	 			  	echo $sql;
					$result=mysql_query($sql);
					echo $result;
					
					// update all the messages to take on the new chat id
			   		$sql="UPDATE chatmapping SET chatid = '$new_chatid' WHERE chatid LIKE '$chatid'";
	 			  	echo $sql;
					$result=mysql_query($sql);
			   		echo $result;
			   }else{
			   	 // if my chatid is equal to my phone number and there are more than 1 with my chat id.. 
		      
			   		$sql = "DELETE FROM chatmapping WHERE chatid = '$phone'";
		       		echo $sql;
		       		$result = mysql_query($sql);
		       		echo $result;
			   }
		  	
		}
		else if ($adjective==1 && $chatid==$phone){
			//User is HUNGRY
			if(strcmp($statusUpdate,"no")){
			$sql="UPDATE users SET chatTime = '$chatTime' WHERE sessid LIKE '$session'";
			}
		}
		
		echo "1";
		
	}
	else{
		echo "0"; //Invalid Login
		return;
	}

	

?>