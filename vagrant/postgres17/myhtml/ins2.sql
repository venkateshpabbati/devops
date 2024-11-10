insert into rao_report_params 
( report_id, report_name ,h1name ,h1desc ,h2nameA ,h2descA ,h3infoA ,color ,theme) values 
(
--report_id
2,
--report_name
'database',

--h1name 
'RAODB Database Report',

--h1desc 
'This report shows bla bla bla ...  ',

--h2nameA 
ARRAY[ 'SECTION1', 'SECTION2'],

-- h2descA 
ARRAY[ 
'Section-1 description ',
'Section-2 description '
],

-- h3infoA 
ARRAY [
'SECTION-1A:pg_database,SECTION-1B:pg_tablespace',
'SECTION-2A:pg_sequences,SECTION-2B:pg_extension,SECTION-2C:pg_language'
],
-- color
5,
-- theme
1
);

