\echo Use "CREATE EXTENSION raohook" to load this file. \quit


/*
CREATE FUNCTION rdb_hook_data(IN hook_id int4,
    OUT hook_name text,
    OUT log_time timestamp,
    OUT log_text text
)
RETURNS SETOF record
AS 'MODULE_PATHNAME', 'rdb_hook_data_1_0'
LANGUAGE C STRICT VOLATILE PARALLEL SAFE;

CREATE VIEW rdb_hook_data AS SELECT * FROM rdb_hook_data(true);

GRANT SELECT ON rdb_hook_data TO PUBLIC;
*/

