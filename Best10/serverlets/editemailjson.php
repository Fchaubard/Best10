<?php
//editemailjson.php

include("../headers/config_wolfpack.php");

$sessid = $_REQUEST['session'];
$email = $_REQUEST['email'];

$email = str_replace('!!_____!_____!!', ' ', $email);

if($sessid == 0)
{
    echo "error: invalid token";
    return;
}

$sql = "SELECT * FROM users WHERE sessid = '$sessid' LIMIT 1";
$result = mysql_query($sql);

//if sessionid exists in user table
if(mysql_num_rows($result) > 0) {
    $sql = "UPDATE users SET email = '$email' WHERE sessid = '$sessid'";
    $updateResult = mysql_query($sql);
} else {
    echo "error: email not updated";
    return;
}

echo $updateResult;

?>