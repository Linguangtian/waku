<?php  
//账号管理控制器
Class  ShopAction extends CommonAction{

    //商品列表
    public function plist(){
			$type = M("type");
			$product = M("product");

			if($_GET['id']){	
               $where = "tid={$_GET['id']}";
            }else{
				$where = "1=1";
			}		   
		     $where.=" and is_on = 0" ;   
		  /*   $where.=" and stock > 0" ;*/

			   
			     import('ORG.Util.Page');
                $map=array();
            /*    $map['stock']=['gt','0'];*/
				$count = $product -> where($map)->count();
				$Page  = new Page($count,14);
				$show = $Page -> show();
				$typeData = $product -> where($where) ->order("id asc") -> limit($Page ->firstRow.','.$Page -> listRows) -> select();
			
			
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
		$product = M("product");
		
	   
		$data = $product -> find($id);
        if(empty($data)){
			
			alert('信息不存在',U('Index/Shop/plist'));
		}
		$this -> assign('product',$data);			
		
		$this->display();
	}
   //订单提交页面
   public function buy(){
	   
	      $userinfo = M("member")->where(array("username"=>session("username")))->find();
		  if($userinfo['level']==0){
			  alert('请先完善个人资料提交系统审核！',U('personal_set/myInfo'));
		  }
		  
		   if($userinfo['checkstatus']==2){
			  alert('账户信息审核失败,请先完善个人资料提交系统审核！',U('personal_set/myInfo'));
		  }
		  
		  
		   if($userinfo['checkstatus']!=3){
			  alert('资料信息正在审核！',U('personal_set/myInfo'));
		  }
		  
		  
	      $product = M("product");

		  $id =  I('get.id',0,'intval');
		  //查询矿机信息
		  $data = $product -> find($id);


        if($data['stock']<=0){
                alert('该矿级库存不足，请选择其他购买！',U('Shop/plist'));
        }


		  if(empty($data)){
			  alert('信息不存在',U('Shop/plist'));
		  }		
		  $suanli = $userinfo['mygonglv'] + $data['gonglv'];
		  $mysuanli = M("member_group")->where(array("level"=>$userinfo['level']))->getField("mysuanli");
		  
		  if($suanli>$mysuanli){
			  alert('超过您的最大可拥有算力'.$mysuanli.',不能购买',U('Shop/plist'));
			  
		  }
		  
		  //判断 是否已经达到限购数量
		  
		  $my_gounum=M("order")->where(array("user"=>session('username'),"sid"=>$id))->count();
		
		  if($my_gounum >=$data['xiangou']){
			    echo '<script>alert("已经达到你购买本矿机上线！");window.history.back(-1);</script>';
				die;
				  
		  }  //统计是否有符合数量的免费合约机
	   	 $zs_count = M("order")->where(array("user"=>session('username'),"sid"=>1))->count();
		 if($zs_count < C("zs_num") && $id==1){
			
		 }else{
			 $jinbi = getMemberField('jinbi');		
			 if($jinbi < $data['price']){
				echo '<script>alert("账户余额不足！");window.history.back(-1);</script>';
				die;
			 }	
             if($id==1){
				if($zs_count >= C("z_num")){
					echo '<script>alert("此类型合约机已达上限！");window.history.back(-1);</script>';
					die;					

				}
			 }	
			 
			  M("member")->where(array('username'=>session('username')))->setDec('jinbi',$data['price']);
			  account_log(session('username'),$data['price'],'购买'.$data['title'],0);					 
		 }
		  
	  
          $map = array();
         // $yCode = array('A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J');		  
          $map['kjbh'] = 'S' . date('d') . substr(time(), -5) . sprintf('%02d', rand(0, 99));
		  $map['user'] = session('username');
		  $map['user_id'] = session('mid');
		  $map['project']= $data['title'];
		  $map['sid'] = $data['id'];
		  $map['yxzq'] = $data['yszq'];		
          $map['sumprice'] = $data['price'];
		  $map['addtime'] = date('Y-m-d H:i:s');	
          $map['imagepath'] = $data['thumb'];
		  $map['lixi']	= $data['gonglv'];
		  $map['kjsl'] =  $data['shouyi'];
          $map['zt'] =  1;	
          $map['UG_getTime'] =  time();		  
		  M('order')->add($map);		
		  $product->where(array("id"=>$id))->setDec("stock");
		  //写入上级团队算力
				$parentpath = M("member")->where(array("username"=>session('username')))->getField("parentpath");
				$path2 = explode('|', $parentpath);
		        array_pop($path2);
			    $parentpath = array_reverse($path2);
	            foreach($parentpath as $k=>$v){
					 M("member")->where(array('id'=>$v))->setInc("teamgonglv",$map['lixi']);
                }	
		   //写入个人算力
		  M("member")->where(array("username"=>session('username')))->setInc("mygonglv",$map['lixi']);
          //updateLevel();				
	      alert('矿机购买成功',U('Shop/orderlist'));
   }
 
   	//订单列表
	public function orderlist(){
		import('ORG.Util.Page');
		$count = M('order') ->where(array('user'=>session('username')))->count();
		$Page  = new Page($count,10);
		$Page->setConfig('theme', '%first% %upPage% %linkPage% %downPage% %end%');
		$show = $Page -> show();		
	 
        $list = M('order')->where(array('user'=>session('username')))->order('id desc') -> limit($Page ->firstRow.','.$Page -> listRows)->select();
		$this ->assign("page",$show);		 
        $this->assign('list',$list);		
		$this->display();
	}  
	public function wakuang(){
		
		$id= I("get.id",0,"intval");
		$result = M('order')->where(array('id'=>$id,"user"=>session('username')))->find();
		if(!$result){
					echo '<script>alert("矿机不存在！");window.history.back(-1);</script>';
					die;					
		}
		

			
		//计算预计总收益

		$time = $result['UG_getTime'];
	    $time1= NOW_TIME;
		$cha = $time1-$time;
		
		//$jrsy= $result['kjsl']/3600;
		$jrsy= 0;
		$jrsy=number_format($jrsy,8);//每秒收益
		
		$yjzsy = $cha * $jrsy;//矿车预计总收益
		$zsy=number_format($yjzsy,8);
		$kcmc = $result['project'];
		$status=$result['zt'];

		$qwsl=$result['qwsl'];
		$qwsljs=M('shop_project')->sum('kjsl');
		//每秒受益
		//$mmsy=$result['kjsl']/86400;
		$mmsy=$result['kjsl']/3600;
		$mmsy=number_format($mmsy,8);
		$this->assign('mmsy',$mmsy);
		//dump($qwsljs);die();
		$ckzqwsl=M('order')->where(array('zt'=>1))->sum('lixi');
		$ckzqwsl=number_format($ckzqwsl,2);
		
		
		$sl=M('slkz')->order('id desc')->find();
		$xssl=$ckzqwsl+$sl['num'];
		$xssl=number_format($xssl,2);
		//dump($xssl);die();
		$down_time=time()-strtotime($result['addtime']);
		
		if($down_time > $result['yxzq']*3600){
			$down_time=$result['yxzq']*3600;
		}
		
		
		$data_b_total=M("jinbidetail")->where("type = 1")->sum('adds');
		
		
		$total_sy=$down_time*$mmsy;
		$this->assign('total_sy',$total_sy);
		$this->assign('data_b_total',$data_b_total);
		$this->assign('kcmc',$kcmc);
		$this->assign('status',$status);
		$this->assign('yjzsy',$zsy);
		$this->assign('gonglv',$result['lixi']);
		$this->assign('qwsl',$ckzqwsl);
		$this->assign('jrsy',$jrsy);
		$this->display();
	}
	
	//支付
	public function ordePay(){
		die;
		$member = M('member');
		$id = I('get.id',0,'intval');
		$jinbi = getMemberField('jinbi');
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

		//扣除并写入明细
		if($jinbi < $money){
				echo '<script>alert("电子币余额不足，请确认！");window.history.back(-1);</script>';
				die;			
		}			

		$member->where(array('username'=>session('username')))->setDec('jinbi',$money);
		account_log(session('username'),$money,'支付商品:('.$orderinfo['stitle'].'),数量 '.$orderinfo['num'].'件。',0);				
	    $parent = $member->where(array('username'=>session('username')))->getField('parent');
		   if(!empty($parent)){
			      //重消奖 
				  $tjj  = cxmoney($money * 0.01 * C("LINGSHOU"));  
				  $member->where(array('username'=>$parent))->setInc('jinbi',$tjj[0]);
				  account_log($parent,$tjj[0],'重消奖,来自会员:'.session('username'),1,5);	
				  $member->where(array('username'=>$parent))->setInc('point',$tjj[1]);
				  account_log3($parent,$tjj[1],'重消奖,来自会员:'.session('username'),1,5);					  
		    }
		//更新订单状态
		M('order')->where(array('member'=>session('username'),'id'=>$id))->save(array('status'=>1,'pay_time'=>NOW_TIME));


        alert('支付成功',U('Index/Shop/orderlist'));		
	}
	
	
		public function payList(){
			$data = M('paydetail')->where(array('member'=>session('username')))->order('id desc')->select();
			$this->assign('data',$data);
			$this->display();
		}
		/**
		 * [会员电子货币充值]
		 * @return [type] [description]
		 */
		public function pay(){
			
			if (IS_POST) {
				$db = M('paydetail');
				$member = M('member');
				$money = I('post.money',0,'intval');
				$password2   = I('post.password2','','md5');
				$data['type'] = I('post.type',0,'strval');
				$data['account'] = I('post.account',0,'strval');
				$data['name'] = I('post.name',0,'strval');
				$data['content'] = I('post.content',0,'strval');
				if(empty($data['type']) || empty($data['account']) || empty($data['name']) || empty($data['content'])){
					
					$this->ajaxReturn(array('info'=>'请完善零售信息！'));
				}
				$money == 0 and  $this->ajaxReturn(array('info'=>'提现金额不能为0！'));
				//验证二级密码是否正确
				if (!$member->where(array('username'=>session('username'),'password2'=>$password2))->getField('id')) {
					$this->ajaxReturn(array('info'=>'对不起!二级密码不正确!'));					
				}		
				$money = intval($money);
				$shoukuan = $member->where(array('member'=>session('username')))->find();
				

				$data['addtime'] = time();
				$data['member'] = session('username');
	            $data['amount'] =  $money;
					if ($db->data($data)->add()) {

						$this->ajaxReturn(array('info'=>'提交成功，等待审核！','url'=>U('Index/shop/pay')));
					}else{
						$this->ajaxReturn(array('info'=>'提交失败！','url'=>U('Index/shop/pay')));
					}				

            }      
			$member = M('member')->field("jinbi")->where(array('id'=>session('mid')))->find();
			
			$status = C("WITHDRAW_STATUS");
			$this->assign('status',$status);
			$this->assign('v',$member);
			$this->display();
		}
}



?>