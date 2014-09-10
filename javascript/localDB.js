//通过滚动滚动条，改变导航栏的样式
window.onscroll = function() {
	var top = document.documentElement.scrollTop || document.body.scrollTop;
	var height = document.getElementsByTagName("header")[0].offsetHeight;
	var nav = document.getElementsByTagName("nav")[0];
	if(top >= height - 50) {
		nav.style.backgroundColor = "#27AE60";
		$(".navbar-brand").css("color", "#FFF");
		$(".link").css("color", "#FFF");
		$(".link").mouseover(function() {
			$(this).css("color", "#FFF");
		});
		$(".link").mouseout(function() {
			$(this).css("color", "#FFF");
		});
		//添加侧边栏的fixed效果
		$("aside").removeClass("affix-top");
		$("aside").addClass("affix");
	} else {
		nav.style.backgroundColor = "#FFF";
		$(".navbar-brand").css("color", "#27AE60");
		$(".link").css("color", "#27AE60");
		$(".link").mouseover(function() {
			$(this).css("color", "#FFF");
		});
		$(".link").mouseout(function() {
			$(this).css("color", "#27AE60");
		});
		//删除侧边栏的fixed效果
		$("aside").removeClass("affix");
		$("aside").addClass("affix-top");
	}
	//返回顶部按钮的效果
	if(top >= 200) {
		$("#goTop").css("display", "block");
	} else {
		$("#goTop").css("display", "none");
	}
};

//返回主页按钮的动态效果
$(".navbar-header").mouseover(function() {
	$(".navbar-brand").addClass("animated tada");
});
$(".navbar-header").mouseout(function() {
	$(".navbar-brand").removeClass("animated tada");
});