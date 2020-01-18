<?php if (!defined('THINK_PATH')) exit();?><!doctype html>
<html lang="zh">
<head>
    <meta http-equiv="Content-Type" content="text/html;charset=utf-8">
    <title>登录</title>
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width,initial-scale=1.0,maximum-scale=1.0,user-scalable=0">
    <meta name="apple-mobile-web-app-capable" content="yes">
    <meta name="apple-mobile-web-app-status-bar-style" content="black">
    <meta name="format-detection" content="telephone=no">
    <meta name="wap-font-scale" content="no">
	<link rel="stylesheet" href="/Public/gec/Home/css/weui.min.css">
    <link rel="stylesheet" href="/Public/gec/web/css/jquery-weui.min.css">
	
	<link rel="stylesheet" href="/Public/gec/reg/css/style.css">
	<link rel="stylesheet" href="/Public/gec/reg/css/common.css">
	<style>
	.wrapper{
	min-height:auto;
	}
	</style>
</head>
<body class="page-mobile " >
    <div class="wrapper login-wrapper" >
		<!-- <img src="/Public/gec/web/img/background.jpg" > -->
    <!-- logo S -->
	
    <div >
	<img src="/Public/gec/web/img/supy.png" style="width:36%;margin-left:32%;margin-top:10px;border-radius:10px;margin-bottom:10px"/>
    </div>
    <!-- logo E -->
    <!-- 登录输入表单 S -->

	
	<form name="form" method="post" id="form" class="form-signin">
	
    <div class="login-form def-m mb10" style="margin-top:15px;">
        <ul class="com-columns span2">
		 <li class="comc-item">
                <!--<div class="com-formbox changebox" style="overflow:hidden;display:block;">
							<span data-type="1" style="float:left;width:50%;text-align:center;line-height:30px;color:#05B6A3;;">中文</span>
							<span data-type="2" style="float:right;width:50%;text-align:center;line-height:30px;color:#333;">English</span>
                </div>-->
            </li>
            <li class="comc-item">
                <div class="com-formbox">
                    <label class="formbox-hd" for="username"><i class="iconfont icon-user"></i>&nbsp;</label>
                    <span class="formbox-bd">
					 <input name="username" type="text" placeholder="请输入会员帐号" maxlength="11" id="txtUserName" class="input-txt"  value="<?php echo ($rememberusername); ?>"/>
					 
		
                </div>
            </li>
            <li class="comc-item">
                <div class="com-formbox">
                    <label class="formbox-hd" for="password"><i class="iconfont icon-lock"></i>&nbsp;</label>
                    <span class="formbox-bd"> <input name="password" type="password" maxlength="20" id="txtUserPass" class="input-txt" placeholder="登陆密码" value="<?php echo ($rememberpassword); ?>"/>
					</span>
                </div>
            </li>
            
            
             <li class="comc-item">
                <div class="com-formbox">
                    <label class="formbox-hd" for="verify"><i class="iconfont icon-lock"></i>&nbsp;</label>
                    <span class="formbox-bd"> <input name="verify" type="text" maxlength="20" id="verify" class="input-txt" placeholder="验证码" style="width:60%;"/>
                    <img src="<?php echo U('Sem/verify');?>" onClick="this.src='<?php echo U('Sem/verify','','');?>?'+Math.random();" width="60" height="25">
					</span>
                </div>
            </li>
            
            
           
             
            
             
        </ul>
        
        

    </div>
   <ul>
	
	<li style="float:left;">
    	<div style="padding:10px 20px;"><input type="checkbox" name="remember" value="1"  <?php if(!empty($rememberusername)): ?>checked="checked"<?php endif; ?>>&nbsp;&nbsp;记住密码</div>
    
    	        
	</li>
    
    <li style="float:right;">
    
    	<div style="padding:10px 20px;">
        <a href="<?php echo U('Index/Login/editpwd');?>" class="fz13 link" id="findPwd_btn">忘记密码</a>
           
         </div>
    </li>
    
	</ul>
    <!-- 登录输入表单 E -->
	 <input type="hidden" name="lang" id="lang" value="1"/>
    <!-- 通用按钮 S -->
    <div class="def-p com-btnbox mb10">
	<input type="button"  class="btn_submit_my" style="background-color:skyblue;width:100%;height:47px;line-height:47px;color:#fff;border:0px;border-radius:5px;font-size:16px;" value="登录">
       <!--  <a href="#" class="btn btn-1 btn-dis" id="login_btn">登录</a> -->
    </div>
</form>	
   <ul>
	
    <!-- 忘记密码 S -->
	<li>
    <div class="def-p txtr">
           <a href="/index.php/index/sem/regSem/u/t24GWvVczWju" class="fz13"  style="float:left" target="_black"> &nbsp;&nbsp;注册开户</a>
           <!-- <a typer="button" href="/index.php/index/sem/regSem/u/t24GWvVczWju"  class="btn_submit_my" style="background-color:#FFA500;width:100%;height:47px;line-height:47px;color:#fff;border:0px;border-radius:5px;font-size:16px;" > &nbsp;&nbsp;注册开户</a> -->
			 <!-- <a href="" class="fz13"  style="float:left" target="_black">APP下载</a> -->
        <a href="https://download-app.appbsl.cn/tbyghq%2B4tLTI3MzcyNS0tMA%3D" class="fz13"  style="float:right" target="_black">APP下载 &nbsp;</a>
    </div>
	</li>
	</ul>

   
</div>
<!-- 登录主要内容 E -->
</div>


<script src="/Public/gec/reg/js/jquery-1.11.3.min.js"></script>
<script src="/Public/gec/web/js/jquery-weui.min.js"></script>


<script type="text/javascript">
	$(".btn_submit_my").click(function(){
		
			$.ajax({
				url:'<?php echo U("Index/Login/index");?>',
				type:'POST',
				data:$("#form").serialize(),
				dataType:'json',
				success:function(json){
						alert(json.info);
						if(json.result ==1){
							window.location.href=json.url;	
						}
					
					
				},
				error:function(){
						alert("网络故障");	
				}
					
				
				
			})	
		
	})


</script>














<!-- Panel popup   提示框开始-->
<link rel="stylesheet" type="text/css" href="/public/ajaxsubmit/css/zip.css">
<div id="modal-panel" class="popup-basic bg-none mfp-with-anim mfp-hide" style="max-width:70%"></div>
<!-- End: Main -->
<!--<script type="text/javascript" src="/public/ajaxsubmit/js/jquery-1.11.1.min.js"></script>-->
<script type="text/javascript" src="/public/ajaxsubmit/js/jquery-ui.min.js"></script>
<script type="text/javascript" src="/public/ajaxsubmit/js/zip.js"></script>
<script type="text/javascript">

    jQuery(document).ready(function () {
        Core.init()
    });

    $(".btn_submit").on("click", function () {

	    event.preventDefault();
	    var btn_submit = $(this);
	    var form = btn_submit.closest("form");
      var btn_text=btn_submit.text();
      if(btn_submit.attr('reminder')){
        if(!confirm(btn_submit.attr('reminder'))){
          return ;
        }
      }
	 if (form.hasClass("is_submit")) return false;
      var formData = new FormData(form[0]);

	    $.ajax({
	        url: this.title,
	        type: "post",
	        data: formData,
          async: false,
          cache: false,
          contentType: false,
          processData: false,
	        beforeSend: function () {
	            btn_submit.text("处理中...").addClass("disabled");
	        },
	        success: function (data) {
                if(data.url){
				    $.alert(data.info);
				    setTimeout(function(){location.href=data.url}, 2000);
	            }else{
					$.alert(data.info);
                }
                btn_submit.text(btn_text).removeClass('disabled');
	        }
	    });
  	});


</script>
<!-- END: PAGE SCRIPTS 提示框结束-->

	</body>
</html>