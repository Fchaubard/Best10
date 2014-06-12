<?php
	
	include("../headers/config_wolfpack.php");
	
	$sessid = $_REQUEST['session'];
	if($sessid == 0){
		echo "not valid session";
		return;
	}

	// check if its a valid sessid
	$sql = "SELECT * FROM users WHERE sessid = '$sessid' LIMIT 1";
	$result = mysql_query($sql);

	//if username exists
	if(mysql_num_rows($result) > 0)
	{
		$i = 0;
		$friends = array();
		$sql = "SELECT * FROM users WHERE phone != '$sessid'";
		$result = mysql_query($sql);
		
		while ($row = mysql_fetch_assoc($result)) {
			$thisfriend = (object) array(
				'fname'=>$row['fname'],
				'lname'=>$row['lname'],
				'status'=>$row['status'],
				'friendphone'=>$row['friendphone'],
				'hidden'=>$row['hidden'],
				'friendstatus'=>$row['friendstatus'],
				'adjective'=>$row['adjective'],
				'lat'=>$row['lat'],
				'long'=>$row['long'],
				'chatid'=>$row['chatid']
				);
		
			$friends[$i] = $thisfriend; 
			$i++;
		}
	
		echo json_encode($friends);
	}
	else{
		echo "error: invalid token"; //Invalid Login
		return;
	}
	

?>