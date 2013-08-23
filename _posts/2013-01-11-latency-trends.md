---
title: 一组延时数据
tags: computer
---

2010年Jeff Dean在一次[演讲](http://stanford-online.stanford.edu/courses/ee380/101110-ee380-300.asx)中给出了一份所有程序员都应该了解的[数据](https://gist.github.com/2843375)。不过这组数据其实有些过时了，Colin Scott这位有心人重新整理了一份[数据](http://www.eecs.berkeley.edu/~rcs/research/interactive_latency.html)，并且还是随时间变化的，对比起来看非常有意思。更新今年的数据如下：

    L1 cache reference ........................... 1 ns
    Branch mispredict ............................ 3 ns
    L2 cache reference ........................... 4 ns
    Mutex lock/unlock ........................... 17 ns
    Main memory reference ...................... 100 ns
    Send 2K bytes over commodity network ....... 500 ns  = 0.5 μs
    Compress 1K bytes with Zippy ............. 2,000 ns  =   2 μs
    SSD random read ......................... 16,000 ns  =  16 μs
    Read 1 MB sequentially from memory ...... 15,000 ns  =  15 μs
    Read 1 MB sequentially from SSD ........ 200,000 ns  = 0.2 ms
    Round trip within same datacenter ...... 500,000 ns  = 0.5 ms
    Read 1 MB sequentially from disk ..... 2,000,000 ns  =   2 ms
    Disk seek ............................ 4,000,000 ns  =   4 ms
    Send packet CA->Netherlands->CA .... 150,000,000 ns  = 150 ms

可以看到最近十年来CPU、高速缓存以及总线的速度变化并不大；硬盘的寻道和顺序读的速度略有提升；SSD的速度也提升了10倍；主流商用网络的速度发展惊人，提升了40倍。这应该也跟我们日常的直观感觉是契合的，而当年所说的网络即硬盘的趋势正一步步成为现实。

## 参考

- [Latency Trends](http://colin-scott.github.io/blog/2012/12/24/latency-trends/)
