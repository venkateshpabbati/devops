
drop table rao_report_params ;

create table rao_report_params (
 report_id  BIGSERIAL PRIMARY KEY, 
 report_name varchar,
 h1name varchar, 
 h1desc varchar, 
 h2nameA varchar[], 
 h2descA varchar[],
 h3infoA varchar[],
 color smallint, 
 theme smallint
);

