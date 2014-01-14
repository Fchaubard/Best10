<?php
//updatefoodiconjson.php
//update food icon in users table

include("../headers/config_wolfpack.php");

$sessid = $_REQUEST['session'];

if($sessid == 0)
{
	echo "error: invalid token";
	return;
}

$foodicon = $_REQUEST['foodicon'];

//update session id information
$sql = "UPDATE users SET foodicon = '$foodicon' WHERE sessid = '$sessid'";
$result = mysql_query($sql);
//-------------------------------------------

echo $result;

?>