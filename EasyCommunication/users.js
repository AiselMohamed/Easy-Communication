
var searchBar = document.querySelector(".content-sidebar-input");
const searchBtn = document.querySelector(".content-sidebar-input button");
var userList = document.querySelector(".users-list");

searchBar.addEventListener("focus", () => {
   userList.style.display = "block";
   setInterval(function () {
		search();
	}, 3000);
});
searchBar.addEventListener("blur", () => {
  
   userList.style.display = "none";
});

function search() {
   var value =searchBar.value;
   console.log(value)
	$.ajax({
		url: 'chat_action.php',
		method: 'POST',
		data: { action: 'search', search:value},
		dataType: 'json',
		success: function (data) {
			// Update the HTML content with the last message time
			console.log(data);
			
		},
		error: function (xhr, status, error) {
			console.error('Error fetching last message time:', error);
		}
	}

	);

}