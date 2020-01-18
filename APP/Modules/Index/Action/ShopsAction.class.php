<?php  
//账号管理控制器
Class  ShopsAction extends CommonAction{

    //商品列表
    public function plist(){
			$type = M("types");
			$product = M("products");

			if($_GET['id']){	
               $where = "tid={$_GET['id']}";
            }else{
				$where = "1";
			}		   
		         import('ORG.Util.Page');
				$count = $product -> where($map)->count();
				$Page  = new Page($count,14);
				$show = $Page -> show();
				$typeData = $product -> where($where) ->order("id DESC") -> limit($Page ->firstRow.','.$Page -> listRows) -> select();
			
			
			//遍历主栏目
			$type =M('type');
			$data = $type -> where("pid=0") -> select();
	
			$this ->assign("page",$show);
			$this ->assign("types",$data);
			$this->assign("typeData",$typeData);
			
		
        $this->display();
    }
	//商品详情
	
	public function pcontent(){
		
		$id =  I('get.id',0,'intval');
		$type = M('type');
		$product = M("products");
		
	   
		$data = $product -> find($id);
        if(empty($data)){
			
			alert('信息不存在',U('Index/Shops/plist'));
		}
		$this -> assign('product',$data);			
		
		$this->display();
	}
   //订单提交页面
   public function buy(){
	    if(IS_AJAX){
			   $data['num'] =  I('post.num',0,'intval');
			   $data['sid'] = I('post.sid',0,'intval');
			   $data['member'] = session('username');
			   $data['stitle'] = I('post.stitle');
			   $data['price'] = I('post.price');
			   $data['money'] = $money = $data['num'] * $data['price'];
			   $data['time'] = NOW_TIME;
			   $data['realname'] = I('post.realname');
			   $data['post'] = I('post.post');
			   $data['mobile'] = I('post.mobile');
			   $data['address'] = I('post.addr');
			   $data['baodan'] = I('post.baodan','','strval');
			   if(empty($data['realname']) || empty($data['post']) || empty($data['mobile']) || empty($data['address'])){
				  $this->ajaxReturn(array('info'=>'收货信息为必填项!')); 
				   
			   }
			   if(!preg_match("/^1[34578]{1}\d{9}$/",$data['mobile'])){  
					$this->ajaxReturn(array('info'=>'手机格式不正确!'));
			   } 
			   if(!preg_match("/^\d{6}$/", $data['post'])){
				   $this->ajaxReturn(array('info'=>'邮编格式不正确！'));
			   }		
			   if($data['sid']==0){
				   $this->ajaxReturn(array('info'=>'商品ID存在错误！'));
			   }
			   if($data['num']==0){
					$this->ajaxReturn(array('info'=>'请输入正确的商品数量！'));
			   }
			   if($data['money']==0){
				   alert('参数出错！',-1);
			   }
			   if(M('order')->add($data)){		
				   $this->ajaxReturn(array('info'=>'下单成功!','url'=>U('Index/Shops/orderlist')));
			   }else{
				   $this->ajaxReturn(array('info'=>'下单失败！'));
			   }				
			
			
		}
	    $id =  I('get.id',0,'intval');
		$product = M("products");
		
	    $huo = M('order')->where(array('member'=>session('username')))->order("id desc")->find();

		$data = $product -> find($id);
        if(empty($data)){
		  alert('信息不存在',U('Index/Shops/plist'));
		}
		$jinbi = getMemberField('jinbi');
		if(!empty($huo)){
			$this -> assign('huo',$huo);
		}		
		$this -> assign('jinbi',$jinbi);
		$this -> assign('product',$data);
	    $this->display();
   }
 
   	//订单列表
	public function orderlist(){
		import('ORG.Util.Page');
		$count = M('order') ->count();
		$Page  = new Page($count,15);
		$show = $Page -> show();		
	 
        $list = M('order')->where(array('member'=>session('username')))->order('id desc')->select();
		$this ->assign("page",$show);		 
        $this->assign('list',$list);		
		$this->display();
	}  
	
	//报单中心支付
	public function ordePay(){
		$id = I('get.id',0,'intval');
		$point = getMemberField('point');
		if($id==0){
			alert('订单参数出错！',-1);
		}
		$orderinfo = M('order')->where(array('member'=>session('username'),'id'=>$id))->find();
		if($orderinfo['status']>0){
			echo '<script>alert("订单已支付，不可操作！");window.history.back(-1);</script>';
			die;
		}
		$money = $orderinfo['money'];
        if (!$orderinfo) {
			echo '<script>alert("对不起，支付信息不正确！");window.history.back(-1);</script>';
			die;				
        }	
	    if($point < $money){
			echo '<script>alert("购物券余额不足，请确认！");window.history.back(-1);</script>';
			die;			
	    }		
		//扣除并写入明细
        $member = M('member');
		//扣除购物券余额
		$member->where(array('username'=>session('username')))->setDec('point',$money);
		account_log3(session('username'),$money,'支付商品:('.$orderinfo['stitle'].'),数量 '.$orderinfo['num'].'件。',0);	
		//更新订单状态
		M('order')->where(array('member'=>session('username'),'id'=>$id))->save(array('status'=>1,'pay_time'=>NOW_TIME));


        alert('支付成功',U('Index/Shops/orderlist'));		
	}
}



?>