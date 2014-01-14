<?php
//addtowpjson.php
//add user as friend

include("../headers/config_wolfpack.php");

$sessid = $_REQUEST['session'];

if($sessid == 0)
{
	echo "error: invalid token";
	return;
}

$sql = "SELECT * FROM users WHERE sessid = '$sessid' LIMIT 1";
$userResult = mysql_query($sql);

//user found
if(mysql_num_rows($userResult) > 0) {
	$userResult = mysql_fetch_assoc($userResult);
	$requestorPhone = $userResult['phone'];
	$friendPhone = $_REQUEST['friendid'];

	$potential = "1";
	$pending = "2";

	$sql = "SELECT * FROM friendmapping WHERE myphone = '$requestorPhone' AND friendphone = '$friendPhone' LIMIT 1";
	$result = mysql_query($sql);

	if(mysql_num_rows($result) > 0) {
		//update my status
		$sql = "UPDATE friendmapping SET friendstatus = '$pending' WHERE myphone = '$requestorPhone' AND friendphone = '$friendPhone' LIMIT 1";
		$result = mysql_query($sql);
	} else {
		// friendmapping not found
		// Assuming for hidden condition: 0 is false, 1 is true
		$sql = "INSERT INTO friendmapping VALUES('$requestorPhone', '$friendPhone', 0, '$pending')";
		$result2 = mysql_query($sql);
	}
	echo json_encode("success");
} else {
	//user not found
	echo "error: invalid token";
}

?>