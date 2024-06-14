<?php

class Chat
{
	private $host  = 'localhost:3307';
	private $user  = 'root';
	private $password   = "";
	private $database  = "chat_system";
	private $chatTable = 'chat';
	private $chatUsersTable = 'chat_users';
	private $chatLoginDetailsTable = 'chat_login_details';
	public $dbConnect = false;
	public function __construct()
	{
		if (!$this->dbConnect) {
			$conn = new mysqli($this->host, $this->user, $this->password, $this->database);
			if ($conn->connect_error) {
				die("Error failed to connect to MySQL: " . $conn->connect_error);
			} else {
				$this->dbConnect = $conn;
			}
		}
	}
	private function getData($sqlQuery)
	{
		$result = mysqli_query($this->dbConnect, $sqlQuery);
		if (!$result) {
			die('Error in query: ' . mysqli_error($this->dbConnect));
		}
		$data = array();
		while ($row = mysqli_fetch_array($result, MYSQLI_ASSOC)) {
			$data[] = $row;
		}
		return $data;
	}
	private function getNumRows($sqlQuery)
	{
		$result = mysqli_query($this->dbConnect, $sqlQuery);
		if (!$result) {
			die('Error in query: ' . mysqli_error($this->dbConnect));
		}
		$numRows = mysqli_num_rows($result);
		return $numRows;
	}
	public function loginUsers($username, $password)
	{
		$sqlQuery = "
			SELECT userid, username 
			FROM " . $this->chatUsersTable . " 
			WHERE username='" . $username . "' AND password='" . $password . "'";
		return  $this->getData($sqlQuery);
	}
	public function chatUsers($userid)
	{
		$sqlQuery = "
			SELECT * FROM " . $this->chatUsersTable . " 
			WHERE userid != '$userid'";
		return  $this->getData($sqlQuery);
	}
	public function listchatUsers()
	{
		$list = '<ul>';
		$chatUsers = $this->chatUsers($_SESSION['userid']);
		foreach ($chatUsers as $user) {
			$sender_id = $user['userid']; // Replace with the actual sender ID
			$receiver_id = $_SESSION['userid']; // Replace with the actual receiver ID
			$emptymessage = $this->emptymessage($sender_id, $receiver_id);
			if (!empty($emptymessage)) {
				$message_time = $this->lastmessage($sender_id, $receiver_id);
				$currentSession = 1;
				if ($user['online'] == 0) {
					$active = "offline";
				} elseif ($user['online'] == 1) {
					$active = "online";
				} elseif ($user['online'] == 2) {
					$active = "busy";
				} elseif ($user['online'] == 3) {
					$active = "away";
				}
				$activeUser = '';
				if ($user['userid'] == $currentSession) {
					$activeUser = "active";
				}
				$list .= '<li id="' . $user['userid'] . '" class="contact ' . $activeUser . '" data-touserid="' . $user['userid'] . '" data-tousername="' . $user['username'] . '">';
				$list .= '<div class="content-messages">
		<ul class="content-messages-list">
			<li>
				<a href="#" data-conversation="#conversation-1">
				<span id="status_' . $user['userid'] . '" class="contact-status ' . $active . '"></span>

					<img class="content-message-image" src="/EasyCommunication/image/' . $user['img'] . '" alt="" />
					<span class="content-message-info">
						<span class="content-message-name">' . $user['username'] . '</span>
						<span class="content-message-text" id="content-message-text-' . $user['userid'] . '">' . $message_time[1] . '	</span>		
						<p class="preview"><span id="isTyping_' . $user['userid'] . '" class="isTyping"></span></p>
					</span>
					<span class="content-message-more">
					<p class="content-message-unread"> <span id="unread_' . $user['userid'] . '" class="unread">' . $this->getUnreadMessageCount($user['userid'], $_SESSION['userid']) . '</span></p>';
				$list .= '<span class="content-message-time" id="last-message-time-' . $user['userid'] . '">' . $message_time[0]
					. '</span>
					</span>
				</a>
			</li>
		</ul> ';
			}
		}
		$list .= '</div>';
		$data = array(
			"list" => $list,
		);
		echo json_encode($data);
	}
	public function getUserDetails($userid)
	{
		$sqlQuery = "
			SELECT * FROM " . $this->chatUsersTable . " 
			WHERE userid = '$userid'";
		return  $this->getData($sqlQuery);
	}
	public function getUserAvatar($userid)
	{
		$sqlQuery = "
			SELECT img 
			FROM " . $this->chatUsersTable . " 
			WHERE userid = '$userid'";
		$userResult = $this->getData($sqlQuery);
		$userAvatar = '';
		foreach ($userResult as $user) {
			$userAvatar = $user['img'];
		}
		return $userAvatar;
	}
	public function updateUserOnline($userId, $online)
	{
		$sqlUserUpdate = "
			UPDATE " . $this->chatUsersTable . " 
			SET online = '" . $online . "' 
			WHERE userid = '" . $userId . "'";
		mysqli_query($this->dbConnect, $sqlUserUpdate);
	}
	public function insertChat($reciever_userid, $user_id, $chat_message)
	{
		$sqlInsert = "
			INSERT INTO " . $this->chatTable . " 
			(reciever_userid, sender_userid, message, status) 
			VALUES ('" . $reciever_userid . "', '" . $user_id . "', '" . $chat_message . "', '1')";
		$result = mysqli_query($this->dbConnect, $sqlInsert);
		if (!$result) {
			return ('Error in query: ' . mysqli_error($this->dbConnect));
		} else {
			$conversation = $this->getUserChat($user_id, $reciever_userid);
			$data = array(
				"conversation" => $conversation
			);
			echo json_encode($data);
		}
	}
	public function getUserChat($from_user_id, $to_user_id)
	{
		$fromUserAvatar = $this->getUserAvatar($from_user_id);
		$toUserAvatar = $this->getUserAvatar($to_user_id);
		$sqlQuery = "SELECT * FROM " . $this->chatTable . " WHERE (sender_userid = '" . $from_user_id . "' AND reciever_userid = '" . $to_user_id . "') OR (sender_userid = '" . $to_user_id . "' 
			AND reciever_userid = '" . $from_user_id . "') ORDER BY timestamp ASC";
		$userChat = $this->getData($sqlQuery);
		$conversation = '<ul>';
		foreach ($userChat as $chat) {
			$user_name = '';
			if ($chat["sender_userid"] == $from_user_id) {
				$conversation .= '<li class="sent">';
				$conversation .= '<img width="22px" height="22px" src="/EasyCommunication/image/' . $fromUserAvatar . '" alt="" />';
			} else {
				$conversation .= '<li class="replies">';
				$conversation .= '<img width="22px" height="22px" src="/EasyCommunication/image/' . $toUserAvatar . '" alt="" />';
			}
			$conversation .= '<p>' . $chat["message"];
			$time = (empty($chat["timestamp"])) ? null : $chat["timestamp"];
			$time_without_seconds = date("g:i A", strtotime($time));
			$conversation .= '<br>';
			$conversation .= ' <small class="conversation-item-time">' .  $time_without_seconds . '</small>';
			$conversation .= '</br>';
			$conversation .= '</li>';
		}
		$conversation .= '</ul>';
		return $conversation;
	}
	public function showUserChat($from_user_id, $to_user_id)
	{
		$userDetails = $this->getUserDetails($to_user_id);
		$toUserAvatar = '';
		foreach ($userDetails as $user) {
			$toUserAvatar = $user['img'];
			$userSection = '<img src="/EasyCommunication/image/' . $user['img'] . '" alt="" />
				<p>' . $user['username'] . '</p>
				<div  class="social-media conversation-buttons" >
					
					<button type="button"><i class="ri-phone-fill"></i></button>
				    <button type="button"><i class="ri-vidicon-line"></i></button>
					<button type="button"><i class="ri-information-line"></i></button>
				</div>';
		}
		// get user conversation
		$conversation = $this->getUserChat($from_user_id, $to_user_id);
		// update chat user read status		
		$sqlUpdate = "
			UPDATE " . $this->chatTable . " 
			SET status = '0' 
			WHERE sender_userid = '" . $to_user_id . "' AND reciever_userid = '" . $from_user_id . "' AND status = '1'";
		mysqli_query($this->dbConnect, $sqlUpdate);
		// update users current chat session
		$sqlUserUpdate = "
			UPDATE " . $this->chatUsersTable . " 
			SET current_session = '" . $to_user_id . "' 
			WHERE userid = '" . $from_user_id . "'";
		mysqli_query($this->dbConnect, $sqlUserUpdate);
		$data = array(
			"userSection" => $userSection,
			"conversation" => $conversation
		);
		echo json_encode($data);
	}
	public function getUnreadMessageCount($senderUserid, $recieverUserid)
	{
		$sqlQuery = "
			SELECT * FROM " . $this->chatTable . "  
			WHERE sender_userid = '$senderUserid' AND reciever_userid = '$recieverUserid' AND status = '1'";
		$numRows = $this->getNumRows($sqlQuery);
		$output = '';
		if ($numRows > 0) {
			$output = $numRows;
		}
		return $output;
	}
	public function updateTypingStatus($is_type, $loginDetailsId)
	{
		$sqlUpdate = "
			UPDATE " . $this->chatLoginDetailsTable . " 
			SET is_typing = '" . $is_type . "' 
			WHERE id = '" . $loginDetailsId . "'";
		mysqli_query($this->dbConnect, $sqlUpdate);
	}
	public function fetchIsTypeStatus($userId)
	{
		$sqlQuery = "
		SELECT is_typing FROM " . $this->chatLoginDetailsTable . " 
		WHERE userid = '" . $userId . "' ORDER BY last_activity DESC LIMIT 1";
		$result =  $this->getData($sqlQuery);
		$output = '';
		foreach ($result as $row) {
			if ($row["is_typing"] == 'yes') {
				$output = ' - <small><em>Typing...</em></small>';
			}
		}
		return $output;
	}
	public function insertUserLoginDetails($userId)
	{
		$sqlInsert = "
			INSERT INTO " . $this->chatLoginDetailsTable . "(userid) 
			VALUES ('" . $userId . "')";
		mysqli_query($this->dbConnect, $sqlInsert);
		$lastInsertId = mysqli_insert_id($this->dbConnect);
		return $lastInsertId;
	}
	public function updateLastActivity($loginDetailsId)
	{
		$sqlUpdate = "
			UPDATE " . $this->chatLoginDetailsTable . " 
			SET last_activity = now() 
			WHERE id = '" . $loginDetailsId . "'";
		mysqli_query($this->dbConnect, $sqlUpdate);
	}
	public function getUserLastActivity($userId)
	{
		$sqlQuery = "
			SELECT last_activity FROM " . $this->chatLoginDetailsTable . " 
			WHERE userid = '$userId' ORDER BY last_activity DESC LIMIT 1";
		$result =  $this->getData($sqlQuery);
		foreach ($result as $row) {
			return $row['last_activity'];
		}
	}
	public function lastmessage($sender_id, $receiver_id)
	{
		$query = " SELECT timestamp AS last_message_time , message AS message FROM chat WHERE (sender_userid = ? AND reciever_userid = ?) OR (sender_userid = ? AND reciever_userid = ?)
    ORDER BY timestamp DESC LIMIT 1;";
		$stmt = mysqli_prepare($this->dbConnect, $query);
		mysqli_stmt_bind_param($stmt, "iiii", $sender_id, $receiver_id, $receiver_id, $sender_id);
		mysqli_stmt_execute($stmt);
		$result = mysqli_stmt_get_result($stmt);
		$row = mysqli_fetch_assoc($result);
		// print_r($row);
		$time = (empty($row['last_message_time'])) ? null : $row['last_message_time'];
		$time_without_seconds = date("g:i A", strtotime($time));
		return [$time_without_seconds, $row['message']];
	}
	public function updatelastmessage($sender_id, $receiver_id)
	{
		$query = "SELECT timestamp AS last_message_time , message AS message FROM chat WHERE (sender_userid = ? AND reciever_userid = ?) OR (sender_userid = ? AND reciever_userid = ?)
    ORDER BY timestamp DESC LIMIT 1;";
		$stmt = mysqli_prepare($this->dbConnect, $query);
		mysqli_stmt_bind_param($stmt, "iiii", $sender_id, $receiver_id, $receiver_id, $sender_id);
		mysqli_stmt_execute($stmt);
		$result = mysqli_stmt_get_result($stmt);
		$row = mysqli_fetch_assoc($result);
		$time = (empty($row['last_message_time'])) ? null : $row['last_message_time'];
		$time_without_seconds = date("g:i A", strtotime($time));
		$message = '<span class="content-message-text" id="content-message-text-' . $sender_id . '">' . $row['message'] . '</span>';
		$time = '<span class="content-message-time" id="last-message-time-' . $sender_id . '">' . $time_without_seconds . '</span>';
		$data = array(
			"last_message_time" => $time,
			"message" => $message,
		);
		echo json_encode($data);
	}
	public function emptymessage($sender_id, $receiver_id)
	{
		$query = "SELECT  message FROM chat WHERE (sender_userid = ? AND reciever_userid = ?) OR (sender_userid = ? AND reciever_userid = ?);";
		$stmt = mysqli_prepare($this->dbConnect, $query);
		mysqli_stmt_bind_param($stmt, "iiii", $sender_id, $receiver_id, $receiver_id, $sender_id);
		mysqli_stmt_execute($stmt);
		$result = mysqli_stmt_get_result($stmt);
		$row = mysqli_fetch_assoc($result);
		return $row;
	}
	public function search($input)
	{
		$query = "SELECT * FROM chat_users WHERE username LIKE ? OR email LIKE ? OR country LIKE ? OR mainlanguage LIKE ?";
		$stmt = mysqli_prepare($this->dbConnect, $query);
		$search = "%" . $input . "%";
		mysqli_stmt_bind_param($stmt, "ssss", $search, $search, $search, $search);
		mysqli_stmt_execute($stmt);
		$result = mysqli_stmt_get_result($stmt);
		// $row = mysqli_fetch_array($result, MYSQLI_ASSOC);
		$rows = []; // Initialize an array to store all matching rows
		// Loop through the result set and fetch all rows
		$message = '';
		while ($row = mysqli_fetch_array($result, MYSQLI_ASSOC)) {
			$rows[] = $row; // Append each row to the array
			$message .= '<a href="#" class="new" id="' . $row['userid'] . '">
			<div class="cont">
				<img src="image/' . $row['img'] . '" alt="">
				<div class="details">
					<span class="user">' . $row['username'] . '</span>
					<span>' . $row['country'] . '</span>
					<span>' . $row['mainlanguage'] . '</span>
					<p>' . $row['email'] . '</p>
				</div>
			</div>
		</a>';
		}
		$data = array(
			"message" => $message,
		);
		echo json_encode($data);
	}
	public function updateprofile($update)
	{
		if ($update[0] == 'update-username') {
			$query = "UPDATE chat_users SET username = ? WHERE userid =?";
			$stmt = mysqli_prepare($this->dbConnect, $query);
			mysqli_stmt_bind_param($stmt, "si", $update[1], $_SESSION['userid']);
			mysqli_stmt_execute($stmt);
			$result = mysqli_stmt_get_result($stmt);
		} elseif ($update[0] == 'update-country') {
			$query = "UPDATE chat_users SET country = ? WHERE userid =?";
			$stmt = mysqli_prepare($this->dbConnect, $query);
			mysqli_stmt_bind_param($stmt, "si", $update[1], $_SESSION['userid']);
			mysqli_stmt_execute($stmt);
			$result = mysqli_stmt_get_result($stmt);
		} elseif ($update[0] == 'update-lang') {
			$query = "UPDATE chat_users SET mainlanguage = ? WHERE userid =?";
			$stmt = mysqli_prepare($this->dbConnect, $query);
			mysqli_stmt_bind_param($stmt, "si", $update[1], $_SESSION['userid']);
			mysqli_stmt_execute($stmt);
			$result = mysqli_stmt_get_result($stmt);
		} elseif ($update[0] == 'update-pass') {
			$query = "SELECT password FROM chat_users WHERE  userid =?";
			$stmt = mysqli_prepare($this->dbConnect, $query);
			mysqli_stmt_bind_param($stmt, "i", $_SESSION['userid']);
			mysqli_stmt_execute($stmt);
			$result = mysqli_stmt_get_result($stmt);
			$row = mysqli_fetch_assoc($result);
			if ($update[2] == $row['password']) {
				$query = "UPDATE chat_users SET password = ? WHERE userid =?";
				// print_r($update[2]);
				$stmt = mysqli_prepare($this->dbConnect, $query);
				mysqli_stmt_bind_param($stmt, "si", $update[1], $_SESSION['userid']);
				mysqli_stmt_execute($stmt);
				$result = mysqli_stmt_get_result($stmt);
			}
		} elseif ($update[0] == 'update-img') {
			move_uploaded_file($update[1]['tmp_name'], "image/" . $update[1]['name']);
			$query = "UPDATE chat_users SET img = ? WHERE userid =?";
			$stmt = mysqli_prepare($this->dbConnect, $query);
			mysqli_stmt_bind_param($stmt, "si", $update[1]['name'], $_SESSION['userid']);
			mysqli_stmt_execute($stmt);
			$result = mysqli_stmt_get_result($stmt);
		}
	}
	public function registerUser($username, $email, $country, $mainLanguage, $password, $img_name)
	{
		$hashedPassword = password_hash($password, PASSWORD_DEFAULT);
		$sqlQuery = "INSERT INTO " . $this->chatUsersTable . " (username,email,country,cainLanguage,password,img) VALUES 
		('" . $username . "', '" . $email . "', '" . $country . "', '" . $mainLanguage . "', '" . $password . "', '" . $img_name . "')";
		return	mysqli_query($this->dbConnect, $sqlQuery);;
	}
	public function isUsernameExists($username)
	{
		$sqlQuery = "SELECT COUNT(*) as count FROM " . $this->chatUsersTable . " WHERE username='" . $username . "'";
		$result = $this->getData($sqlQuery);
		return ($result[0]['count'] > 0);
	}
}
