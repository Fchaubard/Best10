<?php
//editnamejson.php

include("../headers/config_wolfpack.php");

$sessid = $_REQUEST['session'];
$fname = $_REQUEST['fname'];
$lname = $_REQUEST['lname'];
$fname = str_replace('!!_____!_____!!', ' ', $fname);
$lname = str_replace('!!_____!_____!!', ' ', $lname);

if($sessid == 0)
{
    echo "error: could not edit name";
    return;
}

$sql = "SELECT * FROM users WHERE sessid = '$sessid' LIMIT 1";
$result = mysql_query($sql);

//if sessionid exists in user table
if(mysql_num_rows($result) > 0) {
    $sql = "UPDATE users SET fname = '$fname', lname = '$lname' WHERE sessid = '$sessid'";
    $updateResult = mysql_query($sql);
} else {
    echo "error: could not edit name";
    return;
}

echo $updateResult;

?>