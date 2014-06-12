<?php
//getchatjson.php
//Retrieves all the relevant chat information

include("../headers/config_wolfpack.php");

$sessid = $_REQUEST['session'];

if($sessid == 0)
{
	echo "error: invalid token";
	return;
}


$sql = "SELECT * FROM users WHERE sessid = '$sessid' LIMIT 1";
$result = mysql_query($sql);
$row = mysql_fetch_array($result);

if(mysql_num_rows($result) > 0)
{
    //Update the Chat Id to the Session Id.
    $sql = "UPDATE users SET chatid = '$sessid' WHERE sessid = '$sessid'";
	$result = mysql_query($sql);
	echo $result;
    
} else {
    echo "error: invalid token"; //Invalid Login
    return;
}