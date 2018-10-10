select * from member_sun
insert into member (member_no,real_name,phone,id_card,parent_no,cur_level,child_depth,direct_count,child_total,member_info)

select 用户id,真实姓名 , 手机号,身份证号码,推荐人ID,所在层级,下线层数,直接下级人数,所有下级人数,CONCAT('{"基本信息":{"用户等级":"',`用户等级`,'","用户类型":"',`用户类型`,'","创建时间":"',`创建时间`,'"},',
'"人脉":{"一度人脉":',一度人脉,',"二度人脉":',二度人脉,',"一度人脉收益":',一度人脉收益,',"二度人脉收益":',二度人脉收益,'}}')

from member_sun

