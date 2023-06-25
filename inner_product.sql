CREATE OR REPLACE FUNCTION get_inner_product(vec1 int[], vec2 int[]) RETURNS int AS $$
DECLARE
    i int;
    sum int;
BEGIN
    
    sum = 0;

    FOR i IN 1..128 LOOP
        sum = sum + vec1[i] * vec2[i];
    END LOOP    

    return sum;
END;
$$ LANGUAGE plpgsql;
