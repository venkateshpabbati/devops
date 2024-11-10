create or replace function myhtml (p_report_id integer) returns text as 
$$
return query select myhtml( h1name, h1desc, h2nameA, h2descA, h3infoA, color, theme) 
from rao_report_params 
where report_id=p_report_id;
$$
language plpgsql;
 - ################################################################################
