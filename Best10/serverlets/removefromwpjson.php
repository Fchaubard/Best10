<?php
//removefromwpjson.php
//defriend

include("../headers/config_wolfpack.php");

$sessid = $_REQUEST['session'];

if($sessid == 0)
{
    echo "error: invalid token";
    return;
}

//defriend
$sql = "SELECT * FROM users WHERE sessid = '$sessid' LIMIT 1";
$result = mysql_query($sql);

//if sessionid exists in user table
if(mysql_num_rows($result) > 0)
{
    $row = mysql_fetch_array($result);
	$friendphone = $_REQUEST['friendid'];
    $_SESSION['phone'] = $row['phone'];
    $myphone = $row['phone'];
    $friend = 3;
    $sql = "SELECT * FROM friendmapping WHERE myphone = '$myphone' AND friendphone = '$friendphone' AND friendstatus = '$friend' LIMIT 1";
    $result = mysql_query($sql);
    if(mysql_num_rows($result) > 0) {
        $defriend = 2;
    	$sql = "UPDATE friendmapping SET friendstatus = '$defriend' WHERE myphone = '$myphone' AND friendphone = '$friendphone' LIMIT 1";
    	$result = mysql_query($sql);
    } else {
    	echo "error: not friends";
    	return;
    }
} else {
    echo "error: invalid token"; //Invalid Login
    return;
}

echo $result;

?>