riak-r-client
=============
© 2013 Dave Parfitt


# Dependencies:

* bitops
* RCurl
* httr
* rjson

(Easily installed in R through `Packages & Data -> Package Installer`)

# Demo
Contents of demo.R pasted below:

```
source("~/basho/riak-r-client/riak.R")

conn <- riak_connection("localhost",10018)


#######
## basic stats demo
#######

stats <- riak_status(conn)
print(stats$riak_kv_vnodes_running)

# this shows all the stats that are available
names(stats)

## or just print them all out
stats

#######
## store/fetch demo
#######

## store 100 values in TestBucket_currenttime
time = Sys.time()
bucket <- paste("TestBucket", time, sep="_")
for(i in seq(1,100)) {
	x <- list( foo=i, alpha = 1:5, beta = "Bravo", 
           gamma = list(a=1:3, b=NULL), 
           delta = c(TRUE, FALSE) )
   value <- toJSON( x )
	
	key <- paste("Key_",i,sep="")

	obj <- riak_new_json_object(value, bucket, key)
	result <- riak_store(conn, obj)
}

# stream=TRUE doesn't work quite right yet
# don't list_keys on a production system!!
allkeys <- riak_list_keys(conn, bucket, stream=FALSE)
print(length(allkeys$keys))
print(allkeys$keys[10])

# fetch a json object, automatically convert json fields to R format :-)
# I still need to convert to a Riak R object
obj <- riak_fetch(conn, bucket, "Key_10")
obj$alpha

# fetch a "raw" object, including headers, etc
rawobj <- riak_fetch_raw(conn, bucket, "Key_10")
summary(rawobj)
rawobj$headers
# get the json content using the content() function
json <- content(rawobj)
json$delta

# show the vclock
rawobj$headers$`x-riak-vclock`


#######
## 2i demo
#######
# create some 2i data

#curl -X POST -H 'x-riak-index-company_bin: basho' -H 'x-riak-index-email_bin: jsmith@basho.com' 
# -d '...user data...' http://localhost:10018/buckets/users/keys/jsmith1

# curl -X POST -H 'x-riak-index-company_bin: basho' -H 'x-riak-index-email_bin: engbot@basho.com' 
# -d '...user data...' http://localhost:10018/buckets/users/keys/engbot

employees <- riak_2i_exact(conn, "users", "company_bin", "basho")
print(employees$keys)

#######
## graph some Riak stats over time
#######

# I ran basho_bench against the node while this ran
get_samples <- function() {
	vgt <- rep(NA, 10)
	nfsm <- rep(NA, 10)
	
	for(i in seq(1,10)) {
		Sys.sleep(5) # sleep 5 seconds
		stats <- riak_status(conn)
		vgt[i] <- stats$node_gets_total
		nfsm[i] <- stats$node_get_fsm_time_99
	}
	list(vnode_gets_total=vgt, node_get_fsm_time_99=nfsm)
}

samples <- get_samples()
plot(samples$vnode_gets_total, type="o", col="blue")
title(main="Riak data!", col.main="red", font.main=4)

plot(samples$node_get_fsm_time_99, type="o", col="blue")
title(main="Riak data!", col.main="red", font.main=4)



```
