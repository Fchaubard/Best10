<?php
//editpasswordjson.php

include("../headers/config_wolfpack.php");

$sessid = $_REQUEST['session'];
$current = $_REQUEST['current'];
$new = $_REQUEST['new'];

$current = str_replace('!!_____!_____!!', ' ', $current);

$new = str_replace('!!_____!_____!!', ' ', $new);
if($sessid == 0)
{
    echo "error: invalid token";
    return;
}

$sql = "SELECT * FROM users WHERE sessid = '$sessid' LIMIT 1";
$result = mysql_query($sql);

//if sessionid exists in user table
if(mysql_num_rows($result) > 0) {
    $sql = "UPDATE users SET password = '$new' WHERE sessid = '$sessid' AND password = '$current'";
    mysql_query($sql);
    echo str_repeat('*', strlen($new));
} else {
    echo "error: password not updated";
}

?>