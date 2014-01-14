<?php
	
	include("../headers/config_wolfpack.php");
	$session = $_REQUEST['session'];
	if($session==0){
		echo "not valid session";
		return;
	}
	// Ensure email is not taken already
	$sql="SELECT * FROM users WHERE sessid LIKE '$session' LIMIT 1";
	$result=mysql_query($sql);
	$row=mysql_fetch_array($result);

	//if email doesnt exist
	if(mysql_num_rows($result)>0)
	{
		//generate session token
		$token = "0";
		// check if its a valid sessid
		$sql = "UPDATE users SET sessid = '$token' WHERE sessid = '$session' LIMIT 1";
		$result = mysql_query($sql);
		echo "logged out successfully";
		
	} else {
		echo "error: logout error"; //Invalid Login
		return;
	}

?>