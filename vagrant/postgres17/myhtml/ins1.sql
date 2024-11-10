insert into rao_report_params 
( report_id, report_name ,h1name ,h1desc ,h2nameA ,h2descA ,h3infoA ,color ,theme) values 
(
--report_id
1,
--report_name
'example1',

--h1name 
'RAODB Example Report Title',

--h1desc 
'This report shows bla bla bla ...  Documents newly obtained by CNN detail that Boeing warned Southwest Airlines and American Airlines of the potential problem in February and both airlines in turn sent alerts to their respective pilot groups.  Engine maker CFM International says their engine has met “bird ingestion certification requirements, and the engines performed as designed during these events.  The company underscored that birds in the two incidents that prompted pilot bulletins were much larger than required for certification testing and that the CFM engine still performed as designed.',

--h2nameA 
ARRAY[ 'DATABASE', 'SCHEMA', 'STATISTICS', 'EXAMPLE', 'SAMPLE','OTHER' ],

-- h2descA 
ARRAY[ 
'Database server details Engine maker CFM International says their engine has met “bird ingestion certification requirements, and the engines performed as designed during these events',
'Schema Objects information. The company underscored that birds in the two incidents that prompted pilot bulletins were much larger than required for certification testing and that the CFM engine still performed as designed.', 
'Statistics..... The Federal Aviation Administration says it “will continue working with Boeing on the investigation into these incidents and will determine if additional actions are required based on the findings.', 
'Example very long data desccription goes here ....  test test test test',
'Sample header description',
'Other description'
],

-- h3infoA 
ARRAY [
'DATABASES:pg_database,TABLESPACE:pg_tablespace,LANGUAGE:pg_language,EXTENSION:pg_extension,SETTINGS:pg_settings',
'TABLES:pg_tables,TYPE:pg_type,PROCEDURES:pg_proc,SEQUENCES:pg_sequences',
'STATS:pg_statistic,STATEXT:pg_statistic_ext,STATEXTDATA:pg_statistic_ext_data',
'EXAMPLE1:pg_database,EXAMPLE2:pg_database,EXAMPLE3:pg_database,EXAMPLE4:pg_database,EXAMPLE5:pg_database,EXAMPLE6:pg_database,EXAMPLE7:pg_database,EXAMPLE8:pg_database,EXAMPLE9:pg_database,EXAMPLE10:pg_database,EXAMPLE11:pg_database,EXAMPLE12:pg_database,EXAMPLE13:pg_database,EXAMPLE14:pg_database,EXAMPLE15:pg_database',
'SAMPLE1:pg_extension,SAMPLE2:pg_extension,SAMPLE3:pg_extension,SAMPLE4:pg_extension,SAMPLE5:pg_extension,SAMPLE6:pg_extension,SAMPLE7:pg_extension,SAMPLE8:pg_extension,SAMPLE9:pg_extension,SAMPLE10:pg_extension,SAMPLE11:pg_extension,SAMPLE12:pg_extension,SAMPLE13:pg_extension,SAMPLE14:pg_extension,SAMPLE15:pg_extension',
'OTHER1:pg_language,OTHER2:pg_language,OTHER3:pg_language,OTHER4:pg_language,OTHER5:pg_language,OTHER6:pg_language,OTHER7:pg_language,OTHER8:pg_language,OTHER9:pg_language,OTHER10:pg_language,OTHER11:pg_language,OTHER12:pg_language,OTHER13:pg_language,OTHER14:pg_language,OTHER15:pg_language,OTHER101:pg_language,OTHER102:pg_language,OTHER103:pg_language,OTHER104:pg_language,OTHER105:pg_language,OTHER106:pg_language,OTHER107:pg_language,OTHER108:pg_language,OTHER109:pg_language,OTHER1010:pg_language,OTHER1011:pg_language,OTHER1012:pg_language,OTHER1013:pg_language,OTHER1014:pg_language,OTHER1015:pg_language,OTHER201:pg_language,OTHER202:pg_language,OTHER203:pg_language,OTHER204:pg_language,OTHER205:pg_language,OTHER206:pg_language,OTHER207:pg_language,OTHER208:pg_language,OTHER209:pg_language,OTHER2010:pg_language,OTHER2011:pg_language,OTHER2012:pg_language,OTHER2013:pg_language,OTHER2014:pg_language,OTHER2015:pg_language'
],
-- color
4,
-- theme
1
);

