CREATE OR REPLACE FUNCTION euclidean_distance(vec1 double precision[], vec2 double precision[]) RETURNS double precision AS
$$
DECLARE
	i int;
	sum_ double precision;
	result_ double precision;
BEGIN
	sum_ := 0;
	FOR i in 1..128 LOOP
		sum_ := sum_ + POWER(vec1[i]-vec2[i],2);
	END LOOP;
	
	result_ := SQRT(sum_);
	RETURN result_;
	
END;
$$ LANGUAGE plpgsql;
