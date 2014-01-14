<?php
	
	include("../headers/config_wolfpack.php");
	
	$sessid = $_REQUEST['session'];
	if($sessid == 0) {
		echo "not valid session";
		return;
	}

	$potential = "1";
	$pending = "2";
	$friends = "3";
	$blocked = "4";
	$invite = "5";
	
	$sql = "SELECT * FROM users WHERE sessid = '$sessid' LIMIT 1";
	$result = mysql_query($sql);

	//if username doesn't exists
	if(mysql_num_rows($result) != 1)
	{
		echo "0"; //User not found in users table
		return;
	}
	
	//still need to account for hidden feature
	$contacts = json_decode(file_get_contents('php://input'), true);
	$friendsArray = array();
	$i = 0;
	
	//iterate through contacts array from user phone
	foreach($contacts as $value) {
		$phone = $value['phone'];
		$fname = $value['fname'];
		$lname = $value['lname'];
				
		//can't add yourself
		if($phone != $sessid) {
			$sql = "SELECT * FROM users WHERE phone = '$phone' LIMIT 1";
			$result = mysql_query($sql);

			//found an entry in user table for current contact number
			if(mysql_num_rows($result) == 1) {
				$result = mysql_fetch_assoc($result);
				$adjective = $result['adjective'];
				$status = $result['status'];

				$sql = "SELECT * FROM friendmapping WHERE (myphone = '$sessid' AND friendphone = '$phone') OR (myphone = '$phone' AND friendphone = '$sessid')";
				$fmappingresult = mysql_query($sql);
				if(mysql_num_rows($fmappingresult) > 0) {
					while($row = mysql_fetch_assoc($fmappingresult)) {
						$friendstatus = $row['friendstatus'];
						$thisfriend = null;
						if($friendstatus == $potential) { 
							if($row['myphone'] == $sessid) {
								$thisfriend = (object) array(
													'fname'=>$fname,
													'lname'=>$lname,
													'hidden'=>$row['hidden'],
													'friendstatus'=>$potential,
													'status'=>$status,
													'adjective'=>$adjective,
													'myphone'=>$sessid,
													'friendphone'=>$phone //use the friend phone when displaying in app
												);
							}
						} else if($friendstatus == $pending) {
							if($row['friendphone'] == $sessid) { //changed from ($row['myphone'])
								$thisfriend = (object) array(
												'fname'=>$fname,
												'lname'=>$lname,
												'hidden'=>$row['hidden'],
												'friendstatus'=>$pending,
												'status'=>$status,
												'adjective'=>$adjective,
												'myphone'=>$sessid,
												'friendphone'=>$phone //use the friend phone when displaying in app
											);
							}
						} else if($friendstatus == $friends) {
							if($row['myphone'] == $sessid) {
								$thisfriend = (object) array(
													'fname'=>$fname,
													'lname'=>$lname,
													'hidden'=>$row['hidden'],
													'friendstatus'=>$friends,
													'status'=>$status,
													'adjective'=>$adjective,
													'myphone'=>$sessid,
													'friendphone'=>$phone //use the friend phone when displaying in app
												);
							}	
						} else if($friendstatus == $blocked) {
							if($row['myphone'] == $phone) {
								$thisfriend = (object) array(
												'fname'=>$fname,
												'lname'=>$lname,
												'hidden'=>$row['hidden'],
												'friendstatus'=>$blocked,
												'status'=>$status,
												'adjective'=>$adjective,
												'myphone'=>$sessid,
												'friendphone'=>$phone //use the friend phone when displaying in app
											);
							}
						} 
						/*else if($friendstatus == $invite) {
							$sqlUpdate = "UPDATE friendmapping SET friendstatus = 'potential' WHERE myphone = '$sessid' AND friendphone = '$phone' LIMIT 1";
							$update = mysql_query($sqlUpdate);

							$sqlUpdate = "UPDATE friendmapping SET friendstatus = 'potential' WHERE myphone = '$phone' AND friendphone = '$sessid' LIMIT 1";
							$update = mysql_query($sqlUpdate);
						}*/
						if($thisfriend != null) {
							$friendsArray[$i] = $thisfriend;
							$i++;
						}
					}
				} else {
					//valid wp user but no friendmapping entry between myphone and friendphone -- potential
					
					$sql = "INSERT INTO friendmapping VALUES('$sessid', '$phone', '0', '$potential')";
					$res = mysql_query($sql);

					$sql = "INSERT INTO friendmapping VALUES('$phone', '$sessid', '0', '$potential')";
					$res = mysql_query($sql);

					$thisfriend = (object) array(
									'fname'=>$fname,
									'lname'=>$lname,
									'hidden'=>"0",
									'friendstatus'=>$potential,
									'status'=>$status,
									'adjective'=>$adjective,
									'myphone'=>$sessid,
									'friendphone'=>$phone //use the friend phone when displaying in app
								);
					
					$friendsArray[$i] = $thisfriend;
					$i++;
				}
			} else {
				//didn't find an entry in user table for number -- invite
				
				/*
				$sql = "SELECT * FROM friendmapping WHERE (myphone = '$sessid' AND friendphone = '$phone') OR (myphone = '$phone' AND friendphone = '$sessid')";
				$result = mysql_query($sql);
				
				if(mysql_num_rows($result) < 1) {
					$sql = "INSERT INTO friendmapping VALUES('$sessid', '$phone', '0', '$invite')";
					$res = mysql_query($sql);

					$sql = "INSERT INTO friendmapping VALUES('$phone', '$sessid', '0', '$invite')";
					$res = mysql_query($sql); 
				}
				*/
				$thisfriend = (object) array(
					'fname'=>$fname,
					'lname'=>$lname,
					'hidden'=>"0",
					'friendstatus'=>$invite,
					'status'=>"",
					'adjective'=>"",
					'myphone'=>$sessid,
					'friendphone'=>$phone
				);
				$friendsArray[$i] = $thisfriend;
				$i++;		
			}
		}
	}

	echo json_encode($friendsArray);
	return;

?>