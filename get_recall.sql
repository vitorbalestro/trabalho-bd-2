CREATE OR REPLACE FUNCTION get_recall_method1(query_vector_index int, parameters_key int) RETURNS double precision AS
$$
DECLARE
	i int;
	query_vector int[];
	result_vector double precision[];
	reference_distance double precision;
	hit_count int;
	dist double precision;
	line_ record;
	recall_ double precision;
BEGIN
	hit_count = 0;
	reference_distance = get_reference_distance(query_vector_index);
	FOR line_ IN (SELECT * FROM result_table_method1 WHERE parameter_key_value = parameters_key AND query_vector_id_ = query_vector_index) LOOP
		IF(line_.distance <= reference_distance) THEN
			hit_count = hit_count + 1;
		END IF;
	END LOOP;
	recall_ = hit_count :: double precision / 100;
	INSERT INTO recall_table_method1(query_vector_id,parameters_key_,recall) VALUES
		(query_vector_index,parameters_key,recall_);
	RETURN recall_;
END;
$$ LANGUAGE plpgsql;