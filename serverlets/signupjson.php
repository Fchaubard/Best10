<?php
	
	include("../headers/config_wolfpack.php");
	$fname = $_REQUEST['fname'];
	
	$fname = str_replace('!!_____!_____!!', ' ', $fname);
	$lname = $_REQUEST['lname'];
	
	$lname = str_replace('!!_____!_____!!', ' ', $lname);
	$email = $_REQUEST['email'];
	
	$email = str_replace('!!_____!_____!!', ' ', $email);
	$password = $_REQUEST['password'];
	
	$password = str_replace('!!_____!_____!!', ' ', $password);
	$phoneNumber = $_REQUEST['phoneNumber'];
	
	$phoneNumber = str_replace('!!_____!_____!!', ' ', $phoneNumber);
	$pushtoken = $_REQUEST['pushtoken'];
	
	$pushtoken = str_replace('!!_____!_____!!', ' ', $pushtoken);
	
	// Ensure email is not taken already
	$sql="SELECT * FROM users WHERE phone LIKE '$phoneNumber'"; //Should be based on phone number
	$result=mysql_query($sql);
	$row=mysql_fetch_array($result);

	//if email doesnt exist
	if(mysql_num_rows($result)>0)
	{
		echo "phone number already has account"; //Invalid Login
		return;
	}
	else{
		//generate session token
		$token = $phoneNumber;
		// check if its a valid sessid
		$sql="INSERT INTO `wolfpack_ios`.`users` (`phone`, `fname`, `lname`, `email`, `password`, `adjective`, `status`, `lat`, `long`, `sessid`, `chatid`,`registeredIP`) VALUES ('$phoneNumber', '$fname', '$lname', '$email', '$password', '0', '', '', '', '$token', '$phoneNumber','$pushtoken')";
		$result=mysql_query($sql);
		echo $token;
			}
	

?>