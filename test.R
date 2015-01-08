source("riak.R")

# define constants
RIAK_CLUSTER <- 'localhost'
PORT <- 12345

conn <- riak_http_connection(host = RIAK_CLUSTER, port = PORT)


# test
print.riak_connection(conn)

riak_ping(conn)
riak_status(conn)

# create user bucket
riak_store_url(conn, bucket = "users", key = "123456789")
riak_fetch_url(conn, bucket = "users", key = 1234556789)


test_data_path <- paste("/types","user","buckets","joebloggs","keys","123456789", sep="/")

postToHost(RIAK_CLUSTER, path = test_data_path, data.to.send = list("object"="junk"), port = PORT)
