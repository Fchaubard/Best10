<?php
	//getMyWP.php
	//Current iteration takes username and password. It *should* take username and secure token, but we'll get that later.
	// -- So?
	include("../headers/config.php");
	
	$username = $_REQUEST['user'];
	
	$password = md5($_REQUEST['password']);	//this is criminally hacky, but I think Francois is expecting it, so I will leave it this way for now. :-(
	
	//now validating the username and password
	$sql="SELECT * FROM users WHERE userName LIKE '$username'";
	$result=mysql_query($sql);
	$row=mysql_fetch_array($result);

	//if username exists
	if(mysql_num_rows($result)>0)
	{
		//compare the password
		if($row['password']==$password)
		{
			//echo "yes";
			
			$_SESSION['userName']=$user_name; 
			$_SESSION['groupNumber']=$row['groupNumber'];
			//now set the session from here if needed
			if($_SESSION['groupNumber']!=0 && $row['status']!=2){
				$sql="UPDATE users SET hungry='1' WHERE userName LIKE '$user_name'";
				$result=mysql_query($sql);
				echo "1";
			}else{
				$_SESSION['groupNumber']=0;
				//echo "2";
			}
				
			
		}
		else{
			
			echo "error: invalid login	"; 
			//echo $username.$password;
			return;
		}
	}
	else{
		echo "error: invalid login"; //Invalid Login
		return;
	}
	
	//okay, we're logged in. Time to make a list of friends.
	$status = array();
	
	$sql="SELECT * FROM status WHERE user LIKE '$username'";
	$result=mysql_query($sql);
	
	//grab the first row only.
	$row = mysql_fetch_assoc($result);
	$status['text'] = $row['text'];
	$status['hungry'] = $row['hungry'];
	$status['lat'] = $row['latitude'];
	$status['long'] = $row['longitude'];
	echo json_encode($status);
?>