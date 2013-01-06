riak-r-client
=============

(contents of demo.R pasted below)
<pre style="background:#fff;color:#000">source(<span style="color:#409b1c">"~/basho/riak-r-client/riak.R"</span>)

conn <span style="color:#ff7800">&lt;-</span> riak_connection(<span style="color:#409b1c">"localhost"</span>,<span style="color:#3b5bb5">10018</span>)

<span style="color:#8c868f">#######</span>
<span style="color:#8c868f">## basic stats demo</span>
<span style="color:#8c868f">#######</span>
stats <span style="color:#ff7800">&lt;-</span> riak_status(conn)
print(stats<span style="color:#ff7800">$</span>riak_kv_vnodes_running)

<span style="color:#8c868f"># this shows all the stats that are available</span>
names(stats)

<span style="color:#8c868f">## or just print them all out</span>
stats

<span style="color:#8c868f">#######</span>
<span style="color:#8c868f">## store/fetch demo</span>
<span style="color:#8c868f">#######</span>

<span style="color:#8c868f">## store 100 values in TestBucket_currenttime</span>
time <span style="color:#ff7800">=</span> Sys.time()
bucket <span style="color:#ff7800">&lt;-</span> paste(<span style="color:#409b1c">"TestBucket"</span>, time, sep=<span style="color:#409b1c">"_"</span>)
<span style="color:#ff7800">for</span>(i <span style="color:#ff7800">in</span> seq(<span style="color:#3b5bb5">1</span>,<span style="color:#3b5bb5">100</span>)) {
    x <span style="color:#ff7800">&lt;-</span> <span style="color:#ff7800">list</span>( foo=i, alpha <span style="color:#ff7800">=</span> <span style="color:#3b5bb5">1</span><span style="color:#ff7800">:</span><span style="color:#3b5bb5">5</span>, beta <span style="color:#ff7800">=</span> <span style="color:#409b1c">"Bravo"</span>, 
           gamma <span style="color:#ff7800">=</span> <span style="color:#ff7800">list</span>(a=<span style="color:#3b5bb5">1</span><span style="color:#ff7800">:</span><span style="color:#3b5bb5">3</span>, b=<span style="color:#3b5bb5">NULL</span>), 
           delta <span style="color:#ff7800">=</span> c(<span style="color:#3b5bb5">TRUE</span>, <span style="color:#3b5bb5">FALSE</span>) )
   value <span style="color:#ff7800">&lt;-</span> toJSON( x )
    
    key <span style="color:#ff7800">&lt;-</span> paste(<span style="color:#409b1c">"Key_"</span>,i,sep=<span style="color:#409b1c">""</span>)

    obj <span style="color:#ff7800">&lt;-</span> riak_new_json_object(value, bucket, key)
    result <span style="color:#ff7800">&lt;-</span> riak_store(conn, obj)
}

<span style="color:#8c868f"># stream=TRUE doesn't work quite right yet</span>
allkeys <span style="color:#ff7800">&lt;-</span> riak_list_keys(conn, bucket, stream=<span style="color:#3b5bb5">FALSE</span>)
print(length(allkeys<span style="color:#ff7800">$</span>keys))
print(allkeys<span style="color:#ff7800">$</span>keys[<span style="color:#3b5bb5">10</span>])

<span style="color:#8c868f"># fetch a json object, automatically convert json fields to R format :-)</span>
<span style="color:#8c868f"># I still need to convert to a Riak R object</span>
obj <span style="color:#ff7800">&lt;-</span> riak_fetch(conn, bucket, <span style="color:#409b1c">"Key_10"</span>)
obj<span style="color:#ff7800">$</span>alpha

<span style="color:#8c868f"># fetch a "raw" object, including headers, etc</span>
rawobj <span style="color:#ff7800">&lt;-</span> riak_fetch_raw(conn, bucket, <span style="color:#409b1c">"Key_10"</span>)
summary(rawobj)
rawobj<span style="color:#ff7800">$</span>headers
<span style="color:#8c868f"># get the json content using the content() function</span>
json <span style="color:#ff7800">&lt;-</span> content(rawobj)
json<span style="color:#ff7800">$</span>delta

<span style="color:#8c868f"># show the vclock</span>
rawobj<span style="color:#ff7800">$</span>headers<span style="color:#ff7800">$</span>`x<span style="color:#ff7800">-</span>riak<span style="color:#ff7800">-</span>vclock`


<span style="color:#8c868f">#######</span>
<span style="color:#8c868f">## 2i demo</span>
<span style="color:#8c868f">#######</span>
<span style="color:#8c868f"># create some 2i data</span>

<span style="color:#8c868f">#curl -X POST -H 'x-riak-index-company_bin: basho' -H 'x-riak-index-email_bin: jsmith@basho.com' </span>
<span style="color:#8c868f"># -d '...user data...' http://localhost:10018/buckets/users/keys/jsmith1</span>

<span style="color:#8c868f"># curl -X POST -H 'x-riak-index-company_bin: basho' -H 'x-riak-index-email_bin: engbot@basho.com' </span>
<span style="color:#8c868f"># -d '...user data...' http://localhost:10018/buckets/users/keys/engbot</span>

employees <span style="color:#ff7800">&lt;-</span> riak_2i_exact(conn, <span style="color:#409b1c">"users"</span>, <span style="color:#409b1c">"company_bin"</span>, <span style="color:#409b1c">"basho"</span>)
print(employees<span style="color:#ff7800">$</span>keys)

<span style="color:#8c868f">#######</span>
<span style="color:#8c868f">## graph some Riak stats over time</span>
<span style="color:#8c868f">#######</span>

<span style="color:#8c868f"># I ran basho_bench against the node while this ran</span>
<span style="color:#3b5bb5">get_samples</span> <span style="color:#ff7800">&lt;-</span> <span style="color:#ff7800">function</span>() {
    vgt <span style="color:#ff7800">&lt;-</span> rep(<span style="color:#3b5bb5">NA</span>, <span style="color:#3b5bb5">10</span>)
    nfsm <span style="color:#ff7800">&lt;-</span> rep(<span style="color:#3b5bb5">NA</span>, <span style="color:#3b5bb5">10</span>)
    
    <span style="color:#ff7800">for</span>(i <span style="color:#ff7800">in</span> seq(<span style="color:#3b5bb5">1</span>,<span style="color:#3b5bb5">10</span>)) {
        Sys.sleep(<span style="color:#3b5bb5">5</span>) <span style="color:#8c868f"># sleep 5 seconds</span>
        stats <span style="color:#ff7800">&lt;-</span> riak_status(conn)
        vgt[i] <span style="color:#ff7800">&lt;-</span> stats<span style="color:#ff7800">$</span>node_gets_total
        nfsm[i] <span style="color:#ff7800">&lt;-</span> stats<span style="color:#ff7800">$</span>node_get_fsm_time_99
    }
    <span style="color:#ff7800">list</span>(vnode_gets_total=vgt, node_get_fsm_time_99=nfsm)
}

samples <span style="color:#ff7800">&lt;-</span> get_samples()
plot(samples<span style="color:#ff7800">$</span>vnode_gets_total, type=<span style="color:#409b1c">"o"</span>, col=<span style="color:#409b1c">"blue"</span>)
title(main=<span style="color:#409b1c">"Riak data!"</span>, col.main=<span style="color:#409b1c">"red"</span>, font.main=<span style="color:#3b5bb5">4</span>)

plot(samples<span style="color:#ff7800">$</span>node_get_fsm_time_99, type=<span style="color:#409b1c">"o"</span>, col=<span style="color:#409b1c">"blue"</span>)
title(main=<span style="color:#409b1c">"Riak data!"</span>, col.main=<span style="color:#409b1c">"red"</span>, font.main=<span style="color:#3b5bb5">4</span>)


</pre>