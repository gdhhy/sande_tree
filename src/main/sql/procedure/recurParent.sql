CREATE DEFINER=``@`` PROCEDURE `findParent_v1`(in p_user_name varchar(100), in p_maxlevel int)
  BEGIN
    -- 递归深度
    set @@max_sp_recursion_depth = 1000;

    drop table if exists tmp_table;
    CREATE TEMPORARY TABLE tmp_table (
      parent_no   VARCHAR(26),
      user_name   varchar(100),
      parent_name varchar(100),
      real_name   varchar(100),
      id_card     varchar(100),
      phone       varchar(100),
      cur_level       int
    );
    select A.user_name into @parent_name from member_v1 A
                                                left join member_v1 B on B.parent_no = A.member_no where B.user_name = p_user_name;

    insert into tmp_table (parent_no, user_name, parent_name, real_name, id_card, phone, cur_level)
    select parent_no, user_name, @parent_name, real_name, id_card, phone, cur_level
    from member_v1
    where user_name = p_user_name;

    select parent_no into @member_no from member_v1 where user_name = p_user_name;
    if @member_no is not null then
      call recurParent_v1(@member_no, p_maxlevel);
    end if;

    select cur_level '所在层级', user_name '用户名', parent_name '推荐人', id_card '身份证号', phone '电话' from tmp_table order by cur_level desc;

    --  select * from tmp_table;

  END