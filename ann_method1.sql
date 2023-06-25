DROP TABLE method1_parameters_key CASCADE;
DROP TABLE result_table_method1 CASCADE;

CREATE TABLE method1_parameters_key 
	(id SERIAL PRIMARY KEY, 
	 alpha_ double precision,
	 beta_ double precision,
	 gamma_ double precision);

CREATE TABLE result_table_method1
	(id SERIAL PRIMARY KEY,
	 parameter_key_value int,
	 query_vector_id_ int,
	 vector int[],
	 distance double precision
	);


CREATE OR REPLACE FUNCTION ann_method1(query_vector_id int, alpha double precision, beta double precision, gamma double precision) 
RETURNS void AS $$
DECLARE
	query_vector int[]; -- q
	closer_centroid int[]; -- c
	diff_centroid_query int[]; -- q - c
	diff_candidate_centroid int[]; -- v - c
	closer_centroid_index int;
	candidate_vector int[]; -- v
	dist_query_centroid double precision; -- ||q-c|| = d
	dist_candidate_centroid double precision; -- ||v-c||;
	dist_candidate_query double precision; -- ||v-q||;
	inner_product double precision;
	cosine double precision;
	counter int;
	n int;
	parameters_key_value int;
	reference_dist double precision;
	line_ record;
	i int;
BEGIN
	n = (SELECT COUNT(*) FROM method1_parameters_key AS par WHERE par.alpha_ = alpha AND par.beta_ = beta AND par.gamma_ = gamma); 
	IF (n = 0) THEN
		INSERT INTO method1_parameters_key (alpha_,beta_,gamma_) VALUES (alpha,beta,gamma);
		parameters_key_value = (SELECT par.id FROM method1_parameters_key AS par WHERE par.alpha_ = alpha AND par.beta_ = beta AND par.gamma_ = gamma); 
		n = (SELECT COUNT(*) FROM result_table_method1 WHERE parameter_key_value = parameters_key_value AND query_vector_id_ = query_vector_id);
		IF (n != 0) THEN
			RAISE EXCEPTION 'The function was already computed for this query vector and these parameter values';
		END IF;
	END IF;
	
	SELECT query INTO query_vector FROM tquery WHERE id = query_vector_id;
	closer_centroid_index = get_closer_centroid_tquery(query_vector_id);
	SELECT centroid INTO closer_centroid FROM sight_ WHERE id = closer_centroid_index;
	dist_query_centroid = euclidean_distance(closer_centroid,query_vector);
	FOR i IN 1..128 LOOP
		diff_centroid_query[i] = query_vector[i] - closer_centroid[i];
	END LOOP;
	counter = 0;
	FOR line_ IN SELECT * FROM closer_centroids WHERE closer_centroid_ind = closer_centroid_index LOOP
		SELECT features INTO candidate_vector FROM object WHERE id = line_.id;
		dist_candidate_centroid = euclidean_distance(candidate_vector,closer_centroid);
		dist_candidate_query = euclidean_distance(candidate_vector, query_vector);
		FOR i IN 1..128 LOOP
		diff_candidate_centroid[i] = candidate_vector[i] - closer_centroid[i];
		END LOOP;
		IF (dist_candidate_centroid > alpha * dist_query_centroid AND dist_candidate_centroid < beta * dist_query_centroid) THEN
			inner_product = get_inner_product(diff_centroid_query, diff_candidate_centroid) :: double precision;
			cosine = inner_product/(dist_candidate_centroid * dist_query_centroid);
			IF (cosine > gamma AND cosine < 1) THEN
				INSERT INTO result_table_method1(parameter_key_value,query_vector_id_,vector,distance) VALUES
					(parameters_key_value,query_vector_id,candidate_vector,dist_candidate_query);
				counter = counter + 1;
			END IF;
		END IF;
	END LOOP;
	IF counter > 100 THEN
		reference_dist = (SELECT distance FROM result_table_method1 AS r 
		WHERE r.parameter_key_value = parameters_key_value AND
			  r.query_vector_id_ = query_vector_id 
		ORDER BY distance
		LIMIT 1
		OFFSET 99);
		
		DELETE FROM result_table_method1 AS r
		WHERE r.parameter_key_value = parameters_key_value AND
			  r.query_vector_id_ = query_vector_id AND
			  distance > reference_dist;
	END IF;
	
END;
$$ LANGUAGE plpgsql;