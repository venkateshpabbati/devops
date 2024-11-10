\pset tuples_only on
\a
SELECT * from 
(SELECT row_to_json(hdr) FROM
(SELECT 
'reportTitle' as "reportTitle",
'reportName' as "reportName",
'reportDescription' as "reportDescription",
'reportDate' as "reportDate",
'reportColor' as "reportColor",
'reportTheme' as "reportTheme",
-- ----------------------------------------
(SELECT row_to_json(pgSchema) FROM (
	SELECT 
	catalog_name, schema_owner, schema_name
	FROM
	information_schema.schemata
	WHERE
	schema_name='public') as pgSchema
) as "pgSchema",
-- ----------------------------------------
(SELECT json_agg(pgTables) FROM (
	SELECT
   schemaname as "schemaName",
   tablename as "tableName",
   tableowner as "tableOwner",
   tablespace as "tableSpace",
   hasindexes as "hasIndexes"
	FROM 
	pg_tables
	WHERE 
	schemaname='public') as pgTables
) as "pgTables"
-- ----------------------------------------
) hdr)
;
