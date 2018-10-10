drop PROCEDURE showChildLst
CREATE PROCEDURE showChildLst(IN rootId VARCHAR(50))
  BEGIN
    CREATE TEMPORARY TABLE IF NOT EXISTS tmpLst
    (
      sno   int primary key auto_increment,
      id    VARCHAR(50),
      depth int
    );
    DELETE FROM tmpLst;

    CALL createChildLst(rootId, 0);

    select tmpLst.*, m.`所在层级`, m.`会员id`, m.`推荐人id`, m.`证件号码`, m.`手机号码`
    from tmpLst,
         tt6 m
    where tmpLst.id = m.`会员uid`
    order by tmpLst.depth;
  END;


CREATE PROCEDURE createChildLst(IN rootId VARCHAR(50), IN nDepth INT)
  BEGIN
    DECLARE done INT DEFAULT 0;
    DECLARE b VARCHAR(50);
    DECLARE cur1 CURSOR FOR SELECT `会员uid` FROM tt6 where `推荐人uid` = rootId;
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = 1;

    insert into tmpLst values (null, rootId, nDepth);


    OPEN cur1;

    FETCH cur1
    INTO b;
    WHILE done = 0 DO
      CALL createChildLst(b, nDepth + 1);
      FETCH cur1
      INTO b;
    END WHILE;

    CLOSE cur1;
  END;

select *
from tt6
where `会员id` = '田长海'

set max_sp_recursion_depth = 50;

call showChildLst('0000000000_0000065289_0000');