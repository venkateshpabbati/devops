DO $$
DECLARE
    query_text text := 'SELECT count(1) FROM pg_tables WHERE schemaname = ''public''';
    parse_tree json;
    query_tree json;
BEGIN
    -- Parse the query
    parse_tree := (SELECT pg_parse_query(query_text));

    -- Analyze and rewrite the query
    query_tree := (SELECT pg_analyze_and_rewrite(parse_tree, NULL));

    -- Print the parse tree and query tree
    RAISE NOTICE 'Parse Tree: %', parse_tree;
    RAISE NOTICE 'Query Tree: %', query_tree;
END $$;
~  
