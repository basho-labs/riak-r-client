# -------------------------------------------------------------------
#  connect to riak cluster
#-------------------------------------------------------------------

source("datagami-riak.R")

conn <- riak_http_connection("localhost","12345")
print(conn)

# ---------------------------
#  basic ping and stats 
# ---------------------------
riak_ping(conn)

stats <- riak_status(conn)
print(stats$riak_kv_vnodes_running)

# this shows all the stats that are available
names(stats)

# or just print them all out
stats

# ---------------------------
#  store/fetch demo
# ---------------------------

# simple store
bucket_type <- "demo_type_1"  # note bucket types are created by riak-admin on the command line
bucket <- "users"
key <- "123456789"
value <- "{\"joke\": \"lorum ipsem\"}"
obj <- riak_new_json_object(value, bucket_type, bucket, key)

riak_store_object(conn, obj, opts=list("ReturnBody"=TRUE))



## store 100 values in TestBucket_currenttime
time = Sys.time()
bucket_type <- "demo_type_1"
bucket <- paste("TestBucket", time, sep="_")
for(i in seq(1,100)) {
	x <- list( foo=i, alpha = 1:5, beta = "Bravo", 
           gamma = list(a=1:3, b=NULL), 
           delta = c(TRUE, FALSE) )
   value <- toJSON( x )
	
	key <- paste("Key_",i,sep="")

	obj <- riak_new_json_object(value, bucket_type, bucket, key)
	result <- riak_store_object(conn, obj)
}


# fetch a json object, automatically convert json fields to R format :-)
obj <- riak_fetch(conn, "demo_type_1", bucket, "Key_10")
obj$gamma

# fetch a "raw" object, including headers, etc
rawobj <- riak_fetch_raw(conn, "demo_type_1", bucket, "Key_10")
summary(rawobj)
rawobj$headers

# get the json content using the content() function
json <- content(rawobj)
json$delta

# show the vector-clock
rawobj$headers$`x-riak-vclock`

# delete an object
riak_delete(conn, "demo_type_1", bucket, "Key_10")


