<?php
	
	include("../headers/config_wolfpack.php");
	$sessid = $_REQUEST['session'];
	if($sessid == 0) {
		echo "not valid session";
		return;
	}
	
	// check if it's a valid sessid
	$sql = "SELECT * FROM users WHERE sessid = '$sessid' LIMIT 1";
	$result = mysql_query($sql);
	

	//if username exists
	if(mysql_num_rows($result) > 0) {
		$row = mysql_fetch_array($result);
		$user = (object) array('phone'=>$row['phone'], 
							   'fname'=>$row['fname'],
							   'lname'=>$row['lname'],
							   'password'=>str_repeat('*', strlen($row['password'])),
							   'email'=>$row['email'],
							   'adjective'=>$row['adjective'],
							   'foodicon'=>$row['foodicon'],
							   'status'=>$row['status'],
							   'lat'=>$row['lat'],
							   'long'=>$row['long'],
							   'chatid'=>$row['chatid']
								);
		echo json_encode($user);
	} else {
		echo "error: user not found in database";
	}
?>