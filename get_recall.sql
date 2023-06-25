/* The recall metric counts how many vectors in the result table has
distance to the query vector smaller to the reference distance. 

We assume that the results are stored in the table named result_table(id int, vec double precision[]).
The query vector is passed by its index (so we can compute the reference distance by the function
get_reference_distance).*/

CREATE OR REPLACE FUNCTION get_recall(query_vector_index int, parameters_key int) RETURNS double precision AS
$$
DECLARE
	i int;
	query_vector int[];
	result_vector double precision[];
	reference_distance double precision;
	hit_count int;
	dist double precision;
BEGIN
	hit_count = 0;
	reference_distance = get_reference_distance(query_vector_index);
	FOR line_ IN (SELECT * FROM result_table_method1 WHERE parameter_key_value = parameters_key AND query_vector_id_ = query_vector_index) LOOP
		IF(line_.distance <= reference_distance) THEN
			hit_count = hit_count + 1;
		END IF;
	END LOOP;

	RETURN hit_count :: double precision / 100;
END;
$$ LANGUAGE plpgsql;