$(document).ready(function () {
    setInterval(function () {
        updateUserList();
        updateUnreadMessageCount();
        updateUnreadMessages();
        updateUserChatsearch();
        showTypingStatus();
        toggleInputDisplay();
    }, 1000); // Update every second

    $(".messages").animate({ scrollTop: $(document).height() }, "fast");

    // Toggle profile options
    $("#profile-img").on("click", function () {
        $("#status-options").toggleClass("active");
        $(".chat-sidebar-profile-toggle").toggleClass("active");
        $(".chat-sidebar-profile").toggleClass("active");
    });

    $(".emojebutton").on("click", function () {
        $("#emoji").toggleClass("active");
    });

    // Sidebar navigation
    $("#profile-info").on("click", function () {
        $("#sidepanel").hide();
        $("#sidepanel-profile").show();
        $('#chat-menu').removeClass('menu-active');
        $('#update-info').addClass('menu-active');
    });

    $("#Chats").on("click", function () {
        $("#sidepanel").show();
        $("#sidepanel-profile").hide();
        $('#update-info').removeClass('menu-active');
        $('#chat-menu').addClass('menu-active');
    });

    // Profile section actions
    $(".profile-option").on("click", function () {
        let profile = $(this).attr('id');
        getUserProfile(profile);
    });

    // Contact selection
    $(".contact").on("click", function () {
        setActiveContact($(this));
        var toUserId = $(this).data('touserid');
        showUserChat(toUserId);
        updateChatIds(toUserId);
    });

    $(".new").on("click", function () {
        setActiveContact($(this));
        var toUserId = $(this).attr('id');
        showUserChat(toUserId);
        updateChatIds(toUserId);
    });

    // Message submission
    $(".submit").on("click", function () {
        var toUserId = $(this).attr('id').replace(/chatButton/g, "");
        sendMessage(toUserId);
        fetchLastMessageTime(toUserId);
        scrollToBottom();
    });

    // Status update
    $("#status-options ul li").on("click", function () {
        updateStatus($(this));
    });

    // Typing status update
    $(".conversation-form-input").on("focus blur", function (event) {
        var isType = event.type === 'focus' ? 'yes' : 'no';
        updateTypingStatus(isType);
    });

    // Search bar functionality
    const searchBar = $(".content-sidebar-input");
    const userList = $(".users-list");

    let intervalId;
    searchBar.on("focus", function () {
        userList.show();
        intervalId = setInterval(search, 1000);
    });

    searchBar.on("blur", function () {
        userList.on("mouseout", function (event) {
            if (!userList.contains(event.relatedTarget)) {
                userList.hide();
                clearInterval(intervalId);
            }
        });
    });
});

function toggleInputDisplay() {
    var submitId = $(".submit").attr('id').replace(/chatButton/g, "");
    if (submitId == 0) {
        $(".message-input").hide();
    } else {
        $(".message-input").show();
    }
}

function search() {
    const value = $(".content-sidebar-input").val();
    $.ajax({
        url: 'chat_action.php',
        method: 'POST',
        data: { action: 'search', search: value },
        dataType: 'json',
        success: function (data) {
            $(".users-list").html(data.message);
        },
        error: function (xhr, status, error) {
            console.error('Error search:', error);
        }
    });
}

function getUserProfile(profile) {
    $.ajax({
        url: 'chat_action.php',
        method: 'POST',
        data: { action: 'get-user', profile: profile },
        dataType: 'json',
        success: function (data) {
            updateProfileSection(profile, data);
        },
        error: function (xhr, status, error) {
            console.error('Error get user:', error);
        }
    });
}

function updateProfileSection(profile, data) {
    // Your existing code to update the profile section based on `profile`
}

function setActiveContact(contact) {
    $('.contact').removeClass('active');
    contact.addClass('active');
}

function updateChatIds(toUserId) {
    $(".chatMessage").attr('id', 'chatMessage' + toUserId);
    $(".chatButton").attr('id', 'chatButton' + toUserId);
}

function scrollToBottom() {
    var messageDiv = $('#conversation')[0];
    messageDiv.scrollTop = messageDiv.scrollHeight + messageDiv.clientHeight - parseInt(window.getComputedStyle(messageDiv).paddingBottom) - parseInt(window.getComputedStyle(messageDiv).borderBottomWidth) - parseInt(window.getComputedStyle(messageDiv).marginBottom);
}

function fetchLastMessageTime(toUserId) {
    $.ajax({
        url: 'chat_action.php',
        method: 'POST',
        data: { action: 'last-message-time', sender_id: toUserId },
        dataType: 'json',
        success: function (data) {
            $(`#last-message-time-${toUserId}`).html(data.last_message_time);
            $(`#content-message-text-${toUserId}`).html(data.message);
        },
        error: function (xhr, status, error) {
            console.error('Error fetching last message time:', error);
        }
    });
}

function updateStatus(element) {
    $("#profile-img").removeClass();
    $("#status-options ul li").removeClass("active");
    element.addClass("active");

    const statusMap = {
        "status-online": 1,
        "status-away": 3,
        "status-busy": 2,
        "status-offline": 0
    };

    let statusClass = element.attr('id');
    let status = statusMap[statusClass];

    $("#profile-img").addClass(statusClass.split('-')[1]);

    $.ajax({
        url: "chat_action.php",
        method: "POST",
        data: { status: status, action: 'update_status' },
        success: function () { }
    });

    $("#status-options, .chat-sidebar-profile-toggle, .chat-sidebar-profile").removeClass("active");
}

function updateTypingStatus(isType) {
    $.ajax({
        url: "chat_action.php",
        method: "POST",
        data: { is_type: isType, action: 'update_typing_status' },
        success: function () { }
    });
}

function sendMessage(toUserId) {
    const message = $(".message-input input").val().trim();
    if (message === '') return;

    $(".message-input input").val('');
    $.ajax({
        url: "chat_action.php",
        method: "POST",
        data: { to_user_id: toUserId, chat_message: message, action: 'insert_chat' },
        dataType: "json",
        success: function (response) {
            $('#conversation').html(response.conversation);
            $(".messages").animate({ scrollTop: $('.messages').height() }, "fast");
        }
    });
}

function showUserChat(toUserId) {
    $.ajax({
        url: "chat_action.php",
        method: "POST",
        data: { to_user_id: toUserId, action: 'show_chat' },
        dataType: "json",
        success: function (response) {
            $('#userSection').html(response.userSection);
            $('#conversation').html(response.conversation);
            $('#unread_' + toUserId).html('');
        }
    });
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
                const userId = obj[key].userid;
                if ($("#" + userId).length) {
                    const statusClass = obj[key].online == 1 ? 'online' : '';
                    $("#status_" + userId).toggleClass('online', obj[key].online == 1);
                }
            });
        }
    });
}

function updateUnreadMessages() {
    $('li.contact').each(function () {
        var toUserId = $(this).data('touserid');
        fetchLastMessage(toUserId, function (data) {
            if (data && data.last_message_time && data.message) {
                $(`#last-message-time-${toUserId}`).html(data.last_message_time);
                $(`#content-message-text-${toUserId}`).html(data.message);
            } else {
                console.warn('Incomplete data received from server for user ' + toUserId);
            }
        });
    });
}

function fetchLastMessage(toUserId, callback) {
    $.ajax({
        url: 'chat_action.php',
        method: 'POST',
        data: { action: 'last-message-time', sender_id: toUserId },
        dataType: 'json',
        success: callback,
        error: function (xhr, status, error) {
            console.error('Error fetching last message:', error);
        }
    });
}

function updateUnreadMessageCount() {
    $.ajax({
        url: 'chat_action.php',
        method: 'POST',
        data: { action: 'update_unread_message' },
        success: function (response) {
            $("#unread").html(response);
        }
    });
}

function updateUserChatsearch() {
    const value = $(".content-sidebar-input").val();
    $.ajax({
        url: 'chat_action.php',
        method: 'POST',
        data: { action: 'search', search: value },
        dataType: 'json',
        success: function (data) {
            $(".users-list").html(data.message);
        },
        error: function (xhr, status, error) {
            console.error('Error search:', error);
        }
    });
}

function showTypingStatus() {
    $.ajax({
        url: "chat_action.php",
        method: "POST",
        dataType: "json",
        data: { action: 'show_typing_status' },
        success: function (response) {
            $('#isTyping').html(response.message);
        }
    });
}
