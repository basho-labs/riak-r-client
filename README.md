---
output: html_document
---
riak-r-client
=============

# Status

***This is a fork of the Basho client and is being used in production.***

- This is a work in progress. Probably slow and buggy at the moment. The interface is very likely to change.

- **TODO**:
  - implement additional store/fetch options
  - fix mapred
  - link walking
  - retrier/resolver
  - package to CRAN
  - currently the interface uses HTTP, however we'd like to add protobuffs in the future.

# Dependencies:

* bitops
* RCurl
* httr
* jsonlite


(Easily installed in R through `Packages & Data -> Package Installer`)


# Demo

Contents of demo.R pasted below:

```
source("demo.R")

conn <- riak_http_connection("localhost",10018)


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

```
