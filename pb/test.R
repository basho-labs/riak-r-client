library( RProtoBuf )

readProtoFiles("~/basho/riak-r-client/pb/riak_kv.proto")
readProtoFiles("~/basho/riak-r-client/pb/riak_search.proto")

foo <- new( RpbGetReq, bucket = "Foo", key = "Bar")
writeLines( foo$toString() )
