# Riak R Client

**Riak R Client** is a client which makes it easy to communicate with [Riak](http://basho.com/riak/), an open source, distributed database that focuses on high availability, horizontal scalability, and *predictable*
latency. Both Riak and this code is maintained by [Basho](http://www.basho.com/). 

To see other clients available for use with Riak visit our
[Documentation Site](http://docs.basho.com/riak/latest/dev/using/libraries)

This repository is **community supported** and **does not have maintainers**. We both appreciate and need your
contribution to keep it stable. For more on how to contribute, [take a look at the contribution process](#contribution).

## Status

***This is a merge from Datagami employees @alexlouden & @erbas and is being used in production.***
- This is a work in progress. Probably slow and buggy at the moment. The interface is very likely to change.

- **TODO**:
  - implement additional store/fetch options
  - fix mapred
  - link walking
  - retrier/resolver
  - package to CRAN
  - currently the interface uses HTTP, however we'd like to add protobuffs in the future.

## Dependencies:

* bitops
* RCurl
* httr
* jsonlite

(Easily installed in R through `Packages & Data -> Package Installer`)


## Demo

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

## Development

Basho Labs repos survive because of community contribution.

### Maintainers
* You! Open an Issue to volunteer and get involved

You can [read the full guidelines](http://docs.basho.com/riak/latest/community/bugs/) for bug reporting and code contributions on the Riak Docs. And **thank you!** Your contribution is incredible important to us.

## License and Authors

* Author: Dave Parfitt (@metadave)
* Author: Keiran Thompson (@erbas)
* Author: Alex Louden (@alexlouden)

Copyright (c) 2015 Basho Technologies, Inc.

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

[http://www.apache.org/licenses/LICENSE-2.0](http://www.apache.org/licenses/LICENSE-2.0)

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.

