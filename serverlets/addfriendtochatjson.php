<?php
//addfriendtochatjson.php
//merge chats

include("../headers/config_wolfpack.php");


//Newsfeed function:
function newsfeedIt($chat)
{
	//echo "News Feed It Function Called";
	//	addnewsfeedjson.php
	//	adds a new entry to the newsfeed
	
	//$chat = $_SESSION['chatid'];
	//	Figuring out the list of people involved in the message:
	$peopleInTheChat = "SELECT * FROM users WHERE chatid=$chat";
	$result_peopleInTheChat = mysql_query($peopleInTheChat);
	$i=mysql_num_rows($result_peopleInTheChat);
	$size = $i;
	$peopleInTheChat_Text = "";
	$users = "";
	while ($i>0) {
		$row_result_peopleInTheChat = mysql_fetch_assoc($result_peopleInTheChat);
		$firstName = $row_result_peopleInTheChat['fname'];
		$phoneNumber = $row_result_peopleInTheChat['phone'];
		if($size>2){
			
			if($i==2){
				$peopleInTheChat_Text = $peopleInTheChat_Text.$firstName.", and ";
				$users = $users.$phoneNumber.",";
			}
			elseif($i==1){
				$peopleInTheChat_Text = $peopleInTheChat_Text.$firstName." chatted! And you missed it! ";
				$users = $users.$phoneNumber;
			}
			else{
				$peopleInTheChat_Text = $peopleInTheChat_Text.$firstName.", ";
				$users = $users.$phoneNumber.",";
			}
		}
		elseif($size==2){
			
			if($i==2){
				$peopleInTheChat_Text = $peopleInTheChat_Text.$firstName." and ";
				$users = $users.$phoneNumber.",";
			}
			else{
				$peopleInTheChat_Text = $peopleInTheChat_Text.$firstName." chatted! And you missed it! ";
				$users = $users.$phoneNumber;
			}
		}
				
		$i=$i-1;
	}
	
	//[bob] and [jane] chatted over their hunger! And you missed it!
	//echo $peopleInTheChat_Text;
		
	$message = $peopleInTheChat_Text;
	//echo "Message: ".$message;
	//echo "Users: ".$users;
	
	//	Real work of the PHP file in ADDING to the NEWSFEED:
	$messageInsert = "INSERT INTO newsfeedmessages (message) VALUES ('$message')";
	$result_messageInsert=mysql_query($messageInsert);
	
	
	
	$getMessageNumber = "SELECT MAX(messageNumber) AS maxMessageNumber FROM newsfeedmessages";
	$result_getMessageNumber=mysql_query($getMessageNumber);
	$row_getMessageNumber=mysql_fetch_array($result_getMessageNumber);
	if(mysql_num_rows($result_getMessageNumber)>0){
		$messageNumber .= $row_getMessageNumber['maxMessageNumber'];
	}
	//echo "Max Message Number: ".$messageNumber."\n";
	
	
	
	$posters = split(',',$users);
	//Create Values String:
	$valueString = "";
	foreach($posters as $value) {
		//echo "Value: ".$value."\n";
		$valueString = $valueString. "(".$value.", ".$messageNumber.")";
	}
	$valueString = str_replace(")(","),(",$valueString);
	
	//echo "Value String: ".$valueString;
  
  	$mappingInsert = "INSERT INTO newsfeedmapping (phoneNumber,newsfeednumber) VALUES $valueString";
  	$result_mappingInsert = mysql_query($mappingInsert);
  	if (!$result_mappingInsert) { //	UNSuccessful INSERT
    	return 0;
	}
	else{//	Successful INSERT
		return 1;
	}
}



////////////////////
////////////////////


$sessid = $_REQUEST['session'];
$value = $_REQUEST['add'];
date_default_timezone_set("UTC");
$date = date('Y/m/d H:i:s');
$date = str_replace(" ","*",$date);
$date = str_replace("/","-",$date);
//$date = $_REQUEST['date'];

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
$row = mysql_fetch_array($result);
$chatid = $row['chatid']; //Chat ID for the person = phone number if they are Pack Chat "owner" otherwise different.
$phone = $row['phone']; //Current users phone number.
	 
$myname = "". $row['fname']." ". $row['lname'];
//if sessionid exists in user table
if(mysql_num_rows($result) > 0)
{
    $friendphone = $_REQUEST['friendid'];
    $sql = "SELECT * FROM users WHERE phone = '$friendphone' LIMIT 1";
    
    $friendresult = mysql_query($sql);
    if(mysql_num_rows($friendresult) > 0) {
       //More information about the person requesting to add someone:
      
	   //More information about the friend being added:
       $friendrow = mysql_fetch_array($friendresult);
       $friendchatid = $friendrow['chatid']; //Chat ID for the friend
       $friendpushtoken = $friendrow['registeredIP'];
       if($valueBool) //Adding a friend.
       {
       		echo "add";
       		$sql = "SELECT fname, lname FROM users WHERE chatid = '$friendchatid'";
    		$friendList = mysql_query($sql);
    		$friendNameList = "";
    		$num=mysql_numrows($result);
    		$i=0;
			while ($i < $num) {
				$firstName = mysql_result($friendList,$i,"fname");
				$lastName = mysql_result($friendList,$i,"lname");
				if($i!=$num-1){
  					$addOn = $firstName." ".$lastName.", ";
				}
				else{
					$addOn = $firstName." ".$lastName;
				}
  				$friendNameList.=$addOn;
 				
 				$i++;	
  			}

       		
       		if(empty($friendchatid))
       		{
       			
       			echo "friendchatid is blank";
       			return;	
       		}
       		if(empty($chatid))
       		{
       			
       			echo "chatid is blank";
       			return;	
       		}
       		
       		//Chat ID Cases:
       		//If friend is not in a chat, it just adds that one friend.
       		//If friend is already in a chat, it merges two chats together.
	       $sql = "UPDATE users SET chatid = '$chatid' WHERE chatid = '$friendchatid'";
	       $updateChatIdsResult = mysql_query($sql);
	       
	       //Messages Cases:
	       //If messages are merged, all mesages being added will be merged to the initial set.
	       //An administrative message will be added to list all users that were merged into the chat.
	       
	       //Merging of messages:
	       $sql = "UPDATE chatmapping SET chatid = '$chatid' WHERE chatid = '$friendchatid'";
	       $messageMergeResult = mysql_query($sql);
	       
	       //Create admin message text:
	       //ADD CODE HERE...
	       
	       //Administrative Message Added:
	       $adminId = "00000000000";
	       //$date = date('Y-m-d*H:i:s'); //Message needs to change to use date input.
	       if($num>1){
	       		$mergeMessage = $friendNameList." have been added to this Pack Chat.";
	       }
	       else{
	       		$mergeMessage = $friendNameList." has been added to this Pack Chat.";
	       }
	       $sql = "INSERT INTO chatmapping VALUES('$chatid', '$adminId', '$mergeMessage', '$date')";
		   $adminMessageAddedResult = mysql_query($sql);
	       $nfi_result = newsfeedIt($chatid);
	       //echo "Method Call Result: ".$nfi_result;
	       //newsfeedIt($chatid);
	       
	       
       } else { //Removing a friend.
       
       	   	//Cases:
       	   	//LAST FRIEND: Delete All Messages under your chat ID.
       	   	//If you are the chat owner: Change friend back to their phone number
       	   	//If you are not the chat owner: Set your chatid to your own phone number
       	   	//NOT LAST FRIEND: DO NOT change the messages
       	   	//Update the friend's chat id back to their phone number
       	   	
       	   $sql = "SELECT * FROM users WHERE chatid = '$chatid'";
       	   $chatSizeResult = mysql_query($sql);
       	   if(mysql_num_rows($chatSizeResult) > 2){ //NOT LAST FRIEND:
       	   		$sql = "UPDATE users SET chatid = '$friendPhone', chatTime = '$date' WHERE phone = '$friendPhone'";
	       		$removeFriendResult = mysql_query($sql);
       	   }
       	   else{
       	   		// Delete All Messages From the Chat:
       	   		$sql = "DELETE * FROM chatmapping WHERE chatid='$chatid'";
       	   		$deleteTheEntireChat = mysql_query($sql);
       	   		
       	   		if($sessid == $chatid){ //If you are the chat owner:
       	   			$sql = "UPDATE users SET chatid = '$friendPhone', chatTime = '$date' WHERE phone = '$friendPhone'";
	       			$removeFriendResult = mysql_query($sql);
       	   		}
       	   		else{
       	   			$sql = "UPDATE users SET chatid = '$phone', chatTime = '$date' WHERE phone = '$phone'";
	       			$removeYourselfResult = mysql_query($sql);
       	   		}
       	   }
       }
    } else {
        echo "error: friend does not exists";
        return;
    }
} else {
    echo "error: invalid token"; //Invalid Login
    return;
}

echo $result;



// Put your device token here (without spaces):
//$deviceToken = '410b87b7745ca4c84f8afdb999793c5257a4a292de0882a87d66611fbff8e55e';
$deviceToken = $friendpushtoken;

echo $deviceToken;
if(empty($deviceToken))
{
  	echo " Doesnt have a device token"; //Invalid token
   	return;
}
if(($deviceToken=="no"))
{
  	echo " has no for a device token"; //Invalid token
   	return;
}
// Put your private key's passphrase here:
$passphrase = 'f9pbNfzw2E^u';

// Put your alert message here:
$message = "Bro! $myname addeded you to chizat!";

////////////////////////////////////////////////////////////////////////////////

$ctx = stream_context_create();
stream_context_set_option($ctx, 'ssl', 'local_cert', 'PushNotificationCertificates.pem');
stream_context_set_option($ctx, 'ssl', 'passphrase', $passphrase);

// Open a connection to the APNS server
$fp = stream_socket_client(
	'ssl://gateway.sandbox.push.apple.com:2195', $err,
	$errstr, 60, STREAM_CLIENT_CONNECT|STREAM_CLIENT_PERSISTENT, $ctx);

if (!$fp)
	exit("Failed to connect: $err $errstr" . PHP_EOL);

//echo 'Connected to APNS' . PHP_EOL;

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

if (!$result){
	echo 'Message not delivered' . PHP_EOL;
}else{
	echo 'Message successfully delivered' . PHP_EOL;
}
// Close the connection to the server
fclose($fp);


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


?>