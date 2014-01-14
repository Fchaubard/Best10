<?php
//leavechatjson.php
//leave chat

include("../headers/config_wolfpack.php");

$sessid = $_REQUEST['session'];

if($sessid == 0)
{
	echo "error: invalid token";
	return;
}

$sql = "SELECT * FROM users WHERE sessid = '$sessid' LIMIT 1";
$result = mysql_query($sql);

if(mysql_num_rows($result) > 0)
{
	$result = mysql_fetch_array($result);
	$phone = $result['phone'];
	$sql = "UPDATE users SET chatid = '$phone' WHERE sessid = '$sessid' LIMIT 1";
	$result = mysql_query($sql);
} else {
	echo "error: invalid token";
	return;
}

echo $result;

?>