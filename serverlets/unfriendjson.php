<?php
	
	include("../headers/config_wolfpack.php");
	
	$sessid = $_REQUEST['session'];
	if($sessid == 0) {
		echo "not valid session";
		return;
	}

	$friendphone = $_REQUEST['phone'];

	$potentialStatus = "1";

	$sql = "SELECT * FROM users WHERE sessid = '$sessid' LIMIT 1";
	$result = mysql_query($sql);

	//username exists
	if(mysql_num_rows($result) == 1) {
		$result = mysql_fetch_assoc($result);
		$myphone = $result['phone'];

		$sql = "SELECT * FROM users WHERE phone = '$friendphone' LIMIT 1";
		$result = mysql_query($sql);
		
		if(mysql_num_rows($result) == 1) {
			$sql = "UPDATE friendmapping SET friendstatus = '$potentialStatus' WHERE myphone = '$friendphone' AND friendphone = '$myphone' LIMIT 1";
			$result = mysql_query($sql);
			
			$sql = "UPDATE friendmapping SET friendstatus = '$potentialStatus' WHERE myphone = '$myphone' AND friendphone = '$friendphone' LIMIT 1";
			$result = mysql_query($sql);
			
			echo json_encode("success");
		} else {
			echo "0"; //Friend not found in users table
		}
	} else {
		echo "0"; //User not found in users table
	}

?>