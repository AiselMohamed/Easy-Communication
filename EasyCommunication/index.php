<?php
require_once 'vendor/autoload.php';

use Stichoza\GoogleTranslate\GoogleTranslate;
session_start();
include('header.php');
clearstatcache();
include('Chat.php');
$chat = new Chat();
if (isset($_POST['update-username']) && !empty($_POST['update-username'])) {
	$chat->updateprofile(['update-username', $_POST['update-username']]);
} elseif (isset($_POST['update-country']) && !empty($_POST['update-country'])) {
	$chat->updateprofile(['update-country', $_POST['update-country']]);
} elseif (isset($_POST['update-lang']) && !empty($_POST['update-lang'])) {
	$chat->updateprofile(['update-lang', $_POST['update-lang']]);
} elseif (isset($_POST['update-oldpass'], $_POST['update-newpass']) && !empty($_POST['update-oldpass']) && !empty($_POST['update-newpass'])) {
	$chat->updateprofile(['update-pass', $_POST['update-newpass'], $_POST["update-oldpass"]]);
} elseif (isset($_FILES['img_profile']) && $_FILES['img_profile']['size'] > 0) {
	$chat->updateprofile(['update-img', $_FILES['img_profile']]);
}


?>
<link rel='stylesheet prefetch' href='https://cdnjs.cloudflare.com/ajax/libs/font-awesome/4.6.2/css/font-awesome.min.css'>
<link href="https://cdn.jsdelivr.net/npm/remixicon@3.2.0/fonts/remixicon.css" rel="stylesheet">
<script type="module" src="https://cdn.jsdelivr.net/npm/emoji-picker-element@^1/index.js"></script>
<link href='https://unpkg.com/boxicons@2.1.4/css/boxicons.min.css' rel='stylesheet'>

<link href="css/css.css" rel="stylesheet" id="bootstrap-css">
<link rel="stylesheet" href="tailwindcss-colors.css">
<!-- <link rel="stylesheet" href="css/css.css"> -->
<title>Easy Communication</title>
<style>
	.modal-dialog {
		width: 400px;
		margin: 30px auto;
	}

	#frame {
		width: 1535px !important;
		min-width: 360px !important;
		max-width: 2600px !important;
		height: 100vh !important;
		min-height: 300px;
		max-height: 750px;
		background: #E6EAEA;
	}
</style>
<?php
// include('container.php'); 
?>
</head>

<body class="">

	<?php if (isset($_SESSION['userid']) && $_SESSION['userid']) {
		if (isset($_SESSION["login"])) {

	?>
			<!-- start: Chat -->
			<section class="chat-section">

				<div class="chat-container">
					<!-- start: Sidebar -->
					<aside class="chat-sidebar">
						<a href="#" class="chat-sidebar-logo">
							<i class="ri-chat-1-fill"></i>
						</a>
						<ul class="chat-sidebar-menu">
							<li id="chat-menu" class="menu-active"><a href="#" id="Chats" data-title="Chats"><i id="Chats" class="ri-chat-3-line"></i></a></li>

							<li id="update-info"><a href="#" id="profile-info" data-title="profile"><i id="profile-info" class="ri-user-line"></i></a></li>
							<li><a href="logout.php" id="logout" data-title="logout"><i class="ri-logout-box-line"></i></a></li>
							<?php
							$loggedUser = $chat->getUserDetails($_SESSION['userid']);
							$currentSession = '';
							echo '<div class="wrap" style="
								padding-top: 265px;
							">'; ?>
							<li class="chat-sidebar-profile">
							<li class="chat-sidebar-profile">

								<?php
								foreach ($loggedUser as $user) {
									$currentSession = $user['current_session'];
								?>
									<button type="button" class="chat-sidebar-profile-toggle">
										<?php
										if ($user['online'] == 0) {
											$active = "offline";
										} elseif ($user['online'] == 1) {
											$active = "online";
										} elseif ($user['online'] == 2) {
											$active = "busy";
										} elseif ($user['online'] == 3) {
											$active = "away";
										}
										echo '<img id="profile-img" src="/EasyCommunication/image/' . $user['img'] . '" class="' . $active . '" alt="" />';
										?>
									</button>
									<?php
									echo '<div id="status-options">';
									?>
									<ul class="chat-sidebar-profile-dropdown">
										<?php
										echo '<li id="status-online" class="active"><span class="status-circle"></span> <p>Online</p></li>';
										echo '<li id="status-away"><span class="status-circle"></span> <p>Away</p></li>';
										echo '<li id="status-busy"><span class="status-circle"></span> <p>Busy</p></li>';
										echo '<li id="status-offline"><span class="status-circle"></span> <p>Offline</p></li>';

										?>
									</ul>


								<?php echo '</div>';
								}
								echo '</div>';
								?>
							</li>
						</ul>
					</aside>
					<!-- end: Sidebar -->

					<div id="frame">
						<div id="sidepanel" class='active'>
							<div id="profile">
								<?php

								$chat = new Chat();
								$loggedUser = $chat->getUserDetails($_SESSION['userid']);

								?>
								<div class="content-sidebar-title">Chats</div>
								<form action="" class="content-sidebar-form">

									<input type="search" class="content-sidebar-input" placeholder="Search...">

									<button type="submit" class="content-sidebar-submit"><i class="ri-search-line"></i></button>
								</form>
								<div class="users-list">

								</div>


							</div>
							<div id="contacts">
								<?php
								echo '<ul>';
								$chatUsers = $chat->chatUsers($_SESSION['userid']);

								foreach ($chatUsers as $user) {
									$sender_id = $user['userid'];
									$receiver_id = $_SESSION['userid'];
									$emptymessage = $chat->emptymessage($sender_id, $receiver_id);
									if (!empty($emptymessage)) {
										$message_time = $chat->lastmessage($sender_id, $receiver_id);
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
										echo '<li id="' . $user['userid'] . '" class="contact ' . $activeUser . '" data-touserid="' . $user['userid'] . '" data-tousername="' . $user['username'] . '">';

								?>
										<div class="content-messages">
											<ul class="content-messages-list">
												<li>
													<a href="#" data-conversation="#conversation-1">
														<span id="status_<?= $user['userid'] ?>" class="contact-status <?= $active ?>"></span>

														<img class="content-message-image" src="/EasyCommunication/image/<?= $user['img'] ?>" alt="" />

														<span class="content-message-info">
															<span class="content-message-name"><?= $user['username'] ?></span>

															<span class="content-message-text" id="content-message-text-<?= $user['userid'] ?>"><?php 
															$fromUsers = $chat->getUserDetails($_SESSION['userid']);
															$toUsers = $chat->getUserDetails($user['userid']);
															echo  GoogleTranslate::trans($message_time[1],$fromUsers[0]['mainlanguage'] , $toUsers[0]['mainlanguage']);
																																				?></span>
															<p class="preview"><span id="isTyping_<?= $user['userid'] ?>" class="isTyping"></span></p>


														</span>
														<span class="content-message-more">
															<?php echo '<p class="content-message-unread">' . '<span id="unread_' . $user['userid'] . '" class="unread">' . $chat->getUnreadMessageCount($user['userid'], $_SESSION['userid']) . '</span></p>';


															?>

															<span class="content-message-time" id="last-message-time-<?= $user['userid'] ?>"><?php
																																				echo $message_time[0];
																																				?></span>
														</span>
													</a>
												</li>
											</ul>
										</div>

								<?php	}
								}
								?>
							</div>

						</div>
						<div id="sidepanel-profile" class='active'>
							<div class="info_profile">
								<?php
								$chatUsers = $chat->getUserDetails($_SESSION['userid']);
								?>
								<!-- Image part -->
								<div class="img_profile" id="div-img_profile">
									<img src="/EasyCommunication/image/<?= $chatUsers[0]['img'] ?>" alt="Profile Image">
									<form method=post enctype="multipart/form-data" id="img-form">
										<label for="file-input" class="custom-file-input"><i class='bx bx-camera' id="img_profile"></i></label>

										<input type="file" name="img_profile" id="file-input" class="profile-input" style=" 
			border:none; margin:10px 0 0; font-size: 22px;
			font-weight: 600;
			color:#000;">
									</form>
								</div>
								<!-- Name part -->
								<div class="name_profile" id="div-name_profile">
									<h3><?= $chatUsers[0]['username'] ?></h3>

									<i class='bx bx-pencil' id="name_profile"></i>
								</div>
								<!-- email part -->
								<div class="desc_profile">
									<p class="about">Email</p>
									<div class="desc_edit">
										<p><?= $chatUsers[0]['email'] ?></p>
									</div>
									<div class="desc_profile" id="div-country_profile">
										<p class="about">Country</p>
										<div class="desc_edit">
											<p><?= $chatUsers[0]['country'] ?></p>
											<i class='bx bx-pencil' id="country_profile"></i>
										</div>
									</div>
									<div class="desc_profile" id="div-lang_profile">
										<p class="about">MainLanguage</p>
										<div class="desc_edit">
											<p><?php
											$lang=['ar'=>'Arabic','en'=>'English','fr'=>'French','de'=>'Germany','zh-CN'=>'China'];
											echo $lang[$chatUsers[0]['mainlanguage']]?></p>
											<i class='bx bx-pencil' id="lang_profile"></i>
										</div>
									</div>
									<div class="desc_profile" id="div-pass_profile">
										<p class="about">Password</p>
										<div class="desc_edit">
											<p><?= str_repeat("*", strlen($chatUsers[0]['password'])) ?></p>
											<i class='bx bx-pencil' id="pass_profile"></i>
										</div>
									</div>
									<!-- LogOut Button -->

								</div>
							</div>
						</div>
						<div class="content" id="content">
							<div class="contact-profile" id="userSection">
								<?php
								$userDetails = $chat->getUserDetails($currentSession);

								foreach ($userDetails as $user) {
									echo '<img src="/EasyCommunication/image/' . $user['img'] . '" alt="" />';
									echo '<p>' . $user['username'] . '</p>';
									echo '<div class="social-media conversation-buttons">';

									echo '<button type="button"><i class="ri-phone-fill"></i></button>';
									echo '<button type="button"><i class="ri-vidicon-line"></i></button>';
									echo '<button type="button"><i class="ri-information-line"></i></button>';
									echo '</div>';
								}
								?>
							</div>
							<div class="messages" id="conversation">
								<?php
								echo $chat->getUserChat($_SESSION['userid'], $currentSession);
								?>
							</div>
							
							<div class="message-input" id="replySection">
								<div class="message-input" id="replyContainer">
									<div class="conversation-form">
										<button type="button" class="emojebutton"><i class="ri-emotion-line"></i></button>
										<div class="conversation-form-group">
											<input type="text" class="conversation-form-input" id="chatMessage<?php echo $currentSession; ?>" rows="1" placeholder="Type here..." />
											<button type="button" class="conversation-form-record"><i class="ri-mic-line"></i></button>
											<button type="button" class="conversation-form-file"><i class="ri-attachment-2"></i></button>
											<button type="button" class="conversation-form-tran"><i class="ri-translate-2"></i></button>
										</div>
										<button type="button" class="submit chatButton conversation-form-button conversation-form-submit" id="chatButton<?php echo $currentSession; ?>">
											<i class="ri-send-plane-2-line"></i></button>
									</div>
								</div>
							</div>
							<div class="emoji" id="emoji"><emoji-picker class="light"></emoji-picker>
							</div>
						</div>
			</section>
			<!-- end: Chat -->
			<!-- <script src="script.js"></script> -->
			<script src="js/chats.js"></script>
			<script>
				document.querySelector('emoji-picker')
					.addEventListener('emoji-click', (event) => {
						const inputField = document.querySelector(".conversation-form-input");
						inputField.value += event.detail['emoji']['unicode'];
					});
			</script>
			<!-- <script src="script.js"></script> -->
			<!-- <script src="js/chats.js"></script> -->
		<?php }
	} else { ?>

		<?php header("location: login.php") ?>

	<?php } ?>

</body>

</html>