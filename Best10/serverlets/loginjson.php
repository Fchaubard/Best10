<?php
	
	include("../headers/config_wolfpack.php");
	$email = $_REQUEST['email'];
	$password = $_REQUEST['password'];
	
	// Ensure email is not taken already
	$sql="SELECT * FROM users WHERE email = '$email' LIMIT 1";
	$result=mysql_query($sql);
	$row=mysql_fetch_array($result);

	//if email doesnt exist
	if(mysql_num_rows($result)>0)
	{
		if($row['password']==$password){
			$sessionId = $row['sessid'];
			$blank = "0";
			if( strcmp ( $sessionId, $blank) == 0){
				//generate session token
				$phoneNumber = $row['phone'];
				$saltedPhoneNumber = $phoneNumber."salt";
				//$token = md5($phoneNumber);
				$token = $phoneNumber;
				
				// check if its a valid sessid
				$sql="UPDATE  `wolfpack_ios`.`users` SET  `sessid` =  '$token' WHERE `users`.`email` =  '$email' AND  `users`.`password` =  '$password' LIMIT 1";
				$result=mysql_query($sql);
				//echo json_encode($token);
				echo($token);
				}
			else{
				echo "already logged in"; //Invalid Login
				return;
			}
		}
		else{
			echo "invalid login"; //Invalid Login
			return;
		}
	}
	else{
		echo "invalid login"; //Invalid Login
		return;
	}
	
	

?>