---
title: Redis集群小记
tags: redis hadoop 开发
---

Redis近两三年变得来非常流行，它的设计很简洁，非常轻量级，至少到目前2.4.x为止，它的定位还是一个单机版的基于内存的kv数据库服务。当然作者Salvatore目前也正在进行Redis Cluster的设计和开发，有兴趣的可以看看这篇[幻灯片](http://redis.io/presentation/Redis_Cluster.pdf)。单机性能毕竟有限，并且作为内存数据库，单机容易因宕机等原因导致中断服务，所以即使没有正式的Redis Cluter，我们常常不得不自己山寨Redis集群来使用。

最近，需要为我们的CTR模型开发线上预估服务，有大量的特征（数十亿量级）需要在Hadoo集群离线产生之后供在线模型读取，并且对QPS和时延要求都很高。由于数据读取的场景比较多，并且需要支持T+1批量更新。因此，最终选择用Redis搭个集群来提供特征存取服务，这里做一个小结。

在动手之前，需要先了解Redis的优缺点和它的适用场景。这方面的总结也很多，就不细述，简单列举一下。

Redis的优势在于：

- 吞吐量很高。由于是内存数据库，因此支持高速读写，[每秒10w级](http://redis.io/topics/benchmarks)。
- 数据结构很丰富。支持string、list、hash、set、sorted set，且有丰富的数据操作方法，比如string可以按位操作，set可以方便的求交、求并，并且大多数操作都是O(1)的。

同样Redis的缺点也很明显：

- 内存占用稍高。48GB内存的机器上，大概只能用到38GB，再多就开始swap了 [ref](http://www.slideshare.net/mysqlops/redis-9806617)。
- 没有太好的数据持久化方案。rdb有可能丢失数据；aof文件增长太快，并且从aof恢复比较慢。
- Replication还比较简陋。master/slave一旦断开连接，需要重传整个snapshot，估计在以后的版本应该会有改进。

由于我需要的是一个存储服务，所以在选择Redis时，还是有些犹豫的。毕竟如果持久化有问题，当作Storage来用，的确有些发毛。具体在搭建服务的时候，考虑了下面一些问题：

-   负载均衡(load balance)

    在Redis前端有主备路由进程，还有若干处理进程。请求发送到路由进程，然后简单round-robin的方式分派到处理进程，处理进程根据key去访问相应的redis服务。

-   可扩展性(scalablilty)

    当数据量增加的时候，需要能够方便的扩容，这里使用简单的pre-sharding方式。

    比如，你可以估算一下数据最大规模，比如最多1TB+，假设每台server的内存是64GB，那么就可以划分到32个redis服务上去。然后，对key简单取模32，即可散列到各个redis服务上了。如果初始只需要4台server，那么每台server就可以跑8个redis服务；如果以后增加server，那么把其中的一些redis服务挪到新的服务器上；然后新旧redis服务通过配置slaveof，即可同步数据；同步完成后，再切换到新的redis服务，关闭老的redis服务。

-   高可用性(high availability)

    服务一般都需要考虑可用性，需要成熟的failover机制进行故障恢复。做法都是增加冗余了，这里用到了master/slave方式，做读写分离。从Hadoop集群过来的数据写到master，而对外服务从slave读取数据。在这个服务里写操作是常态，而且压力很大。经过权衡测试，发觉master是否持久化，reducer的运行时间居然可以相差一个数量级，所以最终只在slave上使用aof持久化，并关闭appendfsync选项，追求最佳性能。master和slave之间自动replication，从CAP理论来说可以归为一个AP系统。

使用Redis时候的一些注意事项：

-   在2.4.x里，如果设置了`maxmemory`，那么当内存占用没有达到极值时，设置expire的key到期后并不会被立即删除；所以，如果期望利用expire让redis清除过期数据，建议还是不要设置maxmemory。
-   pipeline接口，利用了MULTI和EXEC事务处理指令，可以减少网络IO，不过在latency很低的网络里效果并不是很明显。
-   应该根据自己的应用场景调整redis配置，选择好性能和内存占用的trade-off。

    比如你用Hash的时候，如果能够估计你的应用的fields不会超过64项，每个value值不会超过1KB，那么如下配置后，有可能内存占用甚至能够减少一半，具体请参考[官方说明](http://redis.io/topics/memory-optimization)：

        hash-max-zipmap-entries 64
        hash-max-zipmap-value 1024

    此外2.4.x支持自动rewrite aof文件了，可以通过如下两个参数调整 `BGREWRITEAOF` 的频率：

        auto-aof-rewrite-percentage 100
        auto-aof-rewrite-min-size 64mb

最后，提一下Hadoop集群操作Redis的注意事项。可以有两种办法把数据直接写到Redis里去。一是用Java派生 `OutputFormat`，在其中写Redis，好处是不用调整reduce的逻辑；二是直接在reduce里写Redis。

如果用Java或者C++程序写MapReduce程序话，没有太多好说的，并不太依赖Hadoop集群的环境。但是如果用Python的话，需要把 [redis-py](https://github.com/andymccurdy/redis-py) 复制到集群上；如果集群的python环境是2.4的话就比较郁闷，你还必须退回到redis-py 2.4.x之前的版本，并且不能简单的 `import redis`，需要按照下面的步骤来：

1.  下载redis-py 2.3.x，解压后把其中的redis包单独提取出来，然后使用zip压缩，得到redis.zip。由于直接用 `-file` 上传zip文件到计算节点，会被自动解压（没查到资料为啥会自动解压zip，而tgz就没问题，清楚的盼点解），所以需要把redis.zip改名为redis.mod。

2.  然后，在python脚本中这么使用redis包：

    ```python
    import zipimport

    zipimportor = zipimport.zipimporter("./redis.mod")
    redis = zipimportor.load_module("redis")
    r = redis.Redis(host="10.129.0.14", port=6379, db=0)
    ```

3.  最后，把需要的脚本和文件都上传到Hadoop集群上去，执行：

        $ hadoop jar /home/hadoop/hadoop/contrib/streaming/hadoop-0.20.2-streaming.jar \
                 -D mapred.reduce.tasks=32 \
                 -input ${input} \
                 -output ${output} \
                 -mapper "cat"  \
                 -reducer reducer.py \
                 -file ./reducer.py \
                 -file ./redis.mod \
                 -partitioner org.apache.hadoop.mapred.lib.KeyFieldBasedPartitioner \
                 -jobconf mapred.job.name="an example to call redis in reduce"

还有就是应该控制好reducer的数量，并且先做好测试，保证M/R程序的正确性，否则直接把Redis搞爆了就麻烦了。
