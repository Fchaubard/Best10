<?php
//respondtowprequestjson.php
//respond to friend request

include("../headers/config_wolfpack.php");

$sessid = $_REQUEST['session'];

if($sessid == 0)
{
    echo "error: invalid token first";
    return;
}

//Respond to request
$sql = "SELECT * FROM users WHERE sessid = '$sessid' LIMIT 1";
$result = mysql_query($sql);

//if sessionid exists in user table
if(mysql_num_rows($result) > 0)
{
    $row = mysql_fetch_assoc($result);
	$response = $_REQUEST['response'];
	$friendphone = $_REQUEST['friendid'];
    $myphone = $row['phone'];
  
    $sql = "SELECT * FROM friendmapping WHERE myphone = '$friendphone' AND friendphone = '$myphone' LIMIT 1";
    $result = mysql_query($sql);
 
    if(mysql_num_rows($result) > 0) {
    	$sql = "UPDATE friendmapping SET friendstatus = '$response' WHERE myphone = '$myphone' AND friendphone = '$friendphone' LIMIT 1";
    	$result = mysql_query($sql);

        $sql = "UPDATE friendmapping SET friendstatus = '$response' WHERE myphone = '$friendphone' AND friendphone = '$myphone' LIMIT 1";
        $result = mysql_query($sql);
        echo json_encode("success");
    } else {
    	echo "error: invalid token";
    }
} else {
    echo "error: invalid token"; //Invalid Login
}

?>