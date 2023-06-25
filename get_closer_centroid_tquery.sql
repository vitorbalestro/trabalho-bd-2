CREATE OR REPLACE FUNCTION get_closer_centroid_tquery(ind int) RETURNS int AS $$
DECLARE
	query_vector int[];
	sight_line record;
	centroid_vector int[];
	min_dist float;
	dist float;
	closer_index int;
	i int;
BEGIN
	SELECT query INTO query_vector FROM tquery WHERE id = ind;
	closer_centroid = 1;
	SELECT centroid INTO centroid_vector FROM sight_ WHERE id = 1;
	min_dist = euclidean_distance(query_vector,centroid_vector);
	FOR sight_line IN (sight_ ORDER BY id) LOOP
		centroid_vector = sight_line.centroid;
		dist = euclidean_distance(query_vector,centroid_vector);
		IF (dist < min_dist) THEN
			min_dist = dist;
			closer_centroid = sight_line.id;
		END IF;
	END LOOP;

	RETURN closer_centroid;
END;
$$ LANGUAGE plpgsql;

SELECT get_closer_centroid(6);