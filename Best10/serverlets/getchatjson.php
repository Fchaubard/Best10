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

//if username exists
if(mysql_num_rows($result) > 0)
{
    $_SESSION['phone'] = $row['phone'];
    $_SESSION['fname'] = $row['fname'];
    $_SESSION['lname'] = $row['lname'];
    $_SESSION['adjective'] = $row['adjective'];
    $_SESSION['status'] = $row['status'];
    $_SESSION['lat'] = $row['lat'];
    $_SESSION['long'] = $row['long'];
    $_SESSION['chatid'] = $row['chatid'];
    $_SESSION['chatTime'] = $row['chatTime'];
} else {
    echo "error: invalid token"; //Invalid Login
    return;
}

$chat = array();
$chatid = $row['chatid'];
$chatTime = $row['chatTime'];

$sql = "SELECT * FROM chatmapping WHERE chatid = '$chatid'";
$result = mysql_query($sql);
$i = 0;

while ($row = mysql_fetch_array($result)) {
		$phone = $row['senderphone'];
		$sql = "SELECT * FROM users WHERE phone = '$phone' LIMIT 1";
		$userresult = mysql_query($sql);
        $userresult = mysql_fetch_array($userresult);
        $timeStamp = $row['timestamp'];
        
        $thischat = (object) array('fname'=>$userresult['fname'],
        'lname'=>$userresult['lname'],
        'status'=>$userresult['status'],
        'adjective'=>$userresult['adjective'],
        'lat'=>$userresult['lat'],
        'long'=>$userresult['long'],
        'chatid'=>$userresult['chatid'],
        'message'=>$row['message'],
        'senderphone'=>$phone,
        'timesent'=>$timeStamp
        );
        
        //Compare the date to the current person's chat date...
        
        $s = $timeStamp;
        $s = str_replace("*"," ",$s);
        $s = str_replace("-","/",$s);
		$date = strtotime($s);
		$messageDate =  date('Y/m/d H:i:s', $date);
		//echo "  Time Message was Sent: ".$messageDate;
        
        $c = $chatTime;
        $c = str_replace("*"," ",$c);
        $c = str_replace("-","/",$c);
		$dat = strtotime($c);
		$chatDate =  date('Y/m/d H:i:s', $dat);
		//echo "  Time Added to Chat: ".$chatDate;
         
		
         
        $format = "Y-m-d*H:i:s";
        
        //echo("  Time Stamp: ".$timeStamp." Date Added: ".$dateAdded."\r\n");
        
        if($messageDate >= $chatDate){
        	$chat[$i] = $thischat;
        	$i++;
        }
}

echo json_encode($chat);

?>