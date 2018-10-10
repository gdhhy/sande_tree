CREATE DEFINER=`root`@`localhost` PROCEDURE `recurParent`(in p_member_no int, in p_maxlevel int)
BEGIN
    declare v_parent_no int;
    declare v_parent_name varchar(100);
    declare v_real_name varchar(100);
    declare v_id_card varchar(100);
    declare v_phone varchar(100);
    declare v_level int;

    select parent_no,  real_name, id_card, phone, cur_level
        into v_parent_no,  v_real_name, v_id_card, v_phone, v_level
    from member
    where member_no = p_member_no;
    -- todo 优化
    select A.real_name into v_parent_name
    from member A
           left join member B on B.parent_no = A.member_no
    where B.member_no = p_member_no;

    set @maxlevel = p_maxlevel - 1;
    select parent_no into @parent_no from member where member_no = p_member_no;

    if @maxlevel > 1 and @parent_no >0
    then
      call recurParent(@parent_no, @maxlevel);
    end if;
    insert into tmp_table (parent_no, member_no, parent_name, real_name, id_card, phone, cur_level)
    values (v_parent_no, p_member_no, v_parent_name, v_real_name, v_id_card, v_phone, v_level);
  END