from datetime import datetime

import h5py
import psycopg2 as psycopg



def load():
    filename = "/home/vitorbalestro/Downloads/sift-128-euclidean.hdf5"

    create_dataset = "DROP TABLE IF EXISTS object CASCADE;\n" \
                     "CREATE TABLE IF NOT EXISTS object (id serial NOT NULL, features float[] NOT NULL);\n"
    insert_data = "INSERT INTO object(features) VALUES(%s);"
    index_data = "DO $$\n" \
                 "BEGIN ALTER TABLE object ADD PRIMARY KEY (id);\n" \
                 "EXCEPTION WHEN others THEN NULL;\n" \
                 "END;$$;\n" \
                 "CREATE INDEX IF NOT EXISTS idx_object_pkey ON object USING hash (id);"

    create_queries = "DROP TABLE IF EXISTS tquery CASCADE;\n" \
                     "CREATE TABLE IF NOT EXISTS tquery (id serial NOT NULL, query float[] NOT NULL);\n"
    insert_queries = "INSERT INTO tquery(query) VALUES(%s);"

    create_neighbors = "DROP TABLE IF EXISTS neighbors CASCADE;\n" \
                       "CREATE TABLE IF NOT EXISTS neighbors (id serial NOT NULL, neighbors int[] NOT NULL);\n"
    insert_neighbors = "INSERT INTO neighbors(neighbors) VALUES(%s);"

    connection = None
    try:
        # connection = psycopg.connect(host='bdserver.ic.uff.br', dbname='TCC00288', user='prof', password='docente')
        connection = psycopg.connect(host='localhost', dbname='trabalho-bd-2', user='postgres', password='6wk48900')
        with connection:
            with h5py.File(filename, "r") as h5f:
                start_time = datetime.now()
                print("1/3 - Loading object... ", end='')
                with connection.cursor() as cursor:
                    cursor.execute(create_dataset)
                data = tuple(((v.tolist(),) for v in h5f['train'][:]))
                with connection.cursor() as cursor:
                    cursor.executemany(insert_data, data)
                with connection.cursor() as cursor:
                    cursor.execute(index_data)
                end_time = datetime.now()
                print("Done. ({0})".format(end_time - start_time))

                start_time = datetime.now()
                print("2/3 - Loading queries... ", end='')
                with connection.cursor() as cursor:
                    cursor.execute(create_queries)
                data = tuple(((v.tolist(),) for v in h5f['test'][:]))
                with connection.cursor() as cursor:
                    cursor.executemany(insert_queries, data)
                end_time = datetime.now()
                print("Done. ({0})".format(end_time - start_time))

                start_time = datetime.now()
                print("3/3 - Loading neighbors... ", end='')
                with connection.cursor() as cursor:
                    cursor.execute(create_neighbors)
                data = tuple((([e + 1 for e in v.tolist()],) for v in h5f['neighbors'][:]))
                with connection.cursor() as cursor:
                    cursor.executemany(insert_neighbors, data)
                end_time = datetime.now()
                print("Done. ({0})".format(end_time - start_time))


    except (Exception, psycopg.DatabaseError) as error:
        print("Error while fetching data from PostgreSQL: ", error)
        connection.rollback()

    finally:
        if connection: connection.close()
        print("PostgreSQL connection is closed")


if __name__ == '__main__':
    load()
    print("Loading ended.")