-- phpMyAdmin SQL Dump
-- version 4.8.5
-- https://www.phpmyadmin.net/
--
-- 主机： localhost
-- 生成日期： 2020-01-04 02:57:50
-- 服务器版本： 5.5.29
-- PHP 版本： 7.3.4

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
SET AUTOCOMMIT = 0;
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- 数据库： `zhanmazj`
--

DELIMITER $$
--
-- 存储过程
--
CREATE DEFINER=`root`@`localhost` PROCEDURE `addScore` (`_uid` INT, `_amount` FLOAT)  begin
	
	declare bonus float;
	select `value` into bonus from ssc_params where name='scoreProp' limit 1;
	
	set bonus=bonus*_amount;
	
	if bonus then
		update ssc_members u, ssc_params p set u.score = u.score+bonus, u.scoreTotal=u.scoreTotal+bonus where u.`uid`=_uid;
	end if;
	
end$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `auto_clearData` ()  begin

	declare endDate int;
	set endDate = UNIX_TIMESTAMP(now())-7*24*3600;

	-- 采集记录
	delete from ssc_data where time < endDate;
	-- 会员登录session
	delete from ssc_member_session where accessTime < endDate;
	-- 投注
	delete from ssc_bets where kjTime < endDate and lotteryNo <> '';
	-- 管理员日志
	delete from ssc_admin_log where actionTime < endDate;

end$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `betcount` (`_date` INT(8), `_type` TINYINT(3), `_uid` INT(10))  begin
  -- 按彩种汇总表
	declare _pri int(11) DEFAULT 0; 
	declare _betCount int(5) DEFAULT 0;
	declare _betAmount double(15,4) DEFAULT 0.0000;
	declare _betAmountb double(15,4) DEFAULT 0.0000;
	declare _zjAmount double(15,4) DEFAULT 0.0000;
	declare _rebateMoney double(15,4) DEFAULT 0.0000;
	declare _username VARCHAR(16) DEFAULT null;
	declare _gudongId int(10) DEFAULT 0; 
	declare _zparentId int(10) DEFAULT 0; 
	declare _parentId int(10) DEFAULT 0; 

	select uid into _uid from ssc_members where isDelete=0 and `uid`=_uid;
	if _uid then

	select id into _pri from ssc_count where `date`=_date and `uid`=_uid and `type`=_type  LIMIT 1;

	if _pri=0 or _pri is null THEN
		insert into ssc_count (`date`, `uid`, `type`) values(_date, _uid, _type);
		select id into _pri from ssc_count where date=_date and `uid`=_uid and `type`=_type LIMIT 1;
	end if;

-- 统计有效方案数

	select count(*) into _betCount from ssc_bets where isDelete=0 and `uid`=_uid and `lotteryNo` !='' and `type` =_type and FROM_UNIXTIME(kjTime,'%Y%m%d') = _date;
	
-- 统计总投注额,此处为复式投注总额
	select sum(totalMoney) into _betAmount from ssc_bets where isDelete=0 and `uid` =_uid and `lotteryNo` !='' and `type` =_type and `betInfo` !='' and `totalNums` >1 and `totalMoney` >0 and FROM_UNIXTIME(kjTime,'%Y%m%d') = _date;
-- 此处为单式投注总额
	select sum(money) into _betAmountb from ssc_bets where isDelete=0 and `uid` =_uid and `lotteryNo` !='' and `type` =_type and `totalNums` =1 and `totalMoney` =0 and FROM_UNIXTIME(kjTime,'%Y%m%d') = _date;

-- 统计总中奖额
	select sum(bonus) into _zjAmount from ssc_bets where isDelete=0 and `uid` =_uid and `lotteryNo` !='' and `type` =_type and FROM_UNIXTIME(kjTime,'%Y%m%d') = _date;
-- 统计总退水额
	select sum(rebateMoney) into _rebateMoney from ssc_bets where isDelete=0 and `uid` =_uid and `lotteryNo` !='' and `type` =_type and FROM_UNIXTIME(kjTime,'%Y%m%d') = _date;
	-- 查询用户信息

	select username into _username from ssc_members where isDelete=0 and `uid` =_uid;
	select gudongId into _gudongId from ssc_members where isDelete=0 and `uid` =_uid;
	select zparentId into _zparentId from ssc_members where isDelete=0 and `uid` =_uid;	
	select parentId into _parentId from ssc_members where isDelete=0 and `uid` =_uid;
-- 对空值赋默认值，增强稳定性

	if _betCount is null THEN
		set _betCount = 0;
	end if;

	if _betAmount is null THEN
		set _betAmount = 0;
	end if;
	if _betAmountb is null THEN
		set _betAmountb = 0;
	end if;
	if _zjAmount is null THEN
		set _zjAmount = 0;
	end if;
	if _rebateMoney is null THEN
		set _rebateMoney = 0;
	end if;
	
	set _betAmount = _betAmount + _betAmountb;
-- 更新到数据库
	update ssc_count set betCount=_betCount, betAmount=_betAmount, zjAmount=_zjAmount, rebateMoney=_rebateMoney, username=_username, uid=_uid, gudongId=_gudongId, zparentId=_zparentId, parentId=_parentId where id=_pri;	

	end if;

end$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `betreport` (`_date` INT(8), `_uid` INT(10))  begin
 -- 按日期汇总表
	declare _pri int(11) DEFAULT 0; 
	declare _betCount int(5) DEFAULT 0;
	declare _betAmount double(15,4) DEFAULT 0.0000;
	declare _betAmountb double(15,4) DEFAULT 0.0000;
	declare _zjAmount double(15,4) DEFAULT 0.0000;
	declare _rebateMoney double(15,4) DEFAULT 0.0000;
	declare _username VARCHAR(16) DEFAULT null;
	declare _gudongId int(10) DEFAULT 0; 
	declare _zparentId int(10) DEFAULT 0; 
	declare _parentId int(10) DEFAULT 0; 

	select uid into _uid from ssc_members where isDelete=0 and uid=_uid;
	if _uid then

	select id into _pri from ssc_report where date=_date and uid=_uid LIMIT 1;
	
	if _pri=0 or _pri is null THEN
		insert into ssc_report (date, uid) values(_date, _uid);
		select id into _pri from ssc_report where date=_date and uid=_uid LIMIT 1;
	end if;

-- 统计有效方案数

	select count(*) into _betCount from ssc_bets where isDelete=0 and uid=_uid and lotteryNo!='' and FROM_UNIXTIME(kjTime,'%Y%m%d') = _date;
-- 统计总投注额,此处为复式投注总额
	select sum(totalMoney) into _betAmount from ssc_bets where isDelete=0 and uid=_uid and lotteryNo!='' and betInfo!='' and totalNums>1 and totalMoney>0 and FROM_UNIXTIME(kjTime,'%Y%m%d') = _date;
-- 此处为单式投注总额
	select sum(money) into _betAmountb from ssc_bets where isDelete=0 and uid=_uid and lotteryNo!='' and totalNums=1 and totalMoney=0 and FROM_UNIXTIME(kjTime,'%Y%m%d') = _date;
-- 统计总中奖额
	select sum(bonus) into _zjAmount from ssc_bets where isDelete=0 and uid=_uid and lotteryNo!='' and FROM_UNIXTIME(kjTime,'%Y%m%d') = _date;
-- 统计总退水额
	select sum(rebateMoney) into _rebateMoney from ssc_bets where isDelete=0 and uid=_uid and lotteryNo!='' and FROM_UNIXTIME(kjTime,'%Y%m%d') = _date;
	-- 查询用户信息
	
	select username into _username from ssc_members where isDelete=0 and uid=_uid;
	select gudongId into _gudongId from ssc_members where isDelete=0 and uid=_uid;
	select zparentId into _zparentId from ssc_members where isDelete=0 and uid=_uid;	
	select parentId into _parentId from ssc_members where isDelete=0 and uid=_uid;
-- 对空值赋默认值，增强稳定性

	if _betCount is null THEN
		set _betCount = 0;
	end if;

	if _betAmount is null THEN
		set _betAmount = 0;
	end if;
	if _betAmountb is null THEN
		set _betAmountb = 0;
	end if;
	if _zjAmount is null THEN
		set _zjAmount = 0;
	end if;
	if _rebateMoney is null THEN
		set _rebateMoney = 0;
	end if;
	
	set _betAmount = _betAmount + _betAmountb;
-- 更新到数据库
	update ssc_report set betCount=_betCount, betAmount=_betAmount, zjAmount=_zjAmount, rebateMoney=_rebateMoney, username=_username, uid=_uid, gudongId=_gudongId, zparentId=_zparentId, parentId=_parentId where id=_pri;
	end if;

end$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `cancelBet` (`_zhuiHao` VARCHAR(255))  begin

	declare amount float;
	declare _uid int;
	declare _id int;
	declare _type int;
	
	declare info varchar(255) character set utf8;
	declare liqType int default 5;
	
	declare done int default 0;
	declare cur cursor for
	select id, money, `uid`, `type` from ssc_bets where serializeId=_zhuiHao and lotteryNo='' and isDelete=0;
	declare continue HANDLER for not found set done=1;
	
	open cur;
		repeat
			fetch cur into _id, amount, _uid, _type;
			if not done then
				update ssc_bets set isDelete=1 where id=_id;
				set info='追号撤单';
				call setCoin(amount, 0, _uid, liqType, _type, info, _id, '', '');
			end if;
		until done end repeat;
	close cur;

end$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `clearData` (`dateInt` INT(11))  begin

	declare endDate int;
	set endDate = dateInt;
	-- set endDate = unix_timestamp(dateString)+24*3600;

	-- 投注
	delete from ssc_bets where kjTime < endDate and lotteryNo <> '';
	-- select 1, _fanDian, _parentId;
	-- endDate=FROM_UNIXTIME(endDate,'%Y%m%d');
	delete from ssc_count where `date` < FROM_UNIXTIME(endDate,'%Y-%m-%d');
	delete from ssc_report where `date` < FROM_UNIXTIME(endDate,'%Y-%m-%d');
end$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `clearData2` (`dateInt` INT(11))  begin

	declare endDate int;
	set endDate = dateInt;

	-- 采集记录
	delete from ssc_data where time < endDate;

end$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `clearData3` (`dateInt` INT(11))  begin

	declare endDate int;
	set endDate = dateInt;
	-- set endDate = unix_timestamp(dateString)+24*3600;
	-- 帐变
	delete from ssc_coin_log where actionTime < endDate;
		
	-- select 1, _fanDian, _parentId;
end$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `clearData4` (`dateInt` INT(11))  begin

	declare endDate int;
	set endDate = dateInt;
	-- set endDate = unix_timestamp(dateString)+24*3600;
	-- 管理员日志
	delete from ssc_admin_log where actionTime < endDate;
	-- select 1, _fanDian, _parentId;
end$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `clearData5` (`dateInt` INT(11))  begin

	declare endDate int;
	set endDate = dateInt;
	-- set endDate = unix_timestamp(dateString)+24*3600;
	-- 会员登录session
	delete from ssc_member_session where accessTime < endDate;
	-- select 1, _fanDian, _parentId;
end$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `clearData6` (`dateInt` INT(11))  begin

	declare endDate int;
	set endDate = dateInt;
	-- set endDate = unix_timestamp(dateString)+24*3600;
	-- 提现
	delete from ssc_member_cash where actionTime < endDate and state <> 1;
	-- select 1, _fanDian, _parentId;
end$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `clearData7` (`dateInt` INT(11))  begin

	declare endDate int;
	set endDate = dateInt;
	-- set endDate = unix_timestamp(dateString)+24*3600;
	-- 充值
	delete from ssc_member_recharge where actionTime < endDate and state <> 0;
	delete from ssc_member_recharge where actionTime < endDate-24*3600 and state = 0;
	-- select 1, _fanDian, _parentId;
end$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `conComAll` (`baseAmount` FLOAT, `parentAmount` FLOAT, `parentLevel` INT)  begin

	declare conUid int;
	declare conUserName varchar(255);
	declare tjAmount float;
	declare done int default 0;	
	declare dateTime int default unix_timestamp(curdate());

	declare cur cursor for
	select b.uid, b.username, sum(b.money) _tjAmount from ssc_bets b where b.kjTime>=dateTime and b.uid not in(select distinct l.extfield0 from ssc_coin_log l where l.liqType=53 and l.actionTime>=dateTime and l.extfield2=parentLevel) group by b.uid having _tjAmount>=baseAmount;
	declare continue HANDLER for not found set done=1;

	-- select baseAmount , parentAmount , parentLevel;
	
	open cur;
		repeat fetch cur into conUid, conUserName, tjAmount;
		-- select conUid, conUserName, tjAmount;
		if not done then
			call conComSingle(conUid, parentAmount, parentLevel);
		end if;
		until done end repeat;
	close cur;

end$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `conComSingle` (`conUid` INT, `parentAmount` FLOAT, `parentLevel` INT)  begin

	declare parentId int;
	declare superParentId int;
	declare conUserName varchar(255) character set utf8;
	declare p_username varchar(255) character set utf8;

	declare liqType int default 53;
	declare info varchar(255) character set utf8;

	declare done int default 0;
	declare cur cursor for
	select p.uid, p.parentId, p.username, u.username from ssc_members p, ssc_members u where u.parentId=p.uid and u.`uid`=conUid; 
	declare continue HANDLER for not found set done=1;

	open cur;
		repeat fetch cur into parentId, superParentId, p_username, conUserName;
		-- select parentId, superParentId, p_username, conUserName, parentLevel;
		if not done then
			if parentLevel=1 then
				if parentId and parentAmount then
					set info=concat('下级[', conUserName, ']消费佣金');
					call setCoin(parentAmount, 0, parentId, liqType, 0, info, conUid, conUserName, parentLevel);
				end if;
			end if;
			
			if parentLevel=2 then
				if superParentId and parentAmount then
					set info=concat('下级[', conUserName, '<=', p_username, ']消费佣金');
					call setCoin(parentAmount, 0, superParentId, liqType, 0, info, conUid, conUserName, parentLevel);
				end if;
			end if;
		end if;
		until done end repeat;
	close cur;

end$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `consumptionCommission` ()  begin

	declare baseAmount float;
	declare baseAmount2 float;
	declare parentAmount float;
	declare superParentAmount float;

	call readConComSet(baseAmount, baseAmount2, parentAmount, superParentAmount);
	-- select baseAmount, baseAmount2, parentAmount, superParentAmount;

	if baseAmount>0 then
		call conComAll(baseAmount, parentAmount, 1);
	end if;
	if baseAmount2>0 then
		call conComAll(baseAmount2, superParentAmount, 2);
	end if;

end$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `delUser` (`_uid` INT)  begin
	-- 投注
	delete from ssc_bets where `uid`=_uid;
	-- 帐变
	delete from ssc_coin_log where `uid`=_uid;
	-- 管理员日志
	delete from ssc_admin_log where `uid`=_uid;
	-- 会员登录session
	delete from ssc_sysadmim_session where `uid`=_uid;
	-- 提现
	delete from ssc_member_cash where `uid`=_uid;
	-- 充值
	delete from ssc_member_recharge where `uid`=_uid;
	-- 银行
	delete from ssc_sysadmin_bank where `uid`=_uid;
	-- 用户
	delete from ssc_sysmember where `uid`=_uid;
	-- 推广链接
	delete from ssc_links where `uid`=_uid;
end$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `delUser2` (`_uid` INT)  begin
	-- 投注
	delete from ssc_bets where `uid`=_uid;
	-- 帐变
	delete from ssc_coin_log where `uid`=_uid;
	-- 管理员日志
	delete from ssc_admin_log where `uid`=_uid;
	-- 会员登录session
	delete from ssc_member_session where `uid`=_uid;
	-- 提现
	delete from ssc_member_cash where `uid`=_uid;
	-- 充值
	delete from ssc_member_recharge where `uid`=_uid;
	-- 银行
	delete from ssc_member_bank where `uid`=_uid;
	-- 用户
	delete from ssc_members where `uid`=_uid;
	-- 推广链接
	delete from ssc_links where `uid`=_uid;
end$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `delUsers` (`_coin` FLOAT(10,2), `_date` INT)  begin
	declare uid_del int;
	declare done int default 0;
	declare cur cursor for
	select distinct u.uid from ssc_members u, ssc_member_session s where u.uid=s.uid and u.coin<_coin and s.accessTime<_date and not exists(select u1.`uid` from ssc_members u1 where u1.parentId=u.`uid`)
union 
  select distinct u2.uid from ssc_members u2 where u2.coin<_coin and u2.regTime<_date and not exists (select s1.uid from ssc_member_session s1 where s1.uid=u2.uid);
	declare continue HANDLER for not found set done = 1;

	open cur;
		repeat
			fetch cur into uid_del;
			if not done then 
				call delUser(uid_del);
			end if;
		until done end repeat;
	close cur;
end$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `getQzInfo` (`_uid` INT, INOUT `_fanDian` FLOAT, INOUT `_parentId` INT)  begin

	declare done int default 0;
	declare cur cursor for
	select fanDian, parentId from ssc_members where `uid`=_uid;
	declare continue HANDLER for not found set done = 1;

	open cur;
		fetch cur into _fanDian, _parentId;
	close cur;
	
	-- select 1, _fanDian, _parentId;
end$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `guestclear` ()  begin

	declare endDate int;
	set endDate = UNIX_TIMESTAMP(now())-1*24*3600;

	-- 会员登录session
	delete from ssc_member_session where accessTime < endDate and username like 'guest_%';
	-- 投注
	delete from ssc_guestbets where kjTime < endDate;
	-- 帐变明细
	delete from ssc_guestcoin_log where actionTime < endDate;
	-- 临时会员
	delete from ssc_guestmembers where regTime < endDate;

end$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `guestkanJiang` (`_betId` INT, `_zjCount` INT, `_kjData` VARCHAR(255) CHARACTER SET utf8, `_kset` VARCHAR(255) CHARACTER SET utf8)  begin
	
	declare `uid` int;									-- 抢庄人ID
	declare userid int;
	declare parentId int;								-- 投注人上级ID
	declare zparentId int;
	declare gudongId int;
	declare username varchar(32) character set utf8;	-- 投注人帐号
	-- 此函数为开奖派奖处理函数
	-- 投注
	declare serializeId varchar(64);
	declare actionData longtext character set utf8;
	declare actionNo varchar(255);
	declare `type` int;
	declare playedId int;
	
	declare isDelete int;
	declare odds float;     -- 赔率
	declare _rebate float default 0;
	declare _rebatemoney float default 0;
	declare fanDian float;		-- 返点
	
	declare amount float;					-- 投注总额
	declare zjAmount float default 0;		-- 中奖总额
	declare _fanDianAmount float default 0;	-- 总返点的钱
	
	declare liqType int;
	declare info varchar(255) character set utf8;
	
	declare _parentId int;		-- 处理上级时返回
	declare _zparentId int;		-- 处理上级时返回
	declare _gudongId int;		-- 处理上级时返回
	declare _fanDian float;		-- 用户返点
	
	declare totalnums SMALLINT default 0;
	declare totalmoney float default 0;
	declare betinfo varchar(64) character set utf8;
	declare Groupname varchar(32) character set utf8;
	
	declare _kjTime int(11) DEFAULT 0;
	-- 提取投注信息
	declare done int default 0;
	declare cur cursor for
	select b.`uid`, u.parentId, u.zparentId, u.gudongId, u.username, b.serializeId, b.actionData, b.actionNo, FROM_UNIXTIME(b.kjTime,'%Y%m%d') _kjTime, b.`type`, b.playedId, b.isDelete, b.fanDian, u.fanDian, b.odds, b.rebate, b.money, b.totalNums, b.totalMoney, b.betInfo, b.Groupname  from ssc_guestbets b, ssc_guestmembers u where b.`uid`=u.`uid` and b.id=_betId;
	declare continue handler for sqlstate '02000' set done = 1;
	
	open cur;
		repeat
			fetch cur into `uid`, parentId, zparentId, gudongId, username, serializeId, actionData, actionNo, _kjTime, `type`, playedId, isDelete, fanDian, _fanDian, odds, _rebate, amount, totalnums, totalmoney, betinfo, Groupname;
		until done end repeat;
	close cur;
	-- 开始事务
	start transaction;
	if md5(_kset)='47df5dd3fc251a6115761119c90b964a' then
	
		-- 已撤单处理，不进行处理
		if isDelete=0 then
		
			set userid=`uid`;
			-- 处理上级返点
			set _parentId=parentId;
			set _zparentId=zparentId;
			set _gudongId=gudongId;
			-- set _fanDian=fanDian;
			set fanDian=_fanDian;
			-- select _fanDian , fanDian, _fanDianAmount;
			-- 处理奖金
			if _zjCount then
				-- 中奖处理
				
				set liqType=6;
				set info='中奖奖金';
				if _zjCount = -1 then
					if totalnums>1 and totalmoney>0 and betinfo<>'' then
						set amount=totalmoney;
					end if;
					set zjAmount= amount; -- 和局退回投注金额
				elseif Groupname='三军' then
					set zjAmount= amount * odds + amount * (_zjCount - 1); -- 单注金额*赔率
				else
					set zjAmount= _zjCount * amount * odds; -- 中奖注数*单注金额*赔率
				end if;
				call guestsetCoin(zjAmount, 0, `uid`, liqType, `type`, info, _betId, serializeId, '');
				
			end if;	
	
			if _zjCount = -1 then
				set _zjCount = 0;
			end if;				
			-- 判断是否复选投注
			if totalnums>1 and totalmoney>0 and betinfo<>'' then
				set amount=totalmoney;
			end if;

			-- 处理退水
			if _rebate>0 and  _rebate<0.5 THEN
			set liqType=105;
			set info='退水资金';
			set _rebatemoney = amount * _rebate;
			call guestsetCoin(_rebatemoney, 0, `uid`, liqType, `type`, info, _betId, serializeId, '');
			end if;

			update ssc_guestbets set lotteryNo=_kjData, zjCount=_zjCount, bonus=zjAmount, rebateMoney=_rebatemoney where id=_betId;

			if CONVERT(DATE_FORMAT(now(),'%H%i'), SIGNED)>=100 and CONVERT(DATE_FORMAT(now(),'%H%i'), SIGNED)<105 then
			call guestclear();
			end if;
		end if;
	end if;
	-- 提交事务
	commit;
	
end$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `guestsetCoin` (`_coin` FLOAT, `_fcoin` FLOAT, `_uid` INT, `_liqType` INT, `_type` INT, `_info` VARCHAR(255) CHARACTER SET utf8, `_extfield0` INT, `_extfield1` VARCHAR(255) CHARACTER SET utf8, `_extfield2` VARCHAR(255) CHARACTER SET utf8)  begin
	
	-- 当前时间
	DECLARE currentTime INT DEFAULT UNIX_TIMESTAMP();
	DECLARE _userCoin FLOAT;
	DECLARE _count INT  DEFAULT 0;
	-- select _coin, _fcoin, _liqType, _info;
	IF _coin IS NULL THEN
		SET _coin=0;
	END IF;
	IF _fcoin IS NULL THEN
		SET _fcoin=0;
	END IF;
	-- 更新用户表
	SELECT COUNT(1) INTO _count FROM ssc_guestcoin_log WHERE  extfield0=_extfield0  AND info='中奖奖金'  AND `uid`=_uid;
	IF  _count<1 THEN
	UPDATE ssc_guestmembers SET coin = coin + _coin, fcoin = fcoin + _fcoin WHERE `uid` = _uid;
	SELECT coin INTO _userCoin FROM ssc_guestmembers WHERE `uid`=_uid;
	-- 添加资金流动日志
	INSERT INTO ssc_guestcoin_log(coin, fcoin, userCoin, `uid`, actionTime, liqType, `type`, info, extfield0, extfield1, extfield2) VALUES(_coin, _fcoin, _userCoin, _uid, currentTime, _liqType, _type, _info, _extfield0, _extfield1, _extfield2);
	END IF;
	-- select coin, fcoin from ssc_members where `uid`=_uid;

end$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `isFirstRechargeCom` (`_uid` INT, OUT `flag` INT)  begin
	
	declare dateTime int default unix_timestamp(curdate());
	select id into flag from ssc_member_recharge where rechargeTime>dateTime and `uid`=_uid;
	
end$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `kanJiang` (`_betId` INT, `_zjCount` INT, `_kjData` VARCHAR(255) CHARACTER SET utf8, `_kset` VARCHAR(255) CHARACTER SET utf8)  begin
	
	declare `uid` int;									-- 抢庄人ID
	declare userid int;
	declare parentId int;								-- 投注人上级ID
	declare zparentId int;
	declare gudongId int;
	declare username varchar(32) character set utf8;	-- 投注人帐号
	-- 此函数为开奖派奖处理函数
	-- 投注
	declare serializeId varchar(64);
	declare actionData longtext character set utf8;
	declare actionNo varchar(255);
	declare `type` int;
	declare playedId int;
	
	declare isDelete int;
	declare odds float;     -- 赔率
	declare _rebate float default 0;
	declare _rebatemoney float default 0;
	declare fanDian float;		-- 返点
	
	declare amount float;					-- 投注总额
	declare zjAmount float default 0;		-- 中奖总额
	declare _fanDianAmount float default 0;	-- 总返点的钱
	
	declare liqType int;
	declare info varchar(255) character set utf8;
	
	declare _parentId int;		-- 处理上级时返回
	declare _zparentId int;		-- 处理上级时返回
	declare _gudongId int;		-- 处理上级时返回
	declare _fanDian float;		-- 用户返点
	
	declare totalnums SMALLINT default 0;
	declare totalmoney float default 0;
	declare betinfo varchar(64) character set utf8;
	declare Groupname varchar(32) character set utf8;
	declare _kjTime int(11) DEFAULT 0;
	-- 提取投注信息
	declare done int default 0;
	declare cur cursor for
	select b.`uid`, u.parentId, u.zparentId, u.gudongId, u.username, b.serializeId, b.actionData, b.actionNo, FROM_UNIXTIME(b.kjTime,'%Y%m%d') _kjTime, b.`type`, b.playedId, b.isDelete, b.fanDian, u.fanDian, b.odds, b.rebate, b.money, b.totalNums, b.totalMoney, b.betInfo, b.Groupname  from ssc_bets b, ssc_members u where b.`uid`=u.`uid` and b.id=_betId;
	declare continue handler for sqlstate '02000' set done = 1;
	
	open cur;
		repeat
			fetch cur into `uid`, parentId, zparentId, gudongId, username, serializeId, actionData, actionNo, _kjTime, `type`, playedId, isDelete, fanDian, _fanDian, odds, _rebate, amount, totalnums, totalmoney, betinfo, Groupname;
		until done end repeat;
	close cur;
	
	-- select `uid`, parentId, username, qz_uid, qz_username, qz_fcoin, serializeId, actionData, actionNo, `type`, playedId, isDelete, fanDian, _fanDian, `mode`, beiShu, zhuiHao, zhuiHaoMode, bonusProp, amount;

	-- 开始事务
	start transaction;
	if md5(_kset)='47df5dd3fc251a6115761119c90b964a' then
	
		-- 已撤单处理，不进行处理
		if isDelete=0 then
			
			-- 处理积分
			-- call addScore(`uid`, amount);
		
			-- 处理自己返点备用
			-- if fanDian then
				-- set liqType=2;
				-- set info='返点';
				-- set _fanDianAmount=amount * fanDian/1000;
				-- call setCoin(_fanDianAmount, 0, `uid`, liqType, `type`, info, _betId, '', '');
			-- end if;
			set userid=`uid`;
			-- 处理上级返点
			set _parentId=parentId;
			set _zparentId=zparentId;
			set _gudongId=gudongId;
			-- set _fanDian=fanDian;
			set fanDian=_fanDian;
			-- select _fanDian , fanDian, _fanDianAmount;
			-- 处理奖金
			if _zjCount then
				-- 中奖处理
				
				set liqType=6;
				set info='中奖奖金';
				if _zjCount = -1 then
					if totalnums>1 and totalmoney>0 and betinfo<>'' then
						set amount=totalmoney;
					end if;
					set zjAmount= amount; -- 和局退回投注金额
				elseif Groupname='三军' then
					set zjAmount= amount * odds + amount * (_zjCount - 1); -- 单注金额*赔率
				else
					set zjAmount= _zjCount * amount * odds; -- 中奖注数*单注金额*赔率
				end if;
				call setCoin(zjAmount, 0, `uid`, liqType, `type`, info, _betId, serializeId, '');
				
			end if;	
	
			if _zjCount = -1 then
				set _zjCount = 0;
			end if;			
			-- 判断是否复选投注
			if totalnums>1 and totalmoney>0 and betinfo<>'' then
				set amount=totalmoney;
			end if;

			-- if _zjCount=0 then	
				-- 未中奖处理
				-- if _parentId >0 then
				-- call setDLFanDian(amount, _fanDian, _parentId,  `type`, _betId, userid, username);
				-- end if;
				-- if _zparentId >0 then
				-- call setZDLFanDian(amount, _fanDian, _zparentId,  `type`, _betId, userid, username);
				-- end if;
				-- if _gudongId >0 then
				-- call setGDFanDian(amount, _fanDian, _gudongId,  `type`, _betId, userid, username);
				-- end if;	
			-- end if;	

			-- 处理退水
			if _rebate>0 and  _rebate<0.5 THEN
			set liqType=105;
			set info='退水资金';
			set _rebatemoney = amount * _rebate;
			call setCoin(_rebatemoney, 0, `uid`, liqType, `type`, info, _betId, serializeId, '');
			end if;
			-- if _parentId >0 or _zparentId >0 or _gudongId >0 then
			-- set _fanDianAmount = _fanDianAmount + amount * fanDian/100;
			-- end if;
			-- 更新开奖数据
			update ssc_bets set lotteryNo=_kjData, zjCount=_zjCount, bonus=zjAmount, rebateMoney=_rebatemoney where id=_betId;

			if _kjTime then				
				 call betcount(_kjTime, `type`, userid);
				 call betreport(_kjTime, userid);
			end if;

			-- 处理追号
			-- if _zjCount and zhuiHao=1 and zhuiHaoMode=1 then
				-- 如果是追号单子
				-- 并且中奖时停止追号的单子
				-- 给后续单子撤单
				-- call cancelBet(serializeId);
			-- end if;
		end if;
	end if;
	-- 提交事务
	commit;
	
end$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `pro_count` (`_date` VARCHAR(20))  begin
	
	declare fromTime int;
	declare toTime int;
	
	if not _date then
		set _date=date_add(curdate(), interval -1 day);
	end if;
	
	set toTime=unix_timestamp(_date);
	set fromTime=toTime-24*3600;
	
	insert into ssc_count(`type`, playedId, `date`, betCount, betAmount, zjAmount)
	select `type`, playedId, _date, sum(money), sum(bonus) from ssc_bets where kjTime between fromTime and toTime and isDelete=0 group by type, playedId
	on duplicate key update betCount=values(betCount), betAmount=values(betAmount), zjAmount=values(zjAmount);


end$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `pro_pay` ()  begin

	declare _m_id int;					-- 充值ID
	declare _addmoney float(10,2);		-- 充值金额
	declare _h_fee float(10,2);		-- 手续费
	declare _rechargeTime varchar(20);	-- 充值时间
	declare _rechargeId varchar(64);		-- 订单号
	declare _info varchar(64) character set utf8;	-- 充值方式字符串
	
	declare _uid int;
	declare _coin float;
	declare _fcoin float;
	
	declare _r_id int;
	declare _amount float;
	
	declare currentTime int default unix_timestamp();
	declare _liqType int default 1;
	declare info varchar(64) character set utf8 default '自动到账';
	declare done int default 0;
	
	declare isFirstRecharge int;
	
	declare cur cursor for
	select m.id, m.addmoney, m.h_fee, m.o_time, m.u_id, m.memo,		u.`uid`, u.coin, u.fcoin,		r.id, r.amount from ssc_members u, my18_pay m, ssc_member_recharge r where u.`uid`=r.`uid` and r.rechargeId=m.u_id and m.`state`=0 and r.`state`=0 and r.isDelete=0;
	declare continue HANDLER for not found set done = 1;

	start transaction;
		open cur;
			repeat
				fetch cur into _m_id, _addmoney, _h_fee, _rechargeTime, _rechargeId, _info, _uid, _coin, _fcoin, _r_id, _amount;
				
				if not done then
					-- select _r_id;
					-- if _amount=_addmoney then
						call setCoin(_addmoney, 0, _uid, _liqType, 0, info, _r_id, _rechargeId, '');
						if _h_fee>0 then
							call setCoin(_h_fee, 0, _uid, _liqType, 0, '充值手续费', _r_id, _rechargeId, '');
						end if;
						update ssc_member_recharge set rechargeAmount=_addmoney+_h_fee, coin=_coin, fcoin=_fcoin, rechargeTime=currentTime, `state`=2, `info`=info where id=_r_id;
						update my18_pay set `state`=1 where id=_m_id;
						
						-- 每天首次充值上家赠送充值佣金
						call isFirstRechargeCom(_uid, isFirstRecharge);
						if isFirstRecharge then
							call setRechargeCom(_addmoney, _uid, _r_id, _rechargeId);
						end if;
					-- else
						-- update my18_pay set `state`=2 where id=_m_id;
					-- end if;
				end if;
				
			until done end repeat;
		close cur;
	commit;
	
	
end$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `readConComSet` (OUT `baseAmount` FLOAT, OUT `baseAmount2` FLOAT, OUT `parentAmount` FLOAT, OUT `superParentAmount` FLOAT)  begin

	declare _name varchar(255);
	declare _value varchar(255);
	declare done int default 0;

	declare cur cursor for
	select name, `value` from ssc_params where name in('conCommissionBase', 'conCommissionBase2', 'conCommissionParentAmount', 'conCommissionParentAmount2');
	declare continue HANDLER for not found set done=1;

	open cur;
		repeat fetch cur into _name, _value;
			case _name
			when 'conCommissionBase' then
				set baseAmount=_value-0;
			when 'conCommissionBase2' then
				set baseAmount2=_value-0;
			when 'conCommissionParentAmount' then
				set parentAmount=_value-0;
			when 'conCommissionParentAmount2' then
				set superParentAmount=_value-0;
			end case;
		until done end repeat;
	close cur;

end$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `readRechargeComSet` (OUT `baseAmount` FLOAT, OUT `parentAmount` FLOAT, OUT `superParentAmount` FLOAT)  begin

	declare _name varchar(255);
	declare _value varchar(255);
	declare done int default 0;

	declare cur cursor for
	select name, `value` from ssc_params where name in('rechargeCommissionAmount', 'rechargeCommission', 'rechargeCommission2');
	declare continue HANDLER for not found set done=1;

	open cur;
		repeat fetch cur into _name, _value;
			case _name
			when 'rechargeCommissionAmount' then
				set baseAmount=_value-0;
			when 'rechargeCommission' then
				set parentAmount=_value-0;
			when 'rechargeCommission2' then
				set superParentAmount=_value-0;
			end case;
		until done end repeat;
	close cur;

end$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `setCoin` (`_coin` FLOAT, `_fcoin` FLOAT, `_uid` INT, `_liqType` INT, `_type` INT, `_info` VARCHAR(255) CHARACTER SET utf8, `_extfield0` INT, `_extfield1` VARCHAR(255) CHARACTER SET utf8, `_extfield2` VARCHAR(255) CHARACTER SET utf8)  begin
	
	-- 当前时间
	DECLARE currentTime INT DEFAULT UNIX_TIMESTAMP();
	DECLARE _userCoin FLOAT;
	DECLARE _count INT  DEFAULT 0;
	-- select _coin, _fcoin, _liqType, _info;
	IF _coin IS NULL THEN
		SET _coin=0;
	END IF;
	IF _fcoin IS NULL THEN
		SET _fcoin=0;
	END IF;
	-- 更新用户表
	SELECT COUNT(1) INTO _count FROM ssc_coin_log WHERE  extfield0=_extfield0  AND info='中奖奖金'  AND `uid`=_uid;
	IF  _count<1 THEN
	UPDATE ssc_members SET coin = coin + _coin, fcoin = fcoin + _fcoin WHERE `uid` = _uid;
	SELECT coin INTO _userCoin FROM ssc_members WHERE `uid`=_uid;
	-- 添加资金流动日志
	INSERT INTO ssc_coin_log(coin, fcoin, userCoin, `uid`, actionTime, liqType, `type`, info, extfield0, extfield1, extfield2) VALUES(_coin, _fcoin, _userCoin, _uid, currentTime, _liqType, _type, _info, _extfield0, _extfield1, _extfield2);
	END IF;
	-- select coin, fcoin from ssc_members where `uid`=_uid;

end$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `setDLFanDian` (`amount` FLOAT, INOUT `_fanDian` FLOAT, INOUT `_parentId` INT, `_type` INT, `srcBetId` INT, `srcUid` INT, INOUT `srcUserName` VARCHAR(255))  begin
	
	declare p_parentId int;		-- 上级的上级
	declare p_fanDian float;	-- 上级返点
	declare p_username varchar(64);
	
	-- declare liqType int default 3;
	declare liqType int default 2;
	declare info varchar(255) character set utf8;
	
	declare done int default 0;
	declare cur cursor for
	select fanDian, uid, username from ssc_members where `uid`=_parentId;
	declare continue HANDLER for not found set done = 1;

	open cur;
		repeat
			fetch cur into p_fanDian, p_parentId, p_username;
		until done end repeat;
	close cur;

	if p_fanDian > _fanDian then
		set info=concat('下家[', cast(srcUserName as char), ']投注返点');
		call setCoin(amount * (p_fanDian - _fanDian) / 100, 0, _parentId, liqType, _type, info, srcBetId, srcUid, srcUserName);
	end if;
	
	set _parentId=p_parentId;
	set _fanDian=p_fanDian;
	set srcUserName=concat(p_username, '<=', srcUserName);
	
end$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `setGDFanDian` (`amount` FLOAT, INOUT `_fanDian` FLOAT, INOUT `_gudongId` INT, `_type` INT, `srcBetId` INT, `srcUid` INT, INOUT `srcUserName` VARCHAR(255))  begin
	
	declare p_gudongId int;		-- 上级的上级
	declare p_fanDian float;	-- 上级返点
	declare p_username varchar(64);
	
	declare liqType int default 3;
	-- declare liqType int default 2;
	declare info varchar(255) character set utf8;
	
	declare done int default 0;
	declare cur cursor for
	select fanDian, uid, username from ssc_members where `uid`=_gudongId;
	declare continue HANDLER for not found set done = 1;

	open cur;
		repeat
			fetch cur into p_fanDian, p_gudongId, p_username;
		until done end repeat;
	close cur;

	if p_fanDian > _fanDian then
		set info=concat('下家[', cast(srcUserName as char), ']投注返点');
		call setCoin(amount * (p_fanDian - _fanDian) / 100, 0, _gudongId, liqType, _type, info, srcBetId, srcUid, srcUserName);
	end if;
	
	set _gudongId=p_gudongId;
	set _fanDian=p_fanDian;
	set srcUserName=concat(p_username, '<=', srcUserName);
	
end$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `setRechargeCom` (`_coin` FLOAT, `_uid` INT, `_rechargeId` INT, `_serId` INT)  begin
	
	declare baseAmount float;
	declare parentAmount float;
	declare superParentAmount float;
	
	declare _parentId int;
	declare _surperParentId int;
	
	declare liqType int default 52;
	declare info varchar(255) character set utf8 default '充值佣金';
	
	declare done int default 0;
	declare cur cursor for
	select p.`uid`, p.parentId from ssc_members p, ssc_members u where p.`uid`=u.parentId and u.`uid`=_uid;
	declare continue HANDLER for not found set done=1;
	
	call readRechargeComSet(baseAmount, parentAmount, superParentAmount);
	
	open cur;
		repeat fetch cur into _parentId, _surperParentId;
			if not done then
				if _parentId then
					call setCoin(parentAmount, 0, _parentId, liqType, 0, info, _rechargeId, _serId, '');
				end if;
				
				if _surperParentId then
					call setCoin(superParentAmount, 0, _surperParentId, liqType, 0, info, _rechargeId, _serId, '');
				end if;
			end if;
		until done end repeat;
	close cur;
	
end$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `setZDLFanDian` (`amount` FLOAT, INOUT `_fanDian` FLOAT, INOUT `_zparentId` INT, `_type` INT, `srcBetId` INT, `srcUid` INT, INOUT `srcUserName` VARCHAR(255))  begin
	
	declare p_zparentId int;		-- 上级的上级
	declare p_fanDian float;	-- 上级返点
	declare p_username varchar(64);
	
	declare liqType int default 3;
	-- declare liqType int default 2;
	declare info varchar(255) character set utf8;
	
	declare done int default 0;
	declare cur cursor for
	select fanDian, uid, username from ssc_members where `uid`=_zparentId;
	declare continue HANDLER for not found set done = 1;

	open cur;
		repeat
			fetch cur into p_fanDian, p_zparentId, p_username;
		until done end repeat;
	close cur;

	if p_fanDian > _fanDian then
		set info=concat('下家[', cast(srcUserName as char), ']投注返点');
		call setCoin(amount * (p_fanDian - _fanDian) / 100, 0, _zparentId, liqType, _type, info, srcBetId, srcUid, srcUserName);
	end if;
	
	set _zparentId=p_zparentId;
	set _fanDian=p_fanDian;
	set srcUserName=concat(p_username, '<=', srcUserName);
	
end$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `summarizeData` (`_type` INT, `_issue` VARCHAR(32))  begin

  declare _billCount int(5) DEFAULT 0;
  declare _pjed int(5) DEFAULT 0;
  declare _zjCount int(5) DEFAULT 0;
  declare _userCount int(5) DEFAULT 0;

  declare _betAmount double(18,4) DEFAULT 0.0000;
  declare _zjAmount double(18,4) DEFAULT 0.0000;
  declare _fanDianAmount double(18,4) DEFAULT 0.0000;
	
	select count(*) into _billCount from ssc_bets where isDelete=0 and type=_type and actionNo=_issue;
	select count(*) into _pjed from ssc_bets where isDelete=0 and type=_type and actionNo=_issue and lotteryNo!='';
	select count(*) into _zjCount from ssc_bets where isDelete=0 and type=_type and actionNo=_issue and zjCount>0;
	select count(b.uid) into _userCount from (select uid from ssc_bets where isDelete=0 and type=_type and actionNo=_issue group by uid) b;

	select sum(amount) into _betAmount from ssc_bets where isDelete=0 and type=_type and actionNo=_issue;
	select sum(bonus) into _zjAmount from ssc_bets where isDelete=0 and type=_type and actionNo=_issue;
	select sum(fanDianAmount) into _fanDianAmount from ssc_bets where isDelete=0 and type=_type and actionNo=_issue;

	update ssc_data set billCount=_billCount, pjed=_pjed, zjCount=_zjCount, userCount=_userCount, betAmount=_betAmount, zjAmount=_zjAmount, fanDianAmount=_fanDianAmount where type=_type and number=_issue;
end$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `summarizePlatform` (`_date` INT(8))  begin

  declare _billCount int(5) DEFAULT 0;
  declare _pjed int(5) DEFAULT 0;
  declare _zjCount int(5) DEFAULT 0;
  declare _userCount int(5) DEFAULT 0;

  declare _betAmount double(18,4) DEFAULT 0.0000;
  declare _zjAmount double(18,4) DEFAULT 0.0000;
  declare _fanDianAmount double(18,4) DEFAULT 0.0000;
	
	select count(*) into _billCount from ssc_bets where isDelete=0 and type=_type and actionNo=_issue;
	select count(*) into _pjed from ssc_bets where isDelete=0 and type=_type and actionNo=_issue and lotteryNo!='';
	select count(*) into _zjCount from ssc_bets where isDelete=0 and type=_type and actionNo=_issue and zjCount>0;
	select count(b.uid) into _userCount from (select uid from ssc_bets where isDelete=0 and type=_type and actionNo=_issue group by uid) b;

	select sum(amount) into _betAmount from ssc_bets where isDelete=0 and type=_type and actionNo=_issue;
	select sum(bonus) into _zjAmount from ssc_bets where isDelete=0 and type=_type and actionNo=_issue;
	select sum(fanDianAmount) into _fanDianAmount from ssc_bets where isDelete=0 and type=_type and actionNo=_issue;

	update ssc_data set billCount=_billCount, pjed=_pjed, zjCount=_zjCount, userCount=_userCount, betAmount=_betAmount, zjAmount=_zjAmount, fanDianAmount=_fanDianAmount where type=_type and number=_issue;
end$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `summarizePlayed` (`_date` INT(8), `_type` TINYINT(3), `_played` INT(11), `_issue` VARCHAR(32))  begin

  declare _pri int(11) DEFAULT 0;
  
	declare _betCount int(5) DEFAULT 0;
  declare _betAmount double(15,4) DEFAULT 0.0000;
  declare _zjAmount double(15,4) DEFAULT 0.0000;
  declare _fanDianAmount double(15,4) DEFAULT 0.0000;
	
	select id into _pri from ssc_played_daily_count where date=_date and type=_type and played=_played;
	
	if _pri=0 or _pri is null THEN
		insert into ssc_played_daily_count (date, type, played) values(_date, _type, _played);
		select id into _pri from ssc_played_daily_count where date=_date and type=_type and played=_played;
	end if;

-- 统计有效方案数

	select count(*) into _betCount from ssc_bets where isDelete=0 and type=_type and playedId=_played and lotteryNo!='';
	
-- 统计总投注额
	select sum(money) into _betAmount from ssc_bets where isDelete=0 and type=_type and playedId=_played and lotteryNo!='';
-- 统计总中奖额
	select sum(bonus) into _zjAmount from ssc_bets where isDelete=0 and type=_type and playedId=_played and lotteryNo!='';
-- 统计总返点额
	select sum(fanDianAmount) into _fanDianAmount from ssc_bets where isDelete=0 and type=_type and playedId=_played and lotteryNo!='';
	
	
-- 对空值赋默认值，增强稳定性

	if _betCount is null THEN
		set _betCount = 0;
	end if;

	if _betAmount is null THEN
		set _betAmount = 0;
	end if;
	if _zjAmount is null THEN
		set _zjAmount = 0;
	end if;
	if _fanDianAmount is null THEN
		set _fanDianAmount = 0;
	end if;


-- 更新到数据库
	update ssc_played_daily_count set betCount=_betCount, betAmount=_betAmount, zjAmount=_zjAmount, fanDianAmount=_fanDianAmount where id=_pri;
end$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `userallreport_copy` (`_date` INT(8), `_type` TINYINT(3), `_uid` INT(10))  begin

  declare _pri int(11) DEFAULT 0;
  
	declare _betCount int(5) DEFAULT 0;
  declare _betAmount double(15,4) DEFAULT 0.0000;
  declare _zjAmount double(15,4) DEFAULT 0.0000;
  declare _fanDianAmount double(15,4) DEFAULT 0.0000;
	
	select id into _pri from ssc_count where date=_date and type=_type;
	
	if _pri=0 or _pri is null THEN
		insert into ssc_count (date, type) values(_date, _type);
		select id into _pri from ssc_count where date=_date and type=_type;
	end if;

-- 统计有效方案数

	select count(*) into _betCount from ssc_bets where isDelete=0 and type=_type and lotteryNo!='';
	
-- 统计总投注额
	select sum(money) into _betAmount from ssc_bets where isDelete=0 and type=_type and lotteryNo!='';
-- 统计总中奖额
	select sum(bonus) into _zjAmount from ssc_bets where isDelete=0 and type=_type and lotteryNo!='';
-- 统计总返点额
	select sum(fanDianAmount) into _fanDianAmount from ssc_bets where isDelete=0 and type=_type and lotteryNo!='';
	
	
-- 对空值赋默认值，增强稳定性

	if _betCount is null THEN
		set _betCount = 0;
	end if;

	if _betAmount is null THEN
		set _betAmount = 0;
	end if;
	if _zjAmount is null THEN
		set _zjAmount = 0;
	end if;
	if _fanDianAmount is null THEN
		set _fanDianAmount = 0;
	end if;


-- 更新到数据库
	update ssc_count set betCount=_betCount, betAmount=_betAmount, zjAmount=_zjAmount where id=_pri;
end$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `userallreport_copy1` (`_date` INT(8), `_type` TINYINT(3), `_uid` INT(10))  begin

	declare _pri int(11) DEFAULT 0; 
	declare _betCount int(5) DEFAULT 0;
	declare _betAmount double(15,4) DEFAULT 0.0000;
	declare _zjAmount double(15,4) DEFAULT 0.0000;
	declare _rebateMoney double(15,4) DEFAULT 0.0000;
	declare _username VARCHAR(16) DEFAULT null;
	declare _gudongId int(10) DEFAULT 0; 
	declare _zparentId int(10) DEFAULT 0; 
	declare _parentId int(10) DEFAULT 0; 

	if _uid then

	select id into _pri from ssc_count where date=_date and uid=__uid and type=_type;
	
	if _pri=0 or _pri is null THEN
		insert into ssc_count (date, uid) values(_date, _uid);
		select id into _pri from ssc_count where date=_date and uid=_uid and type=_type;
	end if;

-- 统计有效方案数

	select count(*) into _betCount from ssc_bets where isDelete=0 and uid=_uid and lotteryNo!='' and type=_type;
	
-- 统计总投注额
	select sum(money) into _betAmount from ssc_bets where isDelete=0 and uid=_uid and lotteryNo!='' and type=_type;
-- 统计总中奖额
	select sum(bonus) into _zjAmount from ssc_bets where isDelete=0 and uid=_uid and lotteryNo!='' and type=_type;
-- 统计总退水额
	select sum(rebateMoney) into _rebateMoney from ssc_bets where isDelete=0 and uid=_uid and lotteryNo!='' and type=_type;
	-- 查询用户信息
	select uid into _uid from ssc_members where isDelete=0 and uid=_uid;
	select username into _username from ssc_members where isDelete=0 and uid=_uid;
	select gudongId into _gudongId from ssc_members where isDelete=0 and uid=_uid;
	select zparentId into _zparentId from ssc_members where isDelete=0 and uid=_uid;	
	select parentId into _parentId from ssc_members where isDelete=0 and uid=_uid;
-- 对空值赋默认值，增强稳定性

	if _betCount is null THEN
		set _betCount = 0;
	end if;

	if _betAmount is null THEN
		set _betAmount = 0;
	end if;
	if _zjAmount is null THEN
		set _zjAmount = 0;
	end if;
	if _rebateMoney is null THEN
		set _rebateMoney = 0;
	end if;


-- 更新到数据库
	update ssc_count set betCount=_betCount, betAmount=_betAmount, zjAmount=_zjAmount, rebateMoney=_rebateMoney, username=_username, uid=_uid, gudongId=_gudongId, zparentId=_zparentId, parentId=_parentId where id=_pri;
	end if;

end$$

DELIMITER ;

-- --------------------------------------------------------

--
-- 表的结构 `codepay_order`
--

CREATE TABLE `codepay_order` (
  `id` int(11) UNSIGNED NOT NULL,
  `pay_id` varchar(50) NOT NULL COMMENT '用户ID或订单ID',
  `money` decimal(6,2) UNSIGNED NOT NULL COMMENT '实际金额',
  `price` decimal(6,2) UNSIGNED NOT NULL COMMENT '原价',
  `type` int(1) NOT NULL DEFAULT '1' COMMENT '支付方式',
  `pay_no` varchar(100) NOT NULL COMMENT '流水号',
  `param` varchar(200) DEFAULT NULL COMMENT '自定义参数',
  `pay_time` bigint(11) NOT NULL DEFAULT '0' COMMENT '付款时间',
  `pay_tag` varchar(100) DEFAULT NULL COMMENT '金额的备注',
  `status` int(1) NOT NULL DEFAULT '0' COMMENT '订单状态',
  `creat_time` bigint(11) NOT NULL DEFAULT '0' COMMENT '创建时间',
  `up_time` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间'
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COMMENT='用于区分是否已经处理' ROW_FORMAT=COMPACT;

--
-- 转存表中的数据 `codepay_order`
--

INSERT INTO `codepay_order` (`id`, `pay_id`, `money`, `price`, `type`, `pay_no`, `param`, `pay_time`, `pay_tag`, `status`, `creat_time`, `up_time`) VALUES
(1, '1', '18.00', '18.00', 1, '', '', 0, '保证金', 0, 1530430894, '2018-06-30 23:41:34'),
(3, '1', '18.00', '18.00', 1, '1530430926', NULL, 1530430926, NULL, 0, 1530430926, '2018-06-30 23:42:06'),
(5, '1', '18.00', '18.00', 3, '1530431883', NULL, 1530431883, NULL, 0, 1530431883, '2018-06-30 23:58:03'),
(6, '1', '18.00', '18.00', 3, '', '', 0, '保证金', 0, 1530431883, '2018-06-30 23:58:03'),
(7, '1', '18.00', '18.00', 1, '1530435149', NULL, 1530435149, NULL, 0, 1530435149, '2018-07-01 00:52:29'),
(9, '1', '18.00', '18.00', 1, '1530435438', NULL, 1530435438, NULL, 0, 1530435438, '2018-07-01 00:57:18'),
(11, '20164', '18.00', '18.00', 1, '1530438864', NULL, 1530438864, NULL, 0, 1530438864, '2018-07-01 01:54:24');

-- --------------------------------------------------------

--
-- 表的结构 `ds_access`
--

CREATE TABLE `ds_access` (
  `role_id` smallint(6) UNSIGNED NOT NULL,
  `node_id` smallint(6) UNSIGNED NOT NULL,
  `level` tinyint(1) NOT NULL,
  `module` varchar(50) DEFAULT NULL
) ENGINE=MyISAM AVG_ROW_LENGTH=20 DEFAULT CHARSET=utf8 ROW_FORMAT=COMPACT;

--
-- 转存表中的数据 `ds_access`
--

INSERT INTO `ds_access` (`role_id`, `node_id`, `level`, `module`) VALUES
(1, 41, 3, NULL),
(1, 42, 3, NULL),
(1, 46, 3, NULL),
(1, 25, 3, NULL),
(1, 31, 3, NULL),
(1, 32, 3, NULL),
(1, 12, 3, NULL),
(2, 1, 1, NULL),
(2, 16, 3, NULL),
(2, 37, 3, NULL),
(2, 18, 3, NULL),
(2, 19, 3, NULL),
(2, 35, 3, NULL);

-- --------------------------------------------------------

--
-- 表的结构 `ds_ad`
--

CREATE TABLE `ds_ad` (
  `id` smallint(5) UNSIGNED NOT NULL,
  `name` varchar(50) NOT NULL,
  `pic` varchar(255) NOT NULL,
  `unit` decimal(5,2) UNSIGNED NOT NULL DEFAULT '0.00',
  `money` decimal(10,2) UNSIGNED NOT NULL DEFAULT '0.00',
  `time` smallint(5) UNSIGNED NOT NULL DEFAULT '0',
  `url` varchar(255) NOT NULL,
  `level` varchar(20) NOT NULL,
  `count` int(10) UNSIGNED NOT NULL DEFAULT '0',
  `status` tinyint(3) UNSIGNED NOT NULL DEFAULT '0',
  `addtime` int(11) UNSIGNED NOT NULL DEFAULT '0'
) ENGINE=MyISAM DEFAULT CHARSET=utf8 ROW_FORMAT=COMPACT;

-- --------------------------------------------------------

--
-- 表的结构 `ds_adpoint`
--

CREATE TABLE `ds_adpoint` (
  `id` int(10) UNSIGNED NOT NULL,
  `member` varchar(20) NOT NULL,
  `money` decimal(11,2) UNSIGNED NOT NULL DEFAULT '0.00',
  `info` mediumtext NOT NULL,
  `time` int(11) UNSIGNED NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8 ROW_FORMAT=COMPACT;

-- --------------------------------------------------------

--
-- 表的结构 `ds_announce`
--

CREATE TABLE `ds_announce` (
  `id` int(10) UNSIGNED NOT NULL,
  `title` char(60) NOT NULL DEFAULT '' COMMENT '公告标题',
  `content` text NOT NULL COMMENT '公告内容',
  `operator` varchar(45) NOT NULL DEFAULT '' COMMENT '发布人',
  `addtime` int(10) UNSIGNED NOT NULL DEFAULT '0' COMMENT '添加时间',
  `edittime` int(10) UNSIGNED NOT NULL DEFAULT '0' COMMENT '修改时间',
  `viewer` varchar(10) NOT NULL DEFAULT 'all' COMMENT '查看权限 all:所有人  member:会员  center:报单中心 ',
  `tid` int(10) UNSIGNED NOT NULL COMMENT '公告类别ID'
) ENGINE=MyISAM AVG_ROW_LENGTH=755 DEFAULT CHARSET=utf8 COMMENT='公告信息表' ROW_FORMAT=COMPACT;

--
-- 转存表中的数据 `ds_announce`
--

INSERT INTO `ds_announce` (`id`, `title`, `content`, `operator`, `addtime`, `edittime`, `viewer`, `tid`) VALUES
(128, '矿工公会', '<p class=\"MsoNormal\">\r\n	<br />\r\n</p>\r\n<p class=\"MsoNormal\">\r\n	<span>青铜矿工</span>&nbsp;<span>直推</span><span>10</span><span>人团队</span><span>60</span><span>人 公会算力</span><span>50G </span><span>（或</span><span>5</span><span>台钻石矿机）</span><span>交易手续费</span><span>27% </span><span>团队总提成 </span><span>11%</span> \r\n</p>\r\n<p class=\"MsoNormal\">\r\n	<br />\r\n</p>\r\n<p class=\"MsoNormal\">\r\n	<span>白银矿工</span> <span>直推</span>30<span>人团队</span><span>150</span><span>公会算力</span><span>300G</span><span>（或</span><span>30</span><span>台钻石矿机） </span><span>&nbsp;</span><span>交易手续</span><span>24% </span><span>团队总提成：</span><span>15%</span> \r\n</p>\r\n<p class=\"MsoNormal\">\r\n	<br />\r\n</p>\r\n<p class=\"MsoNormal\">\r\n	<span>黄金矿工</span> &nbsp;<span>直推</span><span>50</span><span>人团队</span><span>1000 </span><span>公会算力</span><span>1500G</span><span>（或</span><span>150</span><span>台钻石矿机）</span><span>交易手续费</span><span>21% </span><span>团队总提成</span><span>18%</span> \r\n</p>\r\n<p class=\"MsoNormal\">\r\n	<br />\r\n</p>\r\n<p class=\"MsoNormal\">\r\n	<span>铂金矿工</span> <span>直推</span>80<span>人 团队</span><span>3000</span><span>公会算力</span><span>5000G</span><span>（或</span><span>500</span><span>台钻石矿机） </span><span>交易手续费</span><span>18% </span><span>团队总提成</span><span>20%</span> \r\n</p>\r\n<p class=\"MsoNormal\">\r\n	<span>钻石矿工</span> <span>直推</span>100 <span>团队</span><span>5000 </span><span>公会算力</span><span>10000G</span><span>（</span><span>1000</span><span>台钻石矿机） </span><span>交易手续费</span><span>15% </span><span>团队总提成</span><span>21%</span> \r\n</p>', 'admin', 1528559294, 1529807413, 'all', 10),
(133, 'CTC区块链新闻', '<span style=\"color:#E53333;\">&nbsp; &nbsp; &nbsp; 开普钻石区块链2018年7月全球震撼起航，6月12日大中华区众筹开启，7月8日全球同步开盘，开盘价0.15美元（人民币1.05元）诚邀各大团队领导对接中，财富盛宴即将开启！</span>', 'admin', 1528611547, 1528611736, 'all', 3),
(134, '天使C轮天使众筹', '开普钻石链6月29日正式开启天使C轮众筹，限量发行800万，价格0.13美元（人民币）0.91元，每名会员认购额度为100个至5万个！', 'admin', 1528758168, 1530250121, 'all', 3),
(135, '开普钻石链技术,将惠及全球亿万钻石用户', '<a href=\"https://www.baidu.com/from=844b/bd_page_type=1/ssid=0/uid=0/pu=usm%402%2Csz%401320_2001%2Cta%40iphone_1_11.4_3_605/baiduid=168F7D40B180E0FC43435A8E5790205B/w=0_10_/t=iphone/l=3/tc?ref=www_iphone&lid=12776121699009595403&order=3&fm=alop&tj=www_normal_3_0_10_title&vit=osres&m=8&srd=1&cltj=cloud_title&asres=1&title=开普钻石链技术%2C将惠及全球亿万钻石用户&dict=32&wd=&eqid=b14de6fe94a08800100000035b26fa4d&w_qd=IlPT2AEptyoA_yk553Abseq6DV-UnX1btUi&tcplug=1&sec=30600&di=b4b233c1931e6f3f&bdenc=1&tch=124.401.338.470.1.16&nsrc=IlPT2AEptyoA_yixCFOxXnANedT62v3IDgG2BHUAOnTnz-TisaWrVQAoXCb7Ln7NXUbbwyyBfwoDlibuKCMz7qQPe358xmdN888cbPbxbM8_U1e&clk_info=%7B%22srcid%22%3A1599%2C%22tplname%22%3A%22www_normal%22%2C%22t%22%3A1529281107647%2C%22xpath%22%3A%22div-a-h3%22%7D&sfOpen=1\" target=\"_blank\">https://www.baidu.com/from=844b/bd_page_type=1/ssid=0/uid=0/pu=usm%402%2Csz%401320_2001%2Cta%40iphone_1_11.4_3_605/baiduid=168F7D40B180E0FC43435A8E5790205B/w=0_10_/t=iphone/l=3/tc?ref=www_iphone&amp;lid=12776121699009595403&amp;order=3&amp;fm=alop&amp;tj=www_normal_3_0_10_title&amp;vit=osres&amp;m=8&amp;srd=1&amp;cltj=cloud_title&amp;asres=1&amp;title=开普钻石链技术%2C将惠及全球亿万钻石用户&amp;dict=32&amp;wd=&amp;eqid=b14de6fe94a08800100000035b26fa4d&amp;w_qd=IlPT2AEptyoA_yk553Abseq6DV-UnX1btUi&amp;tcplug=1&amp;sec=30600&amp;di=b4b233c1931e6f3f&amp;bdenc=1&amp;tch=124.401.338.470.1.16&amp;nsrc=IlPT2AEptyoA_yixCFOxXnANedT62v3IDgG2BHUAOnTnz-TisaWrVQAoXCb7Ln7NXUbbwyyBfwoDlibuKCMz7qQPe358xmdN888cbPbxbM8_U1e&amp;clk_info=%7B%22srcid%22%3A1599%2C%22tplname%22%3A%22www_normal%22%2C%22t%22%3A1529281107647%2C%22xpath%22%3A%22div-a-h3%22%7D&amp;sfOpen=1</a>', 'admin', 1529281076, 1529281076, 'member', 3),
(136, '区块链', '<h1>\r\n	\r\n</h1>\r\n<h1 style=\"font-size:34px;font-weight:400;vertical-align:sub;\">\r\n</h1>', 'admin', 1530539033, 1564138745, 'all', 3);

-- --------------------------------------------------------

--
-- 表的结构 `ds_announcetype`
--

CREATE TABLE `ds_announcetype` (
  `id` int(10) UNSIGNED NOT NULL COMMENT '类别ID',
  `name` varchar(45) NOT NULL DEFAULT ''
) ENGINE=MyISAM AVG_ROW_LENGTH=24 DEFAULT CHARSET=utf8 COMMENT='公告类别' ROW_FORMAT=COMPACT;

--
-- 转存表中的数据 `ds_announcetype`
--

INSERT INTO `ds_announcetype` (`id`, `name`) VALUES
(3, '公司公告'),
(7, '帮助中心'),
(10, '通知'),
(12, '新闻资讯');

-- --------------------------------------------------------

--
-- 表的结构 `ds_announce_click`
--

CREATE TABLE `ds_announce_click` (
  `id` int(11) UNSIGNED NOT NULL,
  `user_id` int(11) NOT NULL,
  `news_id` int(11) NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8 ROW_FORMAT=COMPACT;

--
-- 转存表中的数据 `ds_announce_click`
--

INSERT INTO `ds_announce_click` (`id`, `user_id`, `news_id`) VALUES
(131335, 1, 128),
(131336, 2, 128),
(131337, 4, 128),
(131338, 5, 128),
(131340, 6, 128),
(131342, 7, 128),
(131345, 4, 133),
(131346, 2, 133),
(131347, 8, 133),
(131348, 8, 128),
(131350, 7, 133),
(131351, 1, 133),
(131352, 20000, 133),
(131353, 20000, 128),
(131355, 20002, 133),
(131356, 20002, 128),
(131358, 20003, 133),
(131359, 20003, 128),
(131361, 20001, 133),
(131362, 20001, 128),
(131364, 20005, 133),
(131365, 20005, 128),
(131367, 20004, 133),
(131368, 20004, 128),
(131370, 20006, 133),
(131371, 20006, 128),
(131373, 20010, 133),
(131374, 20010, 128),
(131376, 20008, 133),
(131377, 20008, 128),
(131379, 20007, 133),
(131380, 20007, 128),
(131382, 20000, 134),
(131383, 20006, 134),
(131384, 20001, 134),
(131385, 20013, 134),
(131386, 20013, 133),
(131387, 20013, 128),
(131389, 20014, 134),
(131390, 20014, 133),
(131391, 20014, 128),
(131393, 20015, 134),
(131394, 20015, 133),
(131395, 20015, 128),
(131397, 20007, 134),
(131398, 20018, 134),
(131399, 20018, 133),
(131400, 20018, 128),
(131402, 20019, 134),
(131403, 20019, 133),
(131404, 20019, 128),
(131406, 20008, 134),
(131407, 20010, 134),
(131408, 20016, 134),
(131409, 20016, 133),
(131410, 20016, 128),
(131412, 20021, 134),
(131413, 20021, 133),
(131414, 20021, 128),
(131416, 20022, 134),
(131417, 20022, 133),
(131418, 20022, 128),
(131420, 20023, 134),
(131421, 20023, 133),
(131422, 20023, 128),
(131424, 20026, 134),
(131425, 20026, 133),
(131426, 20026, 128),
(131428, 20002, 134),
(131429, 20003, 134),
(131430, 20024, 134),
(131431, 20024, 133),
(131432, 20024, 128),
(131434, 20004, 134),
(131435, 20030, 134),
(131436, 20030, 133),
(131437, 20030, 128),
(131439, 20031, 134),
(131440, 20031, 133),
(131441, 20031, 128),
(131443, 20034, 134),
(131444, 20034, 133),
(131445, 20034, 128),
(131447, 20035, 134),
(131448, 20035, 133),
(131449, 20035, 128),
(131451, 20033, 134),
(131452, 20033, 133),
(131453, 20033, 128),
(131455, 20036, 134),
(131456, 20036, 133),
(131457, 20036, 128),
(131459, 20040, 134),
(131460, 20040, 133),
(131461, 20040, 128),
(131463, 20038, 134),
(131464, 20038, 133),
(131465, 20038, 128),
(131467, 20020, 134),
(131468, 20020, 133),
(131469, 20020, 128),
(131471, 20047, 134),
(131472, 20047, 133),
(131473, 20047, 128),
(131475, 20048, 134),
(131476, 20048, 133),
(131477, 20048, 128),
(131479, 20049, 134),
(131480, 20049, 133),
(131481, 20049, 128),
(131483, 20052, 134),
(131484, 20052, 133),
(131485, 20052, 128),
(131487, 20053, 134),
(131488, 20053, 133),
(131489, 20053, 128),
(131491, 20002, 135),
(131492, 20006, 135),
(131493, 20015, 135),
(131494, 20019, 135),
(131495, 20016, 135),
(131496, 20018, 135),
(131497, 20021, 135),
(131498, 20037, 135),
(131499, 20037, 134),
(131500, 20037, 133),
(131501, 20037, 128),
(131503, 20000, 135),
(131504, 20007, 135),
(131505, 20052, 135),
(131506, 20049, 135),
(131507, 20023, 135),
(131508, 20045, 135),
(131509, 20045, 134),
(131510, 20045, 133),
(131511, 20045, 128),
(131513, 20055, 135),
(131514, 20055, 134),
(131515, 20055, 133),
(131516, 20055, 128),
(131518, 20038, 135),
(131519, 20005, 135),
(131520, 20005, 134),
(131521, 20004, 135),
(131522, 20058, 135),
(131523, 20058, 134),
(131524, 20058, 133),
(131525, 20058, 128),
(131527, 20060, 135),
(131528, 20060, 134),
(131529, 20060, 133),
(131530, 20060, 128),
(131532, 20010, 135),
(131533, 20062, 135),
(131534, 20062, 134),
(131535, 20062, 133),
(131536, 20062, 128),
(131538, 20063, 135),
(131539, 20063, 134),
(131540, 20063, 133),
(131541, 20063, 128),
(131543, 20066, 135),
(131544, 20066, 134),
(131545, 20066, 133),
(131546, 20066, 128),
(131548, 20056, 135),
(131549, 20056, 134),
(131550, 20056, 133),
(131551, 20056, 128),
(131553, 20059, 135),
(131554, 20059, 134),
(131555, 20059, 133),
(131556, 20059, 128),
(131558, 20067, 135),
(131559, 20067, 134),
(131560, 20067, 133),
(131561, 20067, 128),
(131563, 20014, 135),
(131564, 20069, 135),
(131565, 20069, 134),
(131566, 20069, 133),
(131567, 20069, 128),
(131569, 20047, 135),
(131570, 20061, 135),
(131571, 20061, 134),
(131572, 20061, 133),
(131573, 20061, 128),
(131575, 20070, 135),
(131576, 20070, 134),
(131577, 20070, 133),
(131578, 20070, 128),
(131580, 20074, 135),
(131581, 20074, 134),
(131582, 20074, 133),
(131583, 20074, 128),
(131585, 20065, 135),
(131586, 20065, 134),
(131587, 20065, 133),
(131588, 20065, 128),
(131590, 20075, 135),
(131591, 20075, 134),
(131592, 20075, 133),
(131593, 20075, 128),
(131595, 20076, 135),
(131596, 20076, 134),
(131597, 20076, 133),
(131598, 20076, 128),
(131600, 20082, 135),
(131601, 20082, 134),
(131602, 20082, 133),
(131603, 20082, 128),
(131604, 20084, 135),
(131605, 20084, 134),
(131606, 20084, 133),
(131607, 20084, 128),
(131608, 20087, 135),
(131609, 20087, 134),
(131610, 20087, 133),
(131611, 20087, 128),
(131612, 20086, 135),
(131613, 20086, 134),
(131614, 20086, 133),
(131615, 20086, 128),
(131616, 20091, 135),
(131617, 20091, 134),
(131618, 20091, 133),
(131619, 20091, 128),
(131620, 20094, 135),
(131621, 20094, 134),
(131622, 20094, 133),
(131623, 20094, 128),
(131624, 20054, 135),
(131625, 20054, 134),
(131626, 20054, 133),
(131627, 20054, 128),
(131628, 20030, 135),
(131629, 20095, 135),
(131630, 20095, 134),
(131631, 20095, 133),
(131632, 20095, 128),
(131633, 20097, 135),
(131634, 20097, 134),
(131635, 20097, 133),
(131636, 20097, 128),
(131637, 20033, 135),
(131638, 20036, 135),
(131639, 20039, 135),
(131640, 20039, 134),
(131641, 20039, 133),
(131642, 20039, 128),
(131643, 20103, 135),
(131644, 20103, 134),
(131645, 20103, 133),
(131646, 20103, 128),
(131647, 20101, 135),
(131648, 20101, 134),
(131649, 20101, 133),
(131650, 20101, 128),
(131651, 20104, 135),
(131652, 20104, 134),
(131653, 20104, 133),
(131654, 20104, 128),
(131655, 20064, 135),
(131656, 20064, 134),
(131657, 20064, 133),
(131658, 20064, 128),
(131659, 20024, 135),
(131660, 20040, 135),
(131661, 20001, 135),
(131662, 20109, 135),
(131663, 20109, 134),
(131664, 20109, 133),
(131665, 20109, 128),
(131666, 20108, 135),
(131667, 20108, 134),
(131668, 20108, 133),
(131669, 20108, 128),
(131670, 20093, 135),
(131671, 20093, 134),
(131672, 20093, 133),
(131673, 20093, 128),
(131674, 20105, 135),
(131675, 20105, 134),
(131676, 20105, 133),
(131677, 20105, 128),
(131678, 20118, 135),
(131679, 20118, 134),
(131680, 20118, 133),
(131681, 20118, 128),
(131682, 20110, 135),
(131683, 20110, 134),
(131684, 20110, 133),
(131685, 20110, 128),
(131686, 20116, 135),
(131687, 20116, 134),
(131688, 20116, 133),
(131689, 20116, 128),
(131690, 20022, 135),
(131691, 20113, 135),
(131692, 20113, 134),
(131693, 20113, 133),
(131694, 20113, 128),
(131695, 20127, 135),
(131696, 20127, 134),
(131697, 20127, 133),
(131698, 20127, 128),
(131699, 20135, 135),
(131700, 20135, 134),
(131701, 20135, 133),
(131702, 20135, 128),
(131703, 20072, 135),
(131704, 20072, 134),
(131705, 20072, 133),
(131706, 20072, 128),
(131707, 20140, 135),
(131708, 20140, 134),
(131709, 20140, 133),
(131710, 20140, 128),
(131711, 20142, 135),
(131712, 20142, 134),
(131713, 20142, 133),
(131714, 20142, 128),
(131715, 20139, 135),
(131716, 20139, 134),
(131717, 20139, 133),
(131718, 20139, 128),
(131719, 20143, 135),
(131720, 20143, 134),
(131721, 20143, 133),
(131722, 20143, 128),
(131723, 20031, 135),
(131724, 20147, 135),
(131725, 20147, 134),
(131726, 20147, 133),
(131727, 20147, 128),
(131728, 20083, 135),
(131729, 20083, 134),
(131730, 20083, 133),
(131731, 20083, 128),
(131732, 20148, 135),
(131733, 20148, 134),
(131734, 20148, 133),
(131735, 20148, 128),
(131736, 20145, 135),
(131737, 20145, 134),
(131738, 20145, 133),
(131739, 20145, 128),
(131740, 20137, 135),
(131741, 20137, 134),
(131742, 20137, 133),
(131743, 20137, 128),
(131744, 20151, 135),
(131745, 20151, 134),
(131746, 20151, 133),
(131747, 20151, 128),
(131748, 20152, 135),
(131749, 20152, 134),
(131750, 20152, 133),
(131751, 20152, 128),
(131752, 20136, 135),
(131753, 20136, 134),
(131754, 20136, 133),
(131755, 20136, 128),
(131756, 20153, 135),
(131757, 20153, 134),
(131758, 20153, 133),
(131759, 20153, 128),
(131760, 20155, 135),
(131761, 20155, 134),
(131762, 20155, 133),
(131763, 20155, 128),
(131764, 20157, 135),
(131765, 20157, 134),
(131766, 20157, 133),
(131767, 20157, 128),
(131768, 20156, 135),
(131769, 20156, 134),
(131770, 20156, 133),
(131771, 20156, 128),
(131772, 20159, 135),
(131773, 20159, 134),
(131774, 20159, 133),
(131775, 20159, 128),
(131776, 20163, 135),
(131777, 20163, 134),
(131778, 20163, 133),
(131779, 20163, 128),
(131780, 1, 135),
(131781, 1, 134),
(131782, 20164, 135),
(131783, 20164, 134),
(131784, 20164, 133),
(131785, 20164, 128),
(131786, 20164, 136),
(131787, 1, 136);

-- --------------------------------------------------------

--
-- 表的结构 `ds_auth_group`
--

CREATE TABLE `ds_auth_group` (
  `id` mediumint(8) UNSIGNED NOT NULL,
  `title` char(100) NOT NULL DEFAULT '',
  `status` tinyint(1) NOT NULL DEFAULT '1',
  `rules` varchar(500) NOT NULL DEFAULT '',
  `description` char(50) NOT NULL DEFAULT ''
) ENGINE=MyISAM DEFAULT CHARSET=utf8 ROW_FORMAT=DYNAMIC;

--
-- 转存表中的数据 `ds_auth_group`
--

INSERT INTO `ds_auth_group` (`id`, `title`, `status`, `rules`, `description`) VALUES
(4, '超级管理员', 1, '13,14,15,16,17,18,19,20,21,22,23,24,25,26,89,27,28,29,30,31,32,80,81,33,34,35,36,37,38,39,41,42,43,44,45,46,47,48,49,50,51,52,82,83,84,85,87,88,9,10,11,12,86,62,63,64,65,66,67,68,69,70,71,72,73,74,75,76,77,78,7913,14,15,16,17,18,19,20,21,22,23,24,25,26,89,27,28,29,30,31,32,80,81,33,34,35,36,37,38,39,41,42,43,44,45,46,47,48,49,50,51,52,82,83,84,85,87,88,9,10,11,12,86,62,63,64,65,66,67,68,69,70,71,72,73,74,75,76,77,78,79', '拥有所有权限的管理员'),
(7, '首页管理员', 1, '13,14,15,16,17,18,19,20,21,22,23,24,25,26,9', '能够管理首页推荐位'),
(8, '广告管理员', 1, '27,28,29,30,31,32,9', '管理全部广告'),
(9, '分类管理员', 1, '33,34,35,36,37,38,39,40,41,42,43,44,45,46,47,48,49,50,51,52,9', '分类管理员'),
(10, '优惠券管理', 1, '53,54,55,56,57,58,59,60', '优惠券管理');

-- --------------------------------------------------------

--
-- 表的结构 `ds_auth_group_access`
--

CREATE TABLE `ds_auth_group_access` (
  `uid` mediumint(8) UNSIGNED NOT NULL,
  `group_id` mediumint(8) UNSIGNED NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8 ROW_FORMAT=FIXED;

--
-- 转存表中的数据 `ds_auth_group_access`
--

INSERT INTO `ds_auth_group_access` (`uid`, `group_id`) VALUES
(2651, 4);

-- --------------------------------------------------------

--
-- 表的结构 `ds_auth_rule`
--

CREATE TABLE `ds_auth_rule` (
  `id` mediumint(8) UNSIGNED NOT NULL,
  `name` char(80) NOT NULL DEFAULT '',
  `title` char(20) NOT NULL DEFAULT '',
  `type` tinyint(1) NOT NULL DEFAULT '1',
  `status` tinyint(1) NOT NULL DEFAULT '1',
  `condition` char(100) NOT NULL DEFAULT '',
  `mid` tinyint(3) UNSIGNED NOT NULL DEFAULT '0'
) ENGINE=MyISAM DEFAULT CHARSET=utf8 ROW_FORMAT=FIXED;

--
-- 转存表中的数据 `ds_auth_rule`
--

INSERT INTO `ds_auth_rule` (`id`, `name`, `title`, `type`, `status`, `condition`, `mid`) VALUES
(9, 'Admin/Index/index', '登录首页', 1, 1, '', 9),
(10, 'Admin/Websetting/index', '基础配置', 1, 1, '', 9),
(11, 'Admin/Navsetting/index', '导航配置', 1, 1, '', 9),
(12, 'Admin/Friendlink/index', '友情链接配置', 1, 1, '', 9),
(13, 'Admin/Indexset/index', '查看首页管理', 1, 1, '', 1),
(14, 'Admin/Indexset/addFloor', '添加楼层', 1, 1, '', 1),
(15, 'Admin/Indexset/modifyFloor', '修改楼层', 1, 1, '', 1),
(16, 'Admin/Indexset/deleteFloor', '删除楼层', 1, 1, '', 1),
(17, 'Admin/Indexset/loadData', '显示楼层图片广告', 1, 1, '', 1),
(18, 'Admin/Indexset/viewClass', '查看可添加楼层', 1, 1, '', 1),
(19, 'Admin/Indexset/editAd', '修改楼层广告', 1, 1, '', 1),
(20, 'Admin/Indexset/insertAd', '添加楼层广告', 1, 1, '', 1),
(21, 'Admin/Indexset/deleteAd', '删除楼层广告', 1, 1, '', 1),
(22, 'Admin/Indexset/createPic', '添加楼层广告页面', 1, 1, '', 1),
(23, 'Admin/Indexset/createText', '添加楼层文字广告页面', 1, 1, '', 1),
(24, 'Admin/Indexset/editPic', '修改楼层广告页面', 1, 1, '', 1),
(25, 'Admin/Indexset/editText', '修改楼层文字广告页面', 1, 1, '', 1),
(26, 'Admin/Indexset/loadText', '显示楼层文字广告', 1, 1, '', 1),
(27, 'Admin/Adset/index', '广告管理首页', 1, 1, '', 2),
(28, 'Admin/Adset/createAd', '广告添加页面', 1, 1, '', 2),
(29, 'Admin/Adset/insertAd', '广告添加', 1, 1, '', 2),
(30, 'Admin/Adset/editAd', '广告修改页面', 1, 1, '', 2),
(31, 'Admin/Adset/updataAd', '广告修改', 1, 1, '', 2),
(32, 'Admin/Adset/deleteAd', '广告删除', 1, 1, '', 2),
(33, 'Admin/GoodsClass/index', '商品分类显示', 1, 1, '', 4),
(34, 'Admin/GoodsClass/addClass', '商品分类添加页面', 1, 1, '', 4),
(35, 'Admin/GoodsClass/modifyClass', '商品分类修改页面', 1, 1, '', 4),
(36, 'Admin/GoodsClass/insertClass', '商品分类添加', 1, 1, '', 4),
(37, 'Admin/GoodsClass/updataClass', '商品分类修改', 1, 1, '', 4),
(38, 'Admin/GoodsClass/deleteClass', '商品分类删除', 1, 1, '', 4),
(39, 'Admin/GoodsClass/viewClassId', '商品分类显示分类id', 1, 1, '', 4),
(41, 'Admin/Goodsattr/index', '商品属性查看', 1, 1, '', 4),
(42, 'Admin/Goodsattr/addAttr', '商品属性添加页面', 1, 1, '', 4),
(43, 'Admin/Goodsattr/modifyAttr', '商品属性修改页面', 1, 1, '', 4),
(44, 'Admin/Goodsattr/insertAttr', '商品属性添加', 1, 1, '', 4),
(45, 'Admin/Goodsattr/updataAttr', '商品属性修改', 1, 1, '', 4),
(46, 'Admin/Goodsattr/deleteAttr', '商品属性删除', 1, 1, '', 4),
(47, 'Admin/Goodsbrand/index', '商品品牌查看', 1, 1, '', 4),
(48, 'Admin/Goodsbrand/addBrand', '商品品牌添加页面', 1, 1, '', 4),
(49, 'Admin/Goodsbrand/modifyBrand', '商品品牌修改页面', 1, 1, '', 4),
(50, 'Admin/Goodsbrand/insertBrand', '商品品牌添加', 1, 1, '', 4),
(51, 'Admin/Goodsbrand/updataBrand', '商品品牌修改', 1, 1, '', 4),
(52, 'Admin/Goodsbrand/deleteBrand', '商品品牌删除', 1, 1, '', 4),
(53, 'Admin/Couponmanage/index', '显示优惠券组列表', 1, 1, '', 7),
(54, 'Admin/Couponmanage/coupons', '优惠券详情列表', 1, 1, '', 7),
(55, 'Admin/Couponmanage/addCoupon', '添加优惠券', 1, 1, '', 7),
(56, 'Admin/Couponmanage/modifyCoupon', '修改优惠券', 1, 1, '', 7),
(57, 'Admin/Couponmanage/insertCoupon', '优惠券添加', 1, 1, '', 7),
(58, 'Admin/Couponmanage/updataCoupon', '优惠券修改', 1, 1, '', 7),
(59, 'Admin/Couponmanage/deleteCoupon', '删除优惠券', 1, 1, '', 7),
(60, 'Admin/Couponmanage/couponState', '更新优惠券状态', 1, 1, '', 7),
(62, 'Admin/Accesslist/index', '权限列表页面', 1, 1, '', 10),
(63, 'Admin/Accesslist/addAccess', '权限添加页面', 1, 1, '', 10),
(64, 'Admin/Accesslist/modifyAccess', '权限修改页面', 1, 1, '', 10),
(65, 'Admin/Accesslist/insertAccess', '权限添加', 1, 1, '', 10),
(66, 'Admin/Accesslist/updataAccess', '权限修改', 1, 1, '', 10),
(67, 'Admin/Accesslist/deleteAccess', '权限删除', 1, 1, '', 10),
(68, 'Admin/Accesslist/accessState', '权限状态更新', 1, 1, '', 10),
(69, 'Admin/Grouplist/index', '角色管理页面', 1, 1, '', 10),
(70, 'Admin/Grouplist/addGroup', '角色添加页面', 1, 1, '', 10),
(71, 'Admin/Grouplist/modifyGroup', '角色修改页面', 1, 1, '', 10),
(72, 'Admin/Grouplist/insertGroup', '角色添加', 1, 1, '', 10),
(73, 'Admin/Grouplist/updataGroup', '角色修改', 1, 1, '', 10),
(74, 'Admin/Grouplist/deleteGroup', '角色删除', 1, 1, '', 10),
(75, 'Admin/Grouplist/groupState', '角色状态更新', 1, 1, '', 10),
(76, 'Admin/Grouplist/groupMem', '角色成员管理页面', 1, 1, '', 10),
(77, 'Admin/Grouplist/addMem', '角色成员添加页面', 1, 1, '', 10),
(78, 'Admin/Grouplist/insertMem', '角色成员添加', 1, 1, '', 10),
(79, 'Admin/Grouplist/deleteMem', '角色成员删除', 1, 1, '', 10),
(80, 'Admin/Member/index', '用户管理', 1, 1, '', 3),
(81, 'Admin/Memlevel/index', '用户等级', 1, 1, '', 3),
(82, 'Admin/Goodsissue/index', '商品发布', 1, 1, '', 5),
(83, 'Admin/Goodsup/index', '商品上架', 1, 1, '', 5),
(84, 'Admin/Goodsdown/index', '商品下架', 1, 1, '', 5),
(85, 'Admin/Ordermanage/index', '订单管理', 1, 1, '', 6),
(86, 'Admin/Reviewmanage/index', '评价管理', 1, 1, '', 9),
(87, 'Admin/Articleclasses/index', '文章分类', 1, 1, '', 8),
(88, 'Admin/Articlemanage/index', '文章管理', 1, 1, '', 8),
(89, 'Admin/index/mang', 'cnmmm.com网站管理', 1, 1, '', 1);

-- --------------------------------------------------------

--
-- 表的结构 `ds_banner`
--

CREATE TABLE `ds_banner` (
  `id` int(10) NOT NULL,
  `path` varchar(100) NOT NULL,
  `sort` int(10) DEFAULT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8 ROW_FORMAT=DYNAMIC;

--
-- 转存表中的数据 `ds_banner`
--

INSERT INTO `ds_banner` (`id`, `path`, `sort`) VALUES
(1, '/Public/Uploads/20180701/5b38f8621f76e.jpg', 1),
(2, '/Public/Uploads/20180701/5b38f8f8aeca7.jpg', 2),
(3, '/Public/Uploads/20180701/5b38f90266558.jpg', 3),
(4, '/Public/Uploads/20180701/5b38f90b314f7.jpg', 4);

-- --------------------------------------------------------

--
-- 表的结构 `ds_business`
--

CREATE TABLE `ds_business` (
  `id` int(11) UNSIGNED NOT NULL,
  `seller` varchar(255) DEFAULT NULL COMMENT '卖方编号',
  `buyer` varchar(255) DEFAULT NULL COMMENT '买方编号',
  `qty` decimal(15,2) DEFAULT NULL COMMENT '金额',
  `receivableid` varchar(255) DEFAULT NULL COMMENT '收款账号的编号',
  `addtime` int(10) DEFAULT NULL COMMENT '发起时间',
  `paytime` int(10) DEFAULT NULL COMMENT '支付时间',
  `donetime` int(10) DEFAULT NULL COMMENT '完成时间',
  `status` varchar(20) DEFAULT NULL COMMENT '状态',
  `desc` varchar(255) DEFAULT NULL COMMENT '备注'
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COMMENT='金币买卖记录' ROW_FORMAT=COMPACT;

-- --------------------------------------------------------

--
-- 表的结构 `ds_buylog`
--

CREATE TABLE `ds_buylog` (
  `id` int(11) NOT NULL,
  `uid` int(11) NOT NULL,
  `money` float(10,2) NOT NULL,
  `buyid` int(11) NOT NULL,
  `kid` int(11) NOT NULL COMMENT '结果',
  `starttime` int(11) NOT NULL,
  `endtime` int(11) NOT NULL,
  `yingmoney` float NOT NULL,
  `status` tinyint(4) NOT NULL COMMENT '1进行中，2结束',
  `isid` int(11) NOT NULL,
  `type` tinyint(4) DEFAULT '1' COMMENT '1大小 2点数'
) ENGINE=MyISAM DEFAULT CHARSET=utf8 ROW_FORMAT=FIXED;

-- --------------------------------------------------------

--
-- 表的结构 `ds_ceng`
--

CREATE TABLE `ds_ceng` (
  `id` int(10) UNSIGNED NOT NULL,
  `member` varchar(10) CHARACTER SET utf8 NOT NULL,
  `ceng` smallint(5) UNSIGNED NOT NULL DEFAULT '0'
) ENGINE=MyISAM DEFAULT CHARSET=latin1 ROW_FORMAT=COMPACT;

-- --------------------------------------------------------

--
-- 表的结构 `ds_classify`
--

CREATE TABLE `ds_classify` (
  `cid` mediumint(8) UNSIGNED NOT NULL,
  `cname` varchar(255) NOT NULL,
  `parentid` mediumint(8) NOT NULL,
  `cpath` varchar(255) NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8 ROW_FORMAT=DYNAMIC;

--
-- 转存表中的数据 `ds_classify`
--

INSERT INTO `ds_classify` (`cid`, `cname`, `parentid`, `cpath`) VALUES
(66, '手机数码', 0, '0'),
(67, '钻石珠宝', 0, '0'),
(68, '教育产品', 0, '0'),
(69, '生活电器', 0, '0'),
(70, '食品生鲜', 0, '0'),
(71, '母婴用品', 0, '0'),
(72, '个护清洁', 0, '0'),
(73, '服装家纺', 0, '0'),
(74, '文具办公', 0, '0'),
(75, '爱车养护', 0, '0');

-- --------------------------------------------------------

--
-- 表的结构 `ds_country`
--

CREATE TABLE `ds_country` (
  `id` int(11) NOT NULL,
  `abbr` varchar(100) DEFAULT NULL COMMENT '英文缩写',
  `cninfo` varchar(200) DEFAULT NULL COMMENT '中文名'
) ENGINE=MyISAM DEFAULT CHARSET=utf8 ROW_FORMAT=COMPACT;

--
-- 转存表中的数据 `ds_country`
--

INSERT INTO `ds_country` (`id`, `abbr`, `cninfo`) VALUES
(1, 'AL', '阿尔巴尼亚'),
(2, 'DZ', '阿尔及利亚'),
(3, 'AF', '阿富汗'),
(4, 'AR', '阿根廷'),
(5, 'AE', '阿拉伯联合酋长国'),
(6, 'AW', '阿鲁巴'),
(7, 'OM', '阿曼'),
(8, 'AZ', '阿塞拜疆'),
(9, 'EG', '埃及'),
(10, 'ET', '埃塞俄比亚'),
(11, 'IE', '爱尔兰'),
(12, 'EE', '爱沙尼亚'),
(13, 'AD', '安道尔'),
(14, 'AO', '安哥拉'),
(15, 'AI', '安圭拉岛'),
(16, 'AG', '安提瓜和巴布达'),
(17, 'AT', '奥地利'),
(18, 'AX', '奥兰岛'),
(19, 'AU', '澳大利亚'),
(20, 'MO', '澳门特别行政区'),
(21, 'BB', '巴巴多斯'),
(22, 'PG', '巴布亚新几内亚'),
(23, 'BS', '巴哈马'),
(24, 'PK', '巴基斯坦'),
(25, 'PY', '巴拉圭'),
(26, 'PS', '巴勒斯坦民族权力机构'),
(27, 'BH', '巴林'),
(28, 'PA', '巴拿马'),
(29, 'BR', '巴西'),
(30, 'BY', '白俄罗斯'),
(31, 'BM', '百慕大群岛'),
(32, 'BG', '保加利亚'),
(33, 'MP', '北马里亚纳群岛'),
(34, 'BJ', '贝宁'),
(35, 'BE', '比利时'),
(36, 'IS', '冰岛'),
(37, 'PR', '波多黎各'),
(38, 'PL', '波兰'),
(39, 'BA', '波斯尼亚和黑塞哥维那'),
(40, 'BO', '玻利维亚'),
(41, 'BZ', '伯利兹'),
(42, 'BW', '博茨瓦纳'),
(43, 'BQ', '博内尔'),
(44, 'BT', '不丹'),
(45, 'BF', '布基纳法索'),
(46, 'BI', '布隆迪'),
(47, 'BV', '布韦岛'),
(48, 'KP', '朝鲜'),
(49, 'GQ', '赤道几内亚'),
(50, 'DK', '丹麦'),
(51, 'DE', '德国'),
(52, 'TL', '东帝汶'),
(53, 'TG', '多哥'),
(54, 'DO', '多米尼加共和国'),
(55, 'DM', '多米尼克'),
(56, 'RU', '俄罗斯'),
(57, 'EC', '厄瓜多尔'),
(58, 'ER', '厄立特里亚'),
(59, 'FR', '法国'),
(60, 'FO', '法罗群岛'),
(61, 'PF', '法属波利尼西亚'),
(62, 'GF', '法属圭亚那'),
(63, 'TF', '法属南极地区'),
(64, 'VA', '梵蒂冈城'),
(65, 'PH', '菲律宾'),
(66, 'FJ', '斐济群岛'),
(67, 'FI', '芬兰'),
(68, 'CV', '佛得角'),
(69, 'FK', '福克兰群岛(马尔维纳斯群岛)'),
(70, 'GM', '冈比亚'),
(71, 'CD', '刚果(DRC)'),
(72, 'CG', '刚果共和国'),
(73, 'CO', '哥伦比亚'),
(74, 'CR', '哥斯达黎加'),
(75, 'GG', '格恩西岛'),
(76, 'GD', '格林纳达'),
(77, 'GL', '格陵兰'),
(78, 'GE', '格鲁吉亚'),
(79, 'CU', '古巴'),
(80, 'GP', '瓜德罗普岛'),
(81, 'GU', '关岛'),
(82, 'GY', '圭亚那'),
(83, 'KZ', '哈萨克斯坦'),
(84, 'HT', '海地'),
(85, 'KR', '韩国'),
(86, 'NL', '荷兰'),
(87, 'HM', '赫德和麦克唐纳群岛'),
(88, 'ME', '黑山共和国'),
(89, 'HN', '洪都拉斯'),
(90, 'KI', '基里巴斯'),
(91, 'DJ', '吉布提'),
(92, 'KG', '吉尔吉斯斯坦'),
(93, 'GN', '几内亚'),
(94, 'GW', '几内亚比绍'),
(95, 'CA', '加拿大'),
(96, 'GH', '加纳'),
(97, 'GA', '加蓬'),
(98, 'KH', '柬埔寨'),
(99, 'CZ', '捷克共和国'),
(100, 'ZW', '津巴布韦'),
(101, 'CM', '喀麦隆'),
(102, 'QA', '卡塔尔'),
(103, 'KY', '开曼群岛'),
(104, 'CC', '科科斯群岛(基灵群岛)'),
(105, 'KM', '科摩罗联盟'),
(106, 'CI', '科特迪瓦共和国'),
(107, 'KW', '科威特'),
(108, 'HR', '克罗地亚'),
(109, 'KE', '肯尼亚'),
(110, 'CK', '库可群岛'),
(111, 'CW', '库拉索'),
(112, 'LV', '拉脱维亚'),
(113, 'LS', '莱索托'),
(114, 'LA', '老挝'),
(115, 'LB', '黎巴嫩'),
(116, 'LT', '立陶宛'),
(117, 'LR', '利比里亚'),
(118, 'LY', '利比亚'),
(119, 'LI', '列支敦士登'),
(120, 'RE', '留尼汪岛'),
(121, 'LU', '卢森堡'),
(122, 'RW', '卢旺达'),
(123, 'RO', '罗马尼亚'),
(124, 'MG', '马达加斯加'),
(125, 'IM', '马恩岛'),
(126, 'MV', '马尔代夫'),
(127, 'MT', '马耳他'),
(128, 'MW', '马拉维'),
(129, 'MY', '马来西亚'),
(130, 'ML', '马里'),
(131, 'MK', '马其顿, 前南斯拉夫共和国'),
(132, 'MH', '马绍尔群岛'),
(133, 'MQ', '马提尼克岛'),
(134, 'YT', '马约特岛'),
(135, 'MU', '毛里求斯'),
(136, 'MR', '毛利塔尼亚'),
(137, 'US', '美国'),
(138, 'AS', '美属萨摩亚'),
(139, 'UM', '美属外岛'),
(140, 'VI', '美属维尔京群岛'),
(141, 'MN', '蒙古'),
(142, 'MS', '蒙特塞拉特'),
(143, 'BD', '孟加拉国'),
(144, 'PE', '秘鲁'),
(145, 'FM', '密克罗尼西亚'),
(146, 'MM', '缅甸'),
(147, 'MD', '摩尔多瓦'),
(148, 'MA', '摩洛哥'),
(149, 'MC', '摩纳哥'),
(150, 'MZ', '莫桑比克'),
(151, 'MX', '墨西哥'),
(152, 'NA', '纳米比亚'),
(153, 'ZA', '南非'),
(154, 'AQ', '南极洲'),
(155, 'GS', '南乔治亚和南德桑威奇群岛'),
(156, 'NR', '瑙鲁'),
(157, 'NP', '尼泊尔'),
(158, 'NI', '尼加拉瓜'),
(159, 'NE', '尼日尔'),
(160, 'NG', '尼日利亚'),
(161, 'NU', '纽埃'),
(162, 'NO', '挪威'),
(163, 'NF', '诺福克岛'),
(164, 'PW', '帕劳群岛'),
(165, 'PN', '皮特凯恩群岛'),
(166, 'PT', '葡萄牙'),
(167, 'JP', '日本'),
(168, 'SE', '瑞典'),
(169, 'CH', '瑞士'),
(170, 'SV', '萨尔瓦多'),
(171, 'WS', '萨摩亚'),
(172, 'RS', '塞尔维亚共和国'),
(173, 'SL', '塞拉利昂'),
(174, 'SN', '塞内加尔'),
(175, 'CY', '塞浦路斯'),
(176, 'SC', '塞舌尔'),
(177, 'XS', '沙巴岛'),
(178, 'SA', '沙特阿拉伯'),
(179, 'BL', '圣巴泰勒米岛'),
(180, 'CX', '圣诞岛'),
(181, 'ST', '圣多美和普林西比'),
(182, 'SH', '圣赫勒拿岛'),
(183, 'KN', '圣基茨和尼维斯'),
(184, 'LC', '圣卢西亚'),
(185, 'MF', '法属圣马丁岛'),
(186, 'SX', '荷属圣马丁岛'),
(187, 'SM', '圣马力诺'),
(188, 'PM', '圣皮埃尔岛和密克隆岛'),
(189, 'VC', '圣文森特和格林纳丁斯'),
(190, 'XE', '圣尤斯特歇斯岛'),
(191, 'LK', '斯里兰卡'),
(192, 'SK', '斯洛伐克'),
(193, 'SI', '斯洛文尼亚'),
(194, 'SZ', '斯威士兰'),
(195, 'SD', '苏丹'),
(196, 'SR', '苏里南'),
(197, 'SB', '所罗门群岛'),
(198, 'SO', '索马里'),
(199, 'TJ', '塔吉克斯坦'),
(200, 'TW', '台湾'),
(201, 'TH', '泰国'),
(202, 'TZ', '坦桑尼亚'),
(203, 'TO', '汤加'),
(204, 'TC', '特克斯和凯科斯群岛'),
(205, 'TT', '特立尼达和多巴哥'),
(206, 'TN', '突尼斯'),
(207, 'TV', '图瓦卢'),
(208, 'TR', '土耳其'),
(209, 'TM', '土库曼斯坦'),
(210, 'TK', '托克劳'),
(211, 'WF', '瓦利斯和富图纳'),
(212, 'VU', '瓦努阿图'),
(213, 'GT', '危地马拉'),
(214, 'VG', '维尔京群岛(英属)'),
(215, 'VE', '委内瑞拉'),
(216, 'BN', '文莱'),
(217, 'UG', '乌干达'),
(218, 'UA', '乌克兰'),
(219, 'UY', '乌拉圭'),
(220, 'UZ', '乌兹别克斯坦'),
(221, 'ES', '西班牙'),
(222, 'GR', '希腊'),
(223, 'HK', '香港特别行政区'),
(224, 'SG', '新加坡'),
(225, 'NC', '新喀里多尼亚'),
(226, 'NZ', '新西兰'),
(227, 'HU', '匈牙利'),
(228, 'SY', '叙利亚'),
(229, 'JM', '牙买加'),
(230, 'AM', '亚美尼亚'),
(231, 'SJ', '扬马延岛'),
(232, 'YE', '也门'),
(233, 'IQ', '伊拉克'),
(234, 'IR', '伊朗'),
(235, 'IL', '以色列'),
(236, 'IT', '意大利'),
(237, 'IN', '印度'),
(238, 'ID', '印度尼西亚'),
(239, 'UK', '英国'),
(240, 'IO', '英属印度洋领地'),
(241, 'JO', '约旦'),
(242, 'VN', '越南'),
(243, 'ZM', '赞比亚'),
(244, 'JE', '泽西'),
(245, 'TD', '乍得'),
(246, 'GI', '直布罗陀'),
(247, 'CL', '智利'),
(248, 'CF', '中非共和国'),
(249, 'CN', '中国');

-- --------------------------------------------------------

--
-- 表的结构 `ds_date`
--

CREATE TABLE `ds_date` (
  `Id` int(11) NOT NULL,
  `date` varchar(255) DEFAULT NULL,
  `price` varchar(255) DEFAULT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8 ROW_FORMAT=COMPACT;

--
-- 转存表中的数据 `ds_date`
--

INSERT INTO `ds_date` (`Id`, `date`, `price`) VALUES
(3186, '1528562126', '0.15'),
(3187, '1528610399', '0.16'),
(3188, '1528610430', '0.14'),
(3189, '1528646430', '0.14'),
(3190, '1528646480', '0.14'),
(3191, '1528732830', '0.14'),
(3192, '1528732880', '0.14'),
(3193, '1528819230', '0.14'),
(3194, '1528819280', '0.14'),
(3195, '1528905630', '0.14'),
(3196, '1528905680', '0.14'),
(3197, '1528992030', '0.14'),
(3198, '1528992080', '0.14'),
(3199, '1529078430', '0.14'),
(3200, '1529078480', '0.14'),
(3201, '1529164830', '0.14'),
(3202, '1529164880', '0.14'),
(3203, '1529251230', '0.14'),
(3204, '1529251280', '0.14'),
(3205, '1529337630', '0.14'),
(3206, '1529337680', '0.14'),
(3207, '1529424030', '0.14'),
(3208, '1529424080', '0.14'),
(3209, '1529510430', '0.14'),
(3210, '1529510480', '0.14'),
(3211, '1529596830', '0.14'),
(3212, '1529596880', '0.14'),
(3213, '1529683230', '0.14'),
(3214, '1529683280', '0.14'),
(3215, '1529769630', '0.14'),
(3216, '1529769680', '0.14'),
(3217, '1529856030', '0.14'),
(3218, '1529856080', '0.14'),
(3219, '1529942430', '0.14'),
(3220, '1529942480', '0.14'),
(3221, '1530028830', '0.14'),
(3222, '1530028880', '0.14'),
(3223, '1530115230', '0.14'),
(3224, '1530115280', '0.14'),
(3225, '1530201630', '0.14'),
(3226, '1530201680', '0.14'),
(3227, '1530250048', '0.13'),
(3228, '1530288030', '0.13'),
(3229, '1530288080', '0.13'),
(3230, '1530374430', '0.13'),
(3231, '1530374480', '0.13'),
(3232, '1530460830', '0.13'),
(3233, '1530460880', '0.13'),
(3234, '1530545027', '0.14'),
(3235, '1530547230', '0.14'),
(3236, '1530547280', '0.14'),
(3237, '1530633630', '0.14'),
(3238, '1530633680', '0.14'),
(3239, '1530720030', '0.14'),
(3240, '1530720080', '0.14'),
(3241, '1536422430', '0.14'),
(3242, '1536422480', '0.14'),
(3243, '1536681630', '0.14'),
(3244, '1536681680', '0.14'),
(3245, '1560433025', '0.14');

-- --------------------------------------------------------

--
-- 表的结构 `ds_emoneydetail`
--

CREATE TABLE `ds_emoneydetail` (
  `id` int(10) UNSIGNED NOT NULL,
  `member` varchar(20) NOT NULL,
  `mode` varchar(10) NOT NULL,
  `amount` decimal(10,2) NOT NULL,
  `shouxufei` decimal(10,2) NOT NULL,
  `koujinbi` decimal(10,2) NOT NULL,
  `balance` decimal(10,2) NOT NULL,
  `charge` decimal(10,2) DEFAULT NULL,
  `type` varchar(100) NOT NULL,
  `name` varchar(100) NOT NULL,
  `images` varchar(255) NOT NULL,
  `remark` varchar(100) NOT NULL,
  `addtime` int(11) UNSIGNED NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8 ROW_FORMAT=COMPACT;

--
-- 转存表中的数据 `ds_emoneydetail`
--

INSERT INTO `ds_emoneydetail` (`id`, `member`, `mode`, `amount`, `shouxufei`, `koujinbi`, `balance`, `charge`, `type`, `name`, `images`, `remark`, `addtime`) VALUES
(1, '18888888888', '电子币提现', '-24.00', '4.00', '24.00', '64.00', '4.00', '1', '李秀才', '/Public/Uploads/voucher/1530438855113.png', '申请提现20元,扣除4作为手续费扣除', 1530418131),
(2, '18888888888', '电子币提现', '-36.00', '6.00', '36.00', '52.00', '6.00', '2', '李秀才', '/Public/Uploads/voucher/1530438855113.png', '申请提现30元,扣除6作为手续费扣除', 1530418156),
(3, '18888888888', '电子币提现', '-36.00', '6.00', '36.00', '52.00', '6.00', '2', '李秀才', '/Public/Uploads/voucher/1530438855113.png', '申请提现30元,扣除6作为手续费扣除', 1530418165),
(4, '18888888888', '电子币提现', '-24.00', '4.00', '24.00', '64.00', '4.00', '2', '李秀才', '/Public/Uploads/voucher/1530438855113.png', '申请提现20元,扣除4作为手续费扣除', 1530418556),
(5, '18888888888', '电子币提现', '-12.00', '2.00', '12.00', '52.00', '2.00', '', '李秀才', '/Public/Uploads/voucher/1530438855113.png', '申请提现10元,扣除2作为手续费扣除', 1530418639),
(6, '13103598345', '电子币提现', '-120.00', '20.00', '120.00', '880.00', '20.00', '1', '李秀才', '/Public/Uploads/voucher/1530438855113.png', '申请提现100元,扣除20作为手续费扣除', 1530458172),
(7, '18888888888', '电子币提现', '-10.00', '0.00', '10.00', '86.00', '0.00', '', '李秀才', '/Public/Uploads/voucher/1530423839844.png', '申请提现10元,扣除0作为手续费扣除', 1530635669);

-- --------------------------------------------------------

--
-- 表的结构 `ds_goods`
--

CREATE TABLE `ds_goods` (
  `gid` mediumint(8) UNSIGNED NOT NULL,
  `username` varchar(255) NOT NULL COMMENT '上传商品的用户名',
  `gnum` int(10) UNSIGNED NOT NULL,
  `gclassification` mediumint(8) NOT NULL,
  `gname` varchar(255) NOT NULL,
  `gpic` text NOT NULL,
  `gintroduce` text NOT NULL,
  `goldprice` int(11) NOT NULL,
  `gprice` int(11) NOT NULL,
  `gissuetime` int(10) NOT NULL,
  `issale` tinyint(1) NOT NULL,
  `guptime` int(10) NOT NULL,
  `gdowntime` int(10) NOT NULL,
  `goodnums` int(10) NOT NULL,
  `gattribute` tinytext NOT NULL,
  `gspecifications` text NOT NULL,
  `gsellnums` int(10) NOT NULL DEFAULT '0',
  `bid` mediumint(8) UNSIGNED NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8 ROW_FORMAT=DYNAMIC;

-- --------------------------------------------------------

--
-- 表的结构 `ds_guarantee`
--

CREATE TABLE `ds_guarantee` (
  `id` int(11) UNSIGNED NOT NULL,
  `seller` varchar(255) DEFAULT NULL COMMENT '卖出会员编号',
  `buyer` varchar(255) DEFAULT NULL COMMENT '买入会员编号',
  `qty` decimal(15,2) DEFAULT NULL COMMENT '金币数量',
  `receivableid` varchar(255) DEFAULT NULL COMMENT '卖家收款信息',
  `addtime` int(11) DEFAULT NULL COMMENT '添加时间',
  `donetime` int(11) DEFAULT NULL COMMENT '完成时间',
  `paytime` int(11) DEFAULT NULL COMMENT '支付时间',
  `status` varchar(255) DEFAULT NULL COMMENT '交易状态',
  `sellmsg` varchar(500) DEFAULT NULL COMMENT '卖家留言信息',
  `buymsg` varchar(500) DEFAULT NULL COMMENT '买家留言信息'
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COMMENT='担保交易' ROW_FORMAT=COMPACT;

-- --------------------------------------------------------

--
-- 表的结构 `ds_jiangjin`
--

CREATE TABLE `ds_jiangjin` (
  `id` int(11) UNSIGNED NOT NULL,
  `member` varchar(255) DEFAULT '' COMMENT '会员编号',
  `adds` decimal(12,2) UNSIGNED DEFAULT '0.00' COMMENT '添加',
  `addtime` int(10) DEFAULT '0' COMMENT '操作时间',
  `desc` varchar(255) DEFAULT '' COMMENT '说明'
) ENGINE=MyISAM AVG_ROW_LENGTH=68 DEFAULT CHARSET=utf8 COMMENT='明细' ROW_FORMAT=COMPACT;

-- --------------------------------------------------------

--
-- 表的结构 `ds_jiaoyi`
--

CREATE TABLE `ds_jiaoyi` (
  `id` int(10) UNSIGNED NOT NULL,
  `selluser` varchar(50) CHARACTER SET utf8 NOT NULL,
  `buyuser` varchar(50) CHARACTER SET utf8 NOT NULL,
  `selltime` int(11) UNSIGNED NOT NULL,
  `buytime` int(11) UNSIGNED NOT NULL,
  `jinbi` decimal(11,2) UNSIGNED NOT NULL DEFAULT '0.00',
  `jinzhongzi` decimal(11,0) NOT NULL DEFAULT '0',
  `unit` decimal(11,2) UNSIGNED NOT NULL DEFAULT '0.00',
  `status` tinyint(3) UNSIGNED NOT NULL DEFAULT '0'
) ENGINE=MyISAM DEFAULT CHARSET=latin1 ROW_FORMAT=COMPACT;

-- --------------------------------------------------------

--
-- 表的结构 `ds_jijin`
--

CREATE TABLE `ds_jijin` (
  `id` int(10) UNSIGNED NOT NULL,
  `lun` tinyint(3) UNSIGNED NOT NULL DEFAULT '0',
  `date` int(11) UNSIGNED NOT NULL DEFAULT '0',
  `money` decimal(11,2) UNSIGNED NOT NULL DEFAULT '0.00'
) ENGINE=MyISAM DEFAULT CHARSET=utf8 ROW_FORMAT=COMPACT;

-- --------------------------------------------------------

--
-- 表的结构 `ds_jinbidetail`
--

CREATE TABLE `ds_jinbidetail` (
  `id` int(11) UNSIGNED NOT NULL,
  `jid` int(10) UNSIGNED NOT NULL DEFAULT '0',
  `type` tinyint(4) NOT NULL DEFAULT '0',
  `member` varchar(255) DEFAULT '' COMMENT '会员编号',
  `adds` decimal(15,5) UNSIGNED DEFAULT '0.00000' COMMENT '添加',
  `reduce` decimal(15,5) UNSIGNED DEFAULT '0.00000' COMMENT '减少',
  `balance` decimal(15,5) UNSIGNED DEFAULT '0.00000' COMMENT '余额',
  `addtime` int(10) DEFAULT '0' COMMENT '操作时间',
  `statustime` int(11) UNSIGNED NOT NULL DEFAULT '0',
  `desc` varchar(255) DEFAULT '' COMMENT '说明',
  `status` tinyint(4) NOT NULL DEFAULT '1'
) ENGINE=MyISAM AVG_ROW_LENGTH=68 DEFAULT CHARSET=utf8 COMMENT='金币明细' ROW_FORMAT=COMPACT;

--
-- 转存表中的数据 `ds_jinbidetail`
--

INSERT INTO `ds_jinbidetail` (`id`, `jid`, `type`, `member`, `adds`, `reduce`, `balance`, `addtime`, `statustime`, `desc`, `status`) VALUES
(521328, 0, 0, '13103598345', '0.00100', '0.00000', '0.00100', 1530441826, 0, '签到奖励', 1),
(521329, 0, 0, '13103598345', '0.00100', '0.00000', '0.00200', 1530461395, 0, '签到奖励', 1),
(521330, 0, 0, '13103598345', '100.00000', '0.00000', '100.00200', 1530461499, 0, '平台充值', 1),
(521331, 0, 0, '13103598345', '0.00000', '100.00000', '0.00200', 1530461514, 0, '购买白银矿机', 1),
(521332, 31586, 1, '13103598345', '1.32090', '0.00000', '1.32290', 1530518577, 0, '矿机结算收益', 1),
(521333, 31585, 1, '13103598345', '0.18444', '0.00000', '1.50734', 1530518579, 0, '矿机结算收益', 1),
(521334, 0, 0, '18888888888', '0.00000', '13.00000', '5187.00000', 1530540141, 0, '交易市场下单扣除', 1),
(521335, 0, 0, '18888888888', '13.00000', '0.00000', '5200.00000', 1530540508, 0, '买家取消订单返回', 1),
(521336, 0, 0, '18888888888', '0.00100', '0.00000', '5200.00100', 1530598653, 0, '签到奖励', 1),
(521337, 31587, 1, '18888888888', '0.19462', '0.00000', '5200.19562', 1530623965, 0, '矿机结算收益', 1),
(521338, 0, 0, '13103598345', '0.00100', '0.00000', '1.50834', 1530628145, 0, '签到奖励', 1),
(521339, 31586, 1, '13103598345', '2.54021', '0.00000', '4.04855', 1530628314, 0, '矿机结算收益', 1),
(521340, 0, 2, '18888888888', '0.12701', '0.00000', '5200.32263', 1530628314, 0, '1/20164', 1),
(521341, 31585, 1, '13103598345', '0.25633', '0.00000', '4.30488', 1530629314, 0, '矿机结算收益', 1),
(521342, 0, 2, '18888888888', '0.01282', '0.00000', '5200.33544', 1530629314, 0, '1/20164', 1),
(521343, 0, 0, '18888888888', '0.00100', '0.00000', '5200.33644', 1530635593, 0, '签到奖励', 1),
(521344, 0, 0, '18888888888', '0.00100', '0.00000', '5200.33744', 1536741251, 0, '签到奖励', 1),
(521345, 31587, 1, '18888888888', '11.80533', '0.00000', '5212.14278', 1558797144, 0, '矿机结算收益', 1),
(521346, 0, 0, '18888888888', '1000000.00000', '0.00000', '1005212.14278', 1558947970, 0, '平台充值', 1),
(521347, 0, 0, '18888888888', '0.00000', '10000.00000', '995212.14278', 1558947999, 0, '购买钻石矿机', 1),
(521348, 0, 0, '18888888888', '0.00000', '10000.00000', '985212.14278', 1558947999, 0, '购买钻石矿机', 1),
(521349, 31588, 1, '18888888888', '554.97454', '0.00000', '985767.11732', 1559187748, 0, '矿机结算收益', 1),
(521350, 31589, 1, '18888888888', '554.98148', '0.00000', '986322.09880', 1559187752, 0, '矿机结算收益', 1),
(521351, 0, 0, '18888888888', '0.00000', '10000.00000', '976322.09880', 1559261270, 0, '购买钻石矿机', 1),
(521352, 31590, 1, '18888888888', '427.63194', '0.00000', '976749.73074', 1559446007, 0, '矿机结算收益', 1),
(521353, 31589, 1, '18888888888', '597.81481', '0.00000', '977347.54556', 1559446007, 0, '矿机结算收益', 1),
(521354, 31588, 1, '18888888888', '597.82407', '0.00000', '977945.36963', 1559446008, 0, '矿机结算收益', 1),
(521355, 0, 0, '18888888888', '0.00000', '11.50000', '977933.86963', 1559446029, 0, '交易市场下单扣除', 1),
(521356, 0, 0, '18888888888', '0.00000', '5000.00000', '972933.86963', 1559446203, 0, '购买铂金矿机', 1),
(521357, 0, 0, '18888888888', '0.00000', '10.00000', '972923.86963', 1559789653, 0, '购买微型矿机', 1),
(521358, 31594, 1, '18888888888', '0.24069', '0.00000', '972924.11032', 1559893631, 0, '矿机结算收益', 1),
(521359, 31593, 1, '18888888888', '4.38019', '0.00000', '972928.49050', 1559893639, 0, '矿机结算收益', 1),
(521360, 31594, 1, '18888888888', '0.23080', '0.00000', '972928.72131', 1559993337, 0, '矿机结算收益', 1),
(521361, 31592, 1, '18888888888', '0.80578', '0.00000', '972929.52708', 1559993338, 0, '矿机结算收益', 1),
(521362, 31595, 1, '18888888888', '0.36674', '0.00000', '972929.89383', 1560151805, 0, '矿机结算收益', 1),
(521363, 31594, 1, '18888888888', '0.36683', '0.00000', '972930.26065', 1560151807, 0, '矿机结算收益', 1),
(521364, 31593, 1, '18888888888', '5.97616', '0.00000', '972936.23681', 1560151809, 0, '矿机结算收益', 1),
(521365, 31592, 1, '18888888888', '0.36683', '0.00000', '972936.60364', 1560151810, 0, '矿机结算收益', 1),
(521366, 31591, 1, '18888888888', '816.67593', '0.00000', '973753.27957', 1560151811, 0, '矿机结算收益', 1),
(521367, 31590, 1, '18888888888', '1633.80787', '0.00000', '975387.08744', 1560151812, 0, '矿机结算收益', 1),
(521368, 31588, 1, '18888888888', '1633.81713', '0.00000', '977020.90457', 1560151817, 0, '矿机结算收益', 1),
(521369, 31589, 1, '18888888888', '1633.82176', '0.00000', '978654.72633', 1560151818, 0, '矿机结算收益', 1),
(521370, 0, 0, '18888888888', '0.00000', '100.00000', '978554.72633', 1560156637, 0, '购买白银矿机', 1),
(521371, 0, 0, '18888888888', '0.00000', '12.65000', '978542.07633', 1560336898, 0, ' 卖出挂单', 1),
(521372, 0, 0, '18888888888', '0.00000', '100.00000', '978442.07633', 1560336941, 0, '购买微型矿机(赠)', 1),
(521373, 31595, 1, '18888888888', '0.42859', '0.00000', '978442.50491', 1560336955, 0, '矿机结算收益', 1),
(521374, 31596, 1, '18888888888', '4.17407', '0.00000', '978446.67899', 1560336957, 0, '矿机结算收益', 1),
(521375, 31588, 1, '18888888888', '428.57639', '0.00000', '978875.25538', 1560336962, 0, '矿机结算收益', 1),
(521376, 31589, 1, '18888888888', '428.57639', '0.00000', '979303.83177', 1560336963, 0, '矿机结算收益', 1),
(521377, 31594, 1, '18888888888', '0.49980', '0.00000', '979304.33157', 1560367721, 0, '矿机结算收益', 1),
(521378, 31593, 1, '18888888888', '4.99799', '0.00000', '979309.32955', 1560367722, 0, '矿机结算收益', 1),
(521379, 31591, 1, '18888888888', '249.89815', '0.00000', '979559.22770', 1560367723, 0, '矿机结算收益', 1),
(521380, 0, 0, '18888888888', '0.00000', '10.00000', '979549.22770', 1560390661, 0, '购买微型矿机', 1),
(521381, 0, 0, '18888888888', '0.00000', '100.00000', '979449.22770', 1560417120, 0, '购买微型矿机(赠)', 1),
(521382, 31597, 1, '18888888888', '0.21534', '0.00000', '979449.44304', 1560429969, 0, '矿机结算收益', 1),
(521383, 31596, 1, '18888888888', '2.15308', '0.00000', '979451.59612', 1560429970, 0, '矿机结算收益', 1),
(521384, 31595, 1, '18888888888', '0.21532', '0.00000', '979451.81144', 1560429972, 0, '矿机结算收益', 1),
(521385, 31592, 1, '18888888888', '0.64390', '0.00000', '979452.45533', 1560429974, 0, '矿机结算收益', 1),
(521386, 31590, 1, '18888888888', '643.89352', '0.00000', '980096.34885', 1560429974, 0, '矿机结算收益', 1),
(521387, 31589, 1, '18888888888', '215.30556', '0.00000', '980311.65441', 1560429975, 0, '矿机结算收益', 1),
(521388, 31588, 1, '18888888888', '215.31019', '0.00000', '980526.96459', 1560429977, 0, '矿机结算收益', 1),
(521389, 0, 0, '18888888888', '0.00000', '10.00000', '980516.96459', 1560430008, 0, '购买微型矿机', 1),
(521390, 0, 0, '18888888888', '0.00000', '100.00000', '980416.96459', 1560432176, 0, '购买微型矿机(赠)', 1),
(521391, 0, 0, '18888888888', '0.00000', '100.00000', '980316.96459', 1560432188, 0, '购买微型矿机(赠)', 1),
(521392, 0, 0, '18888888888', '200000000.00000', '0.00000', '200980316.96459', 1560432289, 0, '平台充值', 1),
(521393, 0, 0, '18888888888', '0.00000', '9999999.00000', '1.00000', 1560432336, 0, '平台充值', 1),
(521394, 0, 0, '13103598345', '101000.00000', '0.00000', '101004.30488', 1560432876, 0, '平台充值', 1),
(521395, 0, 0, '13103598345', '0.00000', '124.00000', '100880.30488', 1560432930, 0, '交易市场下单扣除', 1),
(521396, 0, 0, '13103598345', '10.00000', '0.00000', '100890.30488', 1560433025, 0, '交易订单完成获得', 1),
(521397, 31600, 1, '18888888888', '0.21783', '0.00000', '1.21783', 1560511225, 0, '矿机结算收益', 1),
(521398, 31594, 1, '18888888888', '0.33220', '0.00000', '1.55003', 1560511231, 0, '矿机结算收益', 1),
(521399, 0, 0, '18888888888', '100.00000', '0.00000', '101.55003', 1560511731, 0, '平台充值', 1),
(521400, 0, 0, '18888888888', '0.00000', '10.00000', '91.55003', 1560519600, 0, '购买微型矿机', 1),
(521401, 31604, 1, '18888888888', '2.01843', '0.00000', '93.56846', 1560519721, 0, '矿机结算收益', 1),
(521402, 31597, 1, '18888888888', '0.20779', '0.00000', '93.77625', 1560519734, 0, '矿机结算收益', 1),
(521403, 0, 0, '18888888888', '0.00000', '0.00000', '93.77625', 1560519921, 0, '订单撤销返还', 1),
(521404, 31591, 1, '18888888888', '178.15394', '0.00000', '271.93018', 1560521648, 0, '矿机结算收益', 1),
(521405, 0, 0, '18888888888', '0.00000', '115.00000', '156.93018', 1560574015, 0, ' 卖出挂单', 1),
(521406, 31606, 1, '18888888888', '0.30887', '0.00000', '157.23905', 1560653030, 0, '矿机结算收益', 1),
(521407, 31605, 1, '18888888888', '3.27639', '0.00000', '160.51544', 1560653034, 0, '矿机结算收益', 1),
(521408, 0, 0, '18888888888', '0.00000', '10.00000', '150.51544', 1561527078, 0, '购买微型矿机', 1),
(521409, 0, 0, '18888888888', '0.00000', '115.00000', '35.51544', 1561536162, 0, ' 卖出挂单', 1),
(521410, 31607, 1, '18888888888', '6.04588', '0.00000', '41.56132', 1564138899, 0, '矿机结算收益', 1),
(521411, 31606, 1, '18888888888', '8.06915', '0.00000', '49.63046', 1564138903, 0, '矿机结算收益', 1),
(521412, 31605, 1, '18888888888', '80.69148', '0.00000', '130.32194', 1564138906, 0, '矿机结算收益', 1),
(521413, 31604, 1, '18888888888', '83.77750', '0.00000', '214.09944', 1564138909, 0, '矿机结算收益', 1),
(521414, 31603, 1, '18888888888', '8.58035', '0.00000', '222.67978', 1564138912, 0, '矿机结算收益', 1),
(521415, 31602, 1, '18888888888', '8.58038', '0.00000', '231.26016', 1564138914, 0, '矿机结算收益', 1),
(521416, 31601, 1, '18888888888', '8.58544', '0.00000', '239.84560', 1564138919, 0, '矿机结算收益', 1),
(521417, 31600, 1, '18888888888', '8.39742', '0.00000', '248.24302', 1564138923, 0, '矿机结算收益', 1),
(521418, 31599, 1, '18888888888', '8.67654', '0.00000', '256.91955', 1564138927, 0, '矿机结算收益', 1),
(521419, 31598, 1, '18888888888', '87.52183', '0.00000', '344.44138', 1564138930, 0, '矿机结算收益', 1),
(521420, 31597, 1, '18888888888', '8.37774', '0.00000', '352.81912', 1564138932, 0, '矿机结算收益', 1),
(521421, 31596, 1, '18888888888', '85.85567', '0.00000', '438.67479', 1564138935, 0, '矿机结算收益', 1),
(521422, 31595, 1, '18888888888', '8.58553', '0.00000', '447.26032', 1564138937, 0, '矿机结算收益', 1),
(521423, 31594, 1, '18888888888', '8.39747', '0.00000', '455.65779', 1564138940, 0, '矿机结算收益', 1),
(521424, 31593, 1, '18888888888', '87.29678', '0.00000', '542.95457', 1564138943, 0, '矿机结算收益', 1),
(521425, 31592, 1, '18888888888', '8.58555', '0.00000', '551.54012', 1564138949, 0, '矿机结算收益', 1),
(521426, 31591, 1, '18888888888', '4186.69329', '0.00000', '4738.23341', 1564138951, 0, '矿机结算收益', 1),
(521427, 31590, 1, '18888888888', '8585.59953', '0.00000', '13323.83295', 1564138953, 0, '矿机结算收益', 1),
(521428, 31589, 1, '18888888888', '8569.50000', '0.00000', '21893.33294', 1564138956, 0, '矿机结算收益', 1),
(521429, 31588, 1, '18888888888', '8569.49768', '0.00000', '30462.83062', 1564138959, 0, '矿机结算收益', 1);

-- --------------------------------------------------------

--
-- 表的结构 `ds_jorder`
--

CREATE TABLE `ds_jorder` (
  `id` int(10) UNSIGNED NOT NULL,
  `title` varchar(100) NOT NULL,
  `member` varchar(50) NOT NULL,
  `money` decimal(10,2) UNSIGNED NOT NULL DEFAULT '0.00',
  `ymoney` decimal(11,2) UNSIGNED NOT NULL DEFAULT '0.00',
  `time` int(11) UNSIGNED NOT NULL,
  `status` tinyint(3) UNSIGNED NOT NULL DEFAULT '1',
  `realname` varchar(20) NOT NULL,
  `mobile` varchar(20) NOT NULL,
  `address` varchar(100) NOT NULL,
  `post` varchar(20) NOT NULL,
  `ostatus` tinyint(3) UNSIGNED NOT NULL DEFAULT '0'
) ENGINE=MyISAM DEFAULT CHARSET=utf8 ROW_FORMAT=COMPACT;

-- --------------------------------------------------------

--
-- 表的结构 `ds_jyl`
--

CREATE TABLE `ds_jyl` (
  `Id` int(11) NOT NULL,
  `num` varchar(255) DEFAULT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8 ROW_FORMAT=COMPACT;

-- --------------------------------------------------------

--
-- 表的结构 `ds_kailog`
--

CREATE TABLE `ds_kailog` (
  `id` int(11) NOT NULL,
  `starttime` int(11) NOT NULL,
  `endtime` int(11) NOT NULL,
  `allmoney` float(10,2) NOT NULL,
  `allnum` int(11) NOT NULL,
  `status` tinyint(2) NOT NULL COMMENT '1进行中 2结束',
  `kid1` float(10,2) NOT NULL,
  `kid2` float(10,2) NOT NULL,
  `kid3` float(10,2) NOT NULL,
  `kid4` float(10,2) NOT NULL,
  `kid5` float(10,2) NOT NULL,
  `kid6` float(10,2) NOT NULL,
  `da` float(10,0) NOT NULL,
  `xiao` float(10,2) NOT NULL,
  `isid` int(11) NOT NULL,
  `kongid` tinyint(4) NOT NULL,
  `cainum` varchar(255) DEFAULT NULL,
  `zhongnum` varchar(255) DEFAULT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8 ROW_FORMAT=DYNAMIC;

--
-- 转存表中的数据 `ds_kailog`
--

INSERT INTO `ds_kailog` (`id`, `starttime`, `endtime`, `allmoney`, `allnum`, `status`, `kid1`, `kid2`, `kid3`, `kid4`, `kid5`, `kid6`, `da`, `xiao`, `isid`, `kongid`, `cainum`, `zhongnum`) VALUES
(3517, 1530441838, 1530441898, 0.00, 0, 1, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0, 0.00, 0, 0, NULL, NULL);

-- --------------------------------------------------------

--
-- 表的结构 `ds_log`
--

CREATE TABLE `ds_log` (
  `id` int(10) UNSIGNED NOT NULL,
  `logtime` int(10) UNSIGNED NOT NULL DEFAULT '0' COMMENT '操作时间',
  `logaccount` varchar(45) NOT NULL DEFAULT '' COMMENT '操作对应的账号',
  `logip` varchar(100) NOT NULL DEFAULT '' COMMENT '操作者IP',
  `logdesc` varchar(200) NOT NULL DEFAULT '' COMMENT '操作描述',
  `logtype` varchar(10) NOT NULL DEFAULT '' COMMENT '日志类型: member:会员日志 admin:管理员日志',
  `logiplocal` varchar(255) DEFAULT NULL
) ENGINE=MyISAM AVG_ROW_LENGTH=68 DEFAULT CHARSET=utf8 COMMENT='系统操作日志' ROW_FORMAT=COMPACT;

--
-- 转存表中的数据 `ds_log`
--

INSERT INTO `ds_log` (`id`, `logtime`, `logaccount`, `logip`, `logdesc`, `logtype`, `logiplocal`) VALUES
(18690, 1530370435, 'admin', '123.174.23.144', '管理员[admin]登录', 'admin', '山西省运城市电信'),
(18691, 1530374289, 'admin', '123.174.23.144', '管理员[admin]登录', 'admin', '山西省运城市电信'),
(18692, 1530415978, 'admin', '123.174.21.29', '管理员[admin]登录', 'admin', '山西省运城市电信'),
(18693, 1530423333, '', '123.174.21.29', '会员登出', 'member', '山西省运城市电信'),
(18694, 1530430411, '', '123.174.21.29', '会员登出', 'member', '山西省运城市电信'),
(18695, 1530430443, '', '123.174.21.29', '会员登出', 'member', '山西省运城市电信'),
(18696, 1530441553, '', '123.174.21.29', '会员登出', 'member', '山西省运城市电信'),
(18697, 1530457109, 'admin', '123.174.21.29', '管理员[admin]登录', 'admin', '山西省运城市电信'),
(18698, 1530457925, '13103598345', '123.174.21.29', 'ID为5的提现处理', 'admin', '山西省运城市电信'),
(18699, 1530458560, '13103598345', '123.174.21.29', 'ID为6的提现处理', 'admin', '山西省运城市电信'),
(18700, 1530458577, '13103598345', '123.174.21.29', 'ID为6的提现处理', 'admin', '山西省运城市电信'),
(18701, 1530461450, 'admin', '183.195.41.174', '管理员[admin]登录', 'admin', '中国移动'),
(18702, 1530461787, '', '183.195.41.174', '会员登出', 'member', '中国移动'),
(18703, 1530461807, 'admin', '183.195.41.174', '管理员[admin]登录', 'admin', '中国移动'),
(18704, 1530513332, 'admin', '183.195.41.174', '管理员[admin]登录', 'admin', '中国移动'),
(18705, 1530517050, '', '183.195.41.174', '会员登出', 'member', '中国移动'),
(18706, 1530517392, '18888888888', '183.195.41.174', 'ID为4的提现处理', 'admin', '中国移动'),
(18707, 1530518647, '', '183.195.41.174', '会员登出', 'member', '中国移动'),
(18708, 1530539012, 'admin', '183.195.41.174', '管理员[admin]登录', 'admin', '中国移动'),
(18709, 1530539094, '13103598345', '183.195.41.174', '发布公告', 'admin', '中国移动'),
(18710, 1530539132, '13103598345', '183.195.41.174', '修改公告', 'admin', '中国移动'),
(18711, 1530539925, '', '183.195.41.174', '会员登出', 'member', '中国移动'),
(18712, 1530540132, '18888888888', '183.195.41.174', '修改ID为1的会员组', 'admin', '中国移动'),
(18713, 1530540387, '', '183.195.41.174', '会员登出', 'member', '中国移动'),
(18714, 1530598089, '', '183.195.41.174', '会员登出', 'member', '中国移动'),
(18715, 1530598144, 'admin', '183.195.41.174', '管理员[admin]登录', 'admin', '中国移动'),
(18716, 1530602477, '', '183.195.41.174', '会员登出', 'member', '中国移动'),
(18717, 1530621298, '', '183.195.41.174', '会员登出', 'member', '中国移动'),
(18718, 1530623214, '', '123.174.21.29', '会员登出', 'member', '山西省运城市电信'),
(18719, 1530625996, '', '123.174.21.29', '会员登出', 'member', '山西省运城市电信'),
(18720, 1530626081, 'admin', '183.195.41.174', '管理员[admin]登录', 'admin', '中国移动'),
(18721, 1530626402, '', '183.195.41.174', '会员登出', 'member', '中国移动'),
(18722, 1530628478, '', '183.195.41.174', '会员登出', 'member', '中国移动'),
(18723, 1530629430, '', '183.195.41.174', '会员登出', 'member', '中国移动'),
(18724, 1530630229, '', '183.195.41.174', '会员登出', 'member', '中国移动'),
(18725, 1530630332, '', '183.195.41.174', '会员登出', 'member', '中国移动'),
(18726, 1530630404, '', '123.174.21.29', '会员登出', 'member', '山西省运城市电信'),
(18727, 1530630530, '', '123.174.21.29', '会员登出', 'member', '山西省运城市电信'),
(18728, 1530682456, 'admin', '183.195.41.174', '管理员[admin]登录', 'admin', '中国移动'),
(18729, 1530684078, 'admin', '183.195.41.174', '管理员[admin]登录', 'admin', '中国移动'),
(18730, 1530686763, 'admin', '183.195.41.174', '管理员[admin]登录', 'admin', '中国移动'),
(18731, 1530706689, 'admin', '183.195.41.174', '管理员[admin]登录', 'admin', '中国移动'),
(18732, 1536428004, 'admin', '127.0.0.1', '管理员[admin]登录', 'admin', '本机地址'),
(18733, 1536428139, '', '127.0.0.1', '编辑ID为1的管理员', 'admin', '本机地址'),
(18734, 1536428143, 'admin', '127.0.0.1', '管理员admin登出', 'admin', '本机地址'),
(18735, 1536428150, 'admin', '127.0.0.1', '管理员[admin]登录', 'admin', '本机地址'),
(18736, 1536488620, 'admin', '127.0.0.1', '管理员[admin]登录', 'admin', '本机地址'),
(18737, 1536488694, '', '127.0.0.1', '编辑ID为1的管理员', 'admin', '本机地址'),
(18738, 1536488697, 'admin', '127.0.0.1', '管理员admin登出', 'admin', '本机地址'),
(18739, 1536488710, 'admin', '127.0.0.1', '管理员[admin]登录', 'admin', '本机地址'),
(18740, 1536741209, 'admin', '127.0.0.1', '管理员[admin]登录', 'admin', '本机地址'),
(18741, 1536741945, '', '127.0.0.1', '编辑ID为1的管理员', 'admin', '本机地址'),
(18742, 1536742290, '', '127.0.0.1', '会员登出', 'member', '本机地址'),
(18743, 1536742895, '', '127.0.0.1', '会员登出', 'member', '本机地址'),
(18744, 1542625829, 'admin', '127.0.0.1', '管理员[admin]登录', 'admin', '本机地址'),
(18745, 1542626361, '', '127.0.0.1', '会员登出', 'member', '本机地址'),
(18746, 1558791359, 'admin', '58.32.217.165', '管理员[admin]登录', 'admin', '上海市电信ADSL'),
(18747, 1558796638, 'admin', '111.79.124.216', '管理员[admin]登录', 'admin', '江西省赣州市电信'),
(18748, 1558882517, '', '222.244.178.57', '会员登出', 'member', '湖南省长沙市电信'),
(18749, 1558919941, 'admin', '182.113.82.50', '管理员[admin]登录', 'admin', '河南省许昌市联通'),
(18750, 1558920196, 'admin', '110.7.253.229', '管理员[admin]登录', 'admin', '内蒙古联通'),
(18751, 1558920477, 'admin', '14.221.37.51', '管理员[admin]登录', 'admin', '广东省东莞市电信'),
(18752, 1558947631, 'admin', '106.6.116.238', '管理员[admin]登录', 'admin', '江西省电信'),
(18753, 1558947941, 'admin', '106.6.116.238', '管理员[admin]登录', 'admin', '江西省电信'),
(18754, 1559025720, 'admin', '112.65.61.83', '管理员[admin]登录', 'admin', '上海市联通IDC机房'),
(18755, 1559025763, 'admin', '221.192.178.4', '管理员[admin]登录', 'admin', '河北省石家庄市联通ADSL'),
(18756, 1559099201, 'admin', '117.164.159.36', '管理员[admin]登录', 'admin', '中国移动'),
(18757, 1559187556, 'admin', '113.248.148.109', '管理员[admin]登录', 'admin', '重庆市电信'),
(18758, 1559187592, '', '113.248.148.109', '会员登出', 'member', '重庆市电信'),
(18759, 1559191416, 'admin', '117.188.100.84', '管理员[admin]登录', 'admin', '中国移动'),
(18760, 1559282641, 'admin', '125.67.179.18', '管理员[admin]登录', 'admin', '四川省绵阳市电信'),
(18761, 1559306863, 'admin', '125.67.179.18', '管理员[admin]登录', 'admin', '四川省绵阳市电信'),
(18762, 1559311413, 'admin', '125.67.179.18', '管理员[admin]登录', 'admin', '四川省绵阳市电信'),
(18763, 1559365545, 'admin', '36.113.99.53', '管理员[admin]登录', 'admin', '浙江省电信'),
(18764, 1559387101, 'admin', '125.67.179.18', '管理员[admin]登录', 'admin', '四川省绵阳市电信'),
(18765, 1559387523, '', '125.67.179.18', '会员登出', 'member', '四川省绵阳市电信'),
(18766, 1559451974, 'admin', '125.67.179.18', '管理员[admin]登录', 'admin', '四川省绵阳市电信'),
(18767, 1559452016, '', '125.67.179.18', '下载备份文件', 'admin', '四川省绵阳市电信'),
(18768, 1559455194, 'admin', '60.233.0.135', '管理员[admin]登录', 'admin', '山东省济南市广电网'),
(18769, 1559456488, 'admin', '125.67.179.18', '管理员[admin]登录', 'admin', '四川省绵阳市电信'),
(18770, 1559611562, '', '116.9.119.125', '会员登出', 'member', '广西梧州市电信'),
(18771, 1559611636, 'admin', '116.9.119.125', '管理员[admin]登录', 'admin', '广西梧州市电信'),
(18772, 1559704370, 'admin', '223.74.121.32', '管理员[admin]登录', 'admin', '中国移动'),
(18773, 1559736944, 'admin', '125.67.179.18', '管理员[admin]登录', 'admin', '四川省绵阳市电信'),
(18774, 1559809730, 'admin', '183.12.84.206', '管理员[admin]登录', 'admin', '广东省深圳市电信'),
(18775, 1559986937, 'admin', '111.194.168.125', '管理员[admin]登录', 'admin', '北京市联通'),
(18776, 1560003238, 'admin', '112.97.166.79', '管理员[admin]登录', 'admin', '广东省深圳市联通'),
(18777, 1560037151, 'admin', '110.89.21.188', '管理员[admin]登录', 'admin', '福建省电信'),
(18778, 1560151852, 'admin', '183.198.52.175', '管理员[admin]登录', 'admin', '中国移动'),
(18779, 1560184614, 'admin', '36.106.21.23', '管理员[admin]登录', 'admin', '浙江省电信'),
(18780, 1560184661, '', '36.106.21.21', '备份数据库', 'admin', '浙江省电信'),
(18781, 1560184945, '', '36.106.21.21', '删除一个商品', 'admin', '浙江省电信'),
(18782, 1560185021, '', '36.106.21.23', '下载备份文件', 'admin', '浙江省电信'),
(18783, 1560185033, '', '36.106.21.23', '下载备份文件', 'admin', '浙江省电信'),
(18784, 1560185121, '', '36.106.21.21', '添加一个新的公告类别', 'admin', '浙江省电信'),
(18785, 1560185128, '', '36.106.21.23', '删除公告类别', 'admin', '浙江省电信'),
(18786, 1560228075, 'admin', '116.252.234.55', '管理员[admin]登录', 'admin', '广西南宁市电信'),
(18787, 1560268770, 'admin', '223.167.1.232', '管理员[admin]登录', 'admin', '上海市联通'),
(18788, 1560331979, 'admin', '221.216.142.165', '管理员[admin]登录', 'admin', '北京市西城区联通ADSL'),
(18789, 1560333653, 'admin', '218.56.199.38', '管理员[admin]登录', 'admin', '山东省济南市联通ADSL'),
(18790, 1560357960, 'admin', '36.157.225.214', '管理员[admin]登录', 'admin', '中国移动'),
(18791, 1560367608, 'admin', '223.104.102.47', '管理员[admin]登录', 'admin', '中国移动'),
(18792, 1560401935, 'admin', '112.45.233.140', '管理员[admin]登录', 'admin', '江苏省移动'),
(18793, 1560417015, 'admin', '111.34.242.23', '管理员[admin]登录', 'admin', '山东省济南市移动'),
(18794, 1560429888, 'admin', '39.87.198.160', '管理员[admin]登录', 'admin', '山东省联通'),
(18795, 1560430311, 'admin', '27.153.166.108', '管理员[admin]登录', 'admin', '福建省莆田市电信'),
(18796, 1560431965, 'admin', '59.53.18.167', '管理员[admin]登录', 'admin', '江西省赣州市电信ADSL'),
(18797, 1560478539, 'admin', '183.198.52.249', '管理员[admin]登录', 'admin', '中国移动'),
(18798, 1560479016, '', '183.198.52.249', '会员登出', 'member', '中国移动'),
(18799, 1560479178, '', '183.198.52.249', '会员登出', 'member', '中国移动'),
(18800, 1560504678, 'admin', '113.200.204.135', '管理员[admin]登录', 'admin', '陕西省西安市联通'),
(18801, 1560511100, 'admin', '36.5.171.98', '管理员[admin]登录', 'admin', '安徽省合肥市电信'),
(18802, 1560520023, 'admin', '117.179.98.9', '管理员[admin]登录', 'admin', '中国移动'),
(18803, 1560549488, 'admin', '117.179.98.9', '管理员[admin]登录', 'admin', '中国移动'),
(18804, 1560574193, 'admin', '36.23.120.219', '管理员[admin]登录', 'admin', '浙江省电信'),
(18805, 1560596682, 'admin', '36.18.120.205', '管理员[admin]登录', 'admin', '浙江省电信'),
(18806, 1560596773, '18888888888', '36.18.120.205', '添加一个新的角色', 'admin', '浙江省电信'),
(18807, 1560596789, '18888888888', '36.18.120.205', '修改权限ID1', 'admin', '浙江省电信'),
(18808, 1560597366, 'admin', '58.32.217.165', '管理员[admin]登录', 'admin', '上海市电信ADSL'),
(18809, 1560865566, 'admin', '39.87.197.220', '管理员[admin]登录', 'admin', '山东省联通'),
(18810, 1560939872, 'admin', '39.187.120.128', '管理员[admin]登录', 'admin', '中国移动'),
(18811, 1560939883, '18888888888', '39.187.120.128', '删除备份文件', 'admin', '中国移动'),
(18812, 1560939886, '18888888888', '39.187.120.128', '下载备份文件', 'admin', '中国移动'),
(18813, 1561003863, 'admin', '183.198.52.215', '管理员[admin]登录', 'admin', '中国移动'),
(18814, 1561028964, 'admin', '58.32.217.165', '管理员[admin]登录', 'admin', '上海市电信ADSL'),
(18815, 1561135486, 'admin', '182.243.206.77', '管理员[admin]登录', 'admin', '云南省玉溪市电信'),
(18816, 1561259895, 'admin', '58.32.217.165', '管理员[admin]登录', 'admin', '上海市电信ADSL'),
(18817, 1561259916, '', '58.32.217.165', '添加一个新的角色', 'admin', '上海市电信ADSL'),
(18818, 1561259943, '', '58.32.217.165', '修改权限ID2', 'admin', '上海市电信ADSL'),
(18819, 1561259961, '', '58.32.217.165', '添加了一个新用户', 'admin', '上海市电信ADSL'),
(18820, 1561259969, 'admin', '58.32.217.165', '管理员admin登出', 'admin', '上海市电信ADSL'),
(18821, 1561259974, 'ceshi', '58.32.217.165', '管理员[ceshi]登录', 'admin', '上海市电信ADSL'),
(18822, 1561260092, 'ceshi', '58.32.217.165', '管理员ceshi登出', 'admin', '上海市电信ADSL'),
(18823, 1561265457, 'admin', '58.32.217.165', '管理员[admin]登录', 'admin', '上海市电信ADSL'),
(18824, 1561265479, '', '58.32.217.165', '修改权限ID2', 'admin', '上海市电信ADSL'),
(18825, 1561265490, 'admin', '58.32.217.165', '管理员admin登出', 'admin', '上海市电信ADSL'),
(18826, 1561265498, 'ceshi', '58.32.217.165', '管理员[ceshi]登录', 'admin', '上海市电信ADSL'),
(18827, 1561265506, 'ceshi', '58.32.217.165', '管理员ceshi登出', 'admin', '上海市电信ADSL'),
(18828, 1561265510, 'admin', '58.32.217.165', '管理员[admin]登录', 'admin', '上海市电信ADSL'),
(18829, 1561265541, '', '58.32.217.165', '修改权限ID2', 'admin', '上海市电信ADSL'),
(18830, 1561265585, '', '58.32.217.165', '修改权限ID2', 'admin', '上海市电信ADSL'),
(18831, 1561265605, 'admin', '58.32.217.165', '管理员admin登出', 'admin', '上海市电信ADSL'),
(18832, 1561265611, 'ceshi', '58.32.217.165', '管理员[ceshi]登录', 'admin', '上海市电信ADSL'),
(18833, 1561265633, 'ceshi', '58.32.217.165', '管理员ceshi登出', 'admin', '上海市电信ADSL'),
(18834, 1561265637, 'admin', '58.32.217.165', '管理员[admin]登录', 'admin', '上海市电信ADSL'),
(18835, 1561265649, '', '58.32.217.165', '修改权限ID2', 'admin', '上海市电信ADSL'),
(18836, 1561265664, 'admin', '58.32.217.165', '管理员admin登出', 'admin', '上海市电信ADSL'),
(18837, 1561265670, 'ceshi', '58.32.217.165', '管理员[ceshi]登录', 'admin', '上海市电信ADSL'),
(18838, 1561265689, 'ceshi', '58.32.217.165', '管理员ceshi登出', 'admin', '上海市电信ADSL'),
(18839, 1561265715, 'admin', '58.32.217.165', '管理员[admin]登录', 'admin', '上海市电信ADSL'),
(18840, 1561280654, 'admin', '220.164.39.54', '管理员[admin]登录', 'admin', '云南省曲靖市电信'),
(18841, 1561356983, 'admin', '111.67.194.195', '管理员[admin]登录', 'admin', '北京市零色沸点网络科技有限公司'),
(18842, 1561367584, 'admin', '180.113.6.109', '管理员[admin]登录', 'admin', '江苏省无锡市电信'),
(18843, 1561396823, 'admin', '5.252.196.148', '管理员[admin]登录', 'admin', '德国'),
(18844, 1561396969, 'admin', '222.87.164.155', '管理员[admin]登录', 'admin', '贵州省黔西南州兴义市电信'),
(18845, 1561474915, '', '115.120.176.184', '会员登出', 'member', '重庆市'),
(18846, 1561526316, 'admin', '112.37.124.83', '管理员[admin]登录', 'admin', '江苏省移动'),
(18847, 1561527101, 'admin', '59.57.193.223', '管理员[admin]登录', 'admin', '福建省厦门市电信ADSL'),
(18848, 1561536845, 'admin', '183.197.33.57', '管理员[admin]登录', 'admin', '河北省移动'),
(18849, 1561541512, 'admin', '111.67.194.195', '管理员[admin]登录', 'admin', '北京市零色沸点网络科技有限公司'),
(18850, 1564126583, 'admin', '121.227.75.133', '管理员[admin]登录', 'admin', '江苏省苏州市电信'),
(18851, 1564126762, 'admin', '121.227.75.133', '管理员[admin]登录', 'admin', '江苏省苏州市电信'),
(18852, 1564138609, '18888888888', '121.227.75.133', '删除一个商品', 'admin', '江苏省苏州市电信'),
(18853, 1564138615, '18888888888', '121.227.75.133', '删除一个商品', 'admin', '江苏省苏州市电信'),
(18854, 1564138745, '18888888888', '121.227.75.133', '修改公告', 'admin', '江苏省苏州市电信'),
(18855, 1564139080, '', '121.227.75.133', '会员登出', 'member', '江苏省苏州市电信'),
(18856, 1564140478, 'admin', '121.227.75.133', '管理员admin登出', 'admin', '江苏省苏州市电信'),
(18857, 1564277046, 'admin', '127.0.0.1', '管理员[admin]登录', 'admin', '本机地址'),
(18858, 1564277215, 'admin', '127.0.0.1', '管理员[admin]登录', 'admin', '本机地址'),
(18859, 1564277291, '', '127.0.0.1', '编辑ID为1的管理员', 'admin', '本机地址'),
(18860, 1564277296, 'admin', '127.0.0.1', '管理员admin登出', 'admin', '本机地址'),
(18861, 1564277303, 'admin', '127.0.0.1', '管理员[admin]登录', 'admin', '本机地址'),
(18862, 1578076665, 'admin', '127.0.0.1', '管理员[admin]登录', 'admin', '本机地址'),
(18863, 1578076667, 'admin', '127.0.0.1', '管理员[admin]登录', 'admin', '本机地址'),
(18864, 1578076687, '', '127.0.0.1', '删除了ID为2的用户', 'admin', '本机地址'),
(18865, 1578077785, 'admin', '127.0.0.1', '管理员[admin]登录', 'admin', '本机地址'),
(18866, 1578077801, '18888888888', '127.0.0.1', '编辑ID为1的管理员', 'admin', '本机地址'),
(18867, 1578077807, 'admin', '127.0.0.1', '管理员admin登出', 'admin', '本机地址'),
(18868, 1578077815, 'admin', '127.0.0.1', '管理员[admin]登录', 'admin', '本机地址');

-- --------------------------------------------------------

--
-- 表的结构 `ds_mailbox`
--

CREATE TABLE `ds_mailbox` (
  `id` int(11) UNSIGNED NOT NULL,
  `title` varchar(100) DEFAULT '' COMMENT '消息标题',
  `content` varchar(500) DEFAULT '' COMMENT '消息内容',
  `addtime` int(10) DEFAULT '0' COMMENT '添加时间',
  `isread` tinyint(4) DEFAULT '0' COMMENT '是否已读',
  `member` varchar(50) DEFAULT NULL COMMENT '接收会员编号'
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COMMENT='私人信息' ROW_FORMAT=COMPACT;

-- --------------------------------------------------------

--
-- 表的结构 `ds_member`
--

CREATE TABLE `ds_member` (
  `id` int(11) UNSIGNED NOT NULL,
  `uid` int(11) NOT NULL,
  `shopstatus` tinyint(4) NOT NULL COMMENT '商户权限',
  `shopname` varchar(255) DEFAULT NULL,
  `shoplevel` int(10) DEFAULT NULL,
  `level` int(10) UNSIGNED NOT NULL DEFAULT '0',
  `ji` tinyint(3) UNSIGNED NOT NULL DEFAULT '0',
  `fl` tinyint(3) UNSIGNED NOT NULL DEFAULT '0',
  `username` varchar(255) CHARACTER SET utf8 COLLATE utf8_bin DEFAULT NULL COMMENT '会员编号',
  `password` varchar(32) DEFAULT NULL COMMENT '一级密码',
  `password2` varchar(32) DEFAULT NULL COMMENT '二级密码',
  `regdate` int(10) DEFAULT NULL COMMENT '注册时间',
  `checkdate` int(10) DEFAULT NULL COMMENT '审核时间',
  `online_time` int(11) NOT NULL,
  `parent` varchar(255) DEFAULT NULL COMMENT '推荐人',
  `parent_id` int(11) UNSIGNED NOT NULL,
  `ot` int(10) UNSIGNED NOT NULL DEFAULT '0',
  `tt` int(10) UNSIGNED NOT NULL DEFAULT '0',
  `cardpic` varchar(100) NOT NULL,
  `cardpic1` varchar(100) NOT NULL,
  `zhifubao` varchar(30) NOT NULL,
  `weixin` varchar(30) NOT NULL,
  `guoji` varchar(10) NOT NULL,
  `btcaddress` varchar(255) NOT NULL,
  `parentcount` int(11) DEFAULT '0' COMMENT '推荐人数',
  `teamgonglv` decimal(11,2) UNSIGNED NOT NULL DEFAULT '0.00',
  `mygonglv` decimal(11,2) UNSIGNED NOT NULL DEFAULT '0.00',
  `qjinbi` decimal(15,8) UNSIGNED NOT NULL DEFAULT '0.00000000',
  `jinbi` decimal(15,8) UNSIGNED DEFAULT '0.00000000' COMMENT '金币数量',
  `baozhengjin` decimal(15,8) DEFAULT NULL,
  `yj` decimal(15,8) UNSIGNED DEFAULT '0.00000000' COMMENT '佣金数量',
  `point` decimal(11,2) UNSIGNED NOT NULL DEFAULT '0.00',
  `share` decimal(11,2) UNSIGNED NOT NULL DEFAULT '0.00',
  `sellshare` decimal(11,2) UNSIGNED NOT NULL DEFAULT '0.00',
  `nickname` varchar(255) DEFAULT NULL COMMENT '呢称',
  `email` varchar(100) DEFAULT NULL COMMENT '邮箱',
  `truename` varchar(255) DEFAULT NULL COMMENT '真实姓名',
  `post` varchar(10) NOT NULL,
  `address` varchar(100) NOT NULL,
  `idcard` varchar(100) NOT NULL,
  `sktype` varchar(20) NOT NULL,
  `sknumber` varchar(50) NOT NULL,
  `mobile` varchar(20) DEFAULT NULL COMMENT '手机',
  `uname` varchar(255) DEFAULT NULL COMMENT '手机',
  `qq` varchar(20) DEFAULT NULL COMMENT 'QQ',
  `wuliu` varchar(255) DEFAULT NULL COMMENT '报单中心编号',
  `token` varchar(255) DEFAULT NULL COMMENT '令牌',
  `status` tinyint(4) DEFAULT '0' COMMENT '状态',
  `bzjstatus` tinyint(4) DEFAULT NULL COMMENT '保证金状态',
  `checkstatus` tinyint(4) NOT NULL DEFAULT '0',
  `lock` tinyint(4) DEFAULT NULL COMMENT '锁定',
  `logintime` int(10) DEFAULT '0' COMMENT '本次登录时间',
  `loginip` varchar(50) DEFAULT '' COMMENT '本次登录IP',
  `prelogintime` int(10) DEFAULT '0' COMMENT '上次登录时间',
  `preloginip` varchar(255) DEFAULT '' COMMENT '上线登录IP',
  `logincount` int(10) DEFAULT '0' COMMENT '登录总次数',
  `loginaddress` varchar(255) DEFAULT '' COMMENT '本次登录地址',
  `preloginaddress` varchar(255) DEFAULT '' COMMENT '上次登录地址',
  `isout` tinyint(1) DEFAULT '0' COMMENT '是否分红出局',
  `isbaodan` tinyint(1) DEFAULT '0' COMMENT '是否为报单中心',
  `question1` varchar(50) DEFAULT '' COMMENT '密保问题1',
  `answer1` varchar(50) DEFAULT '' COMMENT '密保答案1',
  `question2` varchar(50) DEFAULT '' COMMENT '密保问题2',
  `answer2` varchar(50) DEFAULT '' COMMENT '密保答案2',
  `question3` varchar(50) DEFAULT '' COMMENT '密保问题3',
  `answer3` varchar(50) DEFAULT '' COMMENT '密保答案3',
  `parentpath` longtext COMMENT '推荐遗传码',
  `parentlayer` int(10) DEFAULT NULL COMMENT '推荐代数',
  `gamecount` int(10) DEFAULT '0' COMMENT '游戏账号总数',
  `validgamecount` int(10) DEFAULT '0' COMMENT '有效游戏账号总数',
  `tjsum` decimal(15,4) NOT NULL DEFAULT '0.0000' COMMENT '推荐奖累计',
  `bdsum` decimal(15,4) NOT NULL DEFAULT '0.0000' COMMENT '报单奖累计',
  `fhsum` decimal(15,2) NOT NULL DEFAULT '0.00' COMMENT '分红累计',
  `ldsum` decimal(15,4) NOT NULL DEFAULT '0.0000' COMMENT '领导奖累计',
  `glsum` decimal(15,4) DEFAULT '0.0000' COMMENT '管理奖累计',
  `zysum` decimal(15,4) DEFAULT '0.0000' COMMENT '增员奖累计',
  `fparent` varchar(50) DEFAULT NULL COMMENT '上级编号',
  `my_jd` varchar(6) DEFAULT NULL COMMENT '节点位置(原始点/左/右)',
  `left` varchar(50) DEFAULT NULL COMMENT '左节点',
  `center` varchar(50) DEFAULT NULL,
  `right` varchar(50) DEFAULT NULL COMMENT '右节点',
  `leftnum` mediumint(8) UNSIGNED NOT NULL DEFAULT '0',
  `leftpro` int(10) UNSIGNED NOT NULL DEFAULT '0',
  `leftpeng` int(11) UNSIGNED NOT NULL DEFAULT '0',
  `centernum` int(10) UNSIGNED NOT NULL DEFAULT '0',
  `centerpro` int(10) UNSIGNED NOT NULL DEFAULT '0',
  `centerpeng` int(11) UNSIGNED NOT NULL DEFAULT '0',
  `rightnum` mediumint(8) UNSIGNED NOT NULL DEFAULT '0',
  `rightpro` int(10) UNSIGNED NOT NULL DEFAULT '0',
  `rightpeng` int(11) UNSIGNED NOT NULL DEFAULT '0',
  `countnum` mediumint(8) UNSIGNED NOT NULL DEFAULT '0',
  `countpro` int(10) UNSIGNED NOT NULL DEFAULT '0',
  `countpeng` int(11) UNSIGNED NOT NULL DEFAULT '0',
  `manage_left_end` varchar(50) DEFAULT '' COMMENT '层网络最左端',
  `manage_right_end` varchar(50) DEFAULT '' COMMENT '层网络最右端',
  `manage_node_data` longtext COMMENT '网体数据',
  `manage_ceng` int(11) DEFAULT '0' COMMENT '层数',
  `acc_type` varchar(255) DEFAULT '' COMMENT '账号类型(主账号/新增账号)',
  `main_acc` varchar(255) DEFAULT '' COMMENT '如果是新增账号，需要有对应的主账号',
  `showpass1` varchar(255) DEFAULT '' COMMENT '登录密码显示',
  `showpass2` varchar(255) DEFAULT '' COMMENT '二级密码显示',
  `liyou` varchar(255) DEFAULT NULL,
  `alipay_voucher` varchar(300) DEFAULT NULL,
  `shenfen` varchar(255) DEFAULT NULL,
  `president_qq` varchar(255) DEFAULT NULL,
  `president_qqs` varchar(255) DEFAULT NULL,
  `president_wxewm` varchar(255) DEFAULT NULL,
  `president_desc` varchar(255) DEFAULT NULL
) ENGINE=MyISAM AVG_ROW_LENGTH=278 DEFAULT CHARSET=utf8 COMMENT='会员' ROW_FORMAT=COMPACT;

--
-- 转存表中的数据 `ds_member`
--

INSERT INTO `ds_member` (`id`, `uid`, `shopstatus`, `shopname`, `shoplevel`, `level`, `ji`, `fl`, `username`, `password`, `password2`, `regdate`, `checkdate`, `online_time`, `parent`, `parent_id`, `ot`, `tt`, `cardpic`, `cardpic1`, `zhifubao`, `weixin`, `guoji`, `btcaddress`, `parentcount`, `teamgonglv`, `mygonglv`, `qjinbi`, `jinbi`, `baozhengjin`, `yj`, `point`, `share`, `sellshare`, `nickname`, `email`, `truename`, `post`, `address`, `idcard`, `sktype`, `sknumber`, `mobile`, `uname`, `qq`, `wuliu`, `token`, `status`, `bzjstatus`, `checkstatus`, `lock`, `logintime`, `loginip`, `prelogintime`, `preloginip`, `logincount`, `loginaddress`, `preloginaddress`, `isout`, `isbaodan`, `question1`, `answer1`, `question2`, `answer2`, `question3`, `answer3`, `parentpath`, `parentlayer`, `gamecount`, `validgamecount`, `tjsum`, `bdsum`, `fhsum`, `ldsum`, `glsum`, `zysum`, `fparent`, `my_jd`, `left`, `center`, `right`, `leftnum`, `leftpro`, `leftpeng`, `centernum`, `centerpro`, `centerpeng`, `rightnum`, `rightpro`, `rightpeng`, `countnum`, `countpro`, `countpeng`, `manage_left_end`, `manage_right_end`, `manage_node_data`, `manage_ceng`, `acc_type`, `main_acc`, `showpass1`, `showpass2`, `liyou`, `alipay_voucher`, `shenfen`, `president_qq`, `president_qqs`, `president_wxewm`, `president_desc`) VALUES
(1, 0, 0, '', NULL, 6, 0, 0, '18888888888', '635092b43f6daab6e117b2429f5e6236', '635092b43f6daab6e117b2429f5e6236', 1511146976, 1511146976, 1578077172, '', 0, 0, 0, '', '', '18888888888', '18888888888', '', '', 1, '817.63', '15.61', '230.00000000', '30462.83062408', NULL, '86.00000000', '0.00', '0.00', '0.00', '', '', '站码之家', '', '', '6212255555220121212', '', '', '18888888888', '18888888888', '', '', '', 1, 1, 3, NULL, 0, '', 0, '', 144, '', '', 0, 0, '', '', '', '', '', '', NULL, 0, 160, 0, '0.0000', '0.0000', '0.00', '0.0000', '0.0000', '0.0000', '', '', '', '', '', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, '', '', NULL, 0, '主账号', '', '', '', '', '/Public/Uploads/voucher/1530423839844.png', '142425252525252525', NULL, NULL, NULL, NULL),
(20164, 0, 0, NULL, NULL, 3, 0, 0, '13103598345', 'e10adc3949ba59abbe56e057f20f883e', 'c8837b23ff8aaa8a2dde915473ce0991', 1530438820, 1530438820, 1560479302, '18888888888', 1, 0, 0, '', '', '13103598345', '13103598345', '', '', 0, '0.00', '0.11', '124.00000000', '100890.30488002', NULL, '880.00000000', '0.00', '0.00', '0.00', '', NULL, '李秀才', '', '', '6212255555220121219', '', '', '13103598345', '13103598345', NULL, NULL, NULL, 1, 1, 3, 0, 0, '', 0, '', 16, '', '', 0, 0, '', '', '', '', '', '', '1|', 1, 0, 0, '0.0000', '0.0000', '0.00', '0.0000', '0.0000', '0.0000', NULL, NULL, NULL, NULL, NULL, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, '', '', NULL, 0, '主账号', '', '', '', '', '/Public/Uploads/voucher/1530438855113.png', '142425252525252555', NULL, NULL, NULL, NULL);

-- --------------------------------------------------------

--
-- 表的结构 `ds_members_sign`
--

CREATE TABLE `ds_members_sign` (
  `id` int(11) UNSIGNED NOT NULL,
  `user_id` int(11) UNSIGNED NOT NULL COMMENT '用户id',
  `username` varchar(255) DEFAULT NULL,
  `jiangli` decimal(15,8) UNSIGNED DEFAULT '0.00000000' COMMENT '是否签到过',
  `stime` int(10) UNSIGNED DEFAULT '0' COMMENT '签到的时间',
  `desc` varchar(255) DEFAULT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COMMENT='签到分享表' ROW_FORMAT=COMPACT;

--
-- 转存表中的数据 `ds_members_sign`
--

INSERT INTO `ds_members_sign` (`id`, `user_id`, `username`, `jiangli`, `stime`, `desc`) VALUES
(515, 20005, '18595898679', '0.00100000', 1528689953, '签到奖励'),
(516, 20000, '13164352999', '0.00100000', 1528708352, '签到奖励'),
(517, 20007, '15238625511', '0.00100000', 1528715603, '签到奖励'),
(518, 20008, '15055596222', '0.00100000', 1528717053, '签到奖励'),
(519, 20006, '18803783999', '0.00100000', 1528717470, '签到奖励'),
(520, 20010, '17797752708', '0.00100000', 1528726469, '签到奖励'),
(521, 20008, '15055596222', '0.00100000', 1528778088, '签到奖励'),
(522, 20000, '13164352999', '0.00100000', 1528783851, '签到奖励'),
(523, 20007, '15238625511', '0.00100000', 1528786401, '签到奖励'),
(524, 20015, '13673673027', '0.00100000', 1528795094, '签到奖励'),
(525, 20016, '13339997637', '0.00100000', 1528811993, '签到奖励'),
(526, 20008, '15055596222', '0.00100000', 1528822182, '签到奖励'),
(527, 20015, '13673673027', '0.00100000', 1528845920, '签到奖励'),
(528, 20016, '13339997637', '0.00100000', 1528848593, '签到奖励'),
(529, 20010, '17797752708', '0.00100000', 1528848943, '签到奖励'),
(530, 20024, '18227752815', '0.00100000', 1528865130, '签到奖励'),
(531, 20002, '18318876315', '0.00100000', 1528874200, '签到奖励'),
(532, 20021, '13540373333', '0.00100000', 1528898764, '签到奖励'),
(533, 20016, '13339997637', '0.00100000', 1528936283, '签到奖励'),
(534, 20002, '18318876315', '0.00100000', 1528944486, '签到奖励'),
(535, 20031, '15860670829', '0.00100000', 1528948368, '签到奖励'),
(536, 20033, '13073755270', '0.00100000', 1528951286, '签到奖励'),
(537, 20015, '13673673027', '0.00100000', 1528956413, '签到奖励'),
(538, 20005, '18595898679', '0.00100000', 1528960457, '签到奖励'),
(539, 20036, '15188332982', '0.00100000', 1528972677, '签到奖励'),
(540, 20016, '13339997637', '0.00100000', 1528992424, '签到奖励'),
(541, 20008, '15055596222', '0.00100000', 1528994879, '签到奖励'),
(542, 20031, '15860670829', '0.00100000', 1529021423, '签到奖励'),
(543, 20006, '18803783999', '0.00100000', 1529022196, '签到奖励'),
(544, 20037, '17756235430', '0.00100000', 1529033892, '签到奖励'),
(545, 20040, '15387098613', '0.00100000', 1529043360, '签到奖励'),
(546, 20038, '13864643525', '0.00100000', 1529043493, '签到奖励'),
(547, 20002, '18318876315', '0.00100000', 1529053936, '签到奖励'),
(548, 20047, '18319283191', '0.00100000', 1529068683, '签到奖励'),
(549, 20035, '13623756261', '0.00100000', 1529079141, '签到奖励'),
(550, 20038, '13864643525', '0.00100000', 1529102184, '签到奖励'),
(551, 20016, '13339997637', '0.00100000', 1529108380, '签到奖励'),
(552, 20052, '13193887071', '0.00100000', 1529142940, '签到奖励'),
(553, 20002, '18318876315', '0.00100000', 1529157858, '签到奖励'),
(554, 20016, '13339997637', '0.00100000', 1529195677, '签到奖励'),
(555, 20053, '15257570828', '0.00100000', 1529203045, '签到奖励'),
(556, 20038, '13864643525', '0.00100000', 1529226333, '签到奖励'),
(557, 20000, '13164352999', '0.00100000', 1529228987, '签到奖励'),
(558, 20002, '18318876315', '0.00100000', 1529229941, '签到奖励'),
(559, 20002, '18318876315', '0.00100000', 1529285950, '签到奖励'),
(560, 20016, '13339997637', '0.00100000', 1529293247, '签到奖励'),
(561, 20052, '13193887071', '0.00100000', 1529311847, '签到奖励'),
(562, 20031, '15860670829', '0.00100000', 1529317844, '签到奖励'),
(563, 20016, '13339997637', '0.00100000', 1529365830, '签到奖励'),
(564, 20015, '13673673027', '0.00100000', 1529367121, '签到奖励'),
(565, 20002, '18318876315', '0.00100000', 1529368560, '签到奖励'),
(566, 20052, '13193887071', '0.00100000', 1529371787, '签到奖励'),
(567, 20023, '18639736868', '0.00100000', 1529383770, '签到奖励'),
(568, 20010, '17797752708', '0.00100000', 1529405049, '签到奖励'),
(569, 20038, '13864643525', '0.00100000', 1529413642, '签到奖励'),
(570, 20047, '18319283191', '0.00100000', 1529422267, '签到奖励'),
(571, 20033, '13073755270', '0.00100000', 1529454043, '签到奖励'),
(572, 20016, '13339997637', '0.00100000', 1529455889, '签到奖励'),
(573, 20052, '13193887071', '0.00100000', 1529460686, '签到奖励'),
(574, 20023, '18639736868', '0.00100000', 1529467980, '签到奖励'),
(575, 20038, '13864643525', '0.00100000', 1529468352, '签到奖励'),
(576, 20004, '15516019657', '0.00100000', 1529469066, '签到奖励'),
(577, 20058, '15314099319', '0.00100000', 1529477724, '签到奖励'),
(578, 20015, '13673673027', '0.00100000', 1529483058, '签到奖励'),
(579, 20062, '15315481133', '0.00100000', 1529490269, '签到奖励'),
(580, 20064, '13963018917', '0.00100000', 1529493768, '签到奖励'),
(581, 20066, '18236437259', '0.00100000', 1529504289, '签到奖励'),
(582, 20056, '18803753918', '0.00100000', 1529505738, '签到奖励'),
(583, 20062, '15315481133', '0.00100000', 1529513495, '签到奖励'),
(584, 20058, '15314099319', '0.00100000', 1529521744, '签到奖励'),
(585, 20002, '18318876315', '0.00100000', 1529527924, '签到奖励'),
(586, 20021, '13540373333', '0.00100000', 1529536783, '签到奖励'),
(587, 20067, '18295429981', '0.00100000', 1529538564, '签到奖励'),
(588, 20015, '13673673027', '0.00100000', 1529541323, '签到奖励'),
(589, 20069, '15897755663', '0.00100000', 1529551873, '签到奖励'),
(590, 20047, '18319283191', '0.00100000', 1529552558, '签到奖励'),
(591, 20061, '18053827817', '0.00100000', 1529554532, '签到奖励'),
(592, 20005, '18595898679', '0.00100000', 1529564803, '签到奖励'),
(593, 20016, '13339997637', '0.00100000', 1529567814, '签到奖励'),
(594, 20070, '13612799922', '0.00100000', 1529572622, '签到奖励'),
(595, 20064, '13963018917', '0.00100000', 1529575549, '签到奖励'),
(596, 20021, '13540373333', '0.00100000', 1529597409, '签到奖励'),
(597, 20058, '15314099319', '0.00100000', 1529602739, '签到奖励'),
(598, 20062, '15315481133', '0.00100000', 1529623384, '签到奖励'),
(599, 20047, '18319283191', '0.00100000', 1529624560, '签到奖励'),
(600, 20002, '18318876315', '0.00100000', 1529624710, '签到奖励'),
(601, 20016, '13339997637', '0.00100000', 1529628595, '签到奖励'),
(602, 20061, '18053827817', '0.00100000', 1529636853, '签到奖励'),
(603, 20082, '13307173331', '0.00100000', 1529657457, '签到奖励'),
(604, 20005, '18595898679', '0.00100000', 1529663500, '签到奖励'),
(605, 20086, '17070256888', '0.00100000', 1529663766, '签到奖励'),
(606, 20000, '13164352999', '0.00100000', 1529673563, '签到奖励'),
(607, 20021, '13540373333', '0.00100000', 1529683870, '签到奖励'),
(608, 20007, '15238625511', '0.00100000', 1529693673, '签到奖励'),
(609, 20038, '13864643525', '0.00100000', 1529701893, '签到奖励'),
(610, 20061, '18053827817', '0.00100000', 1529704189, '签到奖励'),
(611, 20016, '13339997637', '0.00100000', 1529711961, '签到奖励'),
(612, 20002, '18318876315', '0.00100000', 1529714357, '签到奖励'),
(613, 20058, '15314099319', '0.00100000', 1529715710, '签到奖励'),
(614, 20062, '15315481133', '0.00100000', 1529722814, '签到奖励'),
(615, 20033, '13073755270', '0.00100000', 1529736120, '签到奖励'),
(616, 20052, '13193887071', '0.00100000', 1529742948, '签到奖励'),
(617, 20086, '17070256888', '0.00100000', 1529744475, '签到奖励'),
(618, 20095, '13260296142', '0.00100000', 1529752162, '签到奖励'),
(619, 20096, '17638151978', '0.00100000', 1529752752, '签到奖励'),
(620, 20021, '13540373333', '0.00100000', 1529770060, '签到奖励'),
(621, 20095, '13260296142', '0.00100000', 1529775167, '签到奖励'),
(622, 20058, '15314099319', '0.00100000', 1529776213, '签到奖励'),
(623, 20062, '15315481133', '0.00100000', 1529779116, '签到奖励'),
(624, 20016, '13339997637', '0.00100000', 1529799784, '签到奖励'),
(625, 20002, '18318876315', '0.00100000', 1529801759, '签到奖励'),
(626, 20061, '18053827817', '0.00100000', 1529803506, '签到奖励'),
(627, 20057, '15288901686', '0.00100000', 1529806722, '签到奖励'),
(628, 20052, '13193887071', '0.00100000', 1529819266, '签到奖励'),
(629, 20033, '13073755270', '0.00100000', 1529831891, '签到奖励'),
(630, 20075, '13169509106', '0.00100000', 1529833283, '签到奖励'),
(631, 20023, '18639736868', '0.00100000', 1529847904, '签到奖励'),
(632, 20021, '13540373333', '0.00100000', 1529860443, '签到奖励'),
(633, 20062, '15315481133', '0.00100000', 1529868514, '签到奖励'),
(634, 20061, '18053827817', '0.00100000', 1529881344, '签到奖励'),
(635, 20002, '18318876315', '0.00100000', 1529887180, '签到奖励'),
(636, 20033, '13073755270', '0.00100000', 1529893310, '签到奖励'),
(637, 20064, '13963018917', '0.00100000', 1529898752, '签到奖励'),
(638, 20093, '18336193888', '0.00100000', 1529910019, '签到奖励'),
(639, 20016, '13339997637', '0.00100000', 1529910063, '签到奖励'),
(640, 20054, '18530807318', '0.00100000', 1529916270, '签到奖励'),
(641, 20005, '18595898679', '0.00100000', 1529920132, '签到奖励'),
(642, 20010, '17797752708', '0.00100000', 1529920568, '签到奖励'),
(643, 20058, '15314099319', '0.00100000', 1529929820, '签到奖励'),
(644, 20007, '15238625511', '0.00100000', 1529932257, '签到奖励'),
(645, 20052, '13193887071', '0.00100000', 1529937508, '签到奖励'),
(646, 20110, '13415062948', '0.00100000', 1529942181, '签到奖励'),
(647, 20021, '13540373333', '0.00100000', 1529942773, '签到奖励'),
(648, 20062, '15315481133', '0.00100000', 1529944907, '签到奖励'),
(649, 20119, '15554579444', '0.00100000', 1529945026, '签到奖励'),
(650, 20002, '18318876315', '0.00100000', 1529945275, '签到奖励'),
(651, 20052, '13193887071', '0.00100000', 1529945414, '签到奖励'),
(652, 20033, '13073755270', '0.00100000', 1529950799, '签到奖励'),
(653, 20058, '15314099319', '0.00100000', 1529951784, '签到奖励'),
(654, 20061, '18053827817', '0.00100000', 1529970219, '签到奖励'),
(655, 20072, '13703671272', '0.00100000', 1529974394, '签到奖励'),
(656, 20008, '15055596222', '0.00100000', 1529975639, '签到奖励'),
(657, 20108, '18306555088', '0.00100000', 1529976404, '签到奖励'),
(658, 20095, '13260296142', '0.00100000', 1529988657, '签到奖励'),
(659, 20129, '13619860123', '0.00100000', 1530002713, '签到奖励'),
(660, 20010, '17797752708', '0.00100000', 1530008879, '签到奖励'),
(661, 20021, '13540373333', '0.00100000', 1530029213, '签到奖励'),
(662, 20062, '15315481133', '0.00100000', 1530030118, '签到奖励'),
(663, 20015, '13673673027', '0.00100000', 1530035049, '签到奖励'),
(664, 20058, '15314099319', '0.00100000', 1530047906, '签到奖励'),
(665, 20056, '18803753918', '0.00100000', 1530053538, '签到奖励'),
(666, 20005, '18595898679', '0.00100000', 1530054336, '签到奖励'),
(667, 20016, '13339997637', '0.00100000', 1530061797, '签到奖励'),
(668, 20047, '18319283191', '0.00100000', 1530061818, '签到奖励'),
(669, 20110, '13415062948', '0.00100000', 1530061983, '签到奖励'),
(670, 20023, '18639736868', '0.00100000', 1530062032, '签到奖励'),
(671, 20052, '13193887071', '0.00100000', 1530072296, '签到奖励'),
(672, 20072, '13703671272', '0.00100000', 1530074590, '签到奖励'),
(673, 20061, '18053827817', '0.00100000', 1530077304, '签到奖励'),
(674, 20140, '13071789700', '0.00100000', 1530084043, '签到奖励'),
(675, 20128, '13428317723', '0.00100000', 1530093938, '签到奖励'),
(676, 20007, '15238625511', '0.00100000', 1530116052, '签到奖励'),
(677, 20062, '15315481133', '0.00100000', 1530117016, '签到奖励'),
(678, 20095, '13260296142', '0.00100000', 1530128720, '签到奖励'),
(679, 20052, '13193887071', '0.00100000', 1530129061, '签到奖励'),
(680, 20058, '15314099319', '0.00100000', 1530140582, '签到奖励'),
(681, 20056, '18803753918', '0.00100000', 1530141413, '签到奖励'),
(682, 20021, '13540373333', '0.00100000', 1530143958, '签到奖励'),
(683, 20005, '18595898679', '0.00100000', 1530148235, '签到奖励'),
(684, 20016, '13339997637', '0.00100000', 1530152273, '签到奖励'),
(685, 20008, '15055596222', '0.00100000', 1530152444, '签到奖励'),
(686, 20072, '13703671272', '0.00100000', 1530154612, '签到奖励'),
(687, 20023, '18639736868', '0.00100000', 1530157559, '签到奖励'),
(688, 20033, '13073755270', '0.00100000', 1530160284, '签到奖励'),
(689, 20061, '18053827817', '0.00100000', 1530160746, '签到奖励'),
(690, 20082, '13307173331', '0.00100000', 1530165270, '签到奖励'),
(691, 20083, '18627031670', '0.00100000', 1530166918, '签到奖励'),
(692, 20147, '18986100270', '0.00100000', 1530168051, '签到奖励'),
(693, 20140, '13071789700', '0.00100000', 1530176562, '签到奖励'),
(694, 20010, '17797752708', '0.00100000', 1530181538, '签到奖励'),
(695, 20145, '15171861230', '0.00100000', 1530183915, '签到奖励'),
(696, 20151, '13849149922', '0.00100000', 1530192590, '签到奖励'),
(697, 20021, '13540373333', '0.00100000', 1530220950, '签到奖励'),
(698, 20058, '15314099319', '0.00100000', 1530221547, '签到奖励'),
(699, 20005, '18595898679', '0.00100000', 1530233077, '签到奖励'),
(700, 20016, '13339997637', '0.00100000', 1530244318, '签到奖励'),
(701, 20061, '18053827817', '0.00100000', 1530245127, '签到奖励'),
(702, 20000, '13164352999', '0.00100000', 1530280137, '签到奖励'),
(703, 20062, '15315481133', '0.00100000', 1530282715, '签到奖励'),
(704, 20056, '18803753918', '0.00100000', 1530286917, '签到奖励'),
(705, 20021, '13540373333', '0.00100000', 1530288190, '签到奖励'),
(706, 20016, '13339997637', '0.00100000', 1530289327, '签到奖励'),
(707, 20159, '18695693310', '0.00100000', 1530300217, '签到奖励'),
(708, 20000, '13164352999', '0.00100000', 1530305709, '签到奖励'),
(709, 20061, '18053827817', '0.00100000', 1530327456, '签到奖励'),
(710, 20002, '18318876315', '0.00100000', 1530327942, '签到奖励'),
(711, 20156, '18230344383', '0.00100000', 1530330127, '签到奖励'),
(712, 20033, '13073755270', '0.00100000', 1530340225, '签到奖励'),
(713, 20056, '18803753918', '0.00100000', 1530360095, '签到奖励'),
(714, 20163, '13387576668', '0.00100000', 1530360155, '签到奖励'),
(715, 20058, '15314099319', '0.00100000', 1530364455, '签到奖励'),
(716, 20164, '13103598345', '0.00100000', 1530441826, '签到奖励'),
(717, 20164, '13103598345', '0.00100000', 1530461395, '签到奖励'),
(718, 1, '18888888888', '0.00100000', 1530598652, '签到奖励'),
(719, 20164, '13103598345', '0.00100000', 1530628145, '签到奖励'),
(720, 1, '18888888888', '0.00100000', 1530635592, '签到奖励'),
(721, 1, '18888888888', '0.00100000', 1536741251, '签到奖励');

-- --------------------------------------------------------

--
-- 表的结构 `ds_member_award_log`
--

CREATE TABLE `ds_member_award_log` (
  `id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `send_type` tinyint(1) NOT NULL,
  `userortype_id` int(11) NOT NULL,
  `send_style` tinyint(1) NOT NULL,
  `num` int(11) NOT NULL,
  `add_time` int(11) NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8 ROW_FORMAT=COMPACT;

--
-- 转存表中的数据 `ds_member_award_log`
--

INSERT INTO `ds_member_award_log` (`id`, `user_id`, `send_type`, `userortype_id`, `send_style`, `num`, `add_time`) VALUES
(1, 20000, 1, 0, 1, 3, 1528687341);

-- --------------------------------------------------------

--
-- 表的结构 `ds_member_group`
--

CREATE TABLE `ds_member_group` (
  `groupid` tinyint(3) UNSIGNED NOT NULL,
  `level` tinyint(3) UNSIGNED NOT NULL DEFAULT '0',
  `name` char(15) NOT NULL,
  `tjjnum` int(10) UNSIGNED NOT NULL DEFAULT '0',
  `teamnum` int(10) UNSIGNED NOT NULL DEFAULT '0',
  `teamsuanli` decimal(11,2) UNSIGNED NOT NULL DEFAULT '0.00',
  `mysuanli` decimal(11,2) UNSIGNED NOT NULL DEFAULT '0.00',
  `csbl` decimal(11,2) UNSIGNED NOT NULL DEFAULT '0.00' COMMENT '出售倍率',
  `shouxu` decimal(11,2) UNSIGNED NOT NULL DEFAULT '0.00',
  `ldj` decimal(11,0) UNSIGNED NOT NULL DEFAULT '0',
  `status` tinyint(3) UNSIGNED NOT NULL DEFAULT '0',
  `addtime` int(11) UNSIGNED NOT NULL DEFAULT '0'
) ENGINE=MyISAM DEFAULT CHARSET=utf8 ROW_FORMAT=COMPACT;

--
-- 转存表中的数据 `ds_member_group`
--

INSERT INTO `ds_member_group` (`groupid`, `level`, `name`, `tjjnum`, `teamnum`, `teamsuanli`, `mysuanli`, `csbl`, `shouxu`, `ldj`, `status`, `addtime`) VALUES
(1, 1, '白铁矿工', 0, 1, '0.00', '80.00', '100.00', '0.30', '1', 1, 1487262445),
(2, 2, '青铜矿工', 10, 50, '50.00', '80.00', '1.20', '0.27', '2', 1, 1487262481),
(3, 3, '白银矿工', 30, 150, '300.00', '80.00', '1.50', '0.24', '3', 1, 1487262481),
(4, 4, '黄金矿工', 50, 1000, '1500.00', '80.00', '1.90', '0.21', '4', 1, 1487262481),
(5, 5, '铂金矿工', 80, 3000, '5000.00', '100.00', '2.40', '0.18', '5', 1, 1487262481),
(6, 6, '钻石矿工', 100, 5000, '10000.00', '200.00', '3.00', '0.15', '6', 1, 1487262481);

-- --------------------------------------------------------

--
-- 表的结构 `ds_member_recharge`
--

CREATE TABLE `ds_member_recharge` (
  `r_id` int(11) NOT NULL,
  `order_sn` varchar(100) NOT NULL,
  `fkzh` varchar(255) NOT NULL,
  `user_id` int(11) NOT NULL,
  `gbc` decimal(15,2) NOT NULL,
  `rmb` decimal(15,2) NOT NULL,
  `bili` varchar(30) NOT NULL,
  `status` tinyint(1) NOT NULL DEFAULT '0',
  `pay_type` varchar(30) NOT NULL,
  `note` varchar(100) NOT NULL,
  `add_time` int(11) NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COMMENT='会员充值表' ROW_FORMAT=COMPACT;

--
-- 转存表中的数据 `ds_member_recharge`
--

INSERT INTO `ds_member_recharge` (`r_id`, `order_sn`, `fkzh`, `user_id`, `gbc`, `rmb`, `bili`, `status`, `pay_type`, `note`, `add_time`) VALUES
(1, '201905301209076231', '', 1, '0.00', '100.00', '0', 1, '1004', '', 1559189347),
(2, '201906081929512661', '', 1, '0.00', '100.00', '0', 1, '1004', '', 1559993391),
(3, '201906132120538461', '', 1, '0.00', '100.00', '0', 1, '1004', '', 1560432053),
(4, '201906141923497591', '', 1, '0.00', '100.00', '0', 1, '1004', '', 1560511429),
(5, '201906142233402191', '', 1, '0.00', '100.00', '0', 0, '1004', '', 1560522820);

-- --------------------------------------------------------

--
-- 表的结构 `ds_message`
--

CREATE TABLE `ds_message` (
  `id` int(10) UNSIGNED NOT NULL,
  `from` varchar(45) NOT NULL DEFAULT '' COMMENT '发件人',
  `to` varchar(45) NOT NULL DEFAULT '' COMMENT '收件人',
  `subject` varchar(200) NOT NULL DEFAULT '' COMMENT '主题',
  `content` text NOT NULL COMMENT '内容',
  `reply` text NOT NULL COMMENT '回复',
  `hasview` tinyint(3) UNSIGNED NOT NULL DEFAULT '0' COMMENT '是否已读 0:未读 1:已读',
  `sendtime` int(10) UNSIGNED NOT NULL DEFAULT '0' COMMENT '发送时间',
  `writetime` int(10) UNSIGNED NOT NULL DEFAULT '0' COMMENT '回复时间',
  `type` varchar(255) DEFAULT NULL COMMENT '留言类型',
  `status` varchar(255) DEFAULT NULL COMMENT '状态'
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COMMENT='站内信息表' ROW_FORMAT=COMPACT;

--
-- 转存表中的数据 `ds_message`
--

INSERT INTO `ds_message` (`id`, `from`, `to`, `subject`, `content`, `reply`, `hasview`, `sendtime`, `writetime`, `type`, `status`) VALUES
(1, '18603865557', '', '我把支付宝账号填写成手机号了', '用手机号就可以找到我的支付宝账号，是否需要更改？', '您好，支付宝账号就是手机号', 1, 1529660103, 1529807483, NULL, '已回復'),
(2, '13103598345', '', '111', '1111', '', 0, 1530628408, 0, NULL, '处理中');

-- --------------------------------------------------------

--
-- 表的结构 `ds_node`
--

CREATE TABLE `ds_node` (
  `id` smallint(6) UNSIGNED NOT NULL,
  `name` varchar(20) NOT NULL DEFAULT '',
  `title` varchar(50) DEFAULT NULL,
  `status` tinyint(1) DEFAULT '0',
  `remark` varchar(255) DEFAULT NULL,
  `sort` smallint(6) UNSIGNED DEFAULT NULL,
  `pid` smallint(6) UNSIGNED NOT NULL,
  `level` tinyint(1) UNSIGNED NOT NULL
) ENGINE=MyISAM AVG_ROW_LENGTH=35 DEFAULT CHARSET=utf8 ROW_FORMAT=COMPACT;

--
-- 转存表中的数据 `ds_node`
--

INSERT INTO `ds_node` (`id`, `name`, `title`, `status`, `remark`, `sort`, `pid`, `level`) VALUES
(1, 'systemlogined', '后台应用', 1, '', 1, 0, 1),
(6, 'Rbac', 'Rbac权限控制', 1, '', 6, 1, 2),
(7, 'Index', '后台首页', 1, '', 1, 1, 2),
(10, 'index', '用户列表', 1, '', 1, 6, 3),
(11, 'role', '角色列表', 1, '', 1, 6, 3),
(12, 'node', '节点列表', 1, '', 1, 6, 3),
(16, 'index', '后台首页', 1, '', 1, 7, 3),
(17, 'Member', '会员管理', 1, '', 2, 1, 2),
(18, 'uncheck', '未审核会员', 1, '', 1, 17, 3),
(19, 'check', '会员查询', 1, '', 1, 17, 3),
(20, 'pw_list', '团队排位图', 1, '', 1, 17, 3),
(21, 'shu_list', '团队树形图', 1, '', 1, 17, 3),
(22, 'Jinbidetail', '资金管理', 1, '', 4, 1, 2),
(23, 'index', 'pv明细', 1, '', 1, 22, 3),
(24, 'paylists', '充值管理', 1, '', 1, 22, 3),
(25, 'emoneyWithdraw', '提现管理', 1, '', 1, 22, 3),
(26, 'shop', '商城管理', 1, '', 3, 1, 2),
(27, 'type_list', '分类列表', 1, '', 1, 26, 3),
(28, 'Info', '信息交流', 1, '', 5, 1, 2),
(29, 'announce', '公告管理', 1, '', 1, 28, 3),
(30, 'annType', '公告类别', 1, '', 1, 28, 3),
(31, 'msgReceive', '收件箱', 1, '', 1, 28, 3),
(32, 'msgSend', '发件箱', 1, '', 1, 28, 3),
(33, 'System', '系统设置', 1, '', 7, 1, 2),
(34, 'backUp', '数据备份', 1, '', 1, 33, 3),
(35, 'customSetting', '自定义配置', 1, '', 1, 33, 3),
(36, ' jiangjin', '奖金查询', 1, '', 1, 22, 3),
(37, 'member_group', '会员等级', 1, '', 1, 17, 3),
(38, 'lists', '商品列表', 1, '', 1, 26, 3),
(39, 'orderlist', '订单列表', 1, '', 1, 26, 3),
(40, 'paylist', '零售管理', 1, '', 1, 22, 3),
(41, 'jinzhongzi', '重消明细', 1, '', 1, 22, 3),
(42, 'point', '代金券明细', 1, '', 1, 22, 3),
(43, 'editPay', '零售操作', 1, '', 1, 22, 3),
(44, 'editPays', '充值操作', 1, '', 1, 22, 3),
(45, 'editEmoney', '提现操作', 1, '', 1, 22, 3),
(46, 'editPayhandles', '充值提交操作', 1, '', 1, 22, 3);

-- --------------------------------------------------------

--
-- 表的结构 `ds_order`
--

CREATE TABLE `ds_order` (
  `id` int(255) UNSIGNED NOT NULL,
  `user` varchar(30) DEFAULT NULL,
  `user_id` int(11) UNSIGNED NOT NULL,
  `project` varchar(30) DEFAULT NULL,
  `count` decimal(10,2) DEFAULT '0.00',
  `sumprice` decimal(10,2) NOT NULL,
  `addtime` varchar(30) DEFAULT NULL,
  `UG_getTime` int(11) UNSIGNED NOT NULL DEFAULT '0',
  `zt` int(10) NOT NULL DEFAULT '0',
  `sid` int(11) DEFAULT NULL,
  `imagepath` text,
  `yxzq` varchar(60) DEFAULT NULL COMMENT '可运行时间小时',
  `lixi` varchar(60) NOT NULL DEFAULT 'NULL' COMMENT '功率',
  `kjsl` varchar(255) DEFAULT NULL COMMENT '收益每小时',
  `kjbh` varchar(255) DEFAULT NULL,
  `already_profit` decimal(15,8) NOT NULL COMMENT '已经收益'
) ENGINE=MyISAM DEFAULT CHARSET=utf8 ROW_FORMAT=COMPACT;

--
-- 转存表中的数据 `ds_order`
--

INSERT INTO `ds_order` (`id`, `user`, `user_id`, `project`, `count`, `sumprice`, `addtime`, `UG_getTime`, `zt`, `sid`, `imagepath`, `yxzq`, `lixi`, `kjsl`, `kjbh`, `already_profit`) VALUES
(31319, '15936266096', 20001, '微型矿机（赠）', '0.00', '10.00', '2018-06-11 10:52:22', 1529905453, 1, 1, '/Public/Uploads/20180609/5b1be4d39ef83.png', '1440', '0.01', '0.00694444', 'S118554225', '2.35322187'),
(31320, '17737783816', 20003, '微型矿机（赠）', '0.00', '10.00', '2018-06-11 10:52:37', 1528685557, 1, 1, '/Public/Uploads/20180609/5b1be4d39ef83.png', '1440', '0.01', '0.00694444', 'S118555743', '0.00000000'),
(31321, '13164352999', 20000, '微型矿机（赠）', '0.00', '10.00', '2018-06-11 11:03:25', 1530250164, 1, 1, '/Public/Uploads/20180609/5b1be4d39ef83.png', '1440', '0.01', '0.00694444', 'S118620548', '3.01689430'),
(31322, '13164352999', 20000, '白银矿机', '0.00', '100.00', '2018-06-11 11:22:21', 1530338841, 1, 3, '/Public/Uploads/20180609/5b1be70c7f73e.png', '1440', '0.10', '0.08571429', 'Z118734147', '39.32143053'),
(31323, '18595898679', 20005, '微型矿机（赠）', '0.00', '10.00', '2018-06-11 12:06:44', 1530233102, 1, 1, '/Public/Uploads/20180611/5b1dedd2c1b76.png', '1440', '0.01', '0.00694444', 'S119000420', '2.97665318'),
(31324, '18803783999', 20006, '微型矿机（赠）', '0.00', '10.00', '2018-06-11 12:41:48', 1530285067, 1, 1, '/Public/Uploads/20180611/5b1dedd2c1b76.png', '1440', '0.01', '0.00694444', 'S119210830', '3.07283562'),
(31325, '15516019657', 20004, '微型矿机（赠）', '0.00', '10.00', '2018-06-11 12:50:17', 1529661440, 1, 1, '/Public/Uploads/20180611/5b1dedd2c1b76.png', '1440', '0.01', '0.00694444', 'S119261710', '1.86887033'),
(31326, '15238625511', 20007, '微型矿机（赠）', '0.00', '10.00', '2018-06-11 14:21:07', 1530186165, 1, 1, '/Public/Uploads/20180611/5b1dedd2c1b76.png', '1440', '0.01', '0.00694444', 'S119806799', '2.87055757'),
(31327, '18803783999', 20006, '微型矿机', '0.00', '10.00', '2018-06-11 19:12:34', 1530285062, 1, 2, '/Public/Uploads/20180611/5b1deda3d03f4.png', '1440', '0.01', '0.00694444', 'S111555434', '3.02759838'),
(31328, '17797752708', 20010, '微型矿机（赠）', '0.00', '10.00', '2018-06-11 19:43:40', 1530329471, 1, 1, '/Public/Uploads/20180611/5b1dedd2c1b76.png', '1440', '0.01', '0.00694444', 'S111742011', '3.10966428'),
(31329, '15936266096', 20001, '微型矿机', '0.00', '10.00', '2018-06-11 22:05:28', 1529905450, 1, 2, '/Public/Uploads/20180611/5b1deda3d03f4.png', '1440', '0.01', '0.00694444', 'S112592834', '2.27531104'),
(31330, '15055596222', 20008, '微型矿机（赠）', '0.00', '10.00', '2018-06-12 10:52:39', 1530347608, 1, 1, '/Public/Uploads/20180611/5b1dedd2c1b76.png', '1440', '0.01', '0.00694444', 'S127195937', '3.03944438'),
(31331, '13673673027', 20015, '微型矿机（赠）', '0.00', '10.00', '2018-06-12 17:12:56', 1530360875, 1, 1, '/Public/Uploads/20180611/5b1dedd2c1b76.png', '1440', '0.01', '0.00694444', 'S129477642', '3.02102239'),
(31332, '15200000908', 20014, '微型矿机（赠）', '0.00', '10.00', '2018-06-12 17:21:59', 1530282978, 1, 1, '/Public/Uploads/20180611/5b1dedd2c1b76.png', '1440', '0.01', '0.00694444', 'S129531932', '2.86971074'),
(31333, '13014509000', 20018, '微型矿机（赠）', '0.00', '10.00', '2018-06-12 19:56:31', 1528804591, 1, 1, '/Public/Uploads/20180611/5b1dedd2c1b76.png', '1440', '0.01', '0.00694444', 'S120459180', '0.00000000'),
(31334, '15055596222', 20008, '钻石矿机', '0.00', '10000.00', '2018-06-12 20:38:06', 1530347612, 1, 6, '/Public/Uploads/20180611/5b1df4906324d.png', '1440', '10.00', '8.33333333', 'S120708622', '3566.03240599'),
(31335, '17797752708', 20010, '钻石矿机', '0.00', '10000.00', '2018-06-12 20:55:59', 1530329473, 1, 6, '/Public/Uploads/20180611/5b1df4906324d.png', '1440', '10.00', '8.33333333', 'S120815941', '3521.56018380'),
(31336, '17797752708', 20010, '铂金矿机', '0.00', '5000.00', '2018-06-12 21:08:42', 1530329476, 1, 5, '/Public/Uploads/20180611/5b1df45327282.png', '1440', '5.00', '4.16666667', 'S120892274', '1759.90046436'),
(31337, '17797752708', 20010, '黄金矿机', '0.00', '1000.00', '2018-06-12 21:10:07', 1530329479, 1, 4, '/Public/Uploads/20180611/5b1df430e4025.png', '1440', '1.00', '0.69444444', 'S120900709', '293.30092406'),
(31338, '17797752708', 20010, '黄金矿机', '0.00', '1000.00', '2018-06-12 21:10:45', 1530329482, 1, 4, '/Public/Uploads/20180611/5b1df430e4025.png', '1440', '1.00', '0.69444444', 'S120904544', '293.29417255'),
(31339, '17797752708', 20010, '黄金矿机', '0.00', '1000.00', '2018-06-12 21:10:58', 1530329484, 1, 4, '/Public/Uploads/20180611/5b1df430e4025.png', '1440', '1.00', '0.69444444', 'S120905822', '293.29205061'),
(31340, '17797752708', 20010, '黄金矿机', '0.00', '1000.00', '2018-06-12 21:11:09', 1530329487, 1, 4, '/Public/Uploads/20180611/5b1df430e4025.png', '1440', '1.00', '0.69444444', 'S120906913', '293.29050739'),
(31341, '13339997637', 20016, '微型矿机（赠）', '0.00', '10.00', '2018-06-12 21:11:21', 1530348388, 1, 1, '/Public/Uploads/20180611/5b1dedd2c1b76.png', '1440', '0.01', '0.00694444', 'S120908106', '2.96934030'),
(31342, '17797752708', 20010, '黄金矿机', '0.00', '1000.00', '2018-06-12 21:11:27', 1530329494, 1, 4, '/Public/Uploads/20180611/5b1df430e4025.png', '1440', '1.00', '0.69444444', 'S120908711', '308.36766778'),
(31343, '18575675134', 20022, '微型矿机（赠）', '0.00', '10.00', '2018-06-12 22:30:27', 1528813827, 1, 1, '/Public/Uploads/20180611/5b1dedd2c1b76.png', '1440', '0.01', '0.00694444', 'S121382736', '0.00000000'),
(31344, '13673673027', 20015, '钻石矿机', '0.00', '10000.00', '2018-06-12 22:51:20', 1530360863, 1, 6, '/Public/Uploads/20180611/5b1df4906324d.png', '1440', '10.00', '8.33333333', 'S121508090', '3578.20138744'),
(31345, '13339997637', 20016, '钻石矿机', '0.00', '10000.00', '2018-06-12 22:54:42', 1530348392, 1, 6, '/Public/Uploads/20180611/5b1df4906324d.png', '1440', '10.00', '8.33333333', 'S121528227', '3548.86573934'),
(31346, '13339997637', 20016, '铂金矿机', '0.00', '5000.00', '2018-06-12 22:58:49', 1530348385, 1, 5, '/Public/Uploads/20180611/5b1df45327282.png', '1440', '5.00', '4.16666667', 'S121552939', '1774.13889034'),
(31347, '13673673027', 20015, '铂金矿机', '0.00', '5000.00', '2018-06-12 23:07:36', 1530360866, 1, 5, '/Public/Uploads/20180611/5b1df45327282.png', '1440', '5.00', '4.16666667', 'S121605624', '1787.97453844'),
(31348, '13339997637', 20016, '黄金矿机', '0.00', '1000.00', '2018-06-12 23:10:35', 1530348383, 1, 4, '/Public/Uploads/20180611/5b1df430e4025.png', '1440', '1.00', '0.69444444', 'S121623500', '295.55323886'),
(31349, '13339997637', 20016, '黄金矿机', '0.00', '1000.00', '2018-06-12 23:10:42', 1530348379, 1, 4, '/Public/Uploads/20180611/5b1df430e4025.png', '1440', '1.00', '0.69444444', 'S121624226', '295.55111693'),
(31350, '13673673027', 20015, '铂金矿机', '0.00', '5000.00', '2018-06-12 23:15:33', 1530360868, 1, 5, '/Public/Uploads/20180611/5b1df45327282.png', '1440', '5.00', '4.16666667', 'S121653381', '1787.42476998'),
(31351, '15055596222', 20008, '钻石矿机', '0.00', '10000.00', '2018-06-13 00:37:58', 1530347615, 1, 6, '/Public/Uploads/20180611/5b1df4906324d.png', '1440', '10.00', '8.33333333', 'S132147811', '3532.72453560'),
(31352, '15238625511', 20007, '钻石矿机', '0.00', '10000.00', '2018-06-13 07:36:46', 1530186167, 1, 6, '/Public/Uploads/20180611/5b1df4906324d.png', '1440', '10.00', '8.33333333', 'S134660684', '3100.83564691'),
(31353, '18639736868', 20023, '微型矿机（赠）', '0.00', '10.00', '2018-06-13 08:42:56', 1530233130, 1, 1, '/Public/Uploads/20180611/5b1dedd2c1b76.png', '1440', '0.01', '0.00694444', 'S135057670', '2.66696204'),
(31354, '13540373333', 20021, '微型矿机（赠）', '0.00', '10.00', '2018-06-13 13:33:59', 1530357907, 1, 1, '/Public/Uploads/20180611/5b1dedd2c1b76.png', '1440', '0.01', '0.00694444', 'S136803917', '2.87397189'),
(31355, '15055596222', 20008, '钻石矿机', '0.00', '10000.00', '2018-06-13 13:37:27', 1530347617, 1, 6, '/Public/Uploads/20180611/5b1df4906324d.png', '1440', '10.00', '8.33333333', 'S136824732', '3424.46759123'),
(31356, '15055596222', 20008, '铂金矿机', '0.00', '5000.00', '2018-06-13 14:36:26', 1530347620, 1, 5, '/Public/Uploads/20180611/5b1df45327282.png', '1440', '5.00', '4.16666667', 'S137178674', '1708.14120506'),
(31357, '15055596222', 20008, '铂金矿机', '0.00', '5000.00', '2018-06-13 14:36:55', 1530347623, 1, 5, '/Public/Uploads/20180611/5b1df45327282.png', '1440', '5.00', '4.16666667', 'S137181552', '1708.11111248'),
(31358, '18318876315', 20002, '微型矿机（赠）', '0.00', '10.00', '2018-06-13 15:13:47', 1530327971, 1, 1, '/Public/Uploads/20180611/5b1dedd2c1b76.png', '1440', '0.01', '0.00694444', 'S137402702', '2.80467411'),
(31359, '18627115588', 20030, '微型矿机（赠）', '0.00', '10.00', '2018-06-13 18:46:44', 1530260276, 1, 1, '/Public/Uploads/20180611/5b1dedd2c1b76.png', '1440', '0.01', '0.00694444', 'S138680417', '2.64944275'),
(31360, '15238625511', 20007, '铂金矿机', '0.00', '5000.00', '2018-06-13 22:43:44', 1530186172, 1, 5, '/Public/Uploads/20180611/5b1df45327282.png', '1440', '5.00', '4.16666667', 'S130102474', '1487.43981600'),
(31361, '15238625511', 20007, '黄金矿机', '0.00', '1000.00', '2018-06-13 22:44:40', 1530186169, 1, 4, '/Public/Uploads/20180611/5b1df430e4025.png', '1440', '1.00', '0.69444444', 'S130108003', '247.89525305'),
(31362, '15238625511', 20007, '白银矿机', '0.00', '100.00', '2018-06-13 22:44:59', 1530186174, 1, 3, '/Public/Uploads/20180611/5b1df30d710a5.png', '1440', '0.10', '0.08571429', 'S130109981', '30.59702533'),
(31363, '13673673027', 20015, '钻石矿机', '0.00', '10000.00', '2018-06-14 12:12:04', 1530360870, 1, 6, '/Public/Uploads/20180611/5b1df4906324d.png', '1440', '10.00', '8.33333333', 'S144952416', '3267.00462835'),
(31364, '13673673027', 20015, '钻石矿机', '0.00', '10000.00', '2018-06-14 12:12:15', 1530360871, 1, 6, '/Public/Uploads/20180611/5b1df4906324d.png', '1440', '10.00', '8.33333333', 'S144953547', '3266.98148015'),
(31365, '18726577272', 20032, '微型矿机（赠）', '0.00', '10.00', '2018-06-14 12:16:20', 1530280409, 1, 1, '/Public/Uploads/20180611/5b1dedd2c1b76.png', '1440', '0.01', '0.00694444', 'S144978089', '2.56679813'),
(31366, '13073755270', 20033, '微型矿机（赠）', '0.00', '10.00', '2018-06-14 12:16:42', 1529831986, 1, 1, '/Public/Uploads/20180611/5b1dedd2c1b76.png', '1440', '0.01', '0.00694444', 'S144980231', '1.70174274'),
(31367, '18639736868', 20023, '铂金矿机', '0.00', '5000.00', '2018-06-14 12:50:00', 1530322594, 1, 5, '/Public/Uploads/20180611/5b1df45327282.png', '1440', '5.00', '4.16666667', 'S145180084', '1586.56713090'),
(31368, '18639736868', 20023, '铂金矿机', '0.00', '5000.00', '2018-06-14 12:50:32', 1530322590, 1, 5, '/Public/Uploads/20180611/5b1df45327282.png', '1440', '5.00', '4.16666667', 'S145183248', '1586.52546425'),
(31369, '18639736868', 20023, '钻石矿机', '0.00', '10000.00', '2018-06-14 12:50:46', 1530322587, 1, 6, '/Public/Uploads/20180611/5b1df4906324d.png', '1440', '10.00', '8.33333333', 'S145184688', '3173.01157280'),
(31370, '18726577272', 20032, '钻石矿机', '0.00', '10000.00', '2018-06-14 14:04:43', 1530347668, 1, 6, '/Public/Uploads/20180611/5b1df4906324d.png', '1440', '10.00', '8.33333333', 'S145628383', '3220.79860981'),
(31371, '18726577272', 20032, '钻石矿机', '0.00', '10000.00', '2018-06-14 14:04:58', 1530347672, 1, 6, '/Public/Uploads/20180611/5b1df4906324d.png', '1440', '10.00', '8.33333333', 'S145629844', '3220.77314685'),
(31372, '15837886090', 20034, '微型矿机（赠）', '0.00', '10.00', '2018-06-14 21:02:22', 1528981342, 1, 1, '/Public/Uploads/20180611/5b1dedd2c1b76.png', '1440', '0.01', '0.00694444', 'S148134244', '0.00000000'),
(31373, '13540373333', 20021, '钻石矿机', '0.00', '10000.00', '2018-06-14 22:15:25', 1530357909, 1, 6, '/Public/Uploads/20180611/5b1df4906324d.png', '1440', '10.00', '8.33333333', 'S148572501', '3176.35185058'),
(31374, '13540373333', 20021, '钻石矿机', '0.00', '10000.00', '2018-06-14 22:15:47', 1530357912, 1, 6, '/Public/Uploads/20180611/5b1df4906324d.png', '1440', '10.00', '8.33333333', 'S148574780', '3176.30786912'),
(31375, '18803783999', 20006, '钻石矿机', '0.00', '10000.00', '2018-06-15 00:35:52', 1530285060, 1, 6, '/Public/Uploads/20180611/5b1df4906324d.png', '1440', '10.00', '8.33333333', 'S159415264', '2988.21296177'),
(31376, '18803783999', 20006, '钻石矿机', '0.00', '10000.00', '2018-06-15 00:36:08', 1530285056, 1, 6, '/Public/Uploads/20180611/5b1df4906324d.png', '1440', '10.00', '8.33333333', 'S159416807', '2988.16666546'),
(31377, '17756235430', 20037, '微型矿机（赠）', '0.00', '10.00', '2018-06-15 11:51:38', 1529034698, 1, 1, '/Public/Uploads/20180611/5b1dedd2c1b76.png', '1440', '0.01', '0.00694444', 'S153469877', '0.00000000'),
(31378, '15200000908', 20014, '钻石矿机', '0.00', '10000.00', '2018-06-15 13:53:04', 1530282976, 1, 6, '/Public/Uploads/20180611/5b1df4906324d.png', '1440', '10.00', '8.33333333', 'S154198417', '2872.66666552'),
(31379, '15200000908', 20014, '钻石矿机', '0.00', '10000.00', '2018-06-15 13:53:37', 1530282973, 1, 6, '/Public/Uploads/20180611/5b1df4906324d.png', '1440', '10.00', '8.33333333', 'S154201737', '2872.58333218'),
(31380, '15200000908', 20014, '钻石矿机', '0.00', '10000.00', '2018-06-15 13:54:12', 1530282971, 1, 6, '/Public/Uploads/20180611/5b1df4906324d.png', '1440', '10.00', '8.33333333', 'S154205233', '2872.49768403'),
(31381, '13864643525', 20038, '微型矿机（赠）', '0.00', '10.00', '2018-06-15 16:28:48', 1530194827, 1, 1, '/Public/Uploads/20180611/5b1dedd2c1b76.png', '1440', '0.01', '0.00694444', 'S155132822', '2.20582229'),
(31382, '13903782436', 20045, '微型矿机（赠）', '0.00', '10.00', '2018-06-15 17:46:03', 1529055963, 1, 1, '/Public/Uploads/20180611/5b1dedd2c1b76.png', '1440', '0.01', '0.00694444', 'S155596312', '0.00000000'),
(31383, '15188332982', 20036, '微型矿机（赠）', '0.00', '10.00', '2018-06-15 21:09:34', 1530142228, 1, 1, '/Public/Uploads/20180611/5b1dedd2c1b76.png', '1440', '0.01', '0.00694444', 'S156817469', '2.07186210'),
(31384, '18805035962', 20049, '微型矿机（赠）', '0.00', '10.00', '2018-06-16 11:45:14', 1530357608, 1, 1, '/Public/Uploads/20180611/5b1dedd2c1b76.png', '1440', '0.01', '0.00694444', 'S162071425', '2.38598228'),
(31385, '18803783999', 20006, '钻石矿机', '0.00', '10000.00', '2018-06-16 16:41:05', 1530285050, 1, 6, '/Public/Uploads/20180611/5b1df4906324d.png', '1440', '10.00', '8.33333333', 'S163846558', '2654.13194339'),
(31386, '13193887071', 20052, '微型矿机（赠）', '0.00', '10.00', '2018-06-16 18:01:25', 1530330867, 1, 1, '/Public/Uploads/20180611/5b1dedd2c1b76.png', '1440', '0.01', '0.00694444', 'S164328577', '2.29085890'),
(31387, '15257570828', 20053, '微型矿机（赠）', '0.00', '10.00', '2018-06-17 09:45:54', 1530137263, 1, 1, '/Public/Uploads/20180611/5b1dedd2c1b76.png', '1440', '0.01', '0.00694444', 'S179995443', '1.80807946'),
(31388, '18803783999', 20006, '铂金矿机', '0.00', '5000.00', '2018-06-17 12:15:55', 1530285048, 1, 5, '/Public/Uploads/20180611/5b1df45327282.png', '1440', '5.00', '4.16666667', 'S170895544', '1245.47801025'),
(31389, '18803783999', 20006, '铂金矿机', '0.00', '5000.00', '2018-06-17 12:16:39', 1530285043, 1, 5, '/Public/Uploads/20180611/5b1df45327282.png', '1440', '5.00', '4.16666667', 'S170899955', '1245.42129729'),
(31390, '18803783999', 20006, '铂金矿机', '0.00', '5000.00', '2018-06-17 12:17:03', 1530285040, 1, 5, '/Public/Uploads/20180611/5b1df45327282.png', '1440', '5.00', '4.16666667', 'S170902355', '1245.39004728'),
(31391, '18803783999', 20006, '铂金矿机', '0.00', '5000.00', '2018-06-17 12:17:04', 1530285037, 1, 5, '/Public/Uploads/20180611/5b1df45327282.png', '1440', '5.00', '4.16666667', 'S170902467', '1245.38541767'),
(31392, '18803783999', 20006, '铂金矿机', '0.00', '5000.00', '2018-06-17 12:17:06', 1530285034, 1, 5, '/Public/Uploads/20180611/5b1df45327282.png', '1440', '5.00', '4.16666667', 'S170902637', '1245.37963063'),
(31393, '13014509000', 20018, '钻石矿机', '0.00', '10000.00', '2018-06-17 16:47:51', 1529225271, 1, 6, '/Public/Uploads/20180611/5b1df4906324d.png', '1440', '10.00', '8.33333333', 'S172527158', '0.00000000'),
(31394, '13014509000', 20018, '钻石矿机', '0.00', '10000.00', '2018-06-17 17:00:59', 1529226059, 1, 6, '/Public/Uploads/20180611/5b1df4906324d.png', '1440', '10.00', '8.33333333', 'S172605918', '0.00000000'),
(31395, '18803783999', 20006, '黄金矿机', '0.00', '1000.00', '2018-06-17 17:49:36', 1530285030, 1, 4, '/Public/Uploads/20180611/5b1df430e4025.png', '1440', '1.00', '0.69444444', 'S172897676', '203.71411907'),
(31396, '18803783999', 20006, '黄金矿机', '0.00', '1000.00', '2018-06-17 17:49:36', 1530285028, 1, 4, '/Public/Uploads/20180611/5b1df430e4025.png', '1440', '1.00', '0.69444444', 'S172897652', '203.71373326'),
(31397, '18803783999', 20006, '黄金矿机', '0.00', '1000.00', '2018-06-18 09:45:39', 1530285026, 1, 4, '/Public/Uploads/20180611/5b1df430e4025.png', '1440', '1.00', '0.69444444', 'S188633943', '192.64795404'),
(31398, '18803783999', 20006, '黄金矿机', '0.00', '1000.00', '2018-06-18 09:45:53', 1530285024, 1, 4, '/Public/Uploads/20180611/5b1df430e4025.png', '1440', '1.00', '0.69444444', 'S188635324', '192.64486759'),
(31399, '18803783999', 20006, '黄金矿机', '0.00', '1000.00', '2018-06-18 09:46:04', 1530285022, 1, 4, '/Public/Uploads/20180611/5b1df430e4025.png', '1440', '1.00', '0.69444444', 'S188636430', '192.64235989'),
(31400, '15055596222', 20008, '铂金矿机', '0.00', '5000.00', '2018-06-19 10:27:35', 1530347626, 1, 5, '/Public/Uploads/20180611/5b1df45327282.png', '1440', '5.00', '4.16666667', 'S197525561', '1125.42939904'),
(31401, '13898572828', 20050, '微型矿机（赠）', '0.00', '10.00', '2018-06-19 17:59:21', 1530315564, 1, 1, '/Public/Uploads/20180611/5b1dedd2c1b76.png', '1440', '0.01', '0.00694444', 'S190236146', '1.76157874'),
(31402, '18530868278', 20055, '微型矿机（赠）', '0.00', '10.00', '2018-06-19 18:23:09', 1529403855, 1, 1, '/Public/Uploads/20180611/5b1dedd2c1b76.png', '1440', '0.01', '0.00694444', 'S190378942', '0.00012731'),
(31403, '13540373333', 20021, '钻石矿机', '0.00', '10000.00', '2018-06-19 22:41:24', 1530357915, 1, 6, '/Public/Uploads/20180611/5b1df4906324d.png', '1440', '10.00', '8.33333333', 'S191928498', '2172.75694358'),
(31404, '15288901686', 20057, '微型矿机（赠）', '0.00', '10.00', '2018-06-20 17:03:30', 1530322770, 1, 1, '/Public/Uploads/20180611/5b1dedd2c1b76.png', '1440', '0.01', '0.00694444', 'S208541057', '1.61527675'),
(31405, '15314099319', 20058, '微型矿机（赠）', '0.00', '10.00', '2018-06-20 17:04:01', 1530363359, 1, 1, '/Public/Uploads/20180611/5b1dedd2c1b76.png', '1440', '0.01', '0.00694444', 'S208544191', '1.69351358'),
(31406, '18661313913', 20059, '微型矿机（赠）', '0.00', '10.00', '2018-06-20 17:04:20', 1530284581, 1, 1, '/Public/Uploads/20180611/5b1dedd2c1b76.png', '1440', '0.01', '0.00694444', 'S208546087', '1.54151329'),
(31407, '17797752708', 20010, '黄金矿机', '0.00', '1000.00', '2018-06-20 18:26:45', 1530329491, 1, 4, '/Public/Uploads/20180611/5b1df430e4025.png', '1440', '1.00', '0.69444444', 'S209040584', '161.86072427'),
(31408, '17797752708', 20010, '黄金矿机', '0.00', '1000.00', '2018-06-20 18:27:02', 1530329497, 1, 4, '/Public/Uploads/20180611/5b1df430e4025.png', '1440', '1.00', '0.69444444', 'S209042261', '161.85860237'),
(31409, '15315481133', 20062, '微型矿机（赠）', '0.00', '10.00', '2018-06-21 01:37:29', 1530281846, 1, 1, '/Public/Uploads/20180611/5b1dedd2c1b76.png', '1440', '0.01', '0.00833330', 'S211624955', '1.77220819'),
(31410, '13963018917', 20064, '微型矿机（赠）', '0.00', '10.00', '2018-06-21 01:37:46', 1530049274, 1, 1, '/Public/Uploads/20180611/5b1dedd2c1b76.png', '1440', '0.01', '0.00833330', 'S211626693', '1.23380988'),
(31411, '18236437259', 20066, '微型矿机（赠）', '0.00', '10.00', '2018-06-21 01:38:03', 1529516283, 1, 1, '/Public/Uploads/20180611/5b1dedd2c1b76.png', '1440', '0.01', '0.00833330', 'S211628365', '0.00000000'),
(31412, '18053827817', 20061, '微型矿机（赠）', '0.00', '10.00', '2018-06-21 09:49:48', 1530327446, 1, 1, '/Public/Uploads/20180611/5b1dedd2c1b76.png', '1440', '0.01', '0.00833330', 'S214578804', '1.80938628'),
(31413, '15315481133', 20062, '钻石矿机', '0.00', '10000.00', '2018-06-21 11:07:07', 1530286358, 1, 6, '/Public/Uploads/20180611/5b1df4906324d.png', '1440', '10.00', '8.33333333', 'S215042759', '1703.54398083'),
(31414, '15315481133', 20062, '钻石矿机', '0.00', '10000.00', '2018-06-21 12:29:03', 1530286355, 1, 6, '/Public/Uploads/20180611/5b1df4906324d.png', '1440', '10.00', '8.33333333', 'S215534382', '1692.15740675'),
(31415, '15897755663', 20069, '微型矿机（赠）', '0.00', '10.00', '2018-06-21 14:03:01', 1530290772, 1, 1, '/Public/Uploads/20180611/5b1dedd2c1b76.png', '1440', '0.01', '0.00833330', 'S216098196', '1.68932426'),
(31416, '13339997637', 20016, '铂金矿机', '0.00', '5000.00', '2018-06-21 15:53:23', 1530348377, 1, 5, '/Public/Uploads/20180611/5b1df45327282.png', '1440', '5.00', '4.16666667', 'S216760326', '903.67361184'),
(31417, '13598442460', 20074, '微型矿机（赠）', '0.00', '10.00', '2018-06-21 21:08:40', 1529586520, 1, 1, '/Public/Uploads/20180611/5b1dedd2c1b76.png', '1440', '0.01', '0.00833330', 'S218652038', '0.00000000'),
(31418, '15314099319', 20058, '微型矿机', '0.00', '10.00', '2018-06-22 06:42:15', 1530363357, 1, 2, '/Public/Uploads/20180611/5b1deda3d03f4.png', '1440', '0.01', '0.00833333', 'S222093512', '1.71856876'),
(31419, '15314099319', 20058, '微型矿机', '0.00', '10.00', '2018-06-22 06:42:25', 1530363355, 1, 2, '/Public/Uploads/20180611/5b1deda3d03f4.png', '1440', '0.01', '0.00833333', 'S222094586', '1.71854099'),
(31420, '13425527320', 20063, '微型矿机（赠）', '0.00', '10.00', '2018-06-22 10:18:59', 1529633939, 1, 1, '/Public/Uploads/20180611/5b1dedd2c1b76.png', '1440', '0.01', '0.00833330', 'S223393944', '0.00000000'),
(31421, '13307173331', 20082, '微型矿机（赠）', '0.00', '10.00', '2018-06-22 15:43:04', 1530244412, 1, 1, '/Public/Uploads/20180611/5b1dedd2c1b76.png', '1440', '0.01', '0.00833330', 'S225338499', '1.36811490'),
(31422, '18137863335', 20084, '微型矿机（赠）', '0.00', '10.00', '2018-06-22 15:43:18', 1530014734, 1, 1, '/Public/Uploads/20180611/5b1dedd2c1b76.png', '1440', '0.01', '0.00833330', 'S225339898', '0.83642259'),
(31423, '13307173331', 20082, '钻石矿机', '0.00', '10000.00', '2018-06-22 16:48:53', 1530244408, 1, 6, '/Public/Uploads/20180611/5b1df4906324d.png', '1440', '10.00', '8.33333333', 'S225733304', '1358.96990686'),
(31424, '18137863335', 20084, '黄金矿机', '0.00', '1000.00', '2018-06-22 17:31:54', 1530014737, 1, 4, '/Public/Uploads/20180611/5b1df430e4025.png', '1440', '1.00', '0.83333333', 'S225991498', '82.13495337'),
(31425, '13937858275', 20039, '微型矿机（赠）', '0.00', '10.00', '2018-06-22 17:39:53', 1530329307, 1, 1, '/Public/Uploads/20180611/5b1dedd2c1b76.png', '1440', '0.01', '0.00833330', 'S226039331', '1.54840582'),
(31426, '18603865557', 20087, '微型矿机（赠）', '0.00', '10.00', '2018-06-22 17:40:07', 1530244557, 1, 1, '/Public/Uploads/20180611/5b1dedd2c1b76.png', '1440', '0.01', '0.00833330', 'S226040716', '1.35219366'),
(31427, '18336193888', 20093, '微型矿机（赠）', '0.00', '10.00', '2018-06-22 19:22:28', 1529672777, 1, 1, '/Public/Uploads/20180611/5b1dedd2c1b76.png', '1440', '0.01', '0.00833330', 'S226654857', '0.01441892'),
(31428, '18336193888', 20093, '白银矿机', '0.00', '100.00', '2018-06-22 21:05:59', 1529672759, 1, 3, '/Public/Uploads/20180611/5b1df30d710a5.png', '1440', '0.10', '0.08333333', 'S227275972', '0.00000000'),
(31429, '15314099319', 20058, '微型矿机', '0.00', '10.00', '2018-06-23 07:46:04', 1530363353, 1, 2, '/Public/Uploads/20180611/5b1deda3d03f4.png', '1440', '0.01', '0.00833333', 'S231116437', '1.50969615'),
(31430, '15314099319', 20058, '微型矿机', '0.00', '10.00', '2018-06-23 07:46:16', 1530363351, 1, 2, '/Public/Uploads/20180611/5b1deda3d03f4.png', '1440', '0.01', '0.00833333', 'S231117621', '1.50966375'),
(31431, '15314099319', 20058, '微型矿机', '0.00', '10.00', '2018-06-23 07:46:26', 1530363348, 1, 2, '/Public/Uploads/20180611/5b1deda3d03f4.png', '1440', '0.01', '0.00833333', 'S231118664', '1.50963367'),
(31432, '15314099319', 20058, '微型矿机', '0.00', '10.00', '2018-06-23 08:58:21', 1530363346, 1, 2, '/Public/Uploads/20180611/5b1deda3d03f4.png', '1440', '0.01', '0.00833333', 'S231550173', '1.49964059'),
(31433, '15839976659', 20089, '微型矿机（赠）', '0.00', '10.00', '2018-06-23 10:21:23', 1529720483, 1, 1, '/Public/Uploads/20180611/5b1dedd2c1b76.png', '1440', '0.01', '0.00833330', 'S232048336', '0.00000000'),
(31434, '15315481133', 20062, '钻石矿机', '0.00', '10000.00', '2018-06-23 10:59:42', 1530286353, 1, 6, '/Public/Uploads/20180611/5b1df4906324d.png', '1440', '10.00', '8.33333333', 'S232278234', '1304.56249948'),
(31435, '17070256888', 20086, '微型矿机（赠）', '0.00', '10.00', '2018-06-23 11:59:31', 1529726371, 1, 1, '/Public/Uploads/20180611/5b1dedd2c1b76.png', '1440', '0.01', '0.00833330', 'S232637100', '0.00000000'),
(31436, '18627115588', 20030, '钻石矿机', '0.00', '10000.00', '2018-06-23 17:47:12', 1530341446, 1, 6, '/Public/Uploads/20180611/5b1df4906324d.png', '1440', '10.00', '8.33333333', 'S234723271', '1375.49536982'),
(31437, '18530807318', 20054, '微型矿机（赠）', '0.00', '10.00', '2018-06-23 18:15:51', 1529748951, 1, 1, '/Public/Uploads/20180611/5b1dedd2c1b76.png', '1440', '0.01', '0.00833330', 'S234895183', '0.00000000'),
(31438, '18803753918', 20056, '微型矿机（赠）', '0.00', '10.00', '2018-06-23 18:16:04', 1529748964, 1, 1, '/Public/Uploads/20180611/5b1dedd2c1b76.png', '1440', '0.01', '0.00833330', 'S234896453', '0.00000000'),
(31439, '18627115588', 20030, '钻石矿机', '0.00', '10000.00', '2018-06-23 18:18:28', 1530341444, 1, 6, '/Public/Uploads/20180611/5b1df4906324d.png', '1440', '10.00', '8.33333333', 'S234910863', '1371.14814760'),
(31440, '13260296142', 20095, '微型矿机（赠）', '0.00', '10.00', '2018-06-23 19:05:49', 1530128710, 1, 1, '/Public/Uploads/20180611/5b1dedd2c1b76.png', '1440', '0.01', '0.00833330', 'S235194945', '0.87212845'),
(31441, '13949424484', 20094, '微型矿机（赠）', '0.00', '10.00', '2018-06-23 19:06:48', 1529752008, 1, 1, '/Public/Uploads/20180611/5b1dedd2c1b76.png', '1440', '0.01', '0.00833330', 'S235200866', '0.00000000'),
(31442, '13949424484', 20094, '钻石矿机', '0.00', '10000.00', '2018-06-23 19:15:15', 1529752515, 1, 6, '/Public/Uploads/20180611/5b1df4906324d.png', '1440', '10.00', '8.33333333', 'S235251519', '0.00000000'),
(31443, '13949424484', 20094, '钻石矿机', '0.00', '10000.00', '2018-06-23 19:15:25', 1529752525, 1, 6, '/Public/Uploads/20180611/5b1df4906324d.png', '1440', '10.00', '8.33333333', 'S235252572', '0.00000000'),
(31444, '13949424484', 20094, '钻石矿机', '0.00', '10000.00', '2018-06-23 19:15:34', 1530068141, 1, 6, '/Public/Uploads/20180611/5b1df4906324d.png', '1440', '10.00', '8.33333333', 'S235253409', '730.57175897'),
(31445, '18627115588', 20030, '钻石矿机', '0.00', '10000.00', '2018-06-23 19:20:59', 1530341441, 1, 6, '/Public/Uploads/20180611/5b1df4906324d.png', '1440', '10.00', '8.33333333', 'S235285912', '1362.45833280'),
(31446, '15670788858', 20097, '微型矿机（赠）', '0.00', '10.00', '2018-06-23 20:04:20', 1529755460, 1, 1, '/Public/Uploads/20180611/5b1dedd2c1b76.png', '1440', '0.01', '0.00833330', 'S235546000', '0.00000000'),
(31447, '15670788858', 20097, '钻石矿机', '0.00', '10000.00', '2018-06-23 20:25:03', 1529756703, 1, 6, '/Public/Uploads/20180611/5b1df4906324d.png', '1440', '10.00', '8.33333333', 'S235670332', '0.00000000'),
(31448, '13169509106', 20075, '微型矿机（赠）', '0.00', '10.00', '2018-06-24 06:13:37', 1529792017, 1, 1, '/Public/Uploads/20180611/5b1dedd2c1b76.png', '1440', '0.01', '0.00833330', 'S249201757', '0.00000000'),
(31449, '13164352999', 20000, '钻石矿机', '0.00', '10000.00', '2018-06-24 06:28:23', 1530338838, 1, 6, '/Public/Uploads/20180611/5b1df4906324d.png', '1440', '10.00', '8.33333333', 'S249290381', '1263.73842542'),
(31450, '15315481133', 20062, '黄金矿机', '0.00', '1000.00', '2018-06-24 10:06:46', 1530286361, 1, 4, '/Public/Uploads/20180611/5b1df430e4025.png', '1440', '1.00', '0.83333333', 'S240600629', '111.19328661'),
(31451, '13253567698', 20101, '微型矿机（赠）', '0.00', '10.00', '2018-06-24 21:43:22', 1529847802, 1, 1, '/Public/Uploads/20180611/5b1dedd2c1b76.png', '1440', '0.01', '0.00833330', 'S244780279', '0.00000000'),
(31452, '15907729146', 20104, '微型矿机（赠）', '0.00', '10.00', '2018-06-24 23:27:11', 1529854031, 1, 1, '/Public/Uploads/20180611/5b1dedd2c1b76.png', '1440', '0.01', '0.00833330', 'S245403148', '0.00000000'),
(31453, '13124394117', 20103, '微型矿机（赠）', '0.00', '10.00', '2018-06-25 10:44:35', 1530312865, 1, 1, '/Public/Uploads/20180611/5b1dedd2c1b76.png', '1440', '0.01', '0.00833330', 'S259467505', '0.96802852'),
(31454, '15315481133', 20062, '黄金矿机', '0.00', '1000.00', '2018-06-25 11:21:48', 1530286364, 1, 4, '/Public/Uploads/20180611/5b1df430e4025.png', '1440', '1.00', '0.83333333', 'S259690861', '90.15185149'),
(31455, '15055596222', 20008, '铂金矿机', '0.00', '5000.00', '2018-06-25 11:44:03', 1530347628, 1, 5, '/Public/Uploads/20180611/5b1df45327282.png', '1440', '5.00', '4.16666667', 'S259824306', '520.12152819'),
(31456, '18912060699', 20109, '微型矿机（赠）', '0.00', '10.00', '2018-06-25 15:07:10', 1529910430, 1, 1, '/Public/Uploads/20180611/5b1dedd2c1b76.png', '1440', '0.01', '0.00833330', 'S251043021', '0.00000000'),
(31457, '13415062948', 20110, '微型矿机（赠）', '0.00', '10.00', '2018-06-25 15:07:32', 1530329720, 1, 1, '/Public/Uploads/20180611/5b1dedd2c1b76.png', '1440', '0.01', '0.00833330', 'S251045233', '0.97052390'),
(31458, '18530807318', 20054, '钻石矿机', '0.00', '10000.00', '2018-06-25 16:36:57', 1529915817, 1, 6, '/Public/Uploads/20180611/5b1df4906324d.png', '1440', '10.00', '8.33333333', 'S251581732', '0.00000000'),
(31459, '18319283191', 20047, '微型矿机（赠）', '0.00', '10.00', '2018-06-25 17:08:33', 1530328643, 1, 1, '/Public/Uploads/20180611/5b1dedd2c1b76.png', '1440', '0.01', '0.00833330', 'S251771389', '0.95122304'),
(31460, '13614995074', 20105, '微型矿机（赠）', '0.00', '10.00', '2018-06-25 17:08:49', 1530307170, 1, 1, '/Public/Uploads/20180611/5b1dedd2c1b76.png', '1440', '0.01', '0.00833330', 'S251772915', '0.90148018'),
(31461, '13333770023', 20112, '微型矿机（赠）', '0.00', '10.00', '2018-06-25 17:22:31', 1529918687, 1, 1, '/Public/Uploads/20180611/5b1dedd2c1b76.png', '1440', '0.01', '0.00833330', 'S251855104', '0.00031481'),
(31462, '13304994936', 20120, '微型矿机（赠）', '0.00', '10.00', '2018-06-26 08:20:47', 1530307261, 1, 1, '/Public/Uploads/20180611/5b1dedd2c1b76.png', '1440', '0.01', '0.00833330', 'S267244798', '0.77502930'),
(31463, '15841286475', 20116, '微型矿机（赠）', '0.00', '10.00', '2018-06-26 08:21:08', 1530307217, 1, 1, '/Public/Uploads/20180611/5b1dedd2c1b76.png', '1440', '0.01', '0.00833330', 'S267246842', '0.77487884'),
(31464, '13414072853', 20113, '微型矿机（赠）', '0.00', '10.00', '2018-06-26 08:21:30', 1530301756, 1, 1, '/Public/Uploads/20180611/5b1dedd2c1b76.png', '1440', '0.01', '0.00833330', 'S267249032', '0.76218676'),
(31465, '18306555088', 20108, '微型矿机（赠）', '0.00', '10.00', '2018-06-26 08:21:42', 1530172863, 1, 1, '/Public/Uploads/20180611/5b1dedd2c1b76.png', '1440', '0.01', '0.00833330', 'S267250229', '0.46379676'),
(31466, '13428317723', 20128, '微型矿机（赠）', '0.00', '10.00', '2018-06-26 13:51:53', 1530025045, 1, 1, '/Public/Uploads/20180611/5b1dedd2c1b76.png', '1440', '0.01', '0.00833330', 'S269231322', '0.07576822'),
(31467, '13703671272', 20072, '微型矿机（赠）', '0.00', '10.00', '2018-06-26 13:52:07', 1530280571, 1, 1, '/Public/Uploads/20180611/5b1dedd2c1b76.png', '1440', '0.01', '0.00833330', 'S269232716', '0.66722881'),
(31468, '18337824444', 20100, '微型矿机（赠）', '0.00', '10.00', '2018-06-26 17:23:10', 1530004990, 1, 1, '/Public/Uploads/20180611/5b1dedd2c1b76.png', '1440', '0.01', '0.00833330', 'S260499042', '0.00000000'),
(31469, '15314099319', 20058, '白银矿机', '0.00', '100.00', '2018-06-26 17:25:10', 1530363343, 1, 3, '/Public/Uploads/20180611/5b1df30d710a5.png', '1440', '0.10', '0.08333333', 'S260511000', '8.29243023'),
(31470, '18337824444', 20100, '钻石矿机', '0.00', '10000.00', '2018-06-26 17:26:51', 1530005315, 1, 6, '/Public/Uploads/20180611/5b1df4906324d.png', '1440', '10.00', '8.33333333', 'S260521121', '0.24074074'),
(31471, '18337824444', 20100, '钻石矿机', '0.00', '10000.00', '2018-06-26 17:27:12', 1530005312, 1, 6, '/Public/Uploads/20180611/5b1df4906324d.png', '1440', '10.00', '8.33333333', 'S260523291', '0.18518519'),
(31472, '18337824444', 20100, '钻石矿机', '0.00', '10000.00', '2018-06-26 17:27:29', 1530005308, 1, 6, '/Public/Uploads/20180611/5b1df4906324d.png', '1440', '10.00', '8.33333333', 'S260524976', '0.13657407'),
(31473, '15315481133', 20062, '黄金矿机', '0.00', '1000.00', '2018-06-27 00:21:35', 1530286366, 1, 4, '/Public/Uploads/20180611/5b1df430e4025.png', '1440', '1.00', '0.83333333', 'S273009512', '59.32199050'),
(31474, '13802717609', 20134, '微型矿机（赠）', '0.00', '10.00', '2018-06-27 09:55:53', 1530064553, 1, 1, '/Public/Uploads/20180611/5b1dedd2c1b76.png', '1440', '0.01', '0.00833330', 'S276455319', '0.00000000'),
(31475, '15670162586', 20135, '微型矿机（赠）', '0.00', '10.00', '2018-06-27 09:56:03', 1530064563, 1, 1, '/Public/Uploads/20180611/5b1dedd2c1b76.png', '1440', '0.01', '0.00833330', 'S276456365', '0.00000000'),
(31476, '18639736868', 20023, '铂金矿机', '0.00', '5000.00', '2018-06-27 10:07:07', 1530322583, 1, 5, '/Public/Uploads/20180611/5b1df45327282.png', '1440', '5.00', '4.16666667', 'S276522734', '297.86574098'),
(31477, '13415062948', 20110, '钻石矿机', '0.00', '10000.00', '2018-06-27 10:53:04', 1530329722, 1, 6, '/Public/Uploads/20180611/5b1df4906324d.png', '1440', '10.00', '8.33333333', 'S276798494', '605.87499977'),
(31478, '13415062948', 20110, '钻石矿机', '0.00', '10000.00', '2018-06-27 10:53:28', 1530329723, 1, 6, '/Public/Uploads/20180611/5b1df4906324d.png', '1440', '10.00', '8.33333333', 'S276800812', '605.82175901'),
(31479, '13415062948', 20110, '钻石矿机', '0.00', '10000.00', '2018-06-27 10:53:59', 1530329724, 1, 6, '/Public/Uploads/20180611/5b1df4906324d.png', '1440', '10.00', '8.33333333', 'S276803900', '605.75231458'),
(31480, '13415062948', 20110, '铂金矿机', '0.00', '5000.00', '2018-06-27 10:55:46', 1530329725, 1, 5, '/Public/Uploads/20180611/5b1df45327282.png', '1440', '5.00', '4.16666667', 'S276814687', '302.75347246'),
(31481, '13415062948', 20110, '铂金矿机', '0.00', '5000.00', '2018-06-27 10:56:06', 1530329726, 1, 5, '/Public/Uploads/20180611/5b1df45327282.png', '1440', '5.00', '4.16666667', 'S276816632', '302.73148172'),
(31482, '13415062948', 20110, '铂金矿机', '0.00', '5000.00', '2018-06-27 10:56:34', 1530329708, 1, 5, '/Public/Uploads/20180611/5b1df45327282.png', '1440', '5.00', '4.16666667', 'S276819429', '302.67824098'),
(31483, '13415062948', 20110, '铂金矿机', '0.00', '5000.00', '2018-06-27 10:57:11', 1530329705, 1, 5, '/Public/Uploads/20180611/5b1df45327282.png', '1440', '5.00', '4.16666667', 'S276823127', '302.63194468'),
(31484, '13415062948', 20110, '铂金矿机', '0.00', '5000.00', '2018-06-27 10:57:54', 1530329704, 1, 5, '/Public/Uploads/20180611/5b1df45327282.png', '1440', '5.00', '4.16666667', 'S276827440', '302.58101876'),
(31485, '13415062948', 20110, '黄金矿机', '0.00', '1000.00', '2018-06-27 10:58:47', 1530329704, 1, 4, '/Public/Uploads/20180611/5b1df430e4025.png', '1440', '1.00', '0.83333333', 'S276832774', '60.50393495'),
(31486, '13415062948', 20110, '黄金矿机', '0.00', '1000.00', '2018-06-27 10:59:06', 1530329703, 1, 4, '/Public/Uploads/20180611/5b1df430e4025.png', '1440', '1.00', '0.83333333', 'S276834685', '60.49930530'),
(31487, '13415062948', 20110, '黄金矿机', '0.00', '1000.00', '2018-06-27 10:59:22', 1530329697, 1, 4, '/Public/Uploads/20180611/5b1df430e4025.png', '1440', '1.00', '0.83333333', 'S276836274', '60.49421271'),
(31488, '13415062948', 20110, '黄金矿机', '0.00', '1000.00', '2018-06-27 10:59:35', 1530329696, 1, 4, '/Public/Uploads/20180611/5b1df430e4025.png', '1440', '1.00', '0.83333333', 'S276837516', '60.49097197'),
(31489, '13415062948', 20110, '黄金矿机', '0.00', '1000.00', '2018-06-27 10:59:48', 1530329695, 1, 4, '/Public/Uploads/20180611/5b1df430e4025.png', '1440', '1.00', '0.83333333', 'S276838871', '60.48773123'),
(31490, '13415062948', 20110, '黄金矿机', '0.00', '1000.00', '2018-06-27 11:00:08', 1530329692, 1, 4, '/Public/Uploads/20180611/5b1df430e4025.png', '1440', '1.00', '0.83333333', 'S276840898', '60.48240717'),
(31491, '13415062948', 20110, '黄金矿机', '0.00', '1000.00', '2018-06-27 11:00:21', 1530329692, 1, 4, '/Public/Uploads/20180611/5b1df430e4025.png', '1440', '1.00', '0.83333333', 'S276842196', '60.47939791'),
(31492, '13946703331', 20137, '微型矿机（赠）', '0.00', '10.00', '2018-06-27 11:39:17', 1530070757, 1, 1, '/Public/Uploads/20180611/5b1dedd2c1b76.png', '1440', '0.01', '0.00833330', 'S277075732', '0.00000000'),
(31493, '18726577272', 20032, '铂金矿机', '0.00', '5000.00', '2018-06-27 11:49:29', 1530347674, 1, 5, '/Public/Uploads/20180611/5b1df45327282.png', '1440', '5.00', '4.16666667', 'S277136910', '319.79745396'),
(31494, '13802717609', 20134, '黄金矿机', '0.00', '1000.00', '2018-06-27 13:36:42', 1530077802, 1, 4, '/Public/Uploads/20180611/5b1df430e4025.png', '1440', '1.00', '0.83333333', 'S277780242', '0.00000000'),
(31495, '13802717609', 20134, '黄金矿机', '0.00', '1000.00', '2018-06-27 13:37:16', 1530077836, 1, 4, '/Public/Uploads/20180611/5b1df430e4025.png', '1440', '1.00', '0.83333333', 'S277783601', '0.00000000'),
(31496, '13802717609', 20134, '黄金矿机', '0.00', '1000.00', '2018-06-27 13:37:46', 1530077866, 1, 4, '/Public/Uploads/20180611/5b1df430e4025.png', '1440', '1.00', '0.83333333', 'S277786653', '0.00000000'),
(31497, '13802717609', 20134, '黄金矿机', '0.00', '1000.00', '2018-06-27 13:38:20', 1530077900, 1, 4, '/Public/Uploads/20180611/5b1df430e4025.png', '1440', '1.00', '0.83333333', 'S277790095', '0.00000000'),
(31498, '13802717609', 20134, '黄金矿机', '0.00', '1000.00', '2018-06-27 13:40:19', 1530078019, 1, 4, '/Public/Uploads/20180611/5b1df430e4025.png', '1440', '1.00', '0.83333333', 'S277801997', '0.00000000'),
(31499, '13415062948', 20110, '白银矿机', '0.00', '100.00', '2018-06-27 13:50:18', 1530329691, 1, 3, '/Public/Uploads/20180611/5b1df30d710a5.png', '1440', '0.10', '0.08333333', 'S277861880', '5.81187478'),
(31500, '13415062948', 20110, '白银矿机', '0.00', '100.00', '2018-06-27 13:50:33', 1530281619, 1, 3, '/Public/Uploads/20180611/5b1df30d710a5.png', '1440', '0.10', '0.08333333', 'S277863342', '4.69874982'),
(31501, '13415062948', 20110, '白银矿机', '0.00', '100.00', '2018-06-27 13:50:44', 1530329689, 1, 3, '/Public/Uploads/20180611/5b1df30d710a5.png', '1440', '0.10', '0.08333333', 'S277864435', '5.81122662'),
(31502, '13415062948', 20110, '白银矿机', '0.00', '100.00', '2018-06-27 13:50:56', 1530329688, 1, 3, '/Public/Uploads/20180611/5b1df30d710a5.png', '1440', '0.10', '0.08333333', 'S277865635', '5.81092569'),
(31503, '13415062948', 20110, '白银矿机', '0.00', '100.00', '2018-06-27 13:51:11', 1530329687, 1, 3, '/Public/Uploads/20180611/5b1df30d710a5.png', '1440', '0.10', '0.08333333', 'S277867195', '5.81055532'),
(31504, '13415062948', 20110, '白银矿机', '0.00', '100.00', '2018-06-27 13:51:24', 1530329667, 1, 3, '/Public/Uploads/20180611/5b1df30d710a5.png', '1440', '0.10', '0.08333333', 'S277868484', '5.80979143'),
(31505, '13415062948', 20110, '白银矿机', '0.00', '100.00', '2018-06-27 13:51:46', 1530329668, 1, 3, '/Public/Uploads/20180611/5b1df30d710a5.png', '1440', '0.10', '0.08333333', 'S277870678', '5.80930531'),
(31506, '13415062948', 20110, '白银矿机', '0.00', '100.00', '2018-06-27 13:51:56', 1530329665, 1, 3, '/Public/Uploads/20180611/5b1df30d710a5.png', '1440', '0.10', '0.08333333', 'S277871644', '5.80900439'),
(31507, '13415062948', 20110, '白银矿机', '0.00', '100.00', '2018-06-27 13:52:05', 1530329663, 1, 3, '/Public/Uploads/20180611/5b1df30d710a5.png', '1440', '0.10', '0.08333333', 'S277872588', '5.80874977'),
(31508, '13415062948', 20110, '微型矿机', '0.00', '10.00', '2018-06-27 13:52:51', 1530329661, 1, 2, '/Public/Uploads/20180611/5b1deda3d03f4.png', '1440', '0.01', '0.00833333', 'S277877190', '0.58076365'),
(31509, '13415062948', 20110, '微型矿机', '0.00', '10.00', '2018-06-27 13:53:02', 1530329658, 1, 2, '/Public/Uploads/20180611/5b1deda3d03f4.png', '1440', '0.01', '0.00833333', 'S277878247', '0.58073125'),
(31510, '13415062948', 20110, '微型矿机', '0.00', '10.00', '2018-06-27 13:53:13', 1530329655, 1, 2, '/Public/Uploads/20180611/5b1deda3d03f4.png', '1440', '0.01', '0.00833333', 'S277879304', '0.58069884'),
(31511, '13415062948', 20110, '微型矿机', '0.00', '10.00', '2018-06-27 13:53:22', 1530329654, 1, 2, '/Public/Uploads/20180611/5b1deda3d03f4.png', '1440', '0.01', '0.00833333', 'S277880261', '0.58067569'),
(31512, '13415062948', 20110, '微型矿机', '0.00', '10.00', '2018-06-27 13:53:33', 1530329652, 1, 2, '/Public/Uploads/20180611/5b1deda3d03f4.png', '1440', '0.01', '0.00833333', 'S277881303', '0.58064560'),
(31513, '13415062948', 20110, '微型矿机', '0.00', '10.00', '2018-06-27 13:53:42', 1530329651, 1, 2, '/Public/Uploads/20180611/5b1deda3d03f4.png', '1440', '0.01', '0.00833333', 'S277882214', '0.58062246'),
(31514, '13415062948', 20110, '微型矿机', '0.00', '10.00', '2018-06-27 13:53:53', 1530329650, 1, 2, '/Public/Uploads/20180611/5b1deda3d03f4.png', '1440', '0.01', '0.00833333', 'S277883306', '0.58059467'),
(31515, '13415062948', 20110, '微型矿机', '0.00', '10.00', '2018-06-27 13:54:02', 1530329648, 1, 2, '/Public/Uploads/20180611/5b1deda3d03f4.png', '1440', '0.01', '0.00833333', 'S277884217', '0.58056922'),
(31516, '13415062948', 20110, '微型矿机', '0.00', '10.00', '2018-06-27 13:54:11', 1530329647, 1, 2, '/Public/Uploads/20180611/5b1deda3d03f4.png', '1440', '0.01', '0.00833333', 'S277885149', '0.58054606'),
(31517, '13415062948', 20110, '微型矿机', '0.00', '10.00', '2018-06-27 13:54:20', 1530329645, 1, 2, '/Public/Uploads/20180611/5b1deda3d03f4.png', '1440', '0.01', '0.00833333', 'S277886020', '0.58052059'),
(31518, '13415062948', 20110, '微型矿机', '0.00', '10.00', '2018-06-27 13:54:28', 1530329643, 1, 2, '/Public/Uploads/20180611/5b1deda3d03f4.png', '1440', '0.01', '0.00833333', 'S277886896', '0.58049744'),
(31519, '13546828815', 20139, '微型矿机（赠）', '0.00', '10.00', '2018-06-27 14:55:35', 1530316984, 1, 1, '/Public/Uploads/20180611/5b1dedd2c1b76.png', '1440', '0.01', '0.00833330', 'S278253564', '0.54270384'),
(31520, '13071789700', 20140, '微型矿机（赠）', '0.00', '10.00', '2018-06-27 14:55:51', 1530153282, 1, 1, '/Public/Uploads/20180611/5b1dedd2c1b76.png', '1440', '0.01', '0.00833330', 'S278255197', '0.16372851'),
(31521, '13546828815', 20139, '铂金矿机', '0.00', '5000.00', '2018-06-27 16:28:14', 1530316976, 1, 5, '/Public/Uploads/20180611/5b1df45327282.png', '1440', '5.00', '4.16666667', 'S278809472', '264.90972244'),
(31522, '13546828815', 20139, '黄金矿机', '0.00', '1000.00', '2018-06-27 16:28:35', 1530316975, 1, 4, '/Public/Uploads/20180611/5b1df430e4025.png', '1440', '1.00', '0.83333333', 'S278811594', '52.97685164'),
(31523, '13546828815', 20139, '黄金矿机', '0.00', '1000.00', '2018-06-27 16:28:44', 1530316974, 1, 4, '/Public/Uploads/20180611/5b1df430e4025.png', '1440', '1.00', '0.83333333', 'S278812448', '52.97453683'),
(31524, '15993399332', 20142, '微型矿机（赠）', '0.00', '10.00', '2018-06-27 16:32:55', 1530088375, 1, 1, '/Public/Uploads/20180611/5b1dedd2c1b76.png', '1440', '0.01', '0.00833330', 'S278837506', '0.00000000'),
(31525, '15837105008', 20090, '微型矿机（赠）', '0.00', '10.00', '2018-06-27 16:39:11', 1530262893, 1, 1, '/Public/Uploads/20180611/5b1dedd2c1b76.png', '1440', '0.01', '0.00833330', 'S278875167', '0.40310487'),
(31526, '15672867237', 20143, '微型矿机（赠）', '0.00', '10.00', '2018-06-27 17:21:35', 1530091295, 1, 1, '/Public/Uploads/20180611/5b1dedd2c1b76.png', '1440', '0.01', '0.00833330', 'S279129556', '0.00000000'),
(31527, '15837105008', 20090, '钻石矿机', '0.00', '10000.00', '2018-06-27 17:26:09', 1530262891, 1, 6, '/Public/Uploads/20180611/5b1df4906324d.png', '1440', '10.00', '8.33333333', 'S279156973', '396.57870354'),
(31528, '15837105008', 20090, '钻石矿机', '0.00', '10000.00', '2018-06-27 17:26:28', 1530262889, 1, 6, '/Public/Uploads/20180611/5b1df4906324d.png', '1440', '10.00', '8.33333333', 'S279158850', '396.53009243'),
(31529, '15837105008', 20090, '钻石矿机', '0.00', '10000.00', '2018-06-27 17:26:37', 1530262886, 1, 6, '/Public/Uploads/20180611/5b1df4906324d.png', '1440', '10.00', '8.33333333', 'S279159701', '396.50231465'),
(31530, '15837105008', 20090, '铂金矿机', '0.00', '5000.00', '2018-06-27 17:27:57', 1530262877, 1, 5, '/Public/Uploads/20180611/5b1df45327282.png', '1440', '5.00', '4.16666667', 'S279167784', '198.14814830'),
(31531, '15837105008', 20090, '铂金矿机', '0.00', '5000.00', '2018-06-27 17:28:06', 1530262876, 1, 5, '/Public/Uploads/20180611/5b1df45327282.png', '1440', '5.00', '4.16666667', 'S279168616', '198.13657424'),
(31532, '15837105008', 20090, '铂金矿机', '0.00', '5000.00', '2018-06-27 17:28:20', 1530262876, 1, 5, '/Public/Uploads/20180611/5b1df45327282.png', '1440', '5.00', '4.16666667', 'S279170027', '198.12037053'),
(31533, '15837105008', 20090, '铂金矿机', '0.00', '5000.00', '2018-06-27 17:28:41', 1530262875, 1, 5, '/Public/Uploads/20180611/5b1df45327282.png', '1440', '5.00', '4.16666667', 'S279172121', '198.09490757'),
(31534, '15993399332', 20142, '钻石矿机', '0.00', '10000.00', '2018-06-27 17:55:32', 1530093332, 1, 6, '/Public/Uploads/20180611/5b1df4906324d.png', '1440', '10.00', '8.33333333', 'S279333295', '0.00000000'),
(31535, '18672996989', 20136, '微型矿机（赠）', '0.00', '10.00', '2018-06-27 18:54:05', 1530213844, 1, 1, '/Public/Uploads/20180611/5b1dedd2c1b76.png', '1440', '0.01', '0.00833330', 'S279684549', '0.27082994'),
(31536, '13428317723', 20128, '黄金矿机', '0.00', '1000.00', '2018-06-27 20:06:46', 1530101206, 1, 4, '/Public/Uploads/20180611/5b1df430e4025.png', '1440', '1.00', '0.83333333', 'S270120620', '0.00000000'),
(31537, '13428317723', 20128, '黄金矿机', '0.00', '1000.00', '2018-06-27 20:06:59', 1530101219, 1, 4, '/Public/Uploads/20180611/5b1df430e4025.png', '1440', '1.00', '0.83333333', 'S270121941', '0.00000000'),
(31538, '13428317723', 20128, '黄金矿机', '0.00', '1000.00', '2018-06-27 20:07:05', 1530101225, 1, 4, '/Public/Uploads/20180611/5b1df430e4025.png', '1440', '1.00', '0.83333333', 'S270122509', '0.00000000'),
(31539, '13428317723', 20128, '黄金矿机', '0.00', '1000.00', '2018-06-27 20:07:12', 1530101232, 1, 4, '/Public/Uploads/20180611/5b1df430e4025.png', '1440', '1.00', '0.83333333', 'S270123273', '0.00000000'),
(31540, '13414072853', 20113, '黄金矿机', '0.00', '1000.00', '2018-06-27 20:21:13', 1530301754, 1, 4, '/Public/Uploads/20180611/5b1df430e4025.png', '1440', '1.00', '0.83333333', 'S270207388', '46.22245352'),
(31541, '13414072853', 20113, '黄金矿机', '0.00', '1000.00', '2018-06-27 20:22:50', 1530301753, 1, 4, '/Public/Uploads/20180611/5b1df430e4025.png', '1440', '1.00', '0.83333333', 'S270217091', '46.19976834'),
(31542, '13414072853', 20113, '黄金矿机', '0.00', '1000.00', '2018-06-27 20:47:06', 1530301751, 1, 4, '/Public/Uploads/20180611/5b1df430e4025.png', '1440', '1.00', '0.83333333', 'S270362639', '45.86226833'),
(31543, '13414072853', 20113, '黄金矿机', '0.00', '1000.00', '2018-06-27 20:47:21', 1530301749, 1, 4, '/Public/Uploads/20180611/5b1df430e4025.png', '1440', '1.00', '0.83333333', 'S270364114', '45.85833315'),
(31544, '18319283191', 20047, '钻石矿机', '0.00', '10000.00', '2018-06-27 22:55:25', 1530328641, 1, 6, '/Public/Uploads/20180611/5b1df4906324d.png', '1440', '10.00', '8.33333333', 'S271132538', '503.04629610'),
(31545, '15055596222', 20008, '黄金矿机', '0.00', '1000.00', '2018-06-28 10:18:53', 1530347632, 1, 4, '/Public/Uploads/20180611/5b1df430e4025.png', '1440', '1.00', '0.83333333', 'S285233391', '45.20810167'),
(31546, '13949424202', 20144, '微型矿机（赠）', '0.00', '10.00', '2018-06-28 11:33:52', 1530156832, 1, 1, '/Public/Uploads/20180611/5b1dedd2c1b76.png', '1440', '0.01', '0.00833330', 'S285683269', '0.00000000'),
(31547, '13949424202', 20144, '钻石矿机', '0.00', '10000.00', '2018-06-28 12:05:55', 1530158755, 1, 6, '/Public/Uploads/20180611/5b1df4906324d.png', '1440', '10.00', '8.33333333', 'S285875571', '0.00000000'),
(31548, '15315481133', 20062, '黄金矿机', '0.00', '1000.00', '2018-06-28 12:41:37', 1530286369, 1, 4, '/Public/Uploads/20180611/5b1df430e4025.png', '1440', '1.00', '0.83333333', 'S286089725', '29.04444433'),
(31549, '13307173331', 20082, '黄金矿机', '0.00', '1000.00', '2018-06-28 14:27:22', 1530244405, 1, 4, '/Public/Uploads/20180611/5b1df430e4025.png', '1440', '1.00', '0.83333333', 'S286724298', '17.86180549'),
(31550, '18627031670', 20083, '微型矿机（赠）', '0.00', '10.00', '2018-06-28 14:32:56', 1530168031, 1, 1, '/Public/Uploads/20180611/5b1dedd2c1b76.png', '1440', '0.01', '0.00833330', 'S286757603', '0.00105324'),
(31551, '18986100270', 20147, '微型矿机（赠）', '0.00', '10.00', '2018-06-28 14:33:08', 1530361050, 1, 1, '/Public/Uploads/20180611/5b1dedd2c1b76.png', '1440', '0.01', '0.00833330', 'S286758881', '0.44782690'),
(31552, '18627031670', 20083, '钻石矿机', '0.00', '10000.00', '2018-06-28 14:38:54', 1530168027, 1, 6, '/Public/Uploads/20180611/5b1df4906324d.png', '1440', '10.00', '8.33333333', 'S286793496', '0.21527778'),
(31553, '18986100270', 20147, '钻石矿机', '0.00', '10000.00', '2018-06-28 14:39:17', 1530361047, 1, 6, '/Public/Uploads/20180611/5b1df4906324d.png', '1440', '10.00', '8.33333333', 'S286795727', '446.96759241'),
(31554, '13271756696', 20148, '微型矿机（赠）', '0.00', '10.00', '2018-06-28 18:41:08', 1530182468, 1, 1, '/Public/Uploads/20180611/5b1dedd2c1b76.png', '1440', '0.01', '0.00833330', 'S288246838', '0.00000000'),
(31555, '18726577272', 20032, '钻石矿机', '0.00', '10000.00', '2018-06-29 09:15:07', 1530347677, 1, 6, '/Public/Uploads/20180611/5b1df4906324d.png', '1440', '10.00', '8.33333333', 'S293490734', '261.04166656'),
(31556, '15886517776', 20155, '微型矿机（赠）', '0.00', '10.00', '2018-06-29 10:43:28', 1530244756, 1, 1, '/Public/Uploads/20180611/5b1dedd2c1b76.png', '1440', '0.01', '0.00833330', 'S294020850', '0.01052774'),
(31557, '18338570180', 20153, '微型矿机（赠）', '0.00', '10.00', '2018-06-29 10:43:40', 1530240220, 1, 1, '/Public/Uploads/20180611/5b1dedd2c1b76.png', '1440', '0.01', '0.00833330', 'S294022072', '0.00000000'),
(31558, '13507663625', 20152, '微型矿机（赠）', '0.00', '10.00', '2018-06-29 10:43:55', 1530240235, 1, 1, '/Public/Uploads/20180611/5b1dedd2c1b76.png', '1440', '0.01', '0.00833330', 'S294023517', '0.00000000'),
(31559, '13253369390', 20125, '微型矿机（赠）', '0.00', '10.00', '2018-06-29 10:44:05', 1530280485, 1, 1, '/Public/Uploads/20180611/5b1dedd2c1b76.png', '1440', '0.01', '0.00833330', 'S294024572', '0.09314778'),
(31560, '13938373986', 20150, '微型矿机（赠）', '0.00', '10.00', '2018-06-29 10:44:20', 1530240260, 1, 1, '/Public/Uploads/20180611/5b1dedd2c1b76.png', '1440', '0.01', '0.00833330', 'S294026055', '0.00000000'),
(31561, '18726577272', 20032, '铂金矿机', '0.00', '5000.00', '2018-06-29 17:43:44', 1530347679, 1, 5, '/Public/Uploads/20180611/5b1df45327282.png', '1440', '5.00', '4.16666667', 'S296542499', '95.20254637'),
(31562, '18726577272', 20032, '铂金矿机', '0.00', '5000.00', '2018-06-29 17:44:16', 1530347676, 1, 5, '/Public/Uploads/20180611/5b1df45327282.png', '1440', '5.00', '4.16666667', 'S296545621', '95.16203711'),
(31563, '15055596222', 20008, '铂金矿机', '0.00', '5000.00', '2018-06-29 17:47:21', 1530347635, 1, 5, '/Public/Uploads/20180611/5b1df45327282.png', '1440', '5.00', '4.16666667', 'S296564160', '94.90046304');
INSERT INTO `ds_order` (`id`, `user`, `user_id`, `project`, `count`, `sumprice`, `addtime`, `UG_getTime`, `zt`, `sid`, `imagepath`, `yxzq`, `lixi`, `kjsl`, `kjbh`, `already_profit`) VALUES
(31564, '18726577272', 20032, '铂金矿机', '0.00', '5000.00', '2018-06-29 22:03:01', 1530347683, 1, 5, '/Public/Uploads/20180611/5b1df45327282.png', '1440', '5.00', '4.16666667', 'S298098130', '77.20138895'),
(31565, '18230344383', 20156, '微型矿机（赠）', '0.00', '10.00', '2018-06-29 23:30:48', 1530286248, 1, 1, '/Public/Uploads/20180611/5b1dedd2c1b76.png', '1440', '0.01', '0.00833330', 'S298624884', '0.00000000'),
(31566, '18603997935', 20158, '微型矿机（赠）', '0.00', '10.00', '2018-06-29 23:31:06', 1530286266, 1, 1, '/Public/Uploads/20180611/5b1dedd2c1b76.png', '1440', '0.01', '0.00833330', 'S298626666', '0.00000000'),
(31567, '15315481133', 20062, '黄金矿机', '0.00', '1000.00', '2018-06-29 23:33:15', 1530286395, 1, 4, '/Public/Uploads/20180611/5b1df430e4025.png', '1440', '1.00', '0.83333333', 'S298639579', '0.00000000'),
(31568, '15314099319', 20058, '白银矿机', '0.00', '100.00', '2018-06-30 00:49:19', 1530363340, 1, 3, '/Public/Uploads/20180611/5b1df30d710a5.png', '1440', '0.10', '0.08333333', 'S309095901', '1.67548604'),
(31569, '18695693310', 20159, '微型矿机（赠）', '0.00', '10.00', '2018-06-30 04:08:55', 1530302935, 1, 1, '/Public/Uploads/20180611/5b1dedd2c1b76.png', '1440', '0.01', '0.00833330', 'S300293557', '0.00000000'),
(31570, '17797752708', 20010, '铂金矿机', '0.00', '5000.00', '2018-06-30 11:32:15', 1530329598, 1, 5, '/Public/Uploads/20180611/5b1df45327282.png', '1440', '5.00', '4.16666667', 'S302953569', '0.07291667'),
(31571, '13164352999', 20000, '白银矿机', '0.00', '100.00', '2018-06-30 13:17:10', 1530338844, 1, 3, '/Public/Uploads/20180611/5b1df30d710a5.png', '1440', '0.10', '0.08333333', 'S303583073', '0.06976852'),
(31572, '13670888292', 20060, '微型矿机（赠）', '0.00', '10.00', '2018-06-30 13:47:09', 1530337629, 1, 1, '/Public/Uploads/20180611/5b1dedd2c1b76.png', '1440', '0.01', '0.00833330', 'S303762911', '0.00000000'),
(31573, '13193976665', 20162, '微型矿机（赠）', '0.00', '10.00', '2018-06-30 13:47:17', 1530338185, 1, 1, '/Public/Uploads/20180611/5b1dedd2c1b76.png', '1440', '0.01', '0.00833330', 'S303763725', '0.00126851'),
(31574, '13507663625', 20152, '钻石矿机', '0.00', '10000.00', '2018-06-30 14:08:05', 1530352873, 1, 6, '/Public/Uploads/20180611/5b1df4906324d.png', '1440', '10.00', '8.33333333', 'S303888523', '32.37962962'),
(31575, '13271756696', 20148, '钻石矿机', '0.00', '10000.00', '2018-06-30 16:09:09', 1530359330, 1, 6, '/Public/Uploads/20180611/5b1df4906324d.png', '1440', '10.00', '8.33333333', 'S304614931', '30.51157406'),
(31576, '13339997637', 20016, '钻石矿机', '0.00', '10000.00', '2018-06-30 16:47:58', 1530348478, 1, 6, '/Public/Uploads/20180611/5b1df4906324d.png', '1440', '10.00', '8.33333333', 'S304847857', '0.00000000'),
(31577, '13413438117', 20157, '微型矿机（赠）', '0.00', '10.00', '2018-06-30 17:26:39', 1530350799, 1, 1, '/Public/Uploads/20180611/5b1dedd2c1b76.png', '1440', '0.01', '0.00833330', 'S305079942', '0.00000000'),
(31578, '13387576668', 20163, '微型矿机（赠）', '0.00', '10.00', '2018-06-30 17:26:55', 1530365024, 1, 1, '/Public/Uploads/20180611/5b1dedd2c1b76.png', '1440', '0.01', '0.00833330', 'S305081578', '0.03289107'),
(31579, '18338570180', 20153, '钻石矿机', '0.00', '10000.00', '2018-06-30 17:33:21', 1530351201, 1, 6, '/Public/Uploads/20180611/5b1df4906324d.png', '1440', '10.00', '8.33333333', 'S305120115', '0.00000000'),
(31580, '18338570180', 20153, '钻石矿机', '0.00', '10000.00', '2018-06-30 17:34:04', 1530351244, 1, 6, '/Public/Uploads/20180611/5b1df4906324d.png', '1440', '10.00', '8.33333333', 'S305124496', '0.00000000'),
(31581, '13387576668', 20163, '钻石矿机', '0.00', '10000.00', '2018-06-30 18:02:59', 1530365022, 1, 6, '/Public/Uploads/20180611/5b1df4906324d.png', '1440', '10.00', '8.33333333', 'S305297965', '27.87731480'),
(31582, '13387576668', 20163, '钻石矿机', '0.00', '10000.00', '2018-06-30 18:03:10', 1530365020, 1, 6, '/Public/Uploads/20180611/5b1df4906324d.png', '1440', '10.00', '8.33333333', 'S305299061', '27.84722220'),
(31583, '13387576668', 20163, '钻石矿机', '0.00', '10000.00', '2018-06-30 18:03:16', 1530365019, 1, 6, '/Public/Uploads/20180611/5b1df4906324d.png', '1440', '10.00', '8.33333333', 'S305299600', '27.83101851'),
(31584, '18336193888', 20093, '钻石矿机', '0.00', '10000.00', '2018-06-30 19:08:25', 1530356905, 1, 6, '/Public/Uploads/20180611/5b1df4906324d.png', '1440', '10.00', '8.33333333', 'S305690538', '0.00000000'),
(31585, '13103598345', 20164, '微型矿机（赠）', '0.00', '10.00', '2018-07-01 17:55:01', 1530629314, 1, 1, '/Public/Uploads/20180611/5b1dedd2c1b76.png', '1440', '0.01', '0.00833330', 'S013890183', '0.44076907'),
(31586, '13103598345', 20164, '白银矿机', '0.00', '100.00', '2018-07-02 00:11:54', 1530628314, 1, 3, '/Public/Uploads/20180611/5b1df30d710a5.png', '1440', '0.10', '0.08333333', 'S026151437', '3.86111095'),
(31587, '18888888888', 1, '微型矿机（赠）', '0.00', '10.00', '2018-07-02 21:58:10', 1558797144, 2, 1, '/Public/Uploads/20180611/5b1dedd2c1b76.png', '1440', '0.01', '0.00833330', 'S023989014', '11.99995200'),
(31588, '18888888888', 1, '钻石矿机', '0.00', '10000.00', '2019-05-27 17:06:39', 1564138959, 2, 6, '/Public/Uploads/20181119/5bf29fa3d16c0.png', '1440', '10.00', '8.33333333', 'S274799954', '11999.99999521'),
(31589, '18888888888', 1, '钻石矿机', '0.00', '10000.00', '2019-05-27 17:06:39', 1564138956, 2, 6, '/Public/Uploads/20181119/5bf29fa3d16c0.png', '1440', '10.00', '8.33333333', 'S274799994', '11999.99999521'),
(31590, '18888888888', 1, '钻石矿机', '0.00', '10000.00', '2019-05-31 08:07:50', 1564138953, 1, 6, '/Public/Uploads/20181119/5bf29fa3d16c0.png', '1440', '10.00', '8.33333333', 'S316127099', '11290.93286585'),
(31591, '18888888888', 1, '铂金矿机', '0.00', '5000.00', '2019-06-02 11:30:03', 1564138951, 1, 5, '/Public/Uploads/20181119/5bf2a16c72e42.png', '1440', '5.00', '4.16666667', 'S024620370', '5431.42130065'),
(31592, '18888888888', 1, '微型矿机(赠)', '0.00', '100.00', '2019-06-04 18:47:21', 1564138948, 1, 1, '/Public/Uploads/20181119/5bf2a19634ccc.png', '1540', '0.01', '0.00833330', 'S044524116', '10.40205793'),
(31593, '18888888888', 1, '白银矿机', '0.00', '100.00', '2019-06-05 11:13:35', 1564138943, 1, 3, '/Public/Uploads/20181119/5bf29f68a7b28.png', '1440', '0.10', '0.08333333', 'S050441551', '102.65110701'),
(31594, '18888888888', 1, '微型矿机', '0.00', '10.00', '2019-06-06 10:54:13', 1564138940, 1, 2, '/Public/Uploads/20181119/5bf2a1a20dd70.png', '1440', '0.01', '0.00833333', 'S068965383', '10.06778996'),
(31595, '18888888888', 1, '微型矿机(赠)', '0.00', '100.00', '2019-06-08 19:29:31', 1564138937, 1, 1, '/Public/Uploads/20181119/5bf2a19634ccc.png', '1540', '0.01', '0.00833330', 'S089337125', '9.59617921'),
(31596, '18888888888', 1, '白银矿机', '0.00', '100.00', '2019-06-10 16:50:37', 1564138935, 1, 3, '/Public/Uploads/20181119/5bf29f68a7b28.png', '1440', '0.10', '0.08333333', 'S105663725', '92.18282039'),
(31597, '18888888888', 1, '微型矿机(赠)', '0.00', '100.00', '2019-06-12 18:55:41', 1564138932, 1, 1, '/Public/Uploads/20181119/5bf2a19634ccc.png', '1540', '0.01', '0.00833330', 'S123694188', '8.80086989'),
(31598, '18888888888', 1, '白银矿机', '0.00', '100.00', '2019-06-13 00:46:27', 1564138930, 1, 3, '/Public/Uploads/20181119/5bf29f68a7b28.png', '1440', '0.10', '0.08333333', 'S135798788', '87.52182520'),
(31599, '18888888888', 1, '微型矿机', '0.00', '10.00', '2019-06-13 09:51:01', 1564138926, 1, 2, '/Public/Uploads/20181119/5bf2a1a20dd70.png', '1440', '0.01', '0.00833333', 'S139066132', '8.67653588'),
(31600, '18888888888', 1, '微型矿机(赠)', '0.00', '100.00', '2019-06-13 17:12:00', 1564138923, 1, 1, '/Public/Uploads/20181119/5bf2a19634ccc.png', '1540', '0.01', '0.00833330', 'S131712033', '8.61525026'),
(31601, '18888888888', 1, '微型矿机', '0.00', '10.00', '2019-06-13 20:46:48', 1564138919, 1, 2, '/Public/Uploads/20181119/5bf2a1a20dd70.png', '1440', '0.01', '0.00833333', 'S133000809', '8.58543870'),
(31602, '18888888888', 1, '微型矿机(赠)', '0.00', '100.00', '2019-06-13 21:22:56', 1564138914, 1, 1, '/Public/Uploads/20181119/5bf2a19634ccc.png', '1540', '0.01', '0.00833330', 'S133217630', '8.58037772'),
(31603, '18888888888', 1, '微型矿机(赠)', '0.00', '100.00', '2019-06-13 21:23:08', 1564138912, 1, 1, '/Public/Uploads/20181119/5bf2a19634ccc.png', '1540', '0.01', '0.00833330', 'S133218805', '8.58034531'),
(31604, '18888888888', 1, '白银矿机', '0.00', '100.00', '2019-06-13 21:28:45', 1564138909, 1, 3, '/Public/Uploads/20181119/5bf29f68a7b28.png', '1440', '0.10', '0.08333333', 'S133252562', '85.79592250'),
(31605, '18888888888', 1, '白银矿机', '0.00', '100.00', '2019-06-14 19:24:54', 1564138906, 1, 3, '/Public/Uploads/20181119/5bf29f68a7b28.png', '1440', '0.10', '0.08333333', 'S141149413', '83.96786701'),
(31606, '18888888888', 1, '微型矿机', '0.00', '10.00', '2019-06-14 21:40:00', 1564138903, 1, 2, '/Public/Uploads/20181119/5bf2a1a20dd70.png', '1440', '0.01', '0.00833333', 'S141960078', '8.37801286'),
(31607, '18888888888', 1, '微型矿机', '0.00', '10.00', '2019-06-26 13:31:18', 1564138899, 1, 2, '/Public/Uploads/20181119/5bf2a1a20dd70.png', '1440', '0.01', '0.00833333', 'S262707896', '6.04587953');

-- --------------------------------------------------------

--
-- 表的结构 `ds_orders`
--

CREATE TABLE `ds_orders` (
  `oid` mediumint(8) UNSIGNED NOT NULL,
  `photo` varchar(20) NOT NULL,
  `kuaidiname` varchar(255) NOT NULL,
  `name` varchar(255) NOT NULL,
  `shangname` varchar(255) NOT NULL,
  `username` varchar(255) NOT NULL,
  `onumber` char(20) NOT NULL,
  `uid` mediumint(8) UNSIGNED NOT NULL,
  `total` decimal(11,2) UNSIGNED NOT NULL,
  `otime` char(10) NOT NULL,
  `expressnum` varchar(255) NOT NULL,
  `freight` int(10) UNSIGNED NOT NULL,
  `deliveryaddress` varchar(255) NOT NULL,
  `remarks` varchar(255) NOT NULL,
  `paymethod` tinyint(1) NOT NULL DEFAULT '0' COMMENT '0未支付1微信支付2支付宝支付3货到付款',
  `status` tinyint(1) NOT NULL DEFAULT '0'
) ENGINE=MyISAM DEFAULT CHARSET=utf8 ROW_FORMAT=DYNAMIC;

-- --------------------------------------------------------

--
-- 表的结构 `ds_paydetail`
--

CREATE TABLE `ds_paydetail` (
  `id` int(10) UNSIGNED NOT NULL,
  `member` varchar(20) NOT NULL,
  `amount` decimal(10,2) NOT NULL,
  `type` varchar(100) NOT NULL,
  `account` varchar(100) NOT NULL,
  `name` varchar(100) NOT NULL,
  `content` varchar(100) NOT NULL,
  `remark` varchar(100) NOT NULL,
  `addtime` int(11) UNSIGNED NOT NULL,
  `status` tinyint(3) UNSIGNED NOT NULL DEFAULT '0'
) ENGINE=MyISAM DEFAULT CHARSET=utf8 ROW_FORMAT=COMPACT;

-- --------------------------------------------------------

--
-- 表的结构 `ds_paydetails`
--

CREATE TABLE `ds_paydetails` (
  `id` int(10) UNSIGNED NOT NULL,
  `member` varchar(20) NOT NULL,
  `amount` decimal(10,2) NOT NULL,
  `type` varchar(100) NOT NULL,
  `account` varchar(100) NOT NULL,
  `name` varchar(100) NOT NULL,
  `remark` varchar(100) NOT NULL,
  `addtime` int(11) UNSIGNED NOT NULL,
  `status` tinyint(3) UNSIGNED NOT NULL DEFAULT '0'
) ENGINE=MyISAM DEFAULT CHARSET=utf8 ROW_FORMAT=COMPACT;

-- --------------------------------------------------------

--
-- 表的结构 `ds_pin`
--

CREATE TABLE `ds_pin` (
  `id` int(11) NOT NULL,
  `pin` varchar(255) DEFAULT NULL,
  `level` tinyint(3) UNSIGNED NOT NULL DEFAULT '0',
  `username` varchar(50) DEFAULT '',
  `sc_date` int(11) UNSIGNED DEFAULT NULL,
  `sy_user` varchar(20) NOT NULL DEFAULT '0',
  `zt` tinyint(3) UNSIGNED NOT NULL DEFAULT '0',
  `sy_date` int(10) UNSIGNED DEFAULT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8 ROW_FORMAT=COMPACT;

-- --------------------------------------------------------

--
-- 表的结构 `ds_pointdetail`
--

CREATE TABLE `ds_pointdetail` (
  `id` int(11) UNSIGNED NOT NULL,
  `type` int(10) UNSIGNED NOT NULL DEFAULT '0',
  `member` varchar(255) DEFAULT '' COMMENT '会员编号',
  `adds` decimal(11,2) DEFAULT '0.00' COMMENT '添加',
  `reduce` decimal(11,2) DEFAULT '0.00' COMMENT '减少',
  `balance` decimal(11,2) DEFAULT '0.00' COMMENT '余额',
  `addtime` int(11) DEFAULT '0' COMMENT '添加时间',
  `desc` varchar(255) DEFAULT '' COMMENT '说明'
) ENGINE=MyISAM AVG_ROW_LENGTH=60 DEFAULT CHARSET=utf8 COMMENT='购物券明细' ROW_FORMAT=COMPACT;

-- --------------------------------------------------------

--
-- 表的结构 `ds_ppdd`
--

CREATE TABLE `ds_ppdd` (
  `id` int(11) NOT NULL,
  `p_id` varchar(255) DEFAULT NULL,
  `g_id` varchar(255) DEFAULT NULL,
  `jb` varchar(15) DEFAULT NULL,
  `lkb` varchar(15) DEFAULT NULL,
  `p_user` varchar(255) DEFAULT NULL,
  `g_user` varchar(255) DEFAULT NULL,
  `date` datetime DEFAULT NULL,
  `zt` int(8) NOT NULL DEFAULT '0',
  `pic` varchar(255) DEFAULT NULL,
  `zffs1` int(8) DEFAULT NULL,
  `zffs2` int(8) DEFAULT NULL,
  `zffs3` int(8) DEFAULT NULL,
  `ts_zt` int(8) NOT NULL DEFAULT '0',
  `date_hk` datetime DEFAULT NULL,
  `pic2` varchar(255) DEFAULT NULL,
  `p_name` varchar(60) DEFAULT NULL,
  `g_name` varchar(60) DEFAULT NULL,
  `p_level` varchar(60) DEFAULT NULL,
  `g_level` varchar(60) DEFAULT NULL,
  `jydate` datetime DEFAULT NULL,
  `imagepath` varchar(255) DEFAULT NULL,
  `danjia` varchar(10) DEFAULT NULL,
  `datatype` varchar(255) DEFAULT NULL,
  `zdjyr` varchar(255) DEFAULT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8 ROW_FORMAT=COMPACT;

--
-- 转存表中的数据 `ds_ppdd`
--

INSERT INTO `ds_ppdd` (`id`, `p_id`, `g_id`, `jb`, `lkb`, `p_user`, `g_user`, `date`, `zt`, `pic`, `zffs1`, `zffs2`, `zffs3`, `ts_zt`, `date_hk`, `pic2`, `p_name`, `g_name`, `p_level`, `g_level`, `jydate`, `imagepath`, `danjia`, `datatype`, `zdjyr`) VALUES
(9, '20164', '1', '1.7', '10', '13103598345', '18888888888', '2019-06-01 19:11:06', 2, NULL, NULL, NULL, NULL, 0, NULL, NULL, NULL, '', '3', '6', '2019-06-02 11:27:09', '/Public/Uploads/pingzheng/5d0251436a7c0.jpg', '0.17', 'qglkb', '0'),
(12, '1', '20164', '14', '100', '18888888888', '13103598345', '2019-06-13 21:16:41', 1, NULL, NULL, NULL, NULL, 0, NULL, NULL, '', '', '6', '3', '2019-06-13 21:35:30', NULL, '0.14', 'qglkb', '0'),
(13, '1', NULL, '10', '100', '18888888888', NULL, '2019-06-15 12:46:55', 0, NULL, NULL, NULL, NULL, 0, NULL, NULL, '', NULL, '6', NULL, NULL, NULL, '0.1', 'cslkb', ''),
(14, '1', NULL, '10', '100', '18888888888', NULL, '2019-06-15 12:47:45', 0, NULL, NULL, NULL, NULL, 0, NULL, NULL, '', NULL, '6', NULL, NULL, NULL, '0.1', 'qglkb', '0'),
(15, '1', NULL, '10', '100', '18888888888', NULL, '2019-06-15 12:48:03', 0, NULL, NULL, NULL, NULL, 0, NULL, NULL, '', NULL, '6', NULL, NULL, NULL, '0.1', 'qglkb', '0'),
(16, '1', NULL, '0.5', '10', '18888888888', NULL, '2019-06-16 10:45:24', 0, NULL, NULL, NULL, NULL, 0, NULL, NULL, '', NULL, '6', NULL, NULL, NULL, '0.05', 'qglkb', '0'),
(17, '1', NULL, '17', '100', '18888888888', NULL, '2019-06-26 16:02:42', 0, NULL, NULL, NULL, NULL, 0, NULL, NULL, '', NULL, '6', NULL, NULL, NULL, '0.17', 'cslkb', ''),
(18, '1', NULL, '0.16', '1', '18888888888', NULL, '2019-07-26 19:04:02', 0, NULL, NULL, NULL, NULL, 0, NULL, NULL, '', NULL, '6', NULL, NULL, NULL, '0.16', 'qglkb', '0');

-- --------------------------------------------------------

--
-- 表的结构 `ds_product`
--

CREATE TABLE `ds_product` (
  `id` int(10) UNSIGNED NOT NULL,
  `tid` int(11) NOT NULL,
  `title` char(255) NOT NULL,
  `price` decimal(10,2) NOT NULL DEFAULT '0.00',
  `stock` mediumint(9) NOT NULL DEFAULT '0',
  `gonglv` decimal(11,2) UNSIGNED NOT NULL DEFAULT '0.00',
  `yszq` mediumint(8) UNSIGNED NOT NULL DEFAULT '0',
  `shouyi` decimal(15,8) UNSIGNED NOT NULL DEFAULT '0.00000000',
  `thumb` char(255) NOT NULL DEFAULT 'pic.png',
  `content` text NOT NULL,
  `pid` int(11) NOT NULL,
  `inputtime` int(11) UNSIGNED NOT NULL,
  `xianshou` int(11) NOT NULL,
  `xiangou` int(11) NOT NULL COMMENT '限购',
  `is_on` tinyint(1) DEFAULT '0'
) ENGINE=MyISAM DEFAULT CHARSET=utf8 ROW_FORMAT=COMPACT;

--
-- 转存表中的数据 `ds_product`
--

INSERT INTO `ds_product` (`id`, `tid`, `title`, `price`, `stock`, `gonglv`, `yszq`, `shouyi`, `thumb`, `content`, `pid`, `inputtime`, `xianshou`, `xiangou`, `is_on`) VALUES
(1, 3, '微型矿机(赠)', '100.00', 999895, '0.01', 1540, '0.00833330', '/Public/Uploads/20181119/5bf2a19634ccc.png', '<p>\r\n	此款矿机为非卖品，限量赠送，每人可领取一台\r\n</p>', 0, 1509817831, 1, 1, 0),
(2, 3, '微型矿机', '10.00', 999973, '0.01', 1440, '0.00833333', '/Public/Uploads/20181119/5bf2a1a20dd70.png', '<span>微型矿机：兑换单价10个CTC，算力为0.01GH/s，运行周期为1440小时，每小时产量个<span style=\"background-color:rgba(255, 255, 255, 0);\">0.0083333</span>CTC，总收益12CTC【CTC可在交易中心获得】</span>', 0, 1527322722, 1, 11, 0),
(3, 3, '白银矿机', '100.00', 999977, '0.10', 1440, '0.08333333', '/Public/Uploads/20181119/5bf29f68a7b28.png', '<span>白银矿机：兑换单价100个CTC，算力为0.1GH/s，运行周期为1440小时，每小时产量<span style=\"background-color:rgba(255, 255, 255, 0);\">0.0833333个</span>CTC，总收益120CTC【CTC可在交易中心获得】</span><br />', 0, 1509817897, 3, 9, 0),
(4, 3, '黄金矿机', '1000.00', 999952, '1.00', 1440, '0.83333333', '/Public/Uploads/20181119/5bf2a1ad8ed95.png', '黄金矿机：兑换单价1000个CTC,算力为1GH/s，运行周期为1440小时，每小时产量个<span style=\"background-color:rgba(255, 255, 255, 0);\">0.833333CTC</span>，总收益1200CTC【CTC可在交易中心获得】<br />', 0, 1509817983, 5, 7, 0),
(6, 3, '钻石矿机', '3898.00', 8388607, '10.00', 1440, '8.33333333', '/Public/Uploads/20181119/5bf29fa3d16c0.png', '<p>\r\n	钻石矿机：兑换单价10000个CTC，算力为10GH/s，运行周期为1440小时，每小时产<span style=\"background-color:rgba(255, 255, 255, 0);\">8.33333333CTC,</span>总收益12000CTC 【CTC可在交易中心获得】\r\n</p>', 0, 1526664588, 50, 3, 0);

-- --------------------------------------------------------

--
-- 表的结构 `ds_qjinbidetail`
--

CREATE TABLE `ds_qjinbidetail` (
  `id` int(11) UNSIGNED NOT NULL,
  `type` tinyint(4) NOT NULL DEFAULT '0',
  `member` varchar(255) DEFAULT '' COMMENT '会员编号',
  `adds` decimal(12,2) UNSIGNED DEFAULT '0.00' COMMENT '添加',
  `reduce` decimal(12,2) UNSIGNED DEFAULT '0.00' COMMENT '减少',
  `balance` decimal(12,2) UNSIGNED DEFAULT '0.00' COMMENT '余额',
  `addtime` int(10) DEFAULT '0' COMMENT '操作时间',
  `statustime` int(11) UNSIGNED NOT NULL DEFAULT '0',
  `desc` varchar(255) DEFAULT '' COMMENT '说明',
  `status` tinyint(4) NOT NULL DEFAULT '1'
) ENGINE=MyISAM AVG_ROW_LENGTH=68 DEFAULT CHARSET=utf8 COMMENT='欠钱明细' ROW_FORMAT=COMPACT;

--
-- 转存表中的数据 `ds_qjinbidetail`
--

INSERT INTO `ds_qjinbidetail` (`id`, `type`, `member`, `adds`, `reduce`, `balance`, `addtime`, `statustime`, `desc`, `status`) VALUES
(6883, 0, '18888888888', '13.00', '0.00', '13.00', 1530540141, 0, '交易市场下单', 1),
(6884, 0, '18888888888', '0.00', '13.00', '0.00', 1530540508, 0, '买家取消订单扣除', 1),
(6885, 0, '18888888888', '11.50', '0.00', '11.50', 1559446029, 0, '交易市场下单', 1),
(6886, 0, '18888888888', '12.65', '0.00', '24.15', 1560336898, 0, ' 卖出挂单', 1),
(6887, 0, '13103598345', '124.00', '0.00', '124.00', 1560432930, 0, '交易市场下单', 1),
(6888, 0, '18888888888', '0.00', '24.15', '0.00', 1560433025, 0, '交易订单完成扣除', 1),
(6889, 0, '18888888888', '0.00', '0.00', '0.00', 1560519921, 0, '订单撤销扣除', 1),
(6890, 0, '18888888888', '115.00', '0.00', '115.00', 1560574015, 0, ' 卖出挂单', 1),
(6891, 0, '18888888888', '115.00', '0.00', '230.00', 1561536162, 0, ' 卖出挂单', 1);

-- --------------------------------------------------------

--
-- 表的结构 `ds_receivable`
--

CREATE TABLE `ds_receivable` (
  `id` int(10) UNSIGNED NOT NULL,
  `member` varchar(255) DEFAULT NULL COMMENT '会员编号',
  `type` varchar(50) DEFAULT NULL COMMENT '收款方式',
  `name` varchar(255) DEFAULT NULL COMMENT '收款人姓名',
  `account` varchar(255) DEFAULT NULL COMMENT '收款人账号',
  `address` varchar(255) DEFAULT NULL COMMENT '开户行',
  `isdefault` tinyint(4) DEFAULT '0' COMMENT '是否默认'
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COMMENT='收款账号' ROW_FORMAT=COMPACT;

-- --------------------------------------------------------

--
-- 表的结构 `ds_regbd`
--

CREATE TABLE `ds_regbd` (
  `id` int(11) NOT NULL,
  `username` varchar(50) NOT NULL,
  `desc` varchar(100) NOT NULL,
  `status` tinyint(3) UNSIGNED NOT NULL DEFAULT '0',
  `addtime` int(11) UNSIGNED NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8 ROW_FORMAT=COMPACT;

-- --------------------------------------------------------

--
-- 表的结构 `ds_ridate`
--

CREATE TABLE `ds_ridate` (
  `Id` int(11) NOT NULL,
  `jinkai` varchar(255) DEFAULT NULL,
  `zuoshou` varchar(255) DEFAULT NULL,
  `jrzg` varchar(255) DEFAULT NULL,
  `jrzd` varchar(255) DEFAULT NULL,
  `date` varchar(255) DEFAULT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8 ROW_FORMAT=COMPACT;

--
-- 转存表中的数据 `ds_ridate`
--

INSERT INTO `ds_ridate` (`Id`, `jinkai`, `zuoshou`, `jrzg`, `jrzd`, `date`) VALUES
(67, '0.16', '0.16', '0.16', '0.16', '1528387200'),
(68, '0.16', '0.16', '0.18', '0.16', '1528473600'),
(69, '0.18', '0.18', '0.18', '0.14', '1528560000'),
(70, '0.14', '0.14', '0.14', '0.14', '1528646400'),
(71, '0.14', '0.14', '0.14', '0.14', '1528732800'),
(72, '0.14', '0.14', '0.14', '0.14', '1528819200'),
(73, '0.14', '0.14', '0.14', '0.14', '1528905600'),
(74, '0.14', '0.14', '0.14', '0.14', '1528992000'),
(75, '0.14', '0.14', '0.14', '0.14', '1529078400'),
(76, '0.14', '0.14', '0.14', '0.14', '1529164800'),
(77, '0.14', '0.14', '0.14', '0.14', '1529251200'),
(78, '0.14', '0.14', '0.14', '0.14', '1529337600'),
(79, '0.14', '0.14', '0.14', '0.14', '1529424000'),
(80, '0.14', '0.14', '0.14', '0.14', '1529510400'),
(81, '0.14', '0.14', '0.14', '0.14', '1529596800'),
(82, '0.14', '0.14', '0.14', '0.14', '1529683200'),
(83, '0.14', '0.14', '0.14', '0.14', '1529769600'),
(84, '0.14', '0.14', '0.14', '0.14', '1529856000'),
(85, '0.14', '0.14', '0.14', '0.14', '1529942400'),
(86, '0.14', '0.14', '0.14', '0.14', '1530028800'),
(87, '0.14', '0.14', '0.14', '0.14', '1530115200'),
(88, '0.14', '0.14', '0.14', '0.13', '1530201600'),
(89, '0.13', '0.13', '0.13', '0.13', '1530288000'),
(90, '0.13', '0.13', '0.13', '0.13', '1530374400'),
(91, '0.13', '0.13', '0.14', '0.13', '1530460800'),
(92, '0.14', '0.14', '0.14', '0.14', '1530547200'),
(93, '0.14', '0.14', '0.14', '0.14', '1530633600'),
(94, '0.14', '0.14', '0.14', '0.14', '1530720000'),
(95, '0.14', NULL, '0.14', '0.14', '1536422400'),
(96, '0.14', NULL, '0.14', '0.14', '1536681600'),
(97, NULL, NULL, NULL, NULL, '1542556800'),
(98, NULL, NULL, NULL, NULL, '1558713600'),
(99, NULL, NULL, NULL, NULL, '1558800000'),
(100, NULL, NULL, NULL, NULL, '1558886400'),
(101, NULL, NULL, NULL, NULL, '1558972800'),
(102, NULL, NULL, NULL, NULL, '1559145600'),
(103, NULL, NULL, NULL, NULL, '1559232000'),
(104, NULL, NULL, NULL, NULL, '1559318400'),
(105, NULL, NULL, NULL, NULL, '1559404800'),
(106, NULL, NULL, NULL, NULL, '1559491200'),
(107, NULL, NULL, NULL, NULL, '1559577600'),
(108, NULL, NULL, NULL, NULL, '1559750400'),
(109, NULL, NULL, NULL, NULL, '1559836800'),
(110, NULL, NULL, NULL, NULL, '1559923200'),
(111, NULL, NULL, NULL, NULL, '1560009600'),
(112, NULL, NULL, NULL, NULL, '1560096000'),
(113, NULL, NULL, NULL, NULL, '1560182400'),
(114, NULL, NULL, NULL, NULL, '1560268800'),
(115, NULL, NULL, '0.14', NULL, '1560355200'),
(116, NULL, '0.14', NULL, NULL, '1560441600'),
(117, NULL, NULL, NULL, NULL, '1560528000'),
(118, NULL, NULL, NULL, NULL, '1560614400'),
(119, NULL, NULL, NULL, NULL, '1560700800'),
(120, NULL, NULL, NULL, NULL, '1560873600'),
(121, NULL, NULL, NULL, NULL, '1561305600'),
(122, NULL, NULL, NULL, NULL, '1561478400'),
(123, NULL, NULL, NULL, NULL, '1564070400'),
(124, NULL, NULL, NULL, NULL, '1564243200'),
(125, NULL, NULL, NULL, NULL, '1578067200');

-- --------------------------------------------------------

--
-- 表的结构 `ds_role`
--

CREATE TABLE `ds_role` (
  `id` smallint(6) UNSIGNED NOT NULL,
  `name` varchar(20) NOT NULL DEFAULT '',
  `pid` smallint(6) DEFAULT NULL,
  `status` tinyint(1) UNSIGNED DEFAULT NULL,
  `remark` varchar(255) DEFAULT NULL
) ENGINE=MyISAM AVG_ROW_LENGTH=32 DEFAULT CHARSET=utf8 ROW_FORMAT=COMPACT;

--
-- 转存表中的数据 `ds_role`
--

INSERT INTO `ds_role` (`id`, `name`, `pid`, `status`, `remark`) VALUES
(1, '111', NULL, 1, '111'),
(2, '测试', NULL, 1, '测试');

-- --------------------------------------------------------

--
-- 表的结构 `ds_role_user`
--

CREATE TABLE `ds_role_user` (
  `role_id` mediumint(9) UNSIGNED DEFAULT NULL,
  `user_id` char(32) DEFAULT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8 ROW_FORMAT=COMPACT;

-- --------------------------------------------------------

--
-- 表的结构 `ds_rotate`
--

CREATE TABLE `ds_rotate` (
  `id` int(10) UNSIGNED NOT NULL,
  `username` varchar(40) NOT NULL,
  `pro_id` mediumint(8) UNSIGNED NOT NULL,
  `title` varchar(255) NOT NULL,
  `time` int(11) UNSIGNED NOT NULL,
  `use` smallint(5) UNSIGNED NOT NULL DEFAULT '0',
  `status` tinyint(3) UNSIGNED NOT NULL DEFAULT '0'
) ENGINE=MyISAM DEFAULT CHARSET=utf8 ROW_FORMAT=COMPACT;

-- --------------------------------------------------------

--
-- 表的结构 `ds_session`
--

CREATE TABLE `ds_session` (
  `session_id` varchar(255) NOT NULL DEFAULT '',
  `session_expire` int(11) NOT NULL,
  `session_data` blob
) ENGINE=MyISAM AVG_ROW_LENGTH=196 DEFAULT CHARSET=utf8 ROW_FORMAT=COMPACT;

-- --------------------------------------------------------

--
-- 表的结构 `ds_sharedetail`
--

CREATE TABLE `ds_sharedetail` (
  `id` int(11) UNSIGNED NOT NULL,
  `type` tinyint(4) NOT NULL DEFAULT '0',
  `member` varchar(255) DEFAULT '' COMMENT '会员编号',
  `adds` decimal(12,2) UNSIGNED DEFAULT '0.00' COMMENT '添加',
  `reduce` decimal(12,2) UNSIGNED DEFAULT '0.00' COMMENT '减少',
  `balance` decimal(12,2) UNSIGNED DEFAULT '0.00' COMMENT '余额',
  `addtime` int(10) DEFAULT '0' COMMENT '操作时间',
  `statustime` int(11) UNSIGNED NOT NULL DEFAULT '0',
  `desc` varchar(255) DEFAULT '' COMMENT '说明',
  `status` tinyint(4) NOT NULL DEFAULT '1'
) ENGINE=MyISAM AVG_ROW_LENGTH=68 DEFAULT CHARSET=utf8 COMMENT='明细' ROW_FORMAT=COMPACT;

-- --------------------------------------------------------

--
-- 表的结构 `ds_shopbanner`
--

CREATE TABLE `ds_shopbanner` (
  `id` int(10) NOT NULL,
  `path` varchar(100) NOT NULL,
  `sort` int(10) DEFAULT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8 ROW_FORMAT=DYNAMIC;

--
-- 转存表中的数据 `ds_shopbanner`
--

INSERT INTO `ds_shopbanner` (`id`, `path`, `sort`) VALUES
(1, '/Public/Uploads/20180701/5b38f936ad734.jpg', 1),
(2, '/Public/Uploads/20180701/5b38f93fb55d3.jpg', 2);

-- --------------------------------------------------------

--
-- 表的结构 `ds_shop_group`
--

CREATE TABLE `ds_shop_group` (
  `groupid` tinyint(3) UNSIGNED NOT NULL,
  `level` tinyint(3) UNSIGNED NOT NULL DEFAULT '0' COMMENT '商户等级',
  `name` char(15) NOT NULL COMMENT '商户名称 ',
  `goosnum` int(10) UNSIGNED NOT NULL DEFAULT '0',
  `price` int(10) UNSIGNED NOT NULL DEFAULT '0',
  `addtime` int(11) UNSIGNED NOT NULL DEFAULT '0',
  `shouxu` int(10) UNSIGNED NOT NULL DEFAULT '0'
) ENGINE=MyISAM DEFAULT CHARSET=utf8 ROW_FORMAT=COMPACT;

--
-- 转存表中的数据 `ds_shop_group`
--

INSERT INTO `ds_shop_group` (`groupid`, `level`, `name`, `goosnum`, `price`, `addtime`, `shouxu`) VALUES
(1, 1, '普通商家', 1, 5000, 1487262445, 20),
(2, 2, '铜牌商家', 3, 10000, 1487262481, 15),
(3, 3, '银牌商家', 9, 30000, 1487262481, 10),
(4, 4, '金牌商家', 15, 50000, 1487262481, 5);

-- --------------------------------------------------------

--
-- 表的结构 `ds_sms_log`
--

CREATE TABLE `ds_sms_log` (
  `id` int(11) NOT NULL COMMENT '表id',
  `mobile` varchar(11) DEFAULT '' COMMENT '手机号',
  `session_id` varchar(128) DEFAULT '' COMMENT 'session_id',
  `add_time` int(11) DEFAULT '0' COMMENT '发送时间',
  `code` varchar(10) DEFAULT '' COMMENT '验证码'
) ENGINE=MyISAM DEFAULT CHARSET=utf8 ROW_FORMAT=COMPACT;

--
-- 转存表中的数据 `ds_sms_log`
--

INSERT INTO `ds_sms_log` (`id`, `mobile`, `session_id`, `add_time`, `code`) VALUES
(24563, '13164352999', '2bptos4m7fo1k36bpkaqs6ums7', 1528681768, '499294'),
(24564, '15936266096', 'v009rdbck47gpet6f9c386e0o0', 1528681991, '611355'),
(24565, '18318876315', '1hc0o6ivlc9fbulhr7i76mqo33', 1528684413, '587592'),
(24566, '17737783816', 'cvs2n3jvadi548rgs7kkd5h067', 1528684450, '383924'),
(24567, '17737783816', 'o92l74fe9nvnh93lrcftu6jsv2', 1528684687, '217474'),
(24568, '15516019657', 'l35qjnsp9hspb9pb7729gmmmv3', 1528684735, '362630'),
(24569, '18595898679', 'qfevolpiomqiq1lgacfmvs2j95', 1528685529, '407877'),
(24570, '18803783999', 'obae9ihnontecsh7qpdqp6qi42', 1528690392, '499647'),
(24571, '13203874511', 'kiont0nv8o49djn7kokcijoh82', 1528696770, '918050'),
(24572, '15238625511', 'kiont0nv8o49djn7kokcijoh82', 1528696910, '188178'),
(24573, '15055596222', '50h3s29nc19on123b4onc3d6d5', 1528703634, '381049'),
(24574, '15055596222', '3e2bv5tcun3ba1146mug46ka44', 1528703903, '393527'),
(24575, '18637385122', 'kv29siv4c37ss0akoqrd5k17i3', 1528713804, '132568'),
(24576, '17797752708', 'bo6k4m56cin1tjsdpu848n6s45', 1528715578, '555202'),
(24577, '17797752708', '67s5nbb3nfe7mrqce0ahdf9kh1', 1528715668, '328938'),
(24578, '15936550416', 'iabn1rpvi2lmtpvvc273j6sjd0', 1528715792, '932996'),
(24579, '18568709191', 'g4jeb8vn49pcaptm14p90u76k0', 1528715800, '769368'),
(24580, '13503845053', 's8ev7oabktv27e8t4888fojb25', 1528772755, '897460'),
(24581, '13503845053', 's8ev7oabktv27e8t4888fojb25', 1528773570, '658420'),
(24582, '15200000908', 'cd0ikiuoca3d7h0rl3rnv9pta3', 1528778035, '196641'),
(24583, '13673673027', 's5hb16tfaaq1skhlhhh92nmqe0', 1528786490, '738389'),
(24584, '13339997637', '9gkt8ct4ejd2mu0h8ekd7dqp36', 1528790022, '120985'),
(24585, '15738179502', 'dvpkkdumm38a52ru8gptomv4u0', 1528797837, '274034'),
(24586, '13014509000', '0d01q35gam7h3dtf03c06cv9v7', 1528803403, '364773'),
(24587, '13014509000', 'gov7r0cv29lma50ii4tjnndq45', 1528803716, '724093'),
(24588, '15186208027', 'kb4gvn28g0h9qdcak5kcfal4m6', 1528803955, '808729'),
(24589, '13667237661', '1ca7gn5s21vddqoas56nn4a8k7', 1528805790, '589463'),
(24590, '13540373333', 'lb57bcdh0mreac2v60lmh93q33', 1528808819, '699137'),
(24591, '13520221994', 'np0j0128t4fpl27du9d8tu1tl4', 1528810626, '327066'),
(24592, '18575675134', 'np0j0128t4fpl27du9d8tu1tl4', 1528810826, '265326'),
(24593, '18639736868', 'km16cevtj89jl2i4tkjv3cijd3', 1528848436, '711100'),
(24594, '18639736868', 'km16cevtj89jl2i4tkjv3cijd3', 1528848737, '878445'),
(24595, '18227752815', 'd5v3g6le3bkdi2v3moppkfmgm5', 1528864780, '830186'),
(24596, '18672133720', 'a6aijgo2hbc2ojvgrklotn2g72', 1528864982, '181532'),
(24597, '15287121558', 'c8k0bgs5cs4ulk4vtqcl7c7l54', 1528865017, '193440'),
(24598, '18726576178', '4o25uuoao0p40rr8aivhpbupb6', 1528870173, '378038'),
(24599, '18397647243', 'dhpfige4o6kgv1huu2cdvq2jv2', 1528878768, '268635'),
(24600, '17719817771', 'kpf7hsttgevb0qppeorel8r0d6', 1528885623, '555229'),
(24601, '18739996688', '0hhmaahlqjvn3t2i4idpos2sj4', 1528886121, '392659'),
(24602, '18627115588', '0hhmaahlqjvn3t2i4idpos2sj4', 1528886324, '550835'),
(24603, '15860670829', 'e9kaesqbss53hr1f5l33hkdfk6', 1528945025, '769666'),
(24604, '18726577272', '6uacnrnakdaqbogcl0pndab5s2', 1528946205, '932698'),
(24605, '13073755270', 'u5f9u0u3vprfjnvvujp4okpbf7', 1528946848, '967936'),
(24606, '15837886090', 'joeev6etoa8ajr4oom7381t3c6', 1528951700, '582329'),
(24607, '15188332982', 'c4ghe92o1ag5psg3vk2o135q14', 1528953113, '746310'),
(24608, '13623756261', '7750rhf121aqp7crflqohk3t06', 1528953115, '758734'),
(24609, '17756235430', 'at4nbs9ilsgsq6kmpu3gmmob92', 1529033576, '290662'),
(24610, '13864643525', '9bt6hrs3r8l41o31t8nrb1hrr7', 1529040650, '517171'),
(24611, '13937858275', 'e3f0f570a151g3a9ap0l03g741', 1529042511, '702256'),
(24612, '15387098613', 'eu29tb8ubt5ifpuupjgp8bghc3', 1529042762, '352837'),
(24613, '13333053581', 'nfk4uf54i720poshtqvg36lg74', 1529043115, '681667'),
(24614, '13333053281', 'cuhojl2clrmfg63u7mc17vs9b1', 1529043295, '579345'),
(24615, '13333053281', 'nfk4uf54i720poshtqvg36lg74', 1529043370, '674587'),
(24616, '15942936103', 'v8aoq2vjfmt45v89hvi956jtu2', 1529044096, '935492'),
(24617, '13563053477', '0rtrhm0hk1ve7f159tmjk4fcf7', 1529044343, '680609'),
(24618, '13193799279', 'hf520vt53g354qh18d301fjqv6', 1529045269, '418267'),
(24619, '15348520673', 'j8q09d9n6kn0u3qeqlq7gaftt1', 1529046617, '129367'),
(24620, '13903782436', 'hf520vt53g354qh18d301fjqv6', 1529054835, '653320'),
(24621, '18577795962', 'esqg3bl17s6ne76fnvig9b3jv4', 1529064715, '837944'),
(24622, '18897719849', '2kare9ortf27t63nb3jkdcmpk0', 1529065833, '358506'),
(24623, '18897719849', '2kare9ortf27t63nb3jkdcmpk0', 1529066043, '170464'),
(24624, '18319283191', 'a7324e35j80q6csj2qq6isrps6', 1529067902, '424289'),
(24625, '15950270704', 'khu688o1b2vrgnuec4v7d9gmk7', 1529071566, '723795'),
(24626, '18805035962', '3tt39u3dsq76ilntcnuoe0i426', 1529077725, '671820'),
(24627, '15387098613', 'favc2ga212d4f4f0eocnf0n9j2', 1529089189, '858751'),
(24628, '13898572828', '8a4tvrmra1h8s6c704sg7b89o2', 1529115783, '315972'),
(24629, '13428317723', 'tfvgop4dgqv3g6n5o9o97b0jc2', 1529117057, '260579'),
(24630, '15239871189', '7r40omb4apvk53201bq08tf775', 1529118334, '706081'),
(24631, '13534929674', 'v5v55jrnu933um8n9nrma3ql94', 1529141141, '181532'),
(24632, '13193887071', 'o3e3gc88j0raadlqbc48lgo5j4', 1529142238, '318386'),
(24633, '13534929674', 'v5v55jrnu933um8n9nrma3ql94', 1529142294, '510416'),
(24634, '15257570828', 'st2s0j7r824g1biso8c12n88s2', 1529144397, '317002'),
(24635, '15257570828', 'st2s0j7r824g1biso8c12n88s2', 1529144633, '457356'),
(24636, '18530807318', '1pqvkrcbp8qluoos1jlov8v9o1', 1529306039, '919623'),
(24637, '18530807318', '8v7427ep4e88fsee076j2n5a92', 1529306365, '719156'),
(24638, '18530807318', '1pqvkrcbp8qluoos1jlov8v9o1', 1529306469, '935818'),
(24639, '13653838803', '469s6eo239j1nbdlrn0rdnn8v3', 1529401760, '792371'),
(24640, '18530868278', '469s6eo239j1nbdlrn0rdnn8v3', 1529401902, '938585'),
(24641, '18803753918', 'nvipgjic3og8r4mvd5n80ufog0', 1529465397, '895833'),
(24642, '15288901686', '0ight717ffjk0vgjcqn52dlki4', 1529475504, '944580'),
(24643, '15314099319', 'i69rprhb9diancv3lrd5fjr8e4', 1529477402, '144476'),
(24644, '18661313913', '3uls3u8d4a2k6q9sp12kfe8fa5', 1529480656, '736029'),
(24645, '18053827817', 'pc77d70tctj9ntm5mfmq59gpo2', 1529487308, '289550'),
(24646, '13670888292', 'ajeof270q19t3cha4kr3mm2ur7', 1529487866, '330918'),
(24647, '18053827817', 'pc77d70tctj9ntm5mfmq59gpo2', 1529488266, '864827'),
(24648, '18747165624', 'ddc71322290sl8pldm6no0gvq6', 1529488281, '704562'),
(24649, '15315481133', 'ghmted59op6kmvcsm3jhoqq9p2', 1529489856, '147406'),
(24650, '13425527320', 'icbogfalbf6smthkmmalmlr402', 1529491752, '326958'),
(24651, '13963018917', 'endvgqqlv28guqfdolrautgnc1', 1529493652, '538519'),
(24652, '13858968074', 'anhdh01ol83mnr7038h98jc1b4', 1529502013, '810194'),
(24653, '18236437259', 'h6n6fi9b020aeu0nh0i1osg5e2', 1529503754, '419325'),
(24654, '18295429981', '25hemqpup9fibipsobregpbh02', 1529538403, '789333'),
(24655, '13673582118', '9k9483ff4bckbjhja58h5cunk3', 1529543717, '598225'),
(24656, '15837105008', 'uo472uc89a6don64aoj2drpic2', 1529548864, '958685'),
(24657, '15897755663', 'jnlcgpfjg40798kbb27257sd67', 1529549204, '300835'),
(24658, '13612799922', 'u5q1jt19br2tjahv0ldcobv114', 1529550325, '583170'),
(24659, '15833525779', 'f7d59a1c042nffa97sdcit07g7', 1529550622, '174180'),
(24660, '15347806699', '321a2m4gql74vp1mifklkqoer0', 1529552954, '571099'),
(24661, '15347806699', 'jnafr3t1kmj9rqfgqcc4fldcv6', 1529553299, '583550'),
(24662, '13703671272', '33de0vudbp4jda8tp5568j9et2', 1529554682, '737467'),
(24663, '13403350334', 'hngjosdbtigik7qtuse5lvqvl4', 1529561353, '552897'),
(24664, '15206390185', 'gedt0afhpvdbnmnu41cisa8em4', 1529567968, '933919'),
(24665, '13598442460', '4ua3ht818hi07qa6h1m3n85jg3', 1529585397, '321017'),
(24666, '13169509106', '6re3j8inegcd8eoe361rect2p0', 1529621104, '597005'),
(24667, '18661560657', 'k1m0tc1pi3k7htbuuvm4l5emn6', 1529627744, '503770'),
(24668, '15222421221', 'uq59t859pp2t7u2tpt13sfqje6', 1529627872, '911838'),
(24669, '18730616376', 'ogkbjfif32spncbpk3iso70m24', 1529636833, '593722'),
(24670, '13319319439', 'ktg7sgrhohgabssi33cpgqjnc1', 1529637628, '755154'),
(24671, '15827500591', 'a4rsn1qh1l85laj4287qeovhm1', 1529638950, '426540'),
(24672, '18872324084', 'cihqmn930cs192nbdodb9sfa05', 1529644837, '393907'),
(24673, '18178339392', 'lujd7snrnnt01dd6oiplson0u0', 1529648257, '309570'),
(24674, '13307173331', '1bg5m7j38gqg7lhaeshd8i8tc5', 1529649767, '179361'),
(24675, '18627031670', 'id1ao1nqaenuvprvj0bh8776u4', 1529650570, '438883'),
(24676, '18137863335', '2pudp7ngu8an1sauc5k1n66tv1', 1529651129, '897108'),
(24677, '13939022990', 'eg6golkdlrgt1uet3ljqtug4g4', 1529652272, '390679'),
(24678, '17070256888', 'ce6c6u6oaij7ljcn6571lrage2', 1529656395, '502142'),
(24679, '18603865557', 'b38mdnlrid7ud4qng1386fi9c6', 1529657895, '554795'),
(24680, '15036048321', '9pm544c5nhgh1i3cv9j5cvhv62', 1529659325, '724500'),
(24681, '15251219448', 'gqv7bf43mot54nu9btaavosn33', 1529660476, '242675'),
(24682, '15839976659', '8jll7t9i1b02rillul9im9lp56', 1529661405, '291286'),
(24683, '15837105008', 'lbd5g3tp2hs42iduskgio4lnl0', 1529663911, '225233'),
(24684, '18034949789', '0arfj6o815fn01p4uta3700k96', 1529664531, '611626'),
(24685, '15517553987', 'f8pt6ci0rqg8cf0vbvr55963i2', 1529664742, '366319'),
(24686, '18336193888', '763omp9f9vj858nphhbggb2ed2', 1529665170, '270941'),
(24687, '18336193888', '763omp9f9vj858nphhbggb2ed2', 1529665479, '929714'),
(24688, '18336193888', '763omp9f9vj858nphhbggb2ed2', 1529666019, '470160'),
(24689, '13253567698', 'c9e2jf1ja2r1nl7a0ou22friu2', 1529744146, '264377'),
(24690, '13203863053', 'c9e2jf1ja2r1nl7a0ou22friu2', 1529745211, '125623'),
(24691, '13253567698', 'c9e2jf1ja2r1nl7a0ou22friu2', 1529745831, '645046'),
(24692, '18603813052', 'c9e2jf1ja2r1nl7a0ou22friu2', 1529746232, '340874'),
(24693, '13949424484', 'b8vuvjm10n935klcn4te0ld252', 1529746890, '453667'),
(24694, '13260296142', 'fn7uc5ffbirqpheea5mucsio15', 1529748550, '913899'),
(24695, '13253567698', 'c9e2jf1ja2r1nl7a0ou22friu2', 1529750871, '834526'),
(24696, '17335775818', 'k2mrceukglgrr0epcid7qtese4', 1529751596, '465087'),
(24697, '13253567698', 'ucup84numc716mlkhqr4gage12', 1529751737, '345106'),
(24698, '17638151978', 'k2mrceukglgrr0epcid7qtese4', 1529751818, '293402'),
(24699, '15670788858', 'gguct1tjf75ju7aqvfvtrhu8v0', 1529752409, '398762'),
(24700, '15670788858', 'gguct1tjf75ju7aqvfvtrhu8v0', 1529752597, '843505'),
(24701, '13616867026', '7f9gqmm9v6aq5lkk2u3qmvhig7', 1529771936, '798204'),
(24702, '13803919094', '84a4dtccqg08gdpocoivmls686', 1529809260, '645345'),
(24703, '18337824444', 'fvvvl7p73q78ep0tr1tothrmg3', 1529820822, '361843'),
(24704, '18337824444', 'fvvvl7p73q78ep0tr1tothrmg3', 1529821531, '958902'),
(24705, '13253567698', 'mf77jd28109vtd5f2l4ru1jeq6', 1529827962, '637776'),
(24706, '13915623789', '9f14j3do2vbmuno0mhoui1toq6', 1529829028, '415011'),
(24707, '13124394117', 'l5kgshg2ttuahv3r3eht00ubi7', 1529843466, '743923'),
(24708, '15907729146', '2jd4ii02luol0l0mf5k7r6erk3', 1529843985, '478108'),
(24709, '13614995074', 'sep3a876gkmogjioklrovks415', 1529879690, '992241'),
(24710, '18638014911', '6tue58dlb4sn6bn7fu51fcscr0', 1529884128, '932834'),
(24711, '18287736214', 'hgffd1eithtj5873pd9u3mgj87', 1529885841, '196831'),
(24712, '15626198863', 'dnor6d3jo42vga0iqfbir7uo03', 1529901275, '633816'),
(24713, '15535580456', 'ljtcummoqn2idinn641dulnf61', 1529903476, '855170'),
(24714, '18306555088', '74aippgohki30cqg0e7frac4o4', 1529905485, '983642'),
(24715, '18912060699', 'riacr7htud1ugsqhb94cjs3df0', 1529905928, '436224'),
(24716, '13415062948', 'o3mtolfmdchlbgncgs961lnra7', 1529908951, '928683'),
(24717, '13673095755', '3b1k1uej3rnm1fm355h8fijnf6', 1529912828, '317138'),
(24718, '13333770023', 'vv3dsd2qng90el5qb6upepocg1', 1529916966, '500027'),
(24719, '13959000013', 'emurkc6nu0fnbo2nipmt2q93a3', 1529918562, '457655'),
(24720, '13414072853', 'f32it8ud9seciiju4eve48na16', 1529923152, '448513'),
(24721, '18348013316', 'trn94ij46s8g8hb5dase1me024', 1529924608, '253309'),
(24722, '13119031896', 'ol6chatl8m1mouqejtgqde8ha0', 1529933307, '593478'),
(24723, '15841286475', 'vgac0gh4pp651tmf576bd02ph7', 1529935690, '850694'),
(24724, '18577795962', 'qu9f7gq8pjguq6a3bg7p42r5k3', 1529936384, '911105'),
(24725, '17316936813', 'lc08jknpbrsmcpkspq4276fdo2', 1529937908, '916476'),
(24726, '15554579444', 'a1k6j7f8e99fs69rai2gf7aj16', 1529944325, '913058'),
(24727, '15554579444', 'a1k6j7f8e99fs69rai2gf7aj16', 1529944865, '983398'),
(24728, '13304994936', 'sep3a876gkmogjioklrovks415', 1529963606, '192192'),
(24729, '15370161687', '40954peslvc36je0duofcvp2q2', 1529963661, '186984'),
(24730, '13791835696', 'ftsl46kvfv8g14g8rg1u3vl0r6', 1529968016, '207031'),
(24731, '13453735985', '8ad9gm36062dlnhucjpcga0ss2', 1529968693, '158338'),
(24732, '13832958695', '67kpi8osa4o0dd4v1tgln72r07', 1529975566, '719672'),
(24733, '13916057836', 'b0fff5qoemt2j8462i2qee0tv3', 1529981877, '644666'),
(24734, '13253369390', 'k2pf0tufubg9d8rat5lqmmub26', 1529982879, '860324'),
(24735, '13916057836', 'lo6a6cfbqsp7tntdo41fouh111', 1529985490, '588270'),
(24736, '17379901201', '1b1vob76ffp9v63nt5o4om17i7', 1529985873, '878743'),
(24737, '18607996835', '1b1vob76ffp9v63nt5o4om17i7', 1529986245, '684977'),
(24738, '18607996835', '1b1vob76ffp9v63nt5o4om17i7', 1529987033, '859076'),
(24739, '18607996835', 'sof8eka4jr3j6fjprvkduquae5', 1529987156, '216525'),
(24740, '13428317723', '7alvp05l8l48aaks4up7kpsg46', 1529987938, '886474'),
(24741, '13619860123', 'vbns183plsqnsr44gosgt78nl3', 1529997611, '989501'),
(24742, '13569392003', 'bac903j2ftbml6apqmjjug5o43', 1529998715, '379068'),
(24743, '13260296174', 'jmc0a5i5emkk8eubjkba3oqti5', 1530000687, '365207'),
(24744, '18782168334', 'tbdh6np5mu4jrkkc35j7hciek2', 1530008852, '962402'),
(24745, '13705385287', 'v4f61rh6505tter6q8l9n0lbu6', 1530021848, '496907'),
(24746, '13802717609', '13bauubbmjjkgqvcaievg8mdq2', 1530023191, '352701'),
(24747, '13802717609', '13bauubbmjjkgqvcaievg8mdq2', 1530023590, '599012'),
(24748, '15670162586', 'trrh5qrgg4qhofutl0v0if0cm5', 1530023688, '973090'),
(24749, '18672996989', 'fpk9glti36slrol5uktftg1ll1', 1530032141, '760253'),
(24750, '18672996989', '5ocsm9blf1f9k573cb9o5mfo24', 1530032240, '148356'),
(24751, '13946703331', 'c0kgu8akmfhtf0c0th541d47c0', 1530067366, '421359'),
(24752, '17602242028', 'a1k6j7f8e99fs69rai2gf7aj16', 1530067413, '187716'),
(24753, '13546828815', 'fum7t3p5p50vk8b17opcv711c4', 1530073717, '393120'),
(24754, '13071789700', '218ejua90vidkq3bm1994qop90', 1530081959, '711371'),
(24755, '18339988826', 'r97n0c5uq3sc2li3grp67g5qo7', 1530085109, '550211'),
(24756, '15993399332', 'ousjsmb4ieb1su9opcoervj2n5', 1530085154, '606743'),
(24757, '15672867237', '748gml3nd7retl759kiinqdeh2', 1530089727, '444986'),
(24758, '18336193888', 'd2m9dmd2b0j6k4sfk1grh3l404', 1530092892, '469970'),
(24759, '13949424202', 'u2k6gmq0o4da3o917fj5pno8e3', 1530111011, '979736'),
(24760, '15171861230', '4sdku56mhdu82flrrvam2q3j96', 1530148852, '234971'),
(24761, '13048484444', '8i4avtp7j10pv8uv63cm2i32j2', 1530154318, '909884'),
(24762, '15327324544', '0ahs8rm0g4s99nkvmmkbn757k5', 1530165782, '251736'),
(24763, '15327324544', 'bgkqm4gkgvh6jbds1c0duj0ld0', 1530166065, '825466'),
(24764, '18986100270', 'bgkqm4gkgvh6jbds1c0duj0ld0', 1530166157, '676025'),
(24765, '18986100270', '0ahs8rm0g4s99nkvmmkbn757k5', 1530166265, '749376'),
(24766, '13271756696', 'uprsf4ujbv1emujlarh0kgojg1', 1530178486, '964599'),
(24767, '13271756696', 'uprsf4ujbv1emujlarh0kgojg1', 1530179084, '516221'),
(24768, '18906478977', '2h3s5b75627r0788blg9ir1mo1', 1530183492, '238091'),
(24769, '13938373986', 'g7uj5nsfvs8kjggku6fj26os82', 1530191297, '227484'),
(24770, '13849149922', '1hvodho13nhohtu5d2lm10efc4', 1530192152, '607231'),
(24771, '13507663625', '0h15uknasle69m30aobv4bppl4', 1530193095, '277289'),
(24772, '18338570180', 'ba8mstabrfam3147dhf4u77vt5', 1530198708, '987738'),
(24773, '18338570180', 'ba8mstabrfam3147dhf4u77vt5', 1530199020, '927571'),
(24774, '18338570180', 'ba8mstabrfam3147dhf4u77vt5', 1530199275, '643636'),
(24775, '13389397003', '3g6gbe6fgtgsn7ko9d86kh6cb5', 1530201385, '784912'),
(24776, '15886517776', 'h38u02a8v0b8cp5ucmbnsk6s13', 1530235506, '925916'),
(24777, '15518385207', 'vtii9emjpqo317fc04s0idohi6', 1530256395, '356173'),
(24778, '13323836511', 'ij3r9nq38t2k5vimff5ropjfe1', 1530260183, '752305'),
(24779, '18230344383', 'ij3r9nq38t2k5vimff5ropjfe1', 1530260326, '273301'),
(24780, '13413438117', 'b4t856imos432cvhj7guef75o4', 1530263240, '449489'),
(24781, '18603997935', 'njes5je678p8q03jbaqk63lau5', 1530281761, '316975'),
(24782, '18695693310', 'qcmhm8locire4fm27st53o4pf6', 1530298867, '999240'),
(24783, '15836773296', 'hjmlvj97c71tu5l4gho1fdu8n3', 1530317938, '486545'),
(24784, '17310199762', 'q0ssliotpleohqrqgo152dunb7', 1530330903, '421603'),
(24785, '18310949895', 'q0ssliotpleohqrqgo152dunb7', 1530330981, '445665'),
(24786, '13193976665', 'nurddoe2k5joeqbadcrabetbe3', 1530337271, '133083'),
(24787, '13387576668', '176h5issdtqsdm0hn9h0g8vmi4', 1530341674, '350097'),
(24788, '13103598345', '6gnjqbebnq3a3qlih540gnckj3', 1530438332, '746012'),
(24789, '13103598345', '6gnjqbebnq3a3qlih540gnckj3', 1530438576, '978244'),
(24790, '13103598345', '6gnjqbebnq3a3qlih540gnckj3', 1530438793, '642333'),
(24791, '13127702598', 'gpb3s5lpjredgh0npsgf18lsa1', 1530501635, '991102'),
(24792, '13127702598', '9lm7go84iir25s3sjbcdaoj915', 1530626430, '562038'),
(24793, '13981733512', '3h4jknrnh26mo575q8a97oakt6', 1530687080, '232611'),
(24794, '13516287009', '9bn0n1npukvgdtcqcb8vlmgni7', 1530690337, '827907'),
(24795, '15332517378', 'n3k1eq6p18t05d2c3nrjupufh3', 1530722378, '815700'),
(24796, '18624619965', 'ebqjcn2tt6q70clf6r4qpgbrn6', 1530724193, '548882'),
(24797, '15227655552', '819dgoas23084sf7fgtn0jhr53', 1560479033, '7405'),
(24798, '15227655552', '819dgoas23084sf7fgtn0jhr53', 1560479204, '3002');

-- --------------------------------------------------------

--
-- 表的结构 `ds_tousu`
--

CREATE TABLE `ds_tousu` (
  `id` int(11) UNSIGNED NOT NULL,
  `user` varchar(255) DEFAULT NULL,
  `buser` varchar(255) DEFAULT NULL,
  `text` varchar(255) DEFAULT NULL,
  `date` varchar(255) DEFAULT NULL,
  `zt` int(10) NOT NULL DEFAULT '0',
  `pid` int(11) DEFAULT NULL,
  `status` varchar(255) DEFAULT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8 ROW_FORMAT=COMPACT;

-- --------------------------------------------------------

--
-- 表的结构 `ds_transfer`
--

CREATE TABLE `ds_transfer` (
  `id` int(11) UNSIGNED NOT NULL,
  `type` tinyint(3) UNSIGNED NOT NULL DEFAULT '0',
  `outer` varchar(255) DEFAULT '' COMMENT '转出会员编号',
  `iner` varchar(255) DEFAULT '' COMMENT '转入会员编号',
  `qty` decimal(15,2) DEFAULT '0.00' COMMENT '金额',
  `sxf` decimal(15,2) DEFAULT NULL,
  `addtime` int(11) DEFAULT '0' COMMENT '时间',
  `desc` varchar(255) DEFAULT '' COMMENT '备注'
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COMMENT='会员转账记录' ROW_FORMAT=COMPACT;

--
-- 转存表中的数据 `ds_transfer`
--

INSERT INTO `ds_transfer` (`id`, `type`, `outer`, `iner`, `qty`, `sxf`, `addtime`, `desc`) VALUES
(22, 0, '13164352999', '15936266096', '10.00', '0.00', 1528703107, '赠送'),
(23, 0, '13164352999', '18803783999', '50.00', '0.00', 1528705846, '你好'),
(24, 0, '18803783999', '13164352999', '50.00', '0.00', 1528705884, ''),
(25, 0, '13164352999', '18803783999', '10.00', '0.00', 1528706290, ''),
(26, 0, '13164352999', '18803783999', '1000000.00', '0.00', 1528789587, '常总'),
(27, 0, '18803783999', '15238625511', '500000.00', '0.00', 1528789665, ''),
(28, 0, '15238625511', '18803783999', '20000.00', '0.00', 1528789730, ''),
(29, 0, '18803783999', '15238625511', '20000.00', '0.00', 1528789781, ''),
(30, 0, '13164352999', '15516019657', '100000.00', '0.00', 1528794665, ''),
(31, 0, '15238625511', '15055596222', '20000.00', '0.00', 1528806837, '矿机'),
(32, 0, '15238625511', '17797752708', '20000.00', '0.00', 1528807950, ''),
(33, 0, '15238625511', '13339997637', '20000.00', '0.00', 1528814984, ''),
(34, 0, '18803783999', '13673673027', '20000.00', '0.00', 1528815024, ''),
(35, 0, '13164352999', '15200000908', '200000.00', '0.00', 1528815283, '梁总'),
(36, 0, '15238625511', '15055596222', '20000.00', '0.00', 1528867863, ''),
(37, 0, '18803783999', '13673673027', '20000.00', '0.00', 1528948766, ''),
(38, 0, '15238625511', '15055596222', '20000.00', '0.00', 1528951146, ''),
(39, 0, '15238625511', '18639736868', '20000.00', '0.00', 1528951254, ''),
(40, 0, '15238625511', '13073755270', '20000.00', '0.00', 1528952514, ''),
(41, 0, '15055596222', '18726577272', '20000.00', '0.00', 1528956215, ''),
(42, 0, '15200000908', '13540373333', '20000.00', '0.00', 1528985022, '谢谢'),
(43, 0, '13164352999', '13014509000', '100000.00', '0.00', 1529225254, '郭总'),
(44, 0, '15200000908', '13540373333', '10000.00', '0.00', 1529419213, '一起赚钱'),
(45, 0, '13164352999', '18318876315', '30000.00', '0.00', 1529511683, ''),
(46, 0, '18318876315', '15315481133', '20000.00', '0.00', 1529550043, ''),
(47, 0, '15238625511', '13339997637', '40000.00', '0.00', 1529650890, ''),
(48, 0, '13339997637', '13307173331', '10000.00', '0.00', 1529655246, ''),
(49, 0, '13164352999', '18336193888', '100.00', '0.00', 1529672534, '老板'),
(50, 0, '18318876315', '15315481133', '10000.00', '0.00', 1529714345, ''),
(51, 0, '15238625511', '18627115588', '100000.00', '0.00', 1529747160, ''),
(52, 0, '18627115588', '13949424484', '40000.00', '0.00', 1529752400, ''),
(53, 0, '15238625511', '15670788858', '10000.00', '0.00', 1529756566, ''),
(54, 0, '13164352999', '18336193888', '500000.00', '0.00', 1529913936, '韦拢'),
(55, 0, '15238625511', '18530807318', '10000.00', '0.00', 1529914965, ''),
(56, 0, '15238625511', '18530807318', '10000.00', '0.00', 1529914973, ''),
(57, 0, '18530807318', '15238625511', '10000.00', '0.00', 1529915077, ''),
(58, 0, '13164352999', '13333770023', '50000.00', '0.00', 1529918938, '侯总'),
(59, 0, '18803783999', '15238625511', '100000.00', '0.00', 1529977240, ''),
(60, 0, '15238625511', '18627115588', '100000.00', '0.00', 1529977389, ''),
(61, 0, '15516019657', '18803753918', '50000.00', '0.00', 1529990952, '收到回话'),
(62, 0, '18627115588', '18337824444', '30000.00', '0.00', 1530005180, ''),
(63, 0, '13415062948', '13802717609', '10000.00', '0.00', 1530075591, ''),
(64, 0, '13164352999', '13071789700', '10000.00', '0.00', 1530085141, ''),
(65, 0, '13415062948', '13546828815', '12000.00', '0.00', 1530087416, ''),
(66, 0, '13164352999', '15837105008', '80000.00', '0.00', 1530091399, ''),
(67, 0, '15837105008', '15672867237', '30000.00', '0.00', 1530091520, ''),
(68, 0, '18627115588', '15993399332', '10000.00', '0.00', 1530092783, ''),
(69, 0, '13415062948', '13428317723', '10000.00', '0.00', 1530100889, ''),
(70, 0, '13415062948', '13428317723', '10000.00', '0.00', 1530100896, ''),
(71, 0, '13415062948', '13414072853', '10000.00', '0.00', 1530101065, '你自己6千4千是我的'),
(72, 0, '13428317723', '13415062948', '14000.00', '0.00', 1530101175, ''),
(73, 0, '13415062948', '13414072853', '10000.00', '0.00', 1530101303, ''),
(74, 0, '13414072853', '13415062948', '14000.00', '0.00', 1530101832, ''),
(75, 0, '13164352999', '15837105008', '100000.00', '0.00', 1530102451, ''),
(76, 0, '13415062948', '18319283191', '10000.00', '0.00', 1530111216, ''),
(77, 0, '15238625511', '18627115588', '100000.00', '0.00', 1530116024, ''),
(78, 0, '13949424484', '13949424202', '10000.00', '0.00', 1530158572, ''),
(79, 0, '13339997637', '18627031670', '10000.00', '0.00', 1530167854, ''),
(80, 0, '13339997637', '18986100270', '10000.00', '0.00', 1530167919, ''),
(81, 0, '15238625511', '15055596222', '10000.00', '0.00', 1530234188, ''),
(82, 0, '15055596222', '18726577272', '10000.00', '0.00', 1530234849, ''),
(83, 0, '18803783999', '15238625511', '300000.00', '0.00', 1530242660, ''),
(84, 0, '18336193888', '13271756696', '10000.00', '0.00', 1530264047, ''),
(85, 0, '15238625511', '15055596222', '10000.00', '0.00', 1530264716, ''),
(86, 0, '15238625511', '15055596222', '10000.00', '0.00', 1530264722, ''),
(87, 0, '15055596222', '18726577272', '10000.00', '0.00', 1530265038, ''),
(88, 0, '18336193888', '18338570180', '20000.00', '0.00', 1530267120, ''),
(89, 0, '18336193888', '18338570180', '20000.00', '0.00', 1530267125, ''),
(90, 0, '18336193888', '13507663625', '10000.00', '0.00', 1530267731, ''),
(91, 0, '15055596222', '18726577272', '9000.00', '0.00', 1530280650, ''),
(92, 0, '18627115588', '13387576668', '30000.00', '0.00', 1530352910, ''),
(93, 0, '15238625511', '18627115588', '50000.00', '0.00', 1530361859, ''),
(94, 0, '15238625511', '18627115588', '50000.00', '0.00', 1530361867, '');

-- --------------------------------------------------------

--
-- 表的结构 `ds_type`
--

CREATE TABLE `ds_type` (
  `id` int(11) NOT NULL,
  `name` char(32) NOT NULL,
  `pid` int(11) NOT NULL DEFAULT '0',
  `path` char(30) NOT NULL DEFAULT '0'
) ENGINE=MyISAM DEFAULT CHARSET=utf8 ROW_FORMAT=COMPACT;

--
-- 转存表中的数据 `ds_type`
--

INSERT INTO `ds_type` (`id`, `name`, `pid`, `path`) VALUES
(3, '系统矿机', 0, '0');

-- --------------------------------------------------------

--
-- 表的结构 `ds_updatelist`
--

CREATE TABLE `ds_updatelist` (
  `id` int(11) NOT NULL,
  `username` varchar(40) NOT NULL,
  `money` decimal(11,2) UNSIGNED NOT NULL,
  `oldlevel` tinyint(3) UNSIGNED NOT NULL,
  `oldname` varchar(50) NOT NULL,
  `newlevel` tinyint(3) UNSIGNED NOT NULL,
  `newname` varchar(50) NOT NULL,
  `addtime` int(11) UNSIGNED NOT NULL,
  `status` tinyint(3) UNSIGNED NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8 ROW_FORMAT=COMPACT;

-- --------------------------------------------------------

--
-- 表的结构 `ds_user`
--

CREATE TABLE `ds_user` (
  `id` int(10) UNSIGNED NOT NULL,
  `username` char(20) NOT NULL DEFAULT '',
  `password` char(32) NOT NULL DEFAULT '',
  `logtime` int(10) NOT NULL,
  `loginip` char(30) NOT NULL DEFAULT '',
  `lock` tinyint(1) UNSIGNED NOT NULL
) ENGINE=MyISAM AVG_ROW_LENGTH=256 DEFAULT CHARSET=utf8 ROW_FORMAT=COMPACT;

--
-- 转存表中的数据 `ds_user`
--

INSERT INTO `ds_user` (`id`, `username`, `password`, `logtime`, `loginip`, `lock`) VALUES
(1, 'admin', '7fef6171469e80d32c0559f88b377245', 1578077815, '127.0.0.1', 0);

-- --------------------------------------------------------

--
-- 表的结构 `ds_yongjindetail`
--

CREATE TABLE `ds_yongjindetail` (
  `id` int(11) UNSIGNED NOT NULL,
  `username` varchar(255) DEFAULT NULL COMMENT '上级',
  `member` varchar(255) DEFAULT '' COMMENT '直推会员',
  `name` varchar(100) NOT NULL DEFAULT '0',
  `yongjin` decimal(11,2) DEFAULT '0.00' COMMENT '添加',
  `balance` decimal(11,2) DEFAULT '0.00' COMMENT '余额',
  `addtime` int(11) DEFAULT '0' COMMENT '添加时间'
) ENGINE=MyISAM AVG_ROW_LENGTH=60 DEFAULT CHARSET=utf8 COMMENT='金种子明细' ROW_FORMAT=COMPACT;

--
-- 转存表中的数据 `ds_yongjindetail`
--

INSERT INTO `ds_yongjindetail` (`id`, `username`, `member`, `name`, `yongjin`, `balance`, `addtime`) VALUES
(1, '18888888888', '13103598345', '李秀才', '10.00', '10.00', 1530438901),
(2, '18888888888', '13103598345', '李秀才', '10.00', '62.00', 1530439272),
(3, '18888888888', '13103598345', '李秀才', '10.00', '72.00', 1530439329),
(4, '', '18888888888', '李秀才', '10.00', '0.00', 1530539890);

--
-- 转储表的索引
--

--
-- 表的索引 `codepay_order`
--
ALTER TABLE `codepay_order`
  ADD PRIMARY KEY (`id`) USING BTREE,
  ADD UNIQUE KEY `pay_no` (`pay_no`,`type`) USING BTREE,
  ADD UNIQUE KEY `main` (`pay_id`,`pay_time`,`money`,`type`,`pay_tag`) USING BTREE;

--
-- 表的索引 `ds_access`
--
ALTER TABLE `ds_access`
  ADD KEY `groupId` (`role_id`) USING BTREE,
  ADD KEY `nodeId` (`node_id`) USING BTREE;

--
-- 表的索引 `ds_ad`
--
ALTER TABLE `ds_ad`
  ADD PRIMARY KEY (`id`) USING BTREE;

--
-- 表的索引 `ds_adpoint`
--
ALTER TABLE `ds_adpoint`
  ADD PRIMARY KEY (`id`) USING BTREE;

--
-- 表的索引 `ds_announce`
--
ALTER TABLE `ds_announce`
  ADD PRIMARY KEY (`id`) USING BTREE,
  ADD KEY `tid` (`tid`) USING BTREE;

--
-- 表的索引 `ds_announcetype`
--
ALTER TABLE `ds_announcetype`
  ADD PRIMARY KEY (`id`) USING BTREE;

--
-- 表的索引 `ds_announce_click`
--
ALTER TABLE `ds_announce_click`
  ADD PRIMARY KEY (`id`) USING BTREE;

--
-- 表的索引 `ds_auth_group`
--
ALTER TABLE `ds_auth_group`
  ADD PRIMARY KEY (`id`) USING BTREE;

--
-- 表的索引 `ds_auth_group_access`
--
ALTER TABLE `ds_auth_group_access`
  ADD UNIQUE KEY `uid_group_id` (`uid`,`group_id`) USING BTREE,
  ADD KEY `uid` (`uid`) USING BTREE,
  ADD KEY `group_id` (`group_id`) USING BTREE;

--
-- 表的索引 `ds_auth_rule`
--
ALTER TABLE `ds_auth_rule`
  ADD PRIMARY KEY (`id`) USING BTREE,
  ADD UNIQUE KEY `name` (`name`) USING BTREE;

--
-- 表的索引 `ds_banner`
--
ALTER TABLE `ds_banner`
  ADD PRIMARY KEY (`id`) USING BTREE;

--
-- 表的索引 `ds_business`
--
ALTER TABLE `ds_business`
  ADD PRIMARY KEY (`id`) USING BTREE;

--
-- 表的索引 `ds_buylog`
--
ALTER TABLE `ds_buylog`
  ADD PRIMARY KEY (`id`) USING BTREE,
  ADD KEY `uid` (`uid`) USING BTREE,
  ADD KEY `kid` (`kid`) USING BTREE;

--
-- 表的索引 `ds_ceng`
--
ALTER TABLE `ds_ceng`
  ADD PRIMARY KEY (`id`) USING BTREE;

--
-- 表的索引 `ds_classify`
--
ALTER TABLE `ds_classify`
  ADD PRIMARY KEY (`cid`) USING BTREE;

--
-- 表的索引 `ds_country`
--
ALTER TABLE `ds_country`
  ADD PRIMARY KEY (`id`) USING BTREE;

--
-- 表的索引 `ds_date`
--
ALTER TABLE `ds_date`
  ADD PRIMARY KEY (`Id`) USING BTREE;

--
-- 表的索引 `ds_emoneydetail`
--
ALTER TABLE `ds_emoneydetail`
  ADD PRIMARY KEY (`id`) USING BTREE;

--
-- 表的索引 `ds_goods`
--
ALTER TABLE `ds_goods`
  ADD PRIMARY KEY (`gid`) USING BTREE,
  ADD UNIQUE KEY `gnum` (`gnum`) USING BTREE;

--
-- 表的索引 `ds_guarantee`
--
ALTER TABLE `ds_guarantee`
  ADD PRIMARY KEY (`id`) USING BTREE;

--
-- 表的索引 `ds_jiangjin`
--
ALTER TABLE `ds_jiangjin`
  ADD PRIMARY KEY (`id`) USING BTREE,
  ADD KEY `member` (`member`) USING BTREE;

--
-- 表的索引 `ds_jiaoyi`
--
ALTER TABLE `ds_jiaoyi`
  ADD PRIMARY KEY (`id`) USING BTREE;

--
-- 表的索引 `ds_jijin`
--
ALTER TABLE `ds_jijin`
  ADD PRIMARY KEY (`id`) USING BTREE;

--
-- 表的索引 `ds_jinbidetail`
--
ALTER TABLE `ds_jinbidetail`
  ADD PRIMARY KEY (`id`) USING BTREE,
  ADD KEY `type` (`type`) USING BTREE,
  ADD KEY `member` (`member`) USING BTREE,
  ADD KEY `jid` (`jid`) USING BTREE,
  ADD KEY `addtime` (`addtime`) USING BTREE;

--
-- 表的索引 `ds_jorder`
--
ALTER TABLE `ds_jorder`
  ADD PRIMARY KEY (`id`) USING BTREE,
  ADD KEY `time` (`time`) USING BTREE,
  ADD KEY `status` (`status`) USING BTREE;

--
-- 表的索引 `ds_jyl`
--
ALTER TABLE `ds_jyl`
  ADD PRIMARY KEY (`Id`) USING BTREE;

--
-- 表的索引 `ds_kailog`
--
ALTER TABLE `ds_kailog`
  ADD PRIMARY KEY (`id`) USING BTREE,
  ADD KEY `endtime` (`endtime`) USING BTREE,
  ADD KEY `starttime` (`starttime`) USING BTREE,
  ADD KEY `status` (`status`) USING BTREE;

--
-- 表的索引 `ds_log`
--
ALTER TABLE `ds_log`
  ADD PRIMARY KEY (`id`) USING BTREE,
  ADD KEY `logtype` (`logtype`) USING BTREE;

--
-- 表的索引 `ds_mailbox`
--
ALTER TABLE `ds_mailbox`
  ADD PRIMARY KEY (`id`) USING BTREE;

--
-- 表的索引 `ds_member`
--
ALTER TABLE `ds_member`
  ADD PRIMARY KEY (`id`,`uid`) USING BTREE,
  ADD KEY `left` (`left`) USING BTREE,
  ADD KEY `right` (`right`) USING BTREE,
  ADD KEY `username` (`username`) USING BTREE,
  ADD KEY `parent` (`parent`) USING BTREE;

--
-- 表的索引 `ds_members_sign`
--
ALTER TABLE `ds_members_sign`
  ADD PRIMARY KEY (`id`) USING BTREE,
  ADD KEY `index_uid` (`user_id`) USING BTREE;

--
-- 表的索引 `ds_member_award_log`
--
ALTER TABLE `ds_member_award_log`
  ADD PRIMARY KEY (`id`) USING BTREE;

--
-- 表的索引 `ds_member_group`
--
ALTER TABLE `ds_member_group`
  ADD PRIMARY KEY (`groupid`) USING BTREE;

--
-- 表的索引 `ds_member_recharge`
--
ALTER TABLE `ds_member_recharge`
  ADD PRIMARY KEY (`r_id`) USING BTREE;

--
-- 表的索引 `ds_message`
--
ALTER TABLE `ds_message`
  ADD PRIMARY KEY (`id`) USING BTREE,
  ADD KEY `subject` (`subject`) USING BTREE;

--
-- 表的索引 `ds_node`
--
ALTER TABLE `ds_node`
  ADD PRIMARY KEY (`id`) USING BTREE,
  ADD KEY `level` (`level`) USING BTREE,
  ADD KEY `name` (`name`) USING BTREE,
  ADD KEY `pid` (`pid`) USING BTREE,
  ADD KEY `status` (`status`) USING BTREE;

--
-- 表的索引 `ds_order`
--
ALTER TABLE `ds_order`
  ADD PRIMARY KEY (`id`) USING BTREE;

--
-- 表的索引 `ds_orders`
--
ALTER TABLE `ds_orders`
  ADD PRIMARY KEY (`oid`) USING BTREE,
  ADD UNIQUE KEY `onumber` (`onumber`) USING BTREE;

--
-- 表的索引 `ds_paydetail`
--
ALTER TABLE `ds_paydetail`
  ADD PRIMARY KEY (`id`) USING BTREE;

--
-- 表的索引 `ds_paydetails`
--
ALTER TABLE `ds_paydetails`
  ADD PRIMARY KEY (`id`) USING BTREE;

--
-- 表的索引 `ds_pin`
--
ALTER TABLE `ds_pin`
  ADD PRIMARY KEY (`id`) USING BTREE;

--
-- 表的索引 `ds_pointdetail`
--
ALTER TABLE `ds_pointdetail`
  ADD PRIMARY KEY (`id`) USING BTREE;

--
-- 表的索引 `ds_ppdd`
--
ALTER TABLE `ds_ppdd`
  ADD PRIMARY KEY (`id`) USING BTREE;

--
-- 表的索引 `ds_product`
--
ALTER TABLE `ds_product`
  ADD PRIMARY KEY (`id`) USING BTREE;

--
-- 表的索引 `ds_qjinbidetail`
--
ALTER TABLE `ds_qjinbidetail`
  ADD PRIMARY KEY (`id`) USING BTREE,
  ADD KEY `type` (`type`) USING BTREE,
  ADD KEY `member` (`member`) USING BTREE;

--
-- 表的索引 `ds_receivable`
--
ALTER TABLE `ds_receivable`
  ADD PRIMARY KEY (`id`) USING BTREE;

--
-- 表的索引 `ds_regbd`
--
ALTER TABLE `ds_regbd`
  ADD PRIMARY KEY (`id`) USING BTREE;

--
-- 表的索引 `ds_ridate`
--
ALTER TABLE `ds_ridate`
  ADD PRIMARY KEY (`Id`) USING BTREE;

--
-- 表的索引 `ds_role`
--
ALTER TABLE `ds_role`
  ADD PRIMARY KEY (`id`) USING BTREE,
  ADD KEY `pid` (`pid`) USING BTREE,
  ADD KEY `status` (`status`) USING BTREE;

--
-- 表的索引 `ds_role_user`
--
ALTER TABLE `ds_role_user`
  ADD KEY `group_id` (`role_id`) USING BTREE,
  ADD KEY `user_id` (`user_id`) USING BTREE;

--
-- 表的索引 `ds_rotate`
--
ALTER TABLE `ds_rotate`
  ADD PRIMARY KEY (`id`) USING BTREE;

--
-- 表的索引 `ds_session`
--
ALTER TABLE `ds_session`
  ADD UNIQUE KEY `session_id` (`session_id`) USING BTREE;

--
-- 表的索引 `ds_sharedetail`
--
ALTER TABLE `ds_sharedetail`
  ADD PRIMARY KEY (`id`) USING BTREE,
  ADD KEY `type` (`type`) USING BTREE,
  ADD KEY `member` (`member`) USING BTREE;

--
-- 表的索引 `ds_shopbanner`
--
ALTER TABLE `ds_shopbanner`
  ADD PRIMARY KEY (`id`) USING BTREE;

--
-- 表的索引 `ds_shop_group`
--
ALTER TABLE `ds_shop_group`
  ADD PRIMARY KEY (`groupid`) USING BTREE;

--
-- 表的索引 `ds_sms_log`
--
ALTER TABLE `ds_sms_log`
  ADD PRIMARY KEY (`id`) USING BTREE;

--
-- 表的索引 `ds_tousu`
--
ALTER TABLE `ds_tousu`
  ADD PRIMARY KEY (`id`) USING BTREE;

--
-- 表的索引 `ds_transfer`
--
ALTER TABLE `ds_transfer`
  ADD PRIMARY KEY (`id`) USING BTREE;

--
-- 表的索引 `ds_type`
--
ALTER TABLE `ds_type`
  ADD PRIMARY KEY (`id`) USING BTREE;

--
-- 表的索引 `ds_updatelist`
--
ALTER TABLE `ds_updatelist`
  ADD PRIMARY KEY (`id`) USING BTREE;

--
-- 表的索引 `ds_user`
--
ALTER TABLE `ds_user`
  ADD PRIMARY KEY (`id`) USING BTREE,
  ADD UNIQUE KEY `username` (`username`) USING BTREE;

--
-- 表的索引 `ds_yongjindetail`
--
ALTER TABLE `ds_yongjindetail`
  ADD PRIMARY KEY (`id`) USING BTREE;

--
-- 在导出的表使用AUTO_INCREMENT
--

--
-- 使用表AUTO_INCREMENT `codepay_order`
--
ALTER TABLE `codepay_order`
  MODIFY `id` int(11) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=12;

--
-- 使用表AUTO_INCREMENT `ds_ad`
--
ALTER TABLE `ds_ad`
  MODIFY `id` smallint(5) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- 使用表AUTO_INCREMENT `ds_adpoint`
--
ALTER TABLE `ds_adpoint`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- 使用表AUTO_INCREMENT `ds_announce`
--
ALTER TABLE `ds_announce`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=137;

--
-- 使用表AUTO_INCREMENT `ds_announcetype`
--
ALTER TABLE `ds_announcetype`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '类别ID', AUTO_INCREMENT=13;

--
-- 使用表AUTO_INCREMENT `ds_announce_click`
--
ALTER TABLE `ds_announce_click`
  MODIFY `id` int(11) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=131788;

--
-- 使用表AUTO_INCREMENT `ds_auth_group`
--
ALTER TABLE `ds_auth_group`
  MODIFY `id` mediumint(8) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=11;

--
-- 使用表AUTO_INCREMENT `ds_auth_rule`
--
ALTER TABLE `ds_auth_rule`
  MODIFY `id` mediumint(8) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=90;

--
-- 使用表AUTO_INCREMENT `ds_business`
--
ALTER TABLE `ds_business`
  MODIFY `id` int(11) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- 使用表AUTO_INCREMENT `ds_buylog`
--
ALTER TABLE `ds_buylog`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- 使用表AUTO_INCREMENT `ds_ceng`
--
ALTER TABLE `ds_ceng`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- 使用表AUTO_INCREMENT `ds_classify`
--
ALTER TABLE `ds_classify`
  MODIFY `cid` mediumint(8) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=76;

--
-- 使用表AUTO_INCREMENT `ds_country`
--
ALTER TABLE `ds_country`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=250;

--
-- 使用表AUTO_INCREMENT `ds_date`
--
ALTER TABLE `ds_date`
  MODIFY `Id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3246;

--
-- 使用表AUTO_INCREMENT `ds_emoneydetail`
--
ALTER TABLE `ds_emoneydetail`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=8;

--
-- 使用表AUTO_INCREMENT `ds_goods`
--
ALTER TABLE `ds_goods`
  MODIFY `gid` mediumint(8) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- 使用表AUTO_INCREMENT `ds_guarantee`
--
ALTER TABLE `ds_guarantee`
  MODIFY `id` int(11) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- 使用表AUTO_INCREMENT `ds_jiangjin`
--
ALTER TABLE `ds_jiangjin`
  MODIFY `id` int(11) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- 使用表AUTO_INCREMENT `ds_jiaoyi`
--
ALTER TABLE `ds_jiaoyi`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- 使用表AUTO_INCREMENT `ds_jijin`
--
ALTER TABLE `ds_jijin`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- 使用表AUTO_INCREMENT `ds_jinbidetail`
--
ALTER TABLE `ds_jinbidetail`
  MODIFY `id` int(11) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=521430;

--
-- 使用表AUTO_INCREMENT `ds_jorder`
--
ALTER TABLE `ds_jorder`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- 使用表AUTO_INCREMENT `ds_jyl`
--
ALTER TABLE `ds_jyl`
  MODIFY `Id` int(11) NOT NULL AUTO_INCREMENT;

--
-- 使用表AUTO_INCREMENT `ds_kailog`
--
ALTER TABLE `ds_kailog`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3518;

--
-- 使用表AUTO_INCREMENT `ds_log`
--
ALTER TABLE `ds_log`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=18869;

--
-- 使用表AUTO_INCREMENT `ds_mailbox`
--
ALTER TABLE `ds_mailbox`
  MODIFY `id` int(11) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- 使用表AUTO_INCREMENT `ds_member`
--
ALTER TABLE `ds_member`
  MODIFY `id` int(11) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=20165;

--
-- 使用表AUTO_INCREMENT `ds_members_sign`
--
ALTER TABLE `ds_members_sign`
  MODIFY `id` int(11) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=722;

--
-- 使用表AUTO_INCREMENT `ds_member_award_log`
--
ALTER TABLE `ds_member_award_log`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- 使用表AUTO_INCREMENT `ds_member_group`
--
ALTER TABLE `ds_member_group`
  MODIFY `groupid` tinyint(3) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=7;

--
-- 使用表AUTO_INCREMENT `ds_member_recharge`
--
ALTER TABLE `ds_member_recharge`
  MODIFY `r_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- 使用表AUTO_INCREMENT `ds_message`
--
ALTER TABLE `ds_message`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- 使用表AUTO_INCREMENT `ds_node`
--
ALTER TABLE `ds_node`
  MODIFY `id` smallint(6) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=47;

--
-- 使用表AUTO_INCREMENT `ds_order`
--
ALTER TABLE `ds_order`
  MODIFY `id` int(255) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=31608;

--
-- 使用表AUTO_INCREMENT `ds_orders`
--
ALTER TABLE `ds_orders`
  MODIFY `oid` mediumint(8) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- 使用表AUTO_INCREMENT `ds_paydetail`
--
ALTER TABLE `ds_paydetail`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- 使用表AUTO_INCREMENT `ds_paydetails`
--
ALTER TABLE `ds_paydetails`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- 使用表AUTO_INCREMENT `ds_pin`
--
ALTER TABLE `ds_pin`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- 使用表AUTO_INCREMENT `ds_pointdetail`
--
ALTER TABLE `ds_pointdetail`
  MODIFY `id` int(11) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- 使用表AUTO_INCREMENT `ds_ppdd`
--
ALTER TABLE `ds_ppdd`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=19;

--
-- 使用表AUTO_INCREMENT `ds_product`
--
ALTER TABLE `ds_product`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=7;

--
-- 使用表AUTO_INCREMENT `ds_qjinbidetail`
--
ALTER TABLE `ds_qjinbidetail`
  MODIFY `id` int(11) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6892;

--
-- 使用表AUTO_INCREMENT `ds_receivable`
--
ALTER TABLE `ds_receivable`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- 使用表AUTO_INCREMENT `ds_regbd`
--
ALTER TABLE `ds_regbd`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- 使用表AUTO_INCREMENT `ds_ridate`
--
ALTER TABLE `ds_ridate`
  MODIFY `Id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=126;

--
-- 使用表AUTO_INCREMENT `ds_role`
--
ALTER TABLE `ds_role`
  MODIFY `id` smallint(6) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- 使用表AUTO_INCREMENT `ds_rotate`
--
ALTER TABLE `ds_rotate`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- 使用表AUTO_INCREMENT `ds_sharedetail`
--
ALTER TABLE `ds_sharedetail`
  MODIFY `id` int(11) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- 使用表AUTO_INCREMENT `ds_shop_group`
--
ALTER TABLE `ds_shop_group`
  MODIFY `groupid` tinyint(3) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- 使用表AUTO_INCREMENT `ds_sms_log`
--
ALTER TABLE `ds_sms_log`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT COMMENT '表id', AUTO_INCREMENT=24799;

--
-- 使用表AUTO_INCREMENT `ds_tousu`
--
ALTER TABLE `ds_tousu`
  MODIFY `id` int(11) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- 使用表AUTO_INCREMENT `ds_transfer`
--
ALTER TABLE `ds_transfer`
  MODIFY `id` int(11) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=95;

--
-- 使用表AUTO_INCREMENT `ds_type`
--
ALTER TABLE `ds_type`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- 使用表AUTO_INCREMENT `ds_updatelist`
--
ALTER TABLE `ds_updatelist`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- 使用表AUTO_INCREMENT `ds_user`
--
ALTER TABLE `ds_user`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- 使用表AUTO_INCREMENT `ds_yongjindetail`
--
ALTER TABLE `ds_yongjindetail`
  MODIFY `id` int(11) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

DELIMITER $$
--
-- 事件
--
CREATE DEFINER=`root`@`localhost` EVENT `event_auto_clearData` ON SCHEDULE EVERY 1 DAY STARTS '2014-11-29 23:56:00' ON COMPLETION NOT PRESERVE ENABLE DO call auto_clearData()$$

CREATE DEFINER=`root`@`localhost` EVENT `event_conCom` ON SCHEDULE EVERY 1 DAY STARTS '2014-11-01 23:50:00' ON COMPLETION NOT PRESERVE ENABLE DO call consumptionCommission()$$

CREATE DEFINER=`root`@`localhost` EVENT `event_pay` ON SCHEDULE EVERY 90 SECOND STARTS '2015-03-25 14:21:53' ON COMPLETION NOT PRESERVE ENABLE DO begin
	
	call pro_pay();

end$$

DELIMITER ;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
