//通过滚动滚动条，改变样式
$(window).bind("scroll", function() {
	var top = $(window).scrollTop();
	var height = $("header").outerHeight();
	if(top >= height - 50) {
		$("nav").css("backgroundColor", "#27AE60");
		$(".navbar-brand").css("color", "#FFF");
		$(".navbar-brand-right").css("color", "#FFF");
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
		$("nav").css("backgroundColor", "#FFF");
		$(".navbar-brand").css("color", "#27AE60");
		$(".navbar-brand-right").css("color", "#27AE60");
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

	//侧边栏滚动效果
	var point = $("article h1, article h2, article h3, article h4, article h5, article h6");
	var arr = [];
	for(var i = 0; i < point.length; i++) {
		arr.push($(point[i]));
	}
	$(".active").removeClass("active");
	for(var i = 0; i < arr.length; i++) {
		var id = $(arr[i]).attr("id");
		var pointH = Math.floor(arr[i].offset().top);
		if(i < arr.length - 1) {
			var pointNextH = Math.floor(arr[i+1].offset().top);
			if(top >= pointH && top < pointNextH) {
				$("[href=#" + id + "]").parents("li").addClass("active");
			}
		} else {
			if(top >= pointH) {
				$("[href=#" + id + "]").parents("li").addClass("active");
			}
		}
	}
});

//导航栏下拉隐藏
$(".navbar-brand-right").click(function() {
	$(".menu-nav").slideToggle("slow");
});

//返回主页按钮的动态效果
$(".navbar-brand").mouseover(function() {
	$(this).addClass("animated tada");
});
$(".navbar-brand").mouseout(function() {
	$(this).removeClass("animated tada");
});

//返回顶部
$("#goTop").click(function(){
    $('body,html').animate({scrollTop:0}, 500);
    return false;
});

//侧边栏效果
var children = false;
$(".sidenav").children("li").click(function() {
	if(children) {
		$(".sidenav").children(".active").removeClass("active");
	} else {
		$(".active").removeClass("active");
	}
	$(this).addClass("active");
	children = false;
});
$(".sidenav").find("ul").children("li").click(function() {
	$(".active").removeClass("active");
	$(this).addClass("active");
	$(this).parents("li").addClass("active");
	children = true;
});

