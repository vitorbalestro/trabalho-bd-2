CREATE TABLE result_table_brute_force
    (id SERIAL PRIMARY KEY,
     query_vector_ind int,
     vector_index int,
     distance double precision;
    );

CREATE OR REPLACE FUNCTION ann_brute_force(query_index int) RETURNS void AS $$
DECLARE
    query_vector int[];
    object_vector int[];
    line_ record;
    dist double precision;
BEGIN
    SELECT query INTO query_vector FROM tquery WHERE id = query_index;
    FOR line_ IN (SELECT * FROM object) LOOP
        candidate_vector = line_.features;
        dist = euclidean_distance(candidate_vector,query_vector);
        INSERT INTO result_table_brute_force(query_vector, vector, distance) VALUES
            (query_index,line_.id,dist);
    END LOOP;

    dist = (SELECT distance FROM result_table_brute_force ORDER BY distance LIMIT 1 OFFSET 99);
    DELETE FROM result_table_brute_force WHERE query_vector = query_index AND distance > dist;

END;
$$ LANGUAGE plpgsql;