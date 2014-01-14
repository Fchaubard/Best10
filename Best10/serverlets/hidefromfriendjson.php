<?php
//hide user from friend

include("../headers/config_wolfpack.php");

$sessid = $_REQUEST['session'];
$value = $_REQUEST['hide'];
$valueBool = 0;
if($value == "true")
{
  $valueBool = 1;
}

if($sessid == 0)
{
	echo "error: invalid token";
	return;
}

$sql = "SELECT * FROM users WHERE sessid = '$sessid' LIMIT 1";
$result = mysql_query($sql);

if(mysql_num_rows($result) > 0)
{
	$friendid = $_REQUEST['friendid'];
	$sql = "SELECT * FROM users WHERE phone = '$friendid' LIMIT 1";
	$result2 = mysql_query($sql);
	if(mysql_num_rows($result2) > 0) {
		$result = mysql_fetch_array($result);
		$myphone = $result['phone'];
		$sql = "SELECT * FROM friendmapping WHERE myphone = '$myphone' AND friendphone = '$friendid' LIMIT 1";
		$result2 = mysql_query($sql);
		if(mysql_num_rows($result2) > 0) {
			$result2 = mysql_fetch_array($result2);
			$friendstatus = $result2['friendstatus'];
			$sql = "UPDATE friendmapping SET hidden = '$valueBool' WHERE myphone = '$myphone' AND friendphone = '$friendid' LIMIT 1";
				$result2 = mysql_query($sql);
			
		} else {
			echo "error: friend not in users table";
			return;
		}
	}
} else {
	echo "error: invalid token";
	return;
}

echo $result2;

?>