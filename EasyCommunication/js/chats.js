
$(document).ready(function () {
	// setInterval(function () {
	 
	// 	updatelist()
	// 	showTypingStatus();
	// 	updateUserChatsearch()
	// }, 1000);//miliseconde 1s=1000ms
	setInterval(function () {
		// updateUserList();
		updateUnreadMessageCount();
		updateUnreadMessage();
		updatelist();
		showTypingStatus();
		updateUserChatsearch()
	}, 1000);//miliseconde 1s=1000ms
	
	$(".messages").animate({
		scrollTop: $(document).height()
	}, "fast");
	$(document).on("click", '#profile-img', function (event) {
		$("#status-options").toggleClass("active");
		$(".chat-sidebar-profile-toggle").toggleClass("active");
		$(".chat-sidebar-profile").toggleClass("active");

	});
	$(document).on("click", '.emojebutton', function (event) {
		$("#emoji").toggleClass("active");

	});
	// open profile section from sidebar and hide users
	$(document).on('click', '#profile-info', function () {
		$("#sidepanel").css("display", "none");
		$("#sidepanel-profile").css("display", "block");
		$('#chat-menu').removeClass('menu-active');
		$('#update-info').addClass('menu-active');
	});
	// open chat users from sidebar and hide profile section
	$(document).on('click', '#Chats', function () {
		$("#sidepanel").css("display", "block");
		$("#sidepanel-profile").css("display", "none");
		$('#update-info').removeClass('menu-active');
		$('#chat-menu').addClass('menu-active');
	});
	// profile js
	$(document).on('click', '#name_profile', function () {
		let profile = "name_profile";
		getuser(profile);
	})
	$(document).on('click', '#country_profile', function () {
		let profile = "country_profile";
		getuser(profile);
	})
	$(document).on('click', '#lang_profile', function () {
		let profile = "lang_profile";
		getuser(profile);
	})
	$(document).on('click', '#pass_profile', function () {
		let profile = "pass_profile";
		getuser(profile);
	})

	$(document).on('click', '#img_profile', function () {
		let profile = "img_profile";
		getuser(profile);
	})


	// profile js
	// $(document).on('click', '.contact', function () {
	// 	$('.contact').removeClass('active');
	// 	$(this).addClass('active');
	// 	var to_user_id = $(this).data('touserid');
	// 	showUserChat(to_user_id);
	// 	$(".chatMessage").attr('id', 'chatMessage' + to_user_id);
	// 	$(".chatButton").attr('id', 'chatButton' + to_user_id);
	// });
	$(document).on('click','.new, .contact', function () {
		$('.contact').removeClass('active');
		$(this).addClass('active');
		var to_user_id = $(this).attr('id');
		showUserChat(to_user_id);
		$(".chatMessage").attr('id', 'chatMessage' + to_user_id);
		$(".chatButton").attr('id', 'chatButton' + to_user_id);
	});
	$(document).on("click", '.submit', function (event) {
		var to_user_id = $(this).attr('id');
		to_user_id = to_user_id.replace(/chatButton/g, "");
		sendMessage(to_user_id);
		fetchLastMessageTime(to_user_id);
		scrollToBottom();
	});
function input(){
	var submit_id = $(".submit").attr('id');
	submit_id = submit_id.replace(/chatButton/g, "");
// console.log(submit_id);

if(submit_id == 0){
	document.querySelector(".message-input").style.display = "none";
}else if(submit_id != 0){
	document.querySelector(".message-input").style.display = "block";

}
}
input()

	// 0=>offline
	// 1=>online
	// 2=>busy
	// 3=>away
	$(document).on("click", '#status-options ul li', function (event) {
		$("#profile-img").removeClass();
		$("#status-online ,#status-busy,#status-offline,#status-away").removeClass("active");
		// $("#status-away").removeClass("active");
		// $("#status-busy").removeClass("active");
		// $("#status-offline").removeClass("active");
		$(this).addClass("active");
		if ($("#status-online").hasClass("active")) {
			$("#profile-img").addClass("online");
			$.ajax({
				url: "chat_action.php",
				method: "POST",
				data: { status: 1, action: 'update_status' },
				success: function () {
				}
			});
		} else if ($("#status-away").hasClass("active")) {
			$("#profile-img").addClass("away");
			$.ajax({
				url: "chat_action.php",
				method: "POST",
				data: { status: 3, action: 'update_status' },
				success: function () {
				}
			});
		} else if ($("#status-busy").hasClass("active")) {
			$("#profile-img").addClass("busy");
			$.ajax({
				url: "chat_action.php",
				method: "POST",
				data: { status: 2, action: 'update_status' },
				success: function () {
				}
			});
		} else if ($("#status-offline").hasClass("active")) {
			$("#profile-img").addClass("offline");
			$.ajax({
				url: "chat_action.php",
				method: "POST",
				data: { status: 0, action: 'update_status' },
				success: function () {
				}
			});
		} else {
			$("#profile-img").removeClass();
		};
		$("#status-options").removeClass("active");
		$(".chat-sidebar-profile-toggle").removeClass("active");
		$(".chat-sidebar-profile").removeClass("active");
	});
	
	$(document).on('focus', '.conversation-form-input', function () {
		var is_type = 'yes';
		$.ajax({
			url: "chat_action.php",
			method: "POST",
			data: { is_type: is_type, action: 'update_typing_status' },
			success: function () {
			}
		});
	});
	$(document).on('blur', '.conversation-form-input', function () {
		var is_type = 'no';
		$.ajax({
			url: "chat_action.php",
			method: "POST",
			data: { is_type: is_type, action: 'update_typing_status' },
			success: function () {
			}
		});
	});
});

var searchBar = document.querySelector(".content-sidebar-input");
const searchBtn = document.querySelector(".content-sidebar-input button");
var userList = document.querySelector(".users-list");
var userLista = document.querySelector(".new");
let intervalId
searchBar.addEventListener("focus", () => {
	userList.style.display = "block";
	intervalId = setInterval(function () {
		search();
		console.log("here");
	}, 1000);
	intervalId
});
searchBar.addEventListener("blur", () => {
	// Add event listener for mouseout on userList
	userList.addEventListener("mouseout", () => {
		// Check if mouse is not over userList
		if (!userList.contains(event.relatedTarget)) {
			userList.style.display = "none";
			clearInterval(intervalId);

		}
	});
});

function search() {
	var value = searchBar.value;
	test = $(`.users-list`);
 console.log(value)
	$.ajax({
		url: 'chat_action.php',
		method: 'POST',
		data: { action: 'search', search: value },
		dataType: 'json',
		success: function (data) {
			// Update the HTML content with the last message time
			test.html(data.message)
 

		},
		error: function (xhr, status, error) {
			console.error('Error search:', error);
		}
	}

	);

}
function getuser(profile) {
	// $.ajax({
	// 	url: 'chat_action.php',
	// 	method: 'POST',
	// 	data: { action: 'get-user', profile: profile },
	// 	dataType: 'json',
	// 	success: function (data) {
			// Update the HTML content with the last message time
			if (profile == "name_profile") {
				console.log(profile);

				$("#div-name_profile").replaceWith
					(`<div class="name_profile" id="div-name_profile" style=" 
			border-bottom: solid 1px black;
			padding-bottom: 5px;">
			<form method="post" style="
			width: 100%;
			display: flex;
			justify-content: space-between;">
		    <input name="update-username" class="profile-input" type="text" style=" 
		    border:none; margin:10px 0 0; font-size: 22px;
		    font-weight: 600;
		    color:#000;" >
		    <button  style="border:none; background-color:white;" type='submit' ><i style="font-size: 23px;" class='bx bx-check' id="save-name_profile"></i></button></form>`
					)
			} else if (profile == "country_profile") {
				$("#div-country_profile").replaceWith
					(`                     <p class="about">Country</p>
					<div class="desc_profile" id="div-country_profile" style=" 
					border-bottom: solid 1px black; margin-bottom:30px;
					padding-bottom: 5px; margin-bottom: 30px;">
					<form method="post" style="
					width: 100%;
					display: flex;
					justify-content: space-between;
				">
				
				<select name="update-country" style=" 
				border:none;  font-size: 19px;
                color:#000;" class="form-control  p_input" style="color: #495c81;">
							    <option label="choose country"></option>
								<option value="Armenia">Armenia</option>
								<option>Albania</option>
								<option value="America">America</option>
								<option>Australia</option>
                                <option>Bahrain</option><option>Bulgaria</option><option>Brazil</option>
                                <option value="China">China</option><option value="Canada">Canada</option>
                                <option>Denmark</option>
                                <option value="Egypt">Egypt</option>
                                <option value="France">France</option>
                                <option>Greece</option><option value="Germany">Germany</option>
                                <option>Hong Kong</option><option>Hawaii</option>
								<option>India</option><option>Iceland</option><option>Ireland</option><option>Italy</option><option>Iran</option>
                                <option>Japan</option>
                                <option>Korea</option><option>Kuwait</option>
                                <option>Luxembourg</option><option>Lebanon</option>
								<option>Mauritania</option><option>Morocco</option><option>Malaysia</option><option>Macau</option><option>Mongolia</option>
                                <option>Norway</option><option>North Macedonia</option><option>Netherlands</option><option>New Zealand</option>
                                <option>Oman</option>
								<option>Palestine</option><option>Poland</option><option>Philippines</option>
                                <option>Qatar</option>
								<option>Romania</option><option>Russia</option><option>Romania</option>
								<option>South Africa</option><option>Somalia</option><option>Sudan</option><option>Serbia</option><option>Singapore</option><option>Somalia</option><option>Spain</option><option>Sweden</option>
                                <option>Tanzania</option><option>Taiwan</option><option>Tunisia</option><option>Thailand</option><option>Turkey</option>
								<option>Ukraine</option><option value="United States">United States</option><option>Ukraine</option><option>United Kingdom</option>
								<option>Vietnam</option><option>Vatican</option>
		
							</select>
				<button  style="border:none; background-color:white;" type='submit' ><i style="font-size: 23px;" class='bx bx-check' id="save-country_profile"></i></button></form>`)
			} else if (profile == "lang_profile") {
				$("#div-lang_profile").replaceWith
					(`                     <p class="about">MainLanguage</p>
				<div class="desc_profile" id="div-lang_profile" style=" 
				border-bottom: solid 1px black;  margin-bottom:30px;
				padding-bottom: 5px;">
				<form method="post" style="
				width: 100%;
				display: flex;
				justify-content: space-between;
			">
			
			<select name="update-lang" class="profile-input" type="text" style=" 
			border:none; margin-bottom:0px;   font-size: 19px;
			color:#000;" >		
												<option label="choose language"></option>
							<option value="af">Afrikaans</option>
                            <option value="ar">Arabic</option>
                            <option value="hy">Armenian</option>
                            <option value="bg">Bulgarian</option>
                            <option value="zh-CN">Chinese(Simplified)</option>
                            <option value="zh-TW">Chinese(Traditional)	</option>
                            <option value="cs">Czech</option>
                            <option value="da">Danish</option>
                            <option value="nl">Dutch</option>
							<option value="en">English</option>
							<option value="fil">Filipino</option>
							<option value="fr">French</option>
							<option value="de">German</option>
							<option value="el">Greek</option>
							<option value="haw">Hawaiian</option>
							<option value="hi">Hindi</option>
							<option value="is">Icelandic</option>
							<option value="ga">Irish</option>
							<option value="it">Italian</option>
							<option value="ja">Japanese</option>
							<option value="kn">Kannada</option>
							<option value="ko">Korean</option>
							<option value="la">Latin</option>
							<option value="mn">Mongolian</option>
							<option value="my">Myanmar</option>
							<option value="no">Norwegian</option>
							<option value="fa">Persian</option>
							<option value="pl">Polish</option>
							<option value="pt">Portuguese</option>
							<option value="ro">Romanian</option>
							<option value="ru">Russian</option>
							<option value="so">Somali</option>
							<option value="es">Spanish</option>
							<option value="sv">Swedish</option>
							<option value="tr">Turkish</option>
							<option value="uk">Ukrainian</option>
							<option value="vi">Vietnamese</option>
						
                            </select>
			<button  style="border:none; background-color:white;" type='submit' ><i style="font-size: 23px;" class='bx bx-check' id="save-lang_profile"></i></button></form>`)

			} else if (profile == "img_profile") {
				$("#img-form").append
					(`
				<button  style="border:none; background-color:transparent;  
			position: absolute;
            left: 30px;
            top: 135px;" name="update-img" type='submit' ><i style="font-size: 30px;" class='bx bx-check' id="save-img_profile"></i></button>`)

			}
			else if (profile == "pass_profile") {
				// let count = data["message"][0]['password'].length
				$("#div-pass_profile").replaceWith
					(` 		<p class="about">Password</p>
			<form method="post" style="
			width: 100%;
			display: flex;
			flex-flow: column;
			justify-content: space-between;
		"><div class="desc_profile" id="div-pass_profile" style=" 
		border-bottom: solid 1px black;  margin-bottom:15px;
		padding-bottom: 5px;">
			<input name="update-oldpass" class="profile-input" type="text" style=" 
			border:none; margin-bottom:0px;  width:100% font-size: 19px;
						color:#000;" placeholder="Enter your old password">
</div><br>
						<div class="desc_profile" id="div-pass_profile" style=" display: flex;
                        justify-content: space-between;
											border-bottom: solid 1px black;  margin-bottom:30px;
						padding-bottom: 5px;">
						
						<input name="update-newpass" class="profile-input" type="text" style=" 
						border:none; margin-bottom:0px;  width:100% font-size: 19px;
									color:#000;" placeholder="Enter your new password">
						
			<button  style="border:none; background-color:white;" type='submit' ><i style="font-size: 23px;" class='bx bx-check' id="save-pass-profile"></i></button></div></form>`)
			}}
		// },
		// error: function (xhr, status, error) {
		// 	console.error('Error get user:', error);
		// }
// 	}

// 	);

// }
function scrollToBottom() {
	var messageDiv = document.getElementById('conversation');
	var scrollHeight = messageDiv.scrollHeight;
	var clientHeight = messageDiv.clientHeight;
	var padding = parseInt(window.getComputedStyle(messageDiv).paddingBottom);
	var border = parseInt(window.getComputedStyle(messageDiv).borderBottomWidth);
	var margin = parseInt(window.getComputedStyle(messageDiv).marginBottom);
	var totalSpace = padding + border + margin;
	messageDiv.scrollTop = scrollHeight + clientHeight - totalSpace;
}
function fetchLastMessageTime(to_user_id) {
	lastMessageTimeElement = $(`#last-message-time-${to_user_id}`);
	lastMessageElement = $(`#content-message-text-${to_user_id}`);

	$.ajax({
		url: 'chat_action.php',
		method: 'POST',
		data: { action: 'last-message-time', sender_id: to_user_id },
		dataType: 'json',
		success: function (data) {
			// Update the HTML content with the last message time

			lastMessageTimeElement.html(data.last_message_time);
			lastMessageElement.html(data.message);
		},
		error: function (xhr, status, error) {
			console.error('Error fetching last message time:', error);
		}
	}

	);

}
function updatelist() {
	userlist = $(`#contacts`);
	$.ajax({
		url: 'chat_action.php',
		method: 'POST',
		data: { action: 'update_list' },
		dataType: 'json',
		success: function (data) {
			// Update the HTML content 

			userlist.html(data.list);
		},
		error: function (xhr, status, error) {
			console.error('Error fetching user list:', error);
		}
	}

	);

}
function updateUserList() {
	$.ajax({
		url: "chat_action.php",
		method: "POST",
		dataType: "json",
		data: { action: 'update_user_list' },
		success: function (response) {
			var obj = response.profileHTML;

			Object.keys(obj).forEach(function (key) {
				// update user online/offline status
				if ($("#" + obj[key].userid).length) {
					if (obj[key].online == 1 && !$("#status_" + obj[key].userid).hasClass('online')) {
						$("#status_" + obj[key].userid).addClass('online');
					} else if (obj[key].online == 0) {
						$("#status_" + obj[key].userid).removeClass('online');
					}
				}
			});
		}
	});
}
function sendMessage(to_user_id) {
	message = $(".message-input input").val();
	$('.message-input input').val('');
	if ($.trim(message) == '') {
		return false;
	}
	console.log("resp")

	$.ajax({
		url: "chat_action.php",
		method: "POST",
		data: { to_user_id: to_user_id, chat_message: message, action: 'insert_chat' },
		dataType: "json",
		success: function (response) {
			var resp = $.parseJSON(response);
			$('#conversation').html(resp.conversation);
			console.log(resp.conversation)
			$(".messages").animate({ scrollTop: $('.messages').height() }, "fast");
		}
	});
}
function showUserChat(to_user_id) {
	$.ajax({
		url: "chat_action.php",
		method: "POST",
		data: { to_user_id: to_user_id, action: 'show_chat' },
		dataType: "json",
		success: function (response) {
			$('#userSection').html(response.userSection);
			$('#conversation').html(response.conversation);
			$('#unread_' + to_user_id).html('');
		}
	});
}
function updateUserChat() {
	$('li.contact.active').each(function () {
		input()
		var to_user_id = $(this).attr('data-touserid');
		$.ajax({
			url: "chat_action.php",
			method: "POST",
			data: { to_user_id: to_user_id, action: 'update_user_chat' },
			dataType: "json",
			success: function (response) {
				$('#conversation').html(response.conversation);
			}
		});
	});
}
// this function upddate chat when the chat open from search
function updateUserChatsearch() {
	var to_user_id = $(`.submit`).attr('id');
	to_user_id_submit = to_user_id.replace(/chatButton/g, "");
	$('li.contact').attr('id');
	$('li.contact').each(function () {
		var contactId = $(this).attr('id');
		if (contactId === to_user_id_submit) {
			$(this).addClass('active');
			// Add 'active' class only to the current <li>
			$.ajax({
				url: "chat_action.php",
				method: "POST",
				data: { to_user_id: contactId, action: 'update_user_chat' },
				dataType: "json",
				success: function (response) {
					$('#conversation').html(response.conversation);
				}
			});
		} else {
			$(this).removeClass('active'); // Remove 'active' class from other <li> elements
		}
	});
}
function updateUnreadMessage() {
	$('li.contact').each(function () {
		var to_user_id = $(this).attr('data-touserid');

		// Fetch last message time and update UI elements within the loop
		fetchLastMessage(to_user_id, function (data) {
			if (data && data.last_message_time && data.message) {
				$(`#last-message-time-${to_user_id}`).html(data.last_message_time);
				$(`#content-message-text-${to_user_id}`).html(data.message);
			} else {
				console.warn('Incomplete data received from server for user ' + to_user_id);
			}
		});
	});
}

function fetchLastMessage(to_user_id, callback) {
	$.ajax({
		url: 'chat_action.php',
		method: 'POST',
		data: { action: 'last-message-time', sender_id: to_user_id },
		dataType: 'json',
		success: function (data) {
			callback(data); // Pass the data to the callback function
		},
		error: function (xhr, status, error) {
			console.error('Error fetching last message time for user ' + to_user_id, error);
			callback(null); // Pass null to the callback in case of error
		}
	});
}

function updateUnreadMessageCount() {
	$('li.contact').each(function () {
		var to_user_id = $(this).attr('data-touserid');
		if (!$(this).hasClass('active') || $(this).hasClass('active')) {
			var to_user_id = $(this).attr('data-touserid');
			$.ajax({
				url: "chat_action.php",
				method: "POST",
				data: { to_user_id: to_user_id, action: 'update_unread_message' },
				dataType: "json",
				success: function (response) {
					if (response.count) {
						$('#unread_' + to_user_id).html(response.count);
					}
				}
			});
		}
	});
}
function showTypingStatus() {
	$('li.contact.active').each(function () {
		var to_user_id = $(this).attr('data-touserid');
		$.ajax({
			url: "chat_action.php",
			method: "POST",
			data: { to_user_id: to_user_id, action: 'show_typing_status' },
			dataType: "json",
			success: function (response) {
				$('#isTyping_' + to_user_id).html(response.message);
			}
		});
	});
}
