<?php
	
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
	$friends = array();

	$phone = $_SESSION['phone'];

	$sql = "SELECT * FROM (SELECT * FROM friendmapping  INNER JOIN users ON friendmapping.friendphone=users.phone ORDER BY users.lname) AS T WHERE T.myphone = '$phone' AND T.friendstatus=3";
	$result=mysql_query($sql);
	$i = 0;
	while ($row = mysql_fetch_assoc($result)) {
		$thisfriend = (object) array('fname'=>$row['fname'],
		'lname'=>$row['lname'],
		'status'=>$row['status'],
		'hidden'=>$row['hidden'],
		'friendstatus'=>$row['friendstatus'],
		'adjective'=>$row['adjective'],
		'lat'=>$row['lat'],
		'long'=>$row['long'],
		'chatid'=>$row['chatid'],
		'phone'=>$row['phone'],
		'sessid'=>$row['sessid']
		);
		
		$friends[$i] = $thisfriend; 
		$i++;
	}
	
	echo json_encode($friends);

?>