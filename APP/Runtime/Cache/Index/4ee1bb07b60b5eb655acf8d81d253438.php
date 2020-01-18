<?php if (!defined('THINK_PATH')) exit();?><!DOCTYPE html>
<html>
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
    <link type="text/css" rel="stylesheet" href="/Public/gec/web/css/lib.css?2">
   <meta name="viewport" content="width=device-width, user-scalable=no, initial-scale=1.0, maximum-scale=1, minimum-scale=1.0"/>
   <meta content="telephone=no" name="format-detection">
    <title>工会收益</title>
    <script src="/Public/gec/web/js/jquery-1.8.3.min.js"></script>
    <link rel="stylesheet" href="/Public/gec/web/css/weui.min.css"/>
    <link rel="stylesheet" href="/Public/gec/web/css/jquery-weui.min.css">
    <link href="/Public/gec/web/css/font-awesome.min.css" rel="stylesheet">
    <link href="/Public/gec/web/fonts/iconfont.css" rel="stylesheet">
    <script src="/Public/gec/web/js/layer.js"></script>
</head>
<body>
<!--顶部开始-->
<div class="header">
    <span class="header_l"><a href="javascript:history.go(-1);"><i class="fa fa-chevron-left"></i></a></span>
    <span class="header_c">工会收益</span>
		<!--<span style="position: absolute;right: 10%;top: 0px;text-align:center;width:20%;white-space:nowrap; overflow:hidden; text-overflow:ellipsis;font-size: 12px; "><?php echo ($memberinfo['username']); ?> </span>
		<span class="header_r"><a href="<?php echo U(GROUP_NAME .'/personal_set/myInfo');?>"><i class="fa fa-user"></i></a></span>-->
</div>
<div class="height40"></div>
<!--顶部结束-->
<!--列表开始-->
<div class="zhul" style="padding-bottom:5px;margin-bottom:80px">


    <table style="width: 94%;margin-left: 5%;color: #333333;margin-top: 20px;border-collapse:collapse;">
        <thead style="font-size: 12px; ">
		
            <tr style="height: 35px;line-height: 35px;">
				 <th  style="border-bottom:2px solid #ddd ">日期</th>
				 <th style="border-bottom:2px solid #ddd ">数量</th>
				 <th style="border-bottom:2px solid #ddd ">代数/会员</th>
                <th style="border-bottom:2px solid #ddd ">结余</th>
               
            </tr>

        </thead>
        <tbody style="font-size: 12px;text-align: center" id="content_ajax">
		 <?php if(is_array($list)): foreach($list as $key=>$v): ?><tr style="text-align:center" class="includeitem">
                            <td><?php echo (date('Y-m-d',$v["addtime"])); ?></td>
                            <td><?php if($v["adds"] == 0.00): ?>-<?php echo (four_number($v["reduce"])); else: ?>+<?php echo (four_number($v["adds"])); endif; ?></td>
							<td><?php echo ($v["desc"]); ?></td>
                            <td><?php echo (four_number($v["balance"])); ?></td>
            </tr><?php endforeach; endif; ?> 		

        </tbody>
    </table>

	<div id="pages"><?php echo ($page); ?></div>
</div>
<style>.weui_media_box:before {left:0}</style>
<!--列表结束-->

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
<!-- <script src="/Public/js/scrollpagination.js" type="text/javascript"></script>

<script type="text/javascript">
$(document).ready(function(){
      $('#content_ajax').infinitescroll({
	       navSelector:"#pages",
		   nextSelector:"#next",
		   itemSelector:".includeitem"
	 });

});
  
</script>-->
</body>
</html>