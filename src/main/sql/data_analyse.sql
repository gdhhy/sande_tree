select uid, concat('[', group_concat(json_object('姓名', cardholder, '银行名称', bank, '卡号', bankcard)), ']') json
from user_bank
where uid != 8294518
group by uid;


insert into bank_json_withdraw
select uid,concat('[',group_concat(json_object('姓名',realname,'银行名称',bank,'卡号',bankcard,'提现金额',amount)),']') kk
from (select uid,realname,bank,bankcard ,cast(sum(amount) as decimal(10,2)) amount from user_withdraw where status=1 group by uid,realname,bank,bankcard ) A
group by uid  ;



update member
set member_info = json_insert(member_info, '$."资金"."提现金额"', member_info -> '$."资金"."申请提现金额"')
where member_info -> '$."资金"."申请提现金额"' > 0;
update member
set member_info = json_remove(member_info, '$."资金"."申请提现金额"')
where member_info -> '$."资金"."申请提现金额"' > 0;
update member
set member_info = json_remove(member_info, '$."资金"."到账金额"')
where member_info -> '$."资金"."到账金额"' > 0;



select A.intopursetypeid,A.reasoncode,C.name,B.name,concat('sum(case when intopursetypeid=',A.intopursetypeid,' and reasoncode = ',
                                                           A.reasoncode,' then intoamount else 0 end) ''',C.name,'-',ifnull(B.name,A.reasoncode),''',') casewhen from purse_reasoncode A
                                                                                                                                                                        left join fund_transfer_reason B on A.reasoncode=B.`code`
                                                                                                                                                                        left join fund_purse_type C on A.intopursetypeid=C.ID where A.total>0
order by A.intopursetypeid,A.reasoncode;



select B.id '用户ID',B.name '用户名',b.real_name '姓名',B.mobile '电话',A.* from(
                                                                       select intouserid,sum(case when intopursetypeid=1 then intoamount else 0 end) '现金钱包',
                                                                              sum(case when intopursetypeid=6 then intoamount else 0 end) '大云豆',
                                                                              sum(case when intopursetypeid=7 then intoamount else 0 end) '小云豆',
                                                                              sum(case when intopursetypeid=8 then intoamount else 0 end) '销售额',
                                                                              sum(case when intopursetypeid=9 then intoamount else 0 end) '创业佣金',
                                                                              sum(case when intopursetypeid=10 then intoamount else 0 end) '合伙商现金钱包',
                                                                              sum(case when intopursetypeid=11 then intoamount else 0 end) '直接结算到卡的销售额度'
                                                                       from fund_transfer where `status` =1 group by intouserid ) A  join cop.user B on A.intouserid=B.id;
select B.id '用户ID',B.name '用户名',b.real_name '姓名',B.mobile '电话',A.* from (
                                                                        select intouserid,sum(case when intopursetypeid=1 and reasoncode = 10002 then intoamount else 0 end) '现金钱包-系统充值，中央到系统',
                                                                               sum(case when intopursetypeid=1 and reasoncode = 10003 then intoamount else 0 end) '现金钱包-订单退款',
                                                                               sum(case when intopursetypeid=1 and reasoncode = 10004 then intoamount else 0 end) '现金钱包-用户支付订单，用户到系统',
                                                                               sum(case when intopursetypeid=1 and reasoncode = 10005 then intoamount else 0 end) '现金钱包-用户订单支付，系统到用户',
                                                                               sum(case when intopursetypeid=1 and reasoncode = 10006 then intoamount else 0 end) '现金钱包-老系统导入，系统升级',
                                                                               sum(case when intopursetypeid=1 and reasoncode = 10007 then intoamount else 0 end) '现金钱包-手工调动账户金额',
                                                                               sum(case when intopursetypeid=1 and reasoncode = 10088 then intoamount else 0 end) '现金钱包-10088',
                                                                               sum(case when intopursetypeid=1 and reasoncode = 20001 then intoamount else 0 end) '现金钱包-合伙人升级推荐人（合伙人）佣金奖',
                                                                               sum(case when intopursetypeid=1 and reasoncode = 20009 then intoamount else 0 end) '现金钱包-用户大云豆提现到余额',
                                                                               sum(case when intopursetypeid=1 and reasoncode = 20018 then intoamount else 0 end) '现金钱包-余额提现成功',
                                                                               sum(case when intopursetypeid=1 and reasoncode = 20026 then intoamount else 0 end) '现金钱包-联盟商家销售额提现',
                                                                               sum(case when intopursetypeid=1 and reasoncode = 20029 then intoamount else 0 end) '现金钱包-联盟商升级推荐人（合伙人）佣金奖',
                                                                               sum(case when intopursetypeid=1 and reasoncode = 20064 then intoamount else 0 end) '现金钱包-创业佣金（合伙人/联盟商升级奖励）提现',
                                                                               sum(case when intopursetypeid=1 and reasoncode = 30001 then intoamount else 0 end) '现金钱包-用户（合伙人）授信，系统现金到用户现金',
                                                                               sum(case when intopursetypeid=1 and reasoncode = 30002 then intoamount else 0 end) '现金钱包-用户（合伙人）授信，购买合伙人等级',
                                                                               sum(case when intopursetypeid=1 and reasoncode = 30003 then intoamount else 0 end) '现金钱包-用户（合伙人）授信，用户还款',
                                                                               sum(case when intopursetypeid=1 and reasoncode = 30004 then intoamount else 0 end) '现金钱包-用户（联盟商）授信，系统现金到用户现金',
                                                                               sum(case when intopursetypeid=1 and reasoncode = 30005 then intoamount else 0 end) '现金钱包-用户（联盟商）授信，购买合伙人等级',
                                                                               sum(case when intopursetypeid=1 and reasoncode = 30006 then intoamount else 0 end) '现金钱包-用户（联盟商）授信，用户还款',
                                                                               sum(case when intopursetypeid=1 and reasoncode = 30007 then intoamount else 0 end) '现金钱包-测试帐号余额充值',
                                                                               sum(case when intopursetypeid=1 and reasoncode = 30010 then intoamount else 0 end) '现金钱包-30010',
                                                                               sum(case when intopursetypeid=1 and reasoncode = 30011 then intoamount else 0 end) '现金钱包-30011',
                                                                               sum(case when intopursetypeid=1 and reasoncode = 30012 then intoamount else 0 end) '现金钱包-30012',
                                                                               sum(case when intopursetypeid=1 and reasoncode = 30019 then intoamount else 0 end) '现金钱包-30019',
                                                                               sum(case when intopursetypeid=1 and reasoncode = 40001 then intoamount else 0 end) '现金钱包-40001',
                                                                               sum(case when intopursetypeid=1 and reasoncode = 40004 then intoamount else 0 end) '现金钱包-40004',
                                                                               sum(case when intopursetypeid=1 and reasoncode = 40005 then intoamount else 0 end) '现金钱包-40005',
                                                                               sum(case when intopursetypeid=1 and reasoncode = 40009 then intoamount else 0 end) '现金钱包-40009',
                                                                               sum(case when intopursetypeid=6 and reasoncode = 10004 then intoamount else 0 end) '大云豆-用户支付订单，用户到系统',
                                                                               sum(case when intopursetypeid=6 and reasoncode = 10006 then intoamount else 0 end) '大云豆-老系统导入，系统升级',
                                                                               sum(case when intopursetypeid=6 and reasoncode = 10007 then intoamount else 0 end) '大云豆-手工调动账户金额',
                                                                               sum(case when intopursetypeid=6 and reasoncode = 10089 then intoamount else 0 end) '大云豆-10089',
                                                                               sum(case when intopursetypeid=6 and reasoncode = 20004 then intoamount else 0 end) '大云豆-每日小云豆转化到大云豆',
                                                                               sum(case when intopursetypeid=6 and reasoncode = 20007 then intoamount else 0 end) '大云豆-合伙人升级大云豆利率扣除',
                                                                               sum(case when intopursetypeid=6 and reasoncode = 20012 then intoamount else 0 end) '大云豆-云豆定制大云豆支付手续费扣除',
                                                                               sum(case when intopursetypeid=6 and reasoncode = 20022 then intoamount else 0 end) '大云豆-用户大云豆提现扣除手续费',
                                                                               sum(case when intopursetypeid=6 and reasoncode = 20027 then intoamount else 0 end) '大云豆-联盟商升级大云豆利率扣除',
                                                                               sum(case when intopursetypeid=6 and reasoncode = 20031 then intoamount else 0 end) '大云豆-赠送小云豆大云豆利率扣除',
                                                                               sum(case when intopursetypeid=6 and reasoncode = 20044 then intoamount else 0 end) '大云豆-购买商品大云豆利率扣除',
                                                                               sum(case when intopursetypeid=6 and reasoncode = 20066 then intoamount else 0 end) '大云豆-POS机21倍专享',
                                                                               sum(case when intopursetypeid=6 and reasoncode = 20109 then intoamount else 0 end) '大云豆-20109',
                                                                               sum(case when intopursetypeid=6 and reasoncode = 30008 then intoamount else 0 end) '大云豆-测试帐号大云豆充值',
                                                                               sum(case when intopursetypeid=6 and reasoncode = 30018 then intoamount else 0 end) '大云豆-30018',
                                                                               sum(case when intopursetypeid=6 and reasoncode = 40002 then intoamount else 0 end) '大云豆-40002',
                                                                               sum(case when intopursetypeid=7 and reasoncode = 10004 then intoamount else 0 end) '小云豆-用户支付订单，用户到系统',
                                                                               sum(case when intopursetypeid=7 and reasoncode = 10006 then intoamount else 0 end) '小云豆-老系统导入，系统升级',
                                                                               sum(case when intopursetypeid=7 and reasoncode = 10007 then intoamount else 0 end) '小云豆-手工调动账户金额',
                                                                               sum(case when intopursetypeid=7 and reasoncode = 20002 then intoamount else 0 end) '小云豆-合伙人升级本人获得小云豆',
                                                                               sum(case when intopursetypeid=7 and reasoncode = 20003 then intoamount else 0 end) '小云豆-云豆定制本人获得小云豆',
                                                                               sum(case when intopursetypeid=7 and reasoncode = 20005 then intoamount else 0 end) '小云豆-云豆定制推荐人（合伙人）奖励',
                                                                               sum(case when intopursetypeid=7 and reasoncode = 20006 then intoamount else 0 end) '小云豆-云豆定制间推人（合伙人）奖励',
                                                                               sum(case when intopursetypeid=7 and reasoncode = 20008 then intoamount else 0 end) '小云豆-新用户注册推荐人获得小云豆',
                                                                               sum(case when intopursetypeid=7 and reasoncode = 20010 then intoamount else 0 end) '小云豆-系统后台手动充值',
                                                                               sum(case when intopursetypeid=7 and reasoncode = 20013 then intoamount else 0 end) '小云豆-大月饼活动买家获得小云豆',
                                                                               sum(case when intopursetypeid=7 and reasoncode = 20014 then intoamount else 0 end) '小云豆-大月饼活动商家获得小云豆',
                                                                               sum(case when intopursetypeid=7 and reasoncode = 20015 then intoamount else 0 end) '小云豆-后台财富增值推荐人（合伙人）云豆定制奖',
                                                                               sum(case when intopursetypeid=7 and reasoncode = 20016 then intoamount else 0 end) '小云豆-后台财富增值间推人（合伙人）云豆定制奖',
                                                                               sum(case when intopursetypeid=7 and reasoncode = 20019 then intoamount else 0 end) '小云豆-大月饼活动用户扣除小云豆',
                                                                               sum(case when intopursetypeid=7 and reasoncode = 20020 then intoamount else 0 end) '小云豆-后台扣除小云豆',
                                                                               sum(case when intopursetypeid=7 and reasoncode = 20023 then intoamount else 0 end) '小云豆-赠送小云豆商家获得小云豆',
                                                                               sum(case when intopursetypeid=7 and reasoncode = 20025 then intoamount else 0 end) '小云豆-赠送小云豆买家获得小云豆',
                                                                               sum(case when intopursetypeid=7 and reasoncode = 20028 then intoamount else 0 end) '小云豆-联盟商升级本人获得小云豆',
                                                                               sum(case when intopursetypeid=7 and reasoncode = 20033 then intoamount else 0 end) '小云豆-赠送小云豆买家推荐人（合伙人）消费奖',
                                                                               sum(case when intopursetypeid=7 and reasoncode = 20034 then intoamount else 0 end) '小云豆-赠送小云豆买家间推人（合伙人）消费奖',
                                                                               sum(case when intopursetypeid=7 and reasoncode = 20035 then intoamount else 0 end) '小云豆-商品购买买家获得小云豆',
                                                                               sum(case when intopursetypeid=7 and reasoncode = 20036 then intoamount else 0 end) '小云豆-商品购买商家获得小云豆',
                                                                               sum(case when intopursetypeid=7 and reasoncode = 20038 then intoamount else 0 end) '小云豆-商品购买买家推荐人（合伙人）消费奖',
                                                                               sum(case when intopursetypeid=7 and reasoncode = 20039 then intoamount else 0 end) '小云豆-商品购买买家间推人（合伙人）消费奖',
                                                                               sum(case when intopursetypeid=7 and reasoncode = 20040 then intoamount else 0 end) '小云豆-商品购买卖家推荐人（联盟商）销售奖',
                                                                               sum(case when intopursetypeid=7 and reasoncode = 20041 then intoamount else 0 end) '小云豆-商品购买卖家推荐人（合伙人）销售奖',
                                                                               sum(case when intopursetypeid=7 and reasoncode = 20042 then intoamount else 0 end) '小云豆-商品购买卖家间推人（合伙人）销售奖',
                                                                               sum(case when intopursetypeid=7 and reasoncode = 20043 then intoamount else 0 end) '小云豆-商品购买消耗小云豆',
                                                                               sum(case when intopursetypeid=7 and reasoncode = 20045 then intoamount else 0 end) '小云豆-POS机支付购买人获得的小云豆',
                                                                               sum(case when intopursetypeid=7 and reasoncode = 20046 then intoamount else 0 end) '小云豆-POS机支付商家获得小云豆',
                                                                               sum(case when intopursetypeid=7 and reasoncode = 20048 then intoamount else 0 end) '小云豆-POS机支付买家推荐人（合伙人）消费奖',
                                                                               sum(case when intopursetypeid=7 and reasoncode = 20049 then intoamount else 0 end) '小云豆-POS机支付买家间推人（合伙人）消费奖',
                                                                               sum(case when intopursetypeid=7 and reasoncode = 20050 then intoamount else 0 end) '小云豆-POS机支付卖家推荐人（联盟商）销售奖',
                                                                               sum(case when intopursetypeid=7 and reasoncode = 20051 then intoamount else 0 end) '小云豆-POS机支付卖家推荐人（合伙人）销售奖',
                                                                               sum(case when intopursetypeid=7 and reasoncode = 20052 then intoamount else 0 end) '小云豆-POS机支付卖家间推人（合伙人）销售奖',
                                                                               sum(case when intopursetypeid=7 and reasoncode = 20053 then intoamount else 0 end) '小云豆-赠送小云豆卖家推荐人（合伙人）销售奖',
                                                                               sum(case when intopursetypeid=7 and reasoncode = 20054 then intoamount else 0 end) '小云豆-赠送小云豆卖家间推人（合伙人）销售奖',
                                                                               sum(case when intopursetypeid=7 and reasoncode = 20055 then intoamount else 0 end) '小云豆-赠送小云豆卖家推荐人（联盟商）销售奖',
                                                                               sum(case when intopursetypeid=7 and reasoncode = 20056 then intoamount else 0 end) '小云豆-线下收银系统买家获得小云豆',
                                                                               sum(case when intopursetypeid=7 and reasoncode = 20057 then intoamount else 0 end) '小云豆-线下收银系统商家获得小云豆',
                                                                               sum(case when intopursetypeid=7 and reasoncode = 20059 then intoamount else 0 end) '小云豆-线下收银系统买家推荐人（合伙人）消费奖',
                                                                               sum(case when intopursetypeid=7 and reasoncode = 20060 then intoamount else 0 end) '小云豆-线下收银系统买家间推人（合伙人）消费奖',
                                                                               sum(case when intopursetypeid=7 and reasoncode = 20061 then intoamount else 0 end) '小云豆-线下收银系统卖家推荐人（联盟商）销售奖',
                                                                               sum(case when intopursetypeid=7 and reasoncode = 20062 then intoamount else 0 end) '小云豆-线下收银系统卖家推荐人（合伙人）销售奖',
                                                                               sum(case when intopursetypeid=7 and reasoncode = 20063 then intoamount else 0 end) '小云豆-线下收银系统卖家间推人（合伙人）销售奖',
                                                                               sum(case when intopursetypeid=7 and reasoncode = 20066 then intoamount else 0 end) '小云豆-POS机21倍专享',
                                                                               sum(case when intopursetypeid=7 and reasoncode = 20067 then intoamount else 0 end) '小云豆-POS机21倍专享推荐人（合伙人）分润',
                                                                               sum(case when intopursetypeid=7 and reasoncode = 20068 then intoamount else 0 end) '小云豆-现场活动21倍购买小云豆',
                                                                               sum(case when intopursetypeid=7 and reasoncode = 20069 then intoamount else 0 end) '小云豆-POS机21倍专享间推人（合伙人）分润',
                                                                               sum(case when intopursetypeid=7 and reasoncode = 20070 then intoamount else 0 end) '小云豆-商品购买买家推荐人（联盟商）消费奖',
                                                                               sum(case when intopursetypeid=7 and reasoncode = 20071 then intoamount else 0 end) '小云豆-POS机支付买家推荐人（联盟商）消费奖',
                                                                               sum(case when intopursetypeid=7 and reasoncode = 20072 then intoamount else 0 end) '小云豆-线下收银系统买家推荐人（联盟商）消费奖',
                                                                               sum(case when intopursetypeid=7 and reasoncode = 20073 then intoamount else 0 end) '小云豆-赠送小云豆买家推荐人（联盟商）消费奖',
                                                                               sum(case when intopursetypeid=7 and reasoncode = 20074 then intoamount else 0 end) '小云豆-云豆定制推荐人（联盟商）奖励',
                                                                               sum(case when intopursetypeid=7 and reasoncode = 20076 then intoamount else 0 end) '小云豆-后台财富增值推荐人（联盟商）云豆定制奖',
                                                                               sum(case when intopursetypeid=7 and reasoncode = 20088 then intoamount else 0 end) '小云豆-20088',
                                                                               sum(case when intopursetypeid=7 and reasoncode = 20091 then intoamount else 0 end) '小云豆-20091',
                                                                               sum(case when intopursetypeid=7 and reasoncode = 20100 then intoamount else 0 end) '小云豆-20100',
                                                                               sum(case when intopursetypeid=7 and reasoncode = 20101 then intoamount else 0 end) '小云豆-20101',
                                                                               sum(case when intopursetypeid=7 and reasoncode = 20103 then intoamount else 0 end) '小云豆-20103',
                                                                               sum(case when intopursetypeid=7 and reasoncode = 20104 then intoamount else 0 end) '小云豆-20104',
                                                                               sum(case when intopursetypeid=7 and reasoncode = 20106 then intoamount else 0 end) '小云豆-20106',
                                                                               sum(case when intopursetypeid=7 and reasoncode = 20107 then intoamount else 0 end) '小云豆-20107',
                                                                               sum(case when intopursetypeid=7 and reasoncode = 20110 then intoamount else 0 end) '小云豆-20110',
                                                                               sum(case when intopursetypeid=7 and reasoncode = 20114 then intoamount else 0 end) '小云豆-20114',
                                                                               sum(case when intopursetypeid=7 and reasoncode = 20115 then intoamount else 0 end) '小云豆-20115',
                                                                               sum(case when intopursetypeid=7 and reasoncode = 20203 then intoamount else 0 end) '小云豆-20203',
                                                                               sum(case when intopursetypeid=7 and reasoncode = 20204 then intoamount else 0 end) '小云豆-20204',
                                                                               sum(case when intopursetypeid=7 and reasoncode = 20207 then intoamount else 0 end) '小云豆-20207',
                                                                               sum(case when intopursetypeid=7 and reasoncode = 20208 then intoamount else 0 end) '小云豆-20208',
                                                                               sum(case when intopursetypeid=7 and reasoncode = 20211 then intoamount else 0 end) '小云豆-20211',
                                                                               sum(case when intopursetypeid=7 and reasoncode = 20213 then intoamount else 0 end) '小云豆-20213',
                                                                               sum(case when intopursetypeid=7 and reasoncode = 20220 then intoamount else 0 end) '小云豆-20220',
                                                                               sum(case when intopursetypeid=7 and reasoncode = 30009 then intoamount else 0 end) '小云豆-测试帐号小云豆充值',
                                                                               sum(case when intopursetypeid=7 and reasoncode = 30014 then intoamount else 0 end) '小云豆-30014',
                                                                               sum(case when intopursetypeid=7 and reasoncode = 30017 then intoamount else 0 end) '小云豆-30017',
                                                                               sum(case when intopursetypeid=7 and reasoncode = 40013 then intoamount else 0 end) '小云豆-40013',
                                                                               sum(case when intopursetypeid=7 and reasoncode = 40014 then intoamount else 0 end) '小云豆-40014',
                                                                               sum(case when intopursetypeid=8 and reasoncode = 20037 then intoamount else 0 end) '销售额-商品购买商家销售额',
                                                                               sum(case when intopursetypeid=8 and reasoncode = 20047 then intoamount else 0 end) '销售额-POS机支付商家销售额',
                                                                               sum(case when intopursetypeid=8 and reasoncode = 20058 then intoamount else 0 end) '销售额-线下收银系统支付商家销售额',
                                                                               sum(case when intopursetypeid=8 and reasoncode = 20102 then intoamount else 0 end) '销售额-20102',
                                                                               sum(case when intopursetypeid=9 and reasoncode = 10007 then intoamount else 0 end) '创业佣金-手工调动账户金额',
                                                                               sum(case when intopursetypeid=9 and reasoncode = 20001 then intoamount else 0 end) '创业佣金-合伙人升级推荐人（合伙人）佣金奖',
                                                                               sum(case when intopursetypeid=9 and reasoncode = 20029 then intoamount else 0 end) '创业佣金-联盟商升级推荐人（合伙人）佣金奖',
                                                                               sum(case when intopursetypeid=9 and reasoncode = 20032 then intoamount else 0 end) '创业佣金-联盟商升级推荐人（联盟商）佣金奖',
                                                                               sum(case when intopursetypeid=9 and reasoncode = 20075 then intoamount else 0 end) '创业佣金-合伙人升级推荐人（联盟商）佣金奖',
                                                                               sum(case when intopursetypeid=9 and reasoncode = 30013 then intoamount else 0 end) '创业佣金-30013',
                                                                               sum(case when intopursetypeid=10 and reasoncode = 20112 then intoamount else 0 end) '合伙商现金钱包-20112',
                                                                               sum(case when intopursetypeid=10 and reasoncode = 20113 then intoamount else 0 end) '合伙商现金钱包-20113',
                                                                               sum(case when intopursetypeid=10 and reasoncode = 20116 then intoamount else 0 end) '合伙商现金钱包-20116',
                                                                               sum(case when intopursetypeid=10 and reasoncode = 20117 then intoamount else 0 end) '合伙商现金钱包-20117',
                                                                               sum(case when intopursetypeid=10 and reasoncode = 20118 then intoamount else 0 end) '合伙商现金钱包-20118',
                                                                               sum(case when intopursetypeid=10 and reasoncode = 20119 then intoamount else 0 end) '合伙商现金钱包-20119',
                                                                               sum(case when intopursetypeid=11 and reasoncode = 40008 then intoamount else 0 end) '直接结算到卡的销售额度-40008'
from fund_transfer where `status` =1 group by intouserid) A  join cop.user B on A.intouserid=B.id;
update member A join  user_credit_payed B on A.member_no =B. uid
set a.member_info = json_insert(member_info,'$."资金"."授信额度"',credit_money,'$."资金"."授信还款"',payed_money);

update  member A   join user_level_money B on A.member_No=B.uid
set A.member_info=json_insert(A.member_info, '$."资金"."购买等级"', B.buy_level)  ;


update member A   join
(select  A.member_no   ,
         CASE
             ifnull( b.rule_id, "" )
           WHEN 1 THEN
             "创业联盟商"
           WHEN 2 THEN
             "核心创业联盟商"
           WHEN 3 THEN
             "创投联盟商"
           WHEN 4 THEN
             "核心创投联盟商"
           WHEN 5 THEN
             "创业联盟企业"
           WHEN 6 THEN
             "核心创业联盟企业"  else ''
             END "li级别"

 from
      ( SELECT DISTINCT uid, rule_id FROM user_store_level_order) b ,member A  where  A.member_no =b.uid) B on A.member_no=B.member_no
set A.member_info=json_set(A.member_info,'$."基本信息"."联盟类型"',B.`li级别`) ;

update member A   join
(SELECT
        A.id,
        CASE
            a.vip_level+1  					WHEN 1 THEN					"免费合伙人" 					WHEN 2 THEN
            "创业合伙人" 					WHEN 3 THEN
            "核心创业合伙人" 					WHEN 4 THEN					"创投合伙人"
                                     WHEN 5 THEN					"核心创投合伙人" 	 else ''			END "level"
 from
      user  a) B on A.member_no=B.id  set A.member_info=json_set(A.member_info,'$."基本信息"."合伙人级别"',B.level) ;