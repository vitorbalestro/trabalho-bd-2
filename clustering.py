import numpy as np
import psycopg2 as psycopg
from sklearn.cluster import KMeans

def cluster() :
    sample = "SELECT features FROM object TABLESAMPLE BERNOULLI (50)"
    connection = None
    try:
        connection = psycopg.connect(host='localhost', dbname='trabalho-bd-2', user='postgres', password='6wk48900')
        with connection:
            with connection.cursor() as cursor:
                cursor.execute(sample)
                vectors = cursor.fetchall();
                input = []
                for i in range(0,499999):
                    input.append(vectors[i][0])
                kmeans = KMeans(n_clusters=128, max_iter=10000, random_state=0, n_init="auto").fit(
                        input)
                centroids = kmeans.cluster_centers_.tolist()
                save_centroids1 = "DROP TABLE IF EXISTS sight_ CASCADE"
                save_centroids2 = "CREATE TABLE IF NOT EXISTS sight_ (id SERIAL, centroid real[])"
                cursor.execute(save_centroids1)
                cursor.execute(save_centroids2)
                i=0
                for centroid in centroids:
                    query = "INSERT INTO sight_ VALUES (DEFAULT, %s)"
                    cursor.execute(query, (centroid,))
                    i = i+1
                print(i)
    except (Exception, psycopg.Error) as error:
        print("Error: ", error)
        connection.rollback()

if __name__ == '__main__':
    cluster()