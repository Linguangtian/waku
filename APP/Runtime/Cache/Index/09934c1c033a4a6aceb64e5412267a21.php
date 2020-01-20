<?php if (!defined('THINK_PATH')) exit();?><!DOCTYPE html>
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




<body>
	<!--顶部开始-->
	<div class="header">
    <span class="header_l"><a href="javascript:history.go(-1);"><i class="fa fa-chevron-left"></i></a></span>
    <span class="header_c">个人中心</span>
		
		<!-- <a href="<?php echo U('Index/Index/logout');?>" style="position:absolute;top:8px;right:3%;width:60px;height:25px;line-height:25px;text-align:center;color:#fff;font-size:12px; background:#FFD306; border-radius:4px;">安全退出</a> -->
</div>
	<div class="height40"></div>
	<!--顶部结束-->
<style>
	.user_sy li{
		width: 33.3%;
	}
</style>
	<div style="background-color: #6495ED ;padding: 0px 0px 10px 0px;  width: 100%;overflow: hidden;color: #FFFFFF;font-size:1.5em; height:90px; ">
	
    
       
        
		<!--<div style="width: 95%;float: right;text-align: center;overflow: hidden;text-align:right;">
            <p style="font-size:12px">可用SUBY:</p>
            <p style="overflow: hidden;text-overflow: ellipsis;white-space: nowrap;font-size:30px"><?php echo ($minfo["jinbi"]); ?></p>
         </div>-->
        <div style="width: 50%;float: left;overflow: hidden; margin-top:10px;">
            
            <p style="overflow: hidden;text-overflow: ellipsis;white-space: nowrap;font-size:14px; padding-left:7%;">我的姓名：<span style="font-size:16px;"><?php echo ($minfo["truename"]); ?></span></p>
            <p style="overflow: hidden;text-overflow: ellipsis;white-space: nowrap;font-size:14px; padding-left:7%;margin-top:12px;">我的级别：<span style="font-size:16px;"><?php echo group($minfo['level']);?></span></p>
        </div>
          <div style="width:50%;float: right;text-align: center;overflow: hidden;text-align:right;"></p>
            <span style="font-size:14px;margin-right:2%">可用CHT: <span style="overflow: hidden;font-size:18px; margin-right:7%;"><?php echo (four_number($minfo["jinbi"])); ?></span></p>
            <span style="font-size:14px;margin-right:2%">冻结CHT: <span style="font-size:18px; margin-right:7%;"><?php echo (four_number($minfo["qjinbi"])); ?></span></p>
	</div>
	</div>
    
    
<div style="width:95%; margin:0 auto;">
<marquee style=" width:100%; height:30px; line-height:30px;" scrollamount="2" direction="left" >
	<a href="<?php echo U('Index/New/newsdetails',array('news_id'=>$news_info['id']));?>" target="_blank" style="color:#FFA500;"><?php echo ($news_info["title"]); ?></a>

</marquee >



</div>
	<?php if($minfo["team_sl"] > 0): ?><!--<?php echo ($minfo["team_sl"]); ?>-->
	<div style="background: #FFFFFF;padding:0 5px;" ><span>团队最高可达：<?php echo ($max_day_sl); ?>/天</span>
		<?php if($team_money_yesterday ): ?><span style="float: right">目前加成：<?php echo ($team_money_yesterday); ?></span><?php endif; ?>
	</div>
		<?php if($team_money_yesterday ): ?><div style="background: #FFFFFF;padding:0 5px;border-top:1px solid #c5c5c5 ">
			今日团队算力加成收益为<?php echo ($team_money_yesterday); ?>，已经自动转入账号余额
		</div><?php endif; endif; ?>



		<div class="weui_grids" style="background-color: #F9F9F9	">
	<a href="<?php echo U('Index/Shop/orderlist');?>" class="weui_grid js_grid" data-id="toast">
		<div class="weui_grid_icon">
			<i class="fa fa-cart-arrow-down" style="color:#483D8B;display: block;width: 16px;margin:0 auto;font-size: 2em;margin-left: -2px;"></i>
		</div>
		<p class="weui_grid_label" style="margin-top: 12px">我的矿机</p>
	</a>

	<a href="<?php echo U('Index/Emoney/myjiaoyi');?>" class="weui_grid js_grid" data-id="toast">
		<div class="weui_grid_icon">
			<i class="fa fa-balance-scale" style="color:#228B22;display: block;width: 16px;margin:0 auto;font-size: 2em;margin-left: -2px;"></i>
		</div>
		<p class="weui_grid_label" style="margin-top: 12px">我的交易</p>
	</a>

        <a href="<?php echo U('Index/Financial/kslist');?>" class="weui_grid js_grid" data-id="toast">
	         <div class="weui_grid_icon">
			<i class="fa fa-cart-plus" style="color:#FF0000;display: block;width: 16px;margin:0 auto;font-size: 2em;margin-left: -2px;"></i>
	         </div>
	        <p class="weui_grid_label" style="margin-top: 12px">矿机收益</p>
	</a>
          
	<a href="<?php echo U('Index/Financial/kglist');?>" class="weui_grid js_grid" data-id="toast">
		<div class="weui_grid_icon">
			<i class="fa fa-bar-chart" style="color:#6A5ACD;display: block;width: 16px;margin:0 auto;font-size: 2em;margin-left: -2px;"></i>
		</div>
		<p class="weui_grid_label" style="margin-top: 12px">我的财务</p>
	</a>
	
          <a href="<?php echo U('Index/Financial/kzlist');?>" class="weui_grid js_grid" data-id="toast">
		<div class="weui_grid_icon">
			<i class="fa fa-gg-circle" style="color:#FF8C00;display: block;width: 16px;margin:0 auto;font-size: 2em;margin-left: -2px;"></i>
		</div>
		<p class="weui_grid_label" style="margin-top: 12px">工会收益</p>
	</a>	
		
	<a href="<?php echo U('Index/Account/myAccount');?>" class="weui_grid js_grid" data-id="toast">
		<div class="weui_grid_icon">
			<i class="fa fa-users" style="color:#800000;display: block;width: 16px;margin:0 auto;font-size: 2em;margin-left: -2px;"></i>
		</div>
		<p class="weui_grid_label" style="margin-top: 12px">我的工会</p>
	</a>



	<a href="<?php echo U('Account/tuiguangma');?>" class="weui_grid js_grid" data-id="toast">
		<div class="weui_grid_icon">
			<i class="fa fa-user-plus" style="color:#FF1493;display: block;width: 16px;margin:0 auto;font-size: 2em;margin-left: -2px;"></i>
		</div>
		<p class="weui_grid_label" style="margin-top: 12px">推广中心</p>
	</a>
	<a href="<?php echo U('Index/PersonalSet/myInfo');?>" class="weui_grid js_grid" data-id="toast">
		<div class="weui_grid_icon">
			<i class="fa fa-venus-double" style="color:#0000CD;display: block;width: 16px;margin:0 auto;font-size: 2em;margin-left: -2px;"></i>
		</div>
		<p class="weui_grid_label" style="margin-top: 12px">个人资料</p>
	</a>
	<a href="<?php echo U('Index/PersonalSet/updatePass');?>" class="weui_grid js_grid" data-id="toast">
		<div class="weui_grid_icon">
			<i class="fa fa-expeditedssl" style="color:#4169E1;display: block;width: 16px;margin:0 auto;font-size: 2em;margin-left: -2px;"></i>
		</div>
		<p class="weui_grid_label" style="margin-top: 12px">密码管理</p>
	</a>
	<a href="<?php echo U('Index/msg/addmsg');?>" class="weui_grid js_grid" data-id="toast">
		<div class="weui_grid_icon">
			<i class="fa fa-envelope-o" style="color:#006400;display: block;width: 16px;margin:0 auto;font-size: 2em;margin-left: -2px;"></i>
		</div>
		<p class="weui_grid_label" style="margin-top: 12px">联系我们</p>
	</a>
	<a href="<?php echo U('Index/new/news');?>" class="weui_grid js_grid" data-id="toast" >
			<div class="weui_grid_icon" style="position:relative;">
			<i class="fa fa-volume-up" style="color:#FA8072;display: block;width: 16px;margin:0 auto;font-size: 2em;margin-left: -2px;"></i>
				<span style="position:absolute; top:0px; right:-20px; background:#F00; color:#ffffff; font-size:12px; font-weight:bold; width:20px; height:20px; border-radius:50%; text-align:center;"><?php echo ($w_read); ?></span>
            
            </div>
			<p class="weui_grid_label" style="margin-top: 12px">网站公告</p>
            
	</a>
	
	

	
		
	       <a href="http://img4.imgtn.bdimg.com/it/u=2402952538,2832795124&fm=26&gp=0.jpg" class="weui_grid js_grid" data-id="toast">
		<div class="weui_grid_icon">
			<i class="fa fa-gift" style="color:#006400;display: block;width: 16px;margin:0 auto;font-size: 2em;margin-left: -2px;"></i>
		</div>
		<p class="weui_grid_label" style="margin-top: 12px">购物商城 </p>
	</a>
	
          
           <a href="http://img4.imgtn.bdimg.com/it/u=2402952538,2832795124&fm=26&gp=0.jpg" class="weui_grid js_grid" data-id="toast">
		<div class="weui_grid_icon">
			<i class="fa fa-gamepad" style="color:#006400;display: block;width: 16px;margin:0 auto;font-size: 2em;margin-left: -2px;"></i>
		</div>
		<p class="weui_grid_label" style="margin-top: 12px">游戏中心 </p>
	</a>
         
		 <a href="http://img4.imgtn.bdimg.com/it/u=2402952538,2832795124&fm=26&gp=0.jpg" class="weui_grid js_grid" data-id="toast">
		<div class="weui_grid_icon">
			<i class="fa fa-clock-o" style="color:#006400;display: block;width: 16px;margin:0 auto;font-size: 2em;margin-left: -2px;"></i>
		</div>
		<p class="weui_grid_label" style="margin-top: 12px">我的钱包 </p>
	</a>
    



    
    
    <a href="<?php echo U('Index/Index/logout');?>" class="weui_grid js_grid" data-id="toast">
		<div class="weui_grid_icon">
			<i class="fa fa-power-off" style="color:#FF0000;display: block;width: 16px;margin:0 auto;font-size: 2em;margin-left: -2px;"></i>
		</div>
		<p class="weui_grid_label" style="margin-top: 12px">安全退出</p>
	</a>
    
        
</div>
	    	<div class="height55"></div>

<!--底部开始-->

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
<script src="/Public/gec/reg/js/jquery-1.11.3.min.js"></script>
<script src="/Public/gec/web/js/jquery-weui.min.js"></script>	




	<!--底部结束-->
	<script src="/Public/web/js/jquery-weui.min.js"></script>
		<p style="display:none;">

</p>

</body>
</html>