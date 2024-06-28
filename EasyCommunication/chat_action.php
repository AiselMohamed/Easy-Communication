<?php
session_start();
include('Chat.php');
$chat = new Chat();
if ($_POST['action'] == 'update_user_list') {
	$chatUsers = $chat->chatUsers($_SESSION['userid']);
	$list = $chat->listchatUsers();
	$data = array(
		"profileHTML" => $chatUsers,
	);
	echo json_encode($data);
}
if ($_POST['action'] == 'update_list') {
	$list = $chat->listchatUsers();
}

if ($_POST['action'] == 'insert_chat') {
	$chat->insertChat($_POST['to_user_id'], $_SESSION['userid'], $_POST['chat_message']);
}
if ($_POST['action'] == 'show_chat') {
	$chat->showUserChat($_SESSION['userid'], $_POST['to_user_id']);
}
if ($_POST['action'] == 'update_user_chat') {
	$conversation = $chat->getUserChat($_SESSION['userid'], $_POST['to_user_id']);
	$data = array(
		"conversation" => $conversation
	);
	echo json_encode($data);
}
if ($_POST['action'] == 'update_unread_message') {
	$count = $chat->getUnreadMessageCount($_POST['to_user_id'], $_SESSION['userid']);
	$data = array(
		"count" => $count
	);
	echo json_encode($data);
}
if ($_POST['action'] == 'update_typing_status') {
	$chat->updateTypingStatus($_POST["is_type"], $_SESSION["login_details_id"]);
}
if ($_POST['action'] == 'show_typing_status') {
	$message = $chat->fetchIsTypeStatus($_POST['to_user_id']);
	$data = array(
		"message" => $message
	);
	echo json_encode($data);
}


if ($_POST['action'] == 'last-message-time') {
	$time_without_seconds = $chat->updatelastmessage($_POST['sender_id'], $_SESSION['userid']);
}

if ($_POST['action'] == 'search') {
	if (!empty($_POST['search'])) {
		 $chat->search($_POST['search']);
	}
}

if ($_POST['action'] == 'update_status') {
	if ($_POST['status'] == 0) {
		$chat->updateUserOnline($_SESSION['userid'], 0);
	} elseif ($_POST['status'] == 1) {
		$chat->updateUserOnline($_SESSION['userid'], 1);
	} else if ($_POST['status'] == 2) {
		$chat->updateUserOnline($_SESSION['userid'], 2);
	} else if ($_POST['status'] == 3) {
		$chat->updateUserOnline($_SESSION['userid'], 3);
	}
}
if ($_POST["action"] == "get-user") {
	// $message = $chat->getUserDetails($_SESSION['userid']);
	$data = array(
		// "message" => $message,
		"profile" => $_POST["profile"]
	);
	echo json_encode($data);
}
