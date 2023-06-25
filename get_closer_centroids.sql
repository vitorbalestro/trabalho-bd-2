CREATE TYPE tuple AS (ind int, dist double precision);

CREATE TABLE closer_centroids (id INT NOT NULL, closer_centroid_ind INT, dist double precision);

CREATE OR REPLACE FUNCTION get_closer_centroids(qtd int,offs int) RETURNS void AS $$
DECLARE
	object_line record;
	sight_line record;
	distances_vector tuple[];
	current_tuple tuple;
	dist double precision;
	min_dist double precision;
	i int;
	ind int;
BEGIN
	FOR object_line IN SELECT * FROM object ORDER BY id LIMIT qtd OFFSET offs LOOP
		FOR sight_line IN SELECT * FROM sight_ LOOP
			dist = euclidean_distance(object_line.features,sight_line.centroid);
			current_tuple = (sight_line.id,dist);
			distances_vector[sight_line.id] = current_tuple;
		END LOOP;
		min_dist = distances_vector[1].dist;
		ind = 1;
		FOR i in 1..128 LOOP
			IF (distances_vector[i].dist < min_dist) THEN
				min_dist = distances_vector[i].dist;
				ind = distances_vector[i].ind;
			END IF;
		END LOOP;
		INSERT INTO closer_centroids VALUES (object_line.id,ind,min_dist);
	END LOOP;
END;
$$ LANGUAGE plpgsql;
