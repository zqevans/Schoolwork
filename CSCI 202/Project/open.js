var count = 0;

function setLetters(){
	var uppers = document.getElementsByClassName("upper");
	for (var i = 0; i < uppers.length; i++){
		uppers[i].style.top = "200px";
	}
	var lowers = document.getElementsByClassName("lower");
	for (var i = 0; i < lowers.length; i++){
		lowers[i].style.top = "400px";
	}
	
	var date = document.getElementById("spring");
	date.style.top = "-325px";
	date.style.left = "-200px";
	
	var name = document.getElementById("name");
	name.style.left = "-550px";
	
}

function moveLetters(){
	var uppers = document.getElementsByClassName("upper");
	for (var i = 0; i < uppers.length; i++){
		var currentTop = parseInt(uppers[i].style.top);
		uppers[i].style.top = currentTop+5+"px";
	}
	var lowers = document.getElementsByClassName("lower");
	for (var i = 0; i < lowers.length; i++){
		var currentTop = parseInt(lowers[i].style.top);
		lowers[i].style.top = currentTop-5+"px";
	}
}

function moveDate(){
	var date = document.getElementById("spring");
	var currentLeft = parseInt(date.style.left);
	var currentTop = parseInt(date.style.top);
	date.style.top = currentTop + 5 + "px";
	date.style.left = currentLeft + 6 + "px";
}

function moveName(){
	var name = document.getElementById("name");
	var currentLeft = parseInt(name.style.left);
	name.style.left = currentLeft + 10 + "px";
}

function startMoving(){
		setLetters();
		var upperMove = setInterval('moveLetters()', 100);
		setTimeout(function(){upperMove = clearInterval(upperMove)}, 2100);
		setTimeout(function(){var springMove = setInterval('moveDate()', 25);
		setTimeout(function(){clearInterval(springMove)}, 3350);
		}, 4000);
		
		setTimeout(function(){var nameMove = setInterval('moveName()', 25);
								setTimeout(function(){clearInterval(nameMove)}, 2250);
		}, 12000);
		setTimeout(function(){window.location.href="intro.html"}, 18000);
		
		
		
}
