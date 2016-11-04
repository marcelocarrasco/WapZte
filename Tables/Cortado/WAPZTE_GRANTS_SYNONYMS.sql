select 'create public synonym '||table_name||' for '||'SMART'||'.'||table_name||';'
from user_tables
where table_name like 'WAP_%';

select 'create public synonym '||VIEW_NAME||' for '||'SMART'||'.'||VIEW_NAME||';'
from USER_VIEWS
where VIEW_NAME like 'VW%';


select 'grant select on '||table_name||' to PRFC;'
from user_tables
where table_name like 'WAP_%'
union
select 'grant select on '||VIEW_NAME||' to PRFC;'
from USER_VIEWS;

--synonyms
create public synonym WAP_GATEWAY_SERVICE_ZTE_IBHW for SMART.WAP_GATEWAY_SERVICE_ZTE_IBHW;
create public synonym WAP_GATEWAY_SERVICE_ZTE_BH for SMART.WAP_GATEWAY_SERVICE_ZTE_BH;
create public synonym WAP_GATEWAY_SERVICE_ZTE_DAY for SMART.WAP_GATEWAY_SERVICE_ZTE_DAY;
create public synonym WAP_GATEWAY_KPI_ZTE_RAW for SMART.WAP_GATEWAY_KPI_ZTE_RAW;
create public synonym WAP_GATEWAY_SERVICE_ZTE_RAW for SMART.WAP_GATEWAY_SERVICE_ZTE_RAW;
create public synonym WAP_GATEWAY_KPI_ZTE_AUX for SMART.WAP_GATEWAY_KPI_ZTE_AUX;
create public synonym WAP_GATEWAY_SERVICE_ZTE_AUX for SMART.WAP_GATEWAY_SERVICE_ZTE_AUX;
create public synonym VWAP_GATEWAY_SERVICE_ZTE_HOUR for SMART.VWAP_GATEWAY_SERVICE_ZTE_HOUR;
create public synonym VWAP_GATEWAY_KPI_ZTE_HOUR for SMART.VWAP_GATEWAY_KPI_ZTE_HOUR;
create public synonym VWAP_GATEWAY_KPI_ZTE_DAY for SMART.VWAP_GATEWAY_KPI_ZTE_DAY;
-- grants
grant select on VWAP_GATEWAY_KPI_ZTE_DAY to PRFC;
grant select on VWAP_GATEWAY_KPI_ZTE_HOUR to PRFC;
grant select on VWAP_GATEWAY_SERVICE_ZTE_HOUR to PRFC;
grant select on WAP_GATEWAY_KPI_ZTE_RAW to PRFC;
grant select on WAP_GATEWAY_SERVICE_ZTE_BH to PRFC;
grant select on WAP_GATEWAY_SERVICE_ZTE_DAY to PRFC;
grant select on WAP_GATEWAY_SERVICE_ZTE_IBHW to PRFC;
grant select on WAP_GATEWAY_SERVICE_ZTE_RAW to PRFC;



select 'select * from '||table_name||';'
from user_tables
where table_name like 'WAP_%'
union
select 'select * from '||VIEW_NAME||';'
from USER_VIEWS;


select * from VWAP_GATEWAY_KPI_ZTE_DAY;
select * from VWAP_GATEWAY_KPI_ZTE_HOUR;
select * from VWAP_GATEWAY_SERVICE_ZTE_HOUR;

select * from WAP_GATEWAY_SERVICE_ZTE_BH;
select * from WAP_GATEWAY_SERVICE_ZTE_DAY;
select * from WAP_GATEWAY_SERVICE_ZTE_IBHW;


