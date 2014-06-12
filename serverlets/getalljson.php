<?php
	
	include("../headers/config_wolfpack.php");
	$sessid = $_REQUEST['session'];
	if($sessid == 0) {
		echo "not valid session";
		return;
	}
	$sql = "SELECT * FROM users WHERE sessid LIKE '$sessid' LIMIT 1";
	$result = mysql_query($sql);
	$row = mysql_fetch_array($result);

	//if username exists
	if(mysql_num_rows($result) > 0)
	{
		$_SESSION['phone']=$row['phone'];
		$phone = $_SESSION['phone'];
		$_SESSION['fname']=$row['fname'];
		$_SESSION['lname']=$row['lname'];
		$_SESSION['adjective']=$row['adjective'];
		$_SESSION['status']=$row['status'];
		$_SESSION['lat']=$row['lat'];
		$_SESSION['long']=$row['long'];
		$_SESSION['chatid']=$row['chatid'];
	}
	else {
		echo "0"; //Invalid Login
		return;
	}
	$friends = array();

	$phone = $_SESSION['phone'];

	$sql = "SELECT * FROM users";
	//$sql = "SELECT * FROM (SELECT * FROM friendmapping INNER JOIN users ON friendmapping.friendphone=users.phone ORDER BY users.lname) AS T";
	$result=mysql_query($sql);
	$i = 0;
	while ($row = mysql_fetch_assoc($result)) {
		$friendphonee = $row['phone'];
		$sql = "SELECT * FROM friendmapping WHERE myphone = '$phone' AND friendphone='$friendphonee' LIMIT 1";
	//$sql = "SELECT * FROM (SELECT * FROM friendmapping INNER JOIN users ON friendmapping.friendphone=users.phone ORDER BY users.lname) AS T";
		$friendStatusResults=mysql_query($sql);
		$friendStatusResultsrow = mysql_fetch_assoc($friendStatusResults);
		if(isset($friendStatusResultsrow['friendstatus'])){
		   // we have some entry for this friendship
			$thisfriend = (object) array('fname'=>$row['fname'],
			'lname'=>$row['lname'],
			'status'=>$row['status'],
			'hidden'=>$friendStatusResultsrow['hidden'],
			'friendstatus'=>$friendStatusResultsrow['friendstatus'],
			'adjective'=>$row['adjective'],
			'lat'=>$row['lat'],
			'long'=>$row['long'],
			'chatid'=>$row['chatid'],
			'phone'=>$row['phone'],
			'sessid'=>$row['sessid']
			);
		}
		else{
			//we have no entry for this friendship
			$thisfriend = (object) array('fname'=>$row['fname'],
			'lname'=>$row['lname'],
			'status'=>$row['status'],
			'hidden'=>-1,
			'friendstatus'=>-1,
			'adjective'=>$row['adjective'],
			'lat'=>$row['lat'],
			'long'=>$row['long'],
			'chatid'=>$row['chatid'],
			'phone'=>$row['phone'],
			'sessid'=>$row['sessid']
			);	
			
			
		}
		$friends[$i] = $thisfriend; 
		$i++;
	}
	
	echo json_encode($friends);

?>