<?php if (!defined('THINK_PATH')) exit();?> 
<!DOCTYPE html>
<html>
<head>
	<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
	<link type="text/css" rel="stylesheet" href="/Public/gec/web/css/lib.css?2">
	<meta name="viewport" content="width=device-width, user-scalable=no, initial-scale=1.0, maximum-scale=1, minimum-scale=1.0"/>
	<meta content="telephone=no" name="format-detection">
	<title>个人中心</title>	
    <link rel="stylesheet" href="/Public/gec/web/css/weui.min.css"/>
	<link rel="stylesheet" href="/Public/gec/web/css/jquery-weui.min.css">
	<link href="/Public/gec/web/css/font-awesome.min.css" rel="stylesheet">
	<link href="/Public/gec/web/fonts/iconfont.css" rel="stylesheet">
	<script src="/Public/gec/web/js/layer.js"></script>
	<link rel="stylesheet" href="/Public/gec/web/css/stylef.css"/>
	
	

</head>




<!--顶部开始-->
    <header class="header">
        <span class="header_l"><a href="javascript:history.go(-1);"><i class="fa fa-chevron-left"></i></a></span>
        <span class="header_c">个人资料</span>
		<!--<span style="position: absolute;right: 10%;top: 0px;text-align:center;width:20%;white-space:nowrap; overflow:hidden; text-overflow:ellipsis;font-size: 12px; "><?php echo ($memberinfo['username']); ?> </span>
		<span class="header_r"><a href="<?php echo U(GROUP_NAME .'/personal_set/myInfo');?>"><i class="fa fa-user"></i></a></span>-->
    </header>
    <div class="height40;"></div>
    <!--顶部结束-->
    <!--列表开始-->
	
	 <form  method="post" action="" style="margin-bottom:80px;font-size:14px" enctype="multipart/form-data">

		<ul style="width: 80%;margin-left: 10%;color: #000" >
	
		<li style="text-align: center;width:100%"><div style="width: 60px;height: 60px;margin-bottom: 10px;border-radius: 100%" src= ></div></li>
	
			<li style="height: 30px;line-height: 30px;margin-top: 5px;width:100%">登陆帐号：&nbsp;&nbsp;&nbsp;<?php echo ($memmber['mobile']); ?></li>
			<li style="height: 30px;line-height: 30px;margin-top: 5px;width:100%">会员等级：&nbsp;&nbsp;&nbsp;<?php echo group($memmber['level']);?></li>	
            <!-- <li style="height: 30px;line-height: 30px;margin-top: 5px;width:100%">会员编号：&nbsp;&nbsp;&nbsp;<?php echo ($memmber['id']); ?></li> -->
            <li style="height: 30px;line-height: 30px;margin-top: 5px;width:100%">手机号码：&nbsp;&nbsp;&nbsp;<?php echo ($memmber['mobile']); ?></li>
<!--	<span style="font-size:14px;text-align:center;color:red;margin-left:0%">温馨提示：&nbsp;&nbsp;&nbsp;支付宝账户名即为你支付宝实名认证的真实姓名，如果审核发现支付宝没有实名认证或者姓名不对应将无法通过认证！</span>-->
	<span style="font-size:14px;text-align:center;color:red;margin-left:0%">温馨提示：一旦提交无法修改！</span>

			<li style="height: 30px;line-height: 30px;margin-top: 5px;width:100%">真实姓名：&nbsp;&nbsp;&nbsp;</span>
            	 
                 <?php if($memmber['checkstatus'] == 2): ?><input name="truename" type="text" value="<?php echo ($memmber['truename']); ?>" style="height: 30px;line-height: 30px;width: 59%;border-radius: 5px;border: 1px solid #eeeeee;padding-left: 5px"  autocomplete="off" placeholder="支付宝账户名"/>
                  <?php else: ?>
                  
                  	<?php if(!empty($memmber['truename'])): echo ($memmber['truename']); ?>
                    <?php else: ?>
            			<input name="truename" type="text" value="<?php echo ($memmber['truename']); ?>" style="height: 30px;line-height: 30px;width: 59%;border-radius: 5px;border: 1px solid #eeeeee;padding-left: 5px"  autocomplete="off" placeholder="支付宝收款人姓名"/><?php endif; endif; ?>
                 
                 
            	 
			</li>






            <li style="height: 30px;line-height: 30px;margin-top: 5px;width:100%">银行卡账号：&nbsp;&nbsp;&nbsp;</span>
              <input name="brank_num" type="text" value="<?php echo ($memmber['brank_num']); ?>" style="height: 30px;line-height: 30px;width: 59%;border-radius: 5px;border: 1px solid #eeeeee;padding-left: 5px"  autocomplete="off" placeholder="银行卡账号"/>
            </li>

            <li style="height: 30px;line-height: 30px;margin-top: 5px;width:100%">属于银行：&nbsp;&nbsp;&nbsp;</span>
                <select name="brank_name" id="sktype" class="form-control">
                    <?php if($memmber['brank_name'] == null): ?><option value="">选择银行</option>
                   <?php else: ?>
                        <option value=""><?php echo ($memmber['brank_name']); ?></option><?php endif; ?>>
                    <option value="工商银行">工商银行</option>
                    <option value="农业银行">农业银行</option>
                    <option value="建设银行">建设银行</option>
                    <option value="光大银行">光大银行</option>
                    <option value="平安银行">平安银行</option>
                    <option value="兴业银行">兴业银行</option>
                    <option value="招商银行">招商银行</option>
                    <option value="民生银行">民生银行</option>
                    <option value="浦发银行">浦发银行</option>
                    <option value="中国银行">中国银行</option>
                    <option value="农村信用社">农村信用社</option>
                    <option value="广发银行">广发银行</option>
                    <option value="邮政储蓄">邮政储蓄</option>
                    <option value="交通银行">交通银行</option>

                </select>
            </li>
             <li style="height: 30px;line-height: 30px;margin-top: 5px;width:100%">户名：&nbsp;&nbsp;&nbsp;</span>
              <input name="brank_user_name" type="text" value="<?php echo ($memmber['brank_user_name']); ?>" style="height: 30px;line-height: 30px;width: 59%;border-radius: 5px;border: 1px solid #eeeeee;padding-left: 5px"  autocomplete="off" placeholder="银行卡户名"/>
            </li>







            <li style="height: 30px;line-height: 30px;margin-top: 5px;width:100%">支&nbsp;&nbsp;付&nbsp;宝：&nbsp;&nbsp;&nbsp;</span>
            
            	<?php if($memmber['checkstatus'] == 2): ?><input type="text" id="zhifubao" name="zhifubao"  value="<?php echo ($memmber['zhifubao']); ?>" placeholder="请输入你的支付宝账号" style="height: 30px;line-height: 30px;width: 59%;border-radius: 5px;border: 1px solid #eeeeee;padding-left: 5px" />
                <?php else: ?>
                	 <?php if(!empty($memmber['zhifubao'])): echo ($memmber['zhifubao']); ?>
               		 <?php else: ?>
                		<input type="text" id="zhifubao" name="zhifubao"  value="<?php echo ($memmber['zhifubao']); ?>" placeholder="请输入你的支付宝账号" style="height: 30px;line-height: 30px;width: 59%;border-radius: 5px;border: 1px solid #eeeeee;padding-left: 5px" /><?php endif; endif; ?> 
           </li>
            <li style="height: 30px;line-height: 30px;margin-top: 5px;width:100%">户名：&nbsp;&nbsp;&nbsp;</span>
                <input name="alipay_user_name" type="text" value="<?php echo ($memmber['alipay_user_name']); ?>" style="height: 30px;line-height: 30px;width: 59%;border-radius: 5px;border: 1px solid #eeeeee;padding-left: 5px"  autocomplete="off" placeholder="支付宝账户名"/>
            </li>



            <li style="font-size:14px;">支付宝收款码：&nbsp;&nbsp;&nbsp;</li>

            <li>
                <?php if(!empty($memmber['alipay_code_img'])): ?><img src="<?php echo ($memmber['alipay_code_img']); ?>" width="120" height="120" />
                    <?php else: ?>
                    <span class="sima1"><img src="<?php echo empty($memmber['alipay_code_img'])? '/Public/gec/web/img/aa4.jpg': $memmber['alipay_code_img'];?>" onclick="document.getElementById('upfile').click()" id="clickimg" width="120" height="120"></span>


                    <!-- <li style="margin-top: 5px;width:100%">认证教程：&nbsp;&nbsp;&nbsp;</span><a href="http://www.cvcoin.cc/index.php/index/new/newsdetails/news_id/117" target="_blank" style="font-size:14px; color:#0000FF;">点此查看教程</a></li>	 -->
                    <!--<span style="font-size:14px;text-align:center;color:red;margin-left:0%">查看参考：&nbsp;&nbsp;&nbsp;
                      </li><img src="/Public/gec/web/img/zzpz.jpg" width="120" height="120" id="imgshow"></span></li>-->
                    <input type="file" style=" opacity:0;filter:alpha(opacity=80);cursor:pointer;" name="photoimg" id="upfile"/>
                    <input type="hidden" name="alipay_code_img" value="" id="alipay_voucher"><?php endif; ?>

            </li>










            <li style="height: 30px;line-height: 30px;margin-top: 5px;width:100%">微&nbsp;&nbsp;信&nbsp;号：&nbsp;&nbsp;&nbsp;</span>
            
            	<?php if(!empty($memmber['weixin'])): echo ($memmber['weixin']); ?>
                <?php else: ?>
                	<input type="text" id="weixin" name="weixin"  value="<?php echo ($memmber['weixin']); ?>" placeholder="请输入你的微信号" style="height: 30px;line-height: 30px;width: 59%;border-radius: 5px;border: 1px solid #eeeeee;padding-left: 5px" /><?php endif; ?> 

			</li>
            <li style="height: 30px;line-height: 30px;margin-top: 5px;width:100%">户名：&nbsp;&nbsp;&nbsp;</span>
                <input name="wechat_user_name" type="text" value="<?php echo ($memmber['wechat_user_name']); ?>" style="height: 30px;line-height: 30px;width: 59%;border-radius: 5px;border: 1px solid #eeeeee;padding-left: 5px"  autocomplete="off" placeholder="微信户名"/>
            </li>

            <li style="font-size:14px;">请上传微信收款码：&nbsp;&nbsp;&nbsp;</li>

            <li>
                <?php if(!empty($memmber['wechat_code_img']) ): ?><img src="<?php echo ($memmber['wechat_code_img']); ?>" width="120" height="120" />

                    <?php else: ?>
                    <span class="sima2">

                    	<img src="<?php echo empty($memmber['wechat_code_img'])? '/Public/gec/web/img/aa4.jpg': $memmber['wechat_code_img'];?>" onclick="document.getElementById('upfile2').click()" id="clickimg2" width="120" height="120">

                    </span>
                    <input type="file" style=" opacity:0;filter:alpha(opacity=80);cursor:pointer;" name="photoimg" id="upfile2"/>
                    <input type="hidden" name="wechat_code_img" value="" id="cardpic"><?php endif; ?>

            </li>




            <!--<span style="font-size:14px;text-align:center;color:red;margin-left:0%">认证提示：&nbsp;&nbsp;&nbsp;请使用你注册填写的支付宝向：打款请备注编号!并在下方上传转账凭证等待认证审核，谢谢！</span></li>-->
		

          
           
       <!--    <li style="font-size:14px;">上传支付宝个人信息页面截图：&nbsp;&nbsp;&nbsp;</li>
		
		  <li>
            	<?php if(!empty($memmber['alipay_voucher']) and $memmber['checkstatus'] != 2): ?><img src="<?php echo ($memmber['alipay_voucher']); ?>" width="120" height="120" />
                <?php else: ?>
               <span class="sima1"><img src="<?php echo empty($memmber['cardpic'])? '/Public/gec/web/img/aa4.jpg': $memmber['alipay_voucher'];?>" onclick="document.getElementById('upfile').click()" id="clickimg" width="120" height="120"></span>
               
             
                &lt;!&ndash; <li style="margin-top: 5px;width:100%">认证教程：&nbsp;&nbsp;&nbsp;</span><a href="http://www.cvcoin.cc/index.php/index/new/newsdetails/news_id/117" target="_blank" style="font-size:14px; color:#0000FF;">点此查看教程</a></li>	 &ndash;&gt;
                 &lt;!&ndash;<span style="font-size:14px;text-align:center;color:red;margin-left:0%">查看参考：&nbsp;&nbsp;&nbsp;
                   </li><img src="/Public/gec/web/img/zzpz.jpg" width="120" height="120" id="imgshow"></span></li>&ndash;&gt;
				 <input type="file" style=" opacity:0;filter:alpha(opacity=80);cursor:pointer;" name="photoimg" id="upfile"/>
            	 <input type="hidden" name="alipay_voucher" value="" id="alipay_voucher"><?php endif; ?>         
            
           </li>
           -->
           

           
           
           
           
           
           
          <?php if($memmber['checkstatus'] == 0): if(!empty($memmber['truename'])): ?><li style="height: 30px;line-height: 30px;margin-top: 5px;width:100%">审核结果：&nbsp;&nbsp;&nbsp;<font style="color:#F00;">待审核，最快10分钟审核通过认证</font></li>
         		<?php else: ?>
                	<li style="height: 30px;line-height: 30px;margin-top: 5px;width:100%">审核结果：&nbsp;&nbsp;&nbsp;<font style="color:#F00;">待完善:收款人姓名、以及上传认证凭证！</font></li><?php endif; endif; ?>	 
           
          <?php if($memmber['checkstatus'] == 3): ?><li style="height: 30px;line-height: 30px;margin-top: 5px;width:100%">审核结果：&nbsp;&nbsp;&nbsp;<font style="color:#F00;">审核已通过</font></li><?php endif; ?>	  
           
           
		<?php if(!empty($memmber['liyou']) and $memmber['checkstatus'] == 2): ?><li style="height: 30px;line-height: 30px;margin-top: 5px;width:100%">审核结果：&nbsp;&nbsp;&nbsp;<font style="color:#F00;"><?php echo ($memmber['liyou']); ?></font></li>
       		<button type="submit" class="btn btn-primary btn-submit btn_submit" style="width: 100%;height: 30px;line-height: 30px;border-radius: 5px;border: 0px; background-color:#87CEEB;margin-top: 5px;color: #FFFFFF;-webkit-appearance: none;">提 交</button>
       
       <?php else: ?>
       	
            <?php if(empty($memmber['weixin']) || empty($memmber['truename'])): ?><button type="submit" class="btn btn-primary btn-submit btn_submit" style="width: 100%;height: 30px;line-height: 30px;border-radius: 5px;border: 0px; background-color:#87CEEB;margin-top: 5px;color: #FFFFFF;-webkit-appearance: none;">提 交</button><?php endif; endif; ?>	
        
        	
			
		</ul>
	</form>
</div>
<!--底部开始-->
<script src="/Public/gec/reg/js/jquery-1.11.3.min.js"></script>
<script src="/Public/gec/web/js/jquery.form.js"></script>
<script src="/Public/js/layer/layer.js"></script>


<script type="text/javascript">
	$("#imgshow").click(function(){
		
			layer.open({
			  type: 1,
			  shadeClose: true,
			  shade: 0.8,
			  title: false, //不显示标题
			  area: ['80%', '520px'],
			  
			  content: '<img src="/Public/gec/web/img/zzpz.jpg" width="100%" height="500">', //捕获的元素，注意：最好该指定的元素要存放在body最外层，否则可能被其它的相对元素所影响
			
			});
		
	})

</script>

 <script type="text/javascript">
 
$(function(){
	 
	
	$("#upfile").wrap("<form action='<?php echo U('Index/PersonalSet/uploads');?>' method='post' enctype='multipart/form-data'></form>"); 
	
	$("#upfile").off().on('change',function(){
		//var status = $("#up_status");
		//var btn = $("#up_btn");
		
		var objform = $(this).parents();
		    objform.ajaxSubmit({
			dataType:  'json',
			target: '#preview', 
			//beforeSubmit:function(){
				//status.show();
				//btn.hide();
			//}, 
			success:function(data){
				if(data.result==1){
					//status.hide();
					//btn.show();
					$("#clickimg").attr('src','/Public/'+data.url)
					$("#alipay_voucher").val('/Public/'+data.url)
				}else{
					
					$('.sima1').html('<font style="color:red;">'+data.msg+'</font>')
					
					}
			}, 
			error:function(){
				//status.hide();
				//btn.show();
			} 
		});
		
		
		
	});
	
	
	
	
	
	
	
   });


 
 </script>


<script type="text/javascript">
 
$(function(){
	 
	
	$("#upfile2").wrap("<form action='<?php echo U('Index/PersonalSet/uploads');?>' method='post' enctype='multipart/form-data'></form>"); 
	
	$("#upfile2").off().on('change',function(){
		//var status = $("#up_status");
		//var btn = $("#up_btn");
		
		var objform = $(this).parents();
		    objform.ajaxSubmit({
			dataType:  'json',
			target: '#preview', 
			//beforeSubmit:function(){
				//status.show();
				//btn.hide();
			//}, 
			success:function(data){
				if(data.result==1){
					//status.hide();
					//btn.show();
					$("#clickimg2").attr('src','/Public/'+data.url)
					$("#cardpic").val('/Public/'+data.url)
				}else{
					
					$('.sima2').html('<font style="color:red;">'+data.msg+'</font>')
					
					}
			}, 
			error:function(){
				//status.hide();
				//btn.show();
			} 
		});
		
		
		
	});
	
	
	
	
	
	
	
   });


 
 </script>



<!--底部开始-->
<style>
	.footer ul li{
		width: 25%;
	}
</style>
	<div class="footer">
    <ul>
        
      <li><a href="<?php echo U('Index/Shop/plist');?>" class="block"><i class="fa fa-university" style="color:#FF9224;"></i>矿机商城</a></li>
      		<li><a href="<?php echo U('Index/Shop/orderlist');?>" class="block"><i class="fa fa-cart-arrow-down" style="color:#483D8B;"></i>我的矿机</a></li>
      		<li><a href="<?php echo U('Index/Emoney/index');?>" class="block"><i class="fa fa-line-chart" style="color:#228B22;"></i>交易中心</a></li>
       <li style="width:24%" ><a href="/" class="block"><i class="fa fa-laptop" style="color:#6495ED;"></i>个人中心</a></li>
    </ul>
</div>
	<!--底部结束-->




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