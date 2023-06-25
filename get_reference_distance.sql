/* To compute the Recall, we need to find the 100th smaller distance to the query vector.
For each index j of tquery, this is the distance between tquery[j] (the query vector)
and object[neighbors[j][100]]. Notice that each vector of neighbor's indexes is sorted
according to increasing distance to the query vector.
*/

CREATE OR REPLACE FUNCTION get_reference_distance(j int) RETURNS double precision AS
$$
DECLARE
	query_vector int[];
	neighbors_vector int[];
	index_ int;
	reference_vector double precision [];
	
BEGIN 
	query_vector := (SELECT query FROM tquery WHERE id = j);
 	neighbors_vector := (SELECT neighbors FROM neighbors WHERE id = j);
	index_ := neighbors_vector[100];
	reference_vector := (SELECT features FROM object WHERE id = index_);
	
	RETURN euclidean_distance(query_vector,reference_vector);
	
END;
$$ LANGUAGE plpgsql;