<?php  
	/**
	 * 自动统计
	 */



	Class AutoAction extends Action{

        private function count_cost($id,$max_total){
            $todate=date('Y-m-d');
            $res=0;
            $db     =   Db::getInstance(C('RBAC_DB_DSN'));
            $sql='select id,username,parentcount from ds_member where parent_id='.$id;
            $son_list=$db-> query($sql);//一级





            $team_one=0;  //一级提供算力
            $team_two=0;
            $team_tress=0;

            $sljc_1=C('sljc_1');
            $sljc_2=C('sljc_2');
            $sljc_3=C('sljc_3');

            foreach ($son_list as $item){
                $sql='select sum(sumprice) as total_sumprice from ds_order where zt=1 and user=\''.$item['username'].'\'';
                $total_kuanji1=$db->query($sql);
                $total_kuanji1=$total_kuanji1['0']['total_sumprice'];


                if($total_kuanji1>0){
                    $team_one +=$total_kuanji1*$sljc_1/100;
                }

                if($item['parentcount']==0||$item['parentcount']==' ')continue;


                //二级列表
                $sql='select id,username,parentcount from ds_member where parent_id='.$item['id'];
                $son2_list=$db-> query($sql);

                foreach ($son2_list as $item2){
                    //二级今日的
                    $sql='select sum(sumprice) as total_sumprice from ds_order where zt=1 and user=\''.$item2['username'].'\'';
                    $total_kuanji2=$db->query($sql);
                    $total_kuanji2=$total_kuanji2['0']['total_sumprice'];


                    if($total_kuanji2>0){
                        $team_two+=$total_kuanji2*$sljc_2/100;
                    }

                    if($item2['parentcount']==0||$item2['parentcount']==' ')continue;
                    //三级列表
                    $sql='select id,username,parentcount from ds_member where parent_id='.$item2['id'];
                    $son3_list=$db-> query($sql);
                    foreach ($son3_list as $item3){
                        $sql='select sum(sumprice) as total_sumprice from ds_order where zt=1 and user=\''.$item3['username'].'\'';
                        $total_kuanji3=$db->query($sql);
                        $total_kuanji3=$total_kuanji3['0']['total_sumprice'];


                        if($total_kuanji3>0){
                            $team_tress+=$total_kuanji3*$sljc_3/100;
                        }
                    }

                }
            }

           $todae_total=$team_tress+$team_two+$team_one;
           $todae_total=$todae_total>$max_total?$todae_total:$todae_total;
           return round($todae_total,5);
        }



        public function index(){



            $db     =   Db::getInstance(C('RBAC_DB_DSN'));
            $sql='select id,username,parentcount,team_sl from ds_member  where parentcount>0';
            $member_list=$db-> query($sql);




           foreach ($member_list as $key=>$li){

               $todate=date('Y-m-d');




               $max_total = M('order')->where(array('member'=>$li['username'],'zt'=>1))->field('sumprice')->count();
               $td_limit=C('td_limit');
               $max_total=$max_total*$td_limit/100;
               $count_sl_today=$this->count_cost($li['id'],$max_total);

                if($count_sl_today<=0)continue;

               account_log($li['username'],$count_sl_today,$todate.'-团队加成',1,1,1);
               $count_team_sl= $li['team_sl']+$count_sl_today;
                $sql='update ds_member set  team_sl='.$count_team_sl.' where id='.$li['id'];
                $db-> query($sql);

               $todate_team_money = M('todate_team_money');
               $data=[
                'username'=>$li['username'],
                   'user_id'=>$li['id'],
                   'todate_money'=>$count_sl_today,
                   'date'=>$todate,
               ];
               $todate_team_money->add($data);

           }
        }

    }
?>