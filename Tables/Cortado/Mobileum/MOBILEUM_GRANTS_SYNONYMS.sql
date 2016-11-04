
select 'create public synonym '||table_name||' for '||'SMART'||'.'||table_name||';'
from user_tables
where table_name like 'MOBILEUM_%';

-- SYNONYMS
create public synonym MOBILEUM_ASP_IBHW for SMART.MOBILEUM_ASP_IBHW;
create public synonym MOBILEUM_ASP_HOUR for SMART.MOBILEUM_ASP_HOUR;
create public synonym MOBILEUM_ASP_DAY for SMART.MOBILEUM_ASP_DAY;
create public synonym MOBILEUM_ASP_BH for SMART.MOBILEUM_ASP_BH;
create public synonym MOBILEUM_ASP_AUX for SMART.MOBILEUM_ASP_AUX;


select 'grant select on '||table_name||' to PRFC;'
from user_tables
where table_name like 'MOBILEUM_%';

-- GRANTS
grant select on MOBILEUM_ASP_IBHW to PRFC;
grant select on MOBILEUM_ASP_HOUR to PRFC;
grant select on MOBILEUM_ASP_DAY to PRFC;
grant select on MOBILEUM_ASP_BH to PRFC;

select 'select * from '||table_name||';'
from user_tables
where table_name like 'MOBILEUM_%';


select * from MOBILEUM_ASP_IBHW;
select * from MOBILEUM_ASP_HOUR;
select * from MOBILEUM_ASP_DAY;
select * from MOBILEUM_ASP_BH;