CREATE DEFINER=`root`@`localhost` PROCEDURE `findParent`(in p_member_no int, in p_maxlevel int)
BEGIN
    -- 递归深度
    set @@max_sp_recursion_depth = 1000;

    drop table if exists tmp_table;
    CREATE TEMPORARY TABLE tmp_table (
      parent_no   int,
      member_no   int,
      parent_name varchar(100) default '',
      real_name   varchar(100) default '',
      id_card     varchar(100) default '',
      phone       varchar(100),
      cur_level       int
    );
    select A.real_name into @parent_name from member A
                                                left join member B on B.parent_no = A.member_no where B.member_no = p_member_no;

    insert into tmp_table (parent_no, member_no, parent_name, real_name, id_card, phone, cur_level)
    select parent_no, member_no, @parent_name, real_name, id_card, phone, cur_level
    from member
    where member_no = p_member_no;

    select parent_no into @member_no from member where member_no = p_member_no;
    if @member_no is not null then
      call recurParent(@member_no, p_maxlevel);
    end if;
		update tmp_table set parent_name='' where parent_name is null;
		update tmp_table set real_name='' where real_name is null;
		update tmp_table set id_card='' where id_card is null;
    select cur_level '所在层级', real_name '姓名',member_no '用户ID', parent_name '推荐人',parent_no '推荐人ID', id_card '身份证号', phone '电话' from tmp_table order by cur_level desc;

    --  select * from tmp_table;

  END