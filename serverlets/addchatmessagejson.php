<?php
//addchatmessagejson.php
//Adds a message to the chat table

include("../headers/config_wolfpack.php");

$sessid = $_REQUEST['session'];
$message = $_REQUEST['message'];

//Create date information using the server time:
date_default_timezone_set("UTC");
$date = date('Y/m/d H:i:s');
$date = str_replace(" ","*",$date);
$date = str_replace("/","-",$date);
//$date = $_REQUEST['date'];

$message = str_replace('!!_____!_____!!', ' ', $message);
if($sessid == 0)
{
    echo "error: invalid token";
    return;
}

//Retrieve session id information
$sql = "SELECT * FROM users WHERE sessid = '$sessid' LIMIT 1";
$result = mysql_query($sql);
$row = mysql_fetch_array($result);

//if sessionid exists in user table
if(mysql_num_rows($result) > 0)
{
    $_SESSION['chatid'] = $row['chatid'];
    $chatid = $row['chatid'];
    $_SESSION['phone'] = $row['phone'];
    $senderphone = $row['phone'];
    $sendername =  "". $row['fname']." ". $row['lname'];
} else {
    echo "error: invalid token"; //Invalid Login
    return;
}
//-------------------------------------------

//adds message and corresponding information to chat table
$sql = "INSERT INTO chatmapping VALUES('$chatid', '$senderphone', '$message', '$date')";
$result = mysql_query($sql);
//-------------------------------------------

echo $result;



//get all ppl with that chat id and send them a push notification
$sql = "SELECT * FROM users WHERE chatid = '$chatid'";
$users_in_this_chat = mysql_query($sql);


//-------------------------------------------
if(mysql_num_rows($users_in_this_chat) > 1)
{
  
} else {
    echo " There are 0 or 1 people in this pack chat"; //Invalid Login
    return;
}

// Put your alert message here:
	$message = "You got a packchat from '$sendername' : '$message'";
	// Put your private key's passphrase here:
	$passphrase = 'f9pbNfzw2E^u';
	
	
	////////////////////////////////////////////////////////////////////////////////
	
	$ctx = stream_context_create();
	stream_context_set_option($ctx, 'ssl', 'local_cert', 'PushNotificationCertificates.pem');
	stream_context_set_option($ctx, 'ssl', 'passphrase', $passphrase);
	
	
while ($row = mysql_fetch_assoc($users_in_this_chat)) {
	
	
	// Put your device token here (without spaces):
	//$deviceToken = '410b87b7745ca4c84f8afdb999793c5257a4a292de0882a87d66611fbff8e55e';
	$deviceToken = $row['registeredIP'];
	if(empty($deviceToken))
	 {
   	 	echo " Doesnt have a device token"; //Invalid Login
    	return;
	}
	if(($deviceToken=="no"))
	 {
   	 	echo " has no for a device token"; //Invalid Login
    	return;
	}

	
	// Open a connection to the APNS server
	$fp = stream_socket_client(
		'ssl://gateway.sandbox.push.apple.com:2195', $err,
		$errstr, 60, STREAM_CLIENT_CONNECT|STREAM_CLIENT_PERSISTENT, $ctx);
	
	if (!$fp)
		exit("Failed to connect: $err $errstr" . PHP_EOL);
	
	echo 'Connected to APNS' . PHP_EOL;
	
	// Create the payload body
	$body['aps'] = array(
		'alert' => $message,
		'sound' => 'default'
		);
	
	// Encode the payload as JSON
	$payload = json_encode($body);
	
	// Build the binary notification
	$msg = chr(0) . pack('n', 32) . pack('H*', $deviceToken) . pack('n', strlen($payload)) . $payload;
	
	// Send it to the server
	$result = fwrite($fp, $msg, strlen($msg));
	
	if (!$result)
		echo 'Message not delivered' . PHP_EOL;
	else
		echo 'Message successfully delivered' . PHP_EOL;
	
	// Close the connection to the server
	fclose($fp);
}

//get all ppl with that chat id and send them a push notification
$sql = "SELECT * FROM users WHERE chatid = '$chatid'";
$users_in_this_chat = mysql_query($sql);


//-------------------------------------------
if(mysql_num_rows($users_in_this_chat) > 1)
{
  
} else {
    echo " There are 0 or 1 people in this pack chat"; //Invalid Login
    return;
}


while ($row = mysql_fetch_assoc($users_in_this_chat)) {

	$deviceToken = $row['registeredIP'];
	if(empty($deviceToken))
	 {
   	 	echo " Doesnt have a device token"; //Invalid Login
    	return;
	}
	if(($deviceToken=="no"))
	 {
   	 	echo " has no for a device token"; //Invalid Login
    	return;
	}


	$ctx = stream_context_create();
	stream_context_set_option($ctx, 'ssl', 'local_cert', 'ProductionPushNotificationCertificates.pem');
	stream_context_set_option($ctx, 'ssl', 'passphrase', $passphrase);
	
	// Open a connection to the APNS server
	$fp = stream_socket_client(
		'ssl://gateway.push.apple.com:2195', $err,
		$errstr, 60, STREAM_CLIENT_CONNECT|STREAM_CLIENT_PERSISTENT, $ctx);
	
	if (!$fp)
		exit("Failed to connect: $err $errstr" . PHP_EOL);
	
	echo 'Connected to APNS' . PHP_EOL;
	
	// Create the payload body
	$body['aps'] = array(
		'alert' => $message,
		'sound' => 'default'
		);
	
	// Encode the payload as JSON
	$payload = json_encode($body);
	
	// Build the binary notification
	$msg = chr(0) . pack('n', 32) . pack('H*', $deviceToken) . pack('n', strlen($payload)) . $payload;
	
	// Send it to the server
	$result = fwrite($fp, $msg, strlen($msg));
	
	if (!$result)
		echo 'Message not delivered' . PHP_EOL;
	else
		echo 'Message successfully delivered' . PHP_EOL;
	
	// Close the connection to the server
	fclose($fp);

}

?>