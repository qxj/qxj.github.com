---
title: 分布式系统学习
tags: Linux distributed
---

## 一致性问题

一致性(consensus)问题是指分布式系统中的节点如何就某些东西达成一致，可能是一个值，一系列动作，也可能是一个决定。通常有如下应用场景：

- 决定是否将一个事务提交到数据库
- 对当前时间的界定达成一致以实现同步化时钟
- 执行分布式算法的下一步
- 选择一个leader节点

一致性是一个重要的问题，实际上大多数的分布式系统都是构建在它之上：Group membership systems, fault-tolerant replicated state machines, data stores 这些典型的分布式系统都在某种程度上依赖于一致性问题的解决。同时该问题与另一个经典问题(atomic broadcast，即能在一个网络内将消息可靠的完全有序的传递给其他节点)本质上是同构的。

### 拜占廷将军问题

拜占廷将军问题([Byzantine Generals Problem](http://research.microsoft.com/en-us/um/people/lamport/pubs/byz.pdf))是[Lamport](http://en.wikipedia.org/wiki/Leslie_Lamport)对分布式计算一致性问题的一个描述。在分布式环境中，有可能出现疏漏型的错误，比如系统崩溃、消息丢失、消息重复等；也可能出现误导型的错误，比如消息篡改、状态错误等。所有这些错误统称为拜占廷错误(Byzantine failure)。如果有一种协议，能够在拜占廷错误环境中，仍然可以让可靠的单元(process)之间通信达到一致性，这样的协议称作BFT([Byzantine fault tolerant](http://en.wikipedia.org/wiki/Byzantine_fault_tolerance))。Lamport证明发生错误的单元需要小于1/3，拜占廷将军问题才有解。

### FLP结论

FLP结论，又名FLP不可能性(The Impossibility of Asynchronous Consensus)，这个概念来自论文[Impossibility of Distributed Consensus with One Faulty Process](http://macs.citadel.edu/rudolphg/csci604/ImpossibilityofConsensus.pdf)，由该论文的三位作者名字首字母缩写命名。LFP结论包含了一个分布式系统领域最重要的理论，即 一致性问题对于同步系统来说，即使存在拜占廷错误，它也是可解的；但是对于异步系统，任何协议都有无法终止的可能性，即使只有一个单元出错，它也是不可解的。

### Paxos算法

临时议会（[Paxos](https://en.wikipedia.org/wiki/Paxos_(computer_science))），是拜占廷将军问题的弱化，即消息在传输中可能花费任意的时间，可能会重复，丢失，但是不会被篡改。Paxos算法同样由Lamport发明，Google Chubby服务的创建者Mike Burrows给该算法很高的评价，他说“世上只有一种一致性协议，那就是paxos”——所有其他的方法都只是paxos的一个特化版本。

Paxos算法用在很多分布式系统中，比如Google Chubby、Apache Zookeeper，而且有很多变种，这里简单描述一下最基础的Basic Paxos算法。

Paxos里的一些约定术语：

- Proposer 提案者，它可以提出一个提案(Proposal)。
- Acceptor 提案的受理者，有权决定它是否接受该提案。
- Learner 需要知道被选定提案的那些人。

每轮Basic Paxos分为Prepare和Accept两个阶段。当Proposer无法与额定数量的Acceptor通讯时，Proposer不应该启动Paxos。

Phase 1a: Prepare

Proposer创建一个提案，这个提案用一个数字N进行标识。这个数字必须比这个Proposer曾使用过的提案编号都大。然后，它发送一个Prepare消息（消息中包括了这个提案）给额定数量的Acceptor。

Phase 1b: Promise

如果Acceptor收到的提案编号N比任何之前收到的提案编号都大的话，那么Acceptor必须返回一个Promise消息，保证忽略之后收到的任何提案编号小于N的提案。如果一个Acceptor在之前已经同意了某个值，那么它在回应Proposer的时候，必须附加上最新同意的提案编号以及相应的值。
否则，Acceptor可以忽略收到的提案，甚至可以不用回应它。然后，为了优化的目的，回应一个Nack消息可以告诉Proposer否决提案N。

Phase 2a: Accept Request

如果一个Proposer从Acceptor处收到了足够多的Promise，那么这个Proposer需要给它的提案设定一个值（Value）。如果某个Acceptor之前已经同意了某个提案的话，那么它已经将它同意的值发送给了Proposer，这时，Proposer必须将值设为已经收到的值中（在Promise中一起返回的，都是各Acceptor已经同意的值）编号最大的提案的值。否则，它可以直接设定自己的独立的值。
然后，Proposer发送一个Accept Request消息给额定数量的Acceptor，这个消息中，包含了提案中选择的值。

Phase 2b: Accepted

如果一个Acceptor收到了提案N的Accept Request消息，它必须接受它，当且仅当它还没有向一个编号大于N的提案回应Promise时。这种情况下，它应该注册这个相应的值，然后发送一个Accepted消息给Proposer和每个Learner。否则，它可以忽略这个Accept Request消息。

每轮过程会在下面两种情况下失败：多个Proposer发送了冲突的Prepare消息；或者是Proposer没有收到额定数目的回应（Promise或Accepted）。在这些情况下，需要使用更大的提案编号，重新开始新一轮投票。

注意到当Acceptor接受一个请求时，他们也会告知Proposer的Leader。因此，Paxos也可以用于在一个集群的节点中选择主节点。

下图展示了Basic Paxos一轮就成功的示例：

     Client   Proposer      Acceptor     Learner
       |         |          |  |  |       |  |
       X-------->|          |  |  |       |  |  Request
       |         X--------->|->|->|       |  |  Prepare(N)
       |         |<---------X--X--X       |  |  Promise(N,{Va,Vb,Vc})
       |         X--------->|->|->|       |  |  Accept!(N,Vn)
       |         |<---------X--X--X------>|->|  Accepted(N,Vn)
       |<---------------------------------X--X  Response
       |         |          |  |  |       |  |


### 常用模型

分布式系统中的一致性问题有三种常用模型：

- Transactional one-copy serializability model，一般见于数据库系统，适用于持久性数据，且数据操作是事务性的（ACID）
- Virtual synchrony，适用于内存数据（in memory）
- State machine/Paxos，适用于持久性数据（persistent），不要求事务性

Data Replication的性能对比：

Virtual synchrony 性能最高，但容错性（Fault-Tolerance）稍逊。

Paxos和Transactional模型可以确保宕机不会丢失数据，因为它们持久化数据，且在实际更新数据的时候，会首先确认前一次更新在日志中的记录。这其实是一种2PC，会降低性能：当一个节点发出更新请求之后，其他所有的节点成员需要确认本次更新操作，该请求才会被真正执行。

相反，Virtual synchrony只做内存数据复制，当一条更新消息（message）到达相关的组员后，无需进一步确认。而且高频率的多条更新操作可以合并到一条更新消息里，批量执行。

有[数据表明](http://en.wikipedia.org/wiki/Virtual_synchrony#Performance)，四节点数据同步的速度，Virtual synchrony是Paxos状态机模型的100倍，是Transactional one-copy-serializability模型的1000到10000倍。

两阶段提交(2PC)用于保证分布式事务性，该算法是同步协议，需要在节点HA的基础上使用。

临时议会(Paxos)用于保证节点一致性，和EVS类似，Paxos也可以看作是一种异步的2PC协议。

## 可用性

可用性(Availability)是指所有的读和写都必须要能终止。

## 参考文档

- [Impossibility of Distributed Consensus with One Faulty Process](http://macs.citadel.edu/rudolphg/csci604/ImpossibilityofConsensus.pdf), Fischer, Lynch and Paterson
- [Publication of Lamport](http://research.microsoft.com/en-us/um/people/lamport/pubs/pubs.html)
- Distributed Systems - Principle and Paradigms, Andrew S.Tanenbaum, Maarten Van Steen
- Reliable Distributed Systems - Technologies, Web Services, and Applications, Kenneth P. Birman
