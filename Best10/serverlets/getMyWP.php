<?php
	//getMyWP.php
	//Current iteration takes username and password. It *should* take username and secure token, but we'll get that later.
	// -- So?
	include("../headers/config_wolfpack.php");
	$sessid = $_REQUEST['session'];
	
	$sql="SELECT * FROM users WHERE sessid LIKE '$sessid'";
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
			
			//now set the session from here if needed
			//if($_SESSION['groupNumber']!=0 && $row['status']!=2){
			//	$sql="UPDATE users SET hungry='1' WHERE userName LIKE '$user_name'";
			//	$result=mysql_query($sql);
			//	echo "1";
			//}else{
			//	$_SESSION['groupNumber']=0;
				//echo "2";
			//}
		//else{
			
		//	echo "error: invalid login	"; 
			//echo $username.$password;
		//	return;
		//}
	}
	else{
		echo "error: invalid token"; //Invalid Login
		return;
	}
	$friends = array();
	/*
	$sql="SELECT * FROM friends WHERE phone LIKE '$phone'";
	$result=mysql_query($sql);
	$i = 0;
	while ($row = mysql_fetch_assoc($result)) {
		$friends[$i] = $row['friend'];
		$i++;
	}
	
	echo json_encode($friends);
	
	*/
	$phone = $_SESSION['phone'];
	//$sql="SELECT * FROM friendmapping WHERE phone LIKE '$phone' RIGHT JOIN users ON users.phone=friendmapping.friendphone ORDER BY users.lname";
	$sql = "SELECT * FROM (SELECT * FROM friendmapping INNER JOIN users ON friendmapping.friendphone=users.phone ORDER BY users.lname) AS T WHERE T.myphone = '$phone'";
	$result=mysql_query($sql);
	$i = 0;
	while ($row = mysql_fetch_assoc($result)) {
		$thisfriend = (object) array('fname'=>$row['fname'],
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
	
	//$arrytest = array(array('a'=>1, 'b'=>2),array('c'=>3),array('d'=>4));

	// Force the outer structure into an object rather than array
	echo json_encode($friends);

	// {"0":{"a":1,"b":2},"1":{"c":3},"2":{"d":4}}
?>