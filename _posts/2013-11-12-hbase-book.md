---
title: 《Hbase权威指南》阅读笔记
tags: hadoop reading
---

本书代码：https://github.com/larsgeorge/hbase-book

# 1 简介

hbase是按照bigtable模型实现的，是一个稀疏的、分布式的、持久化的、多维的映射，由行键、列键和时间戳索引。

    (Table, RowKey, Family, Column, Timestamp) -> Value

一行由若干 *列* 组成，若干列又构成一个*列族*（Column Family），这不仅有助于构建数据的语义边界，也有助于给它们设置某些压缩特性，或指示它们存在在内存中。一个列族的所有列存储在同一个底层存储文件里，即 *HFile*。

一个列族的所有列成员是有着相同的前缀。比如，列 courses:history 和 courses:math 都是 列族 courses的成员。冒号(:)是列族的分隔符，用来区分列族（列的前缀）和列。列族必须是可打印的字符（对应HFile文件名），剩下的部分（对应列，也称为qualify），可以由任意字节数组组成。列族必须在表建立的时候声明。column就不需要了，随时可以新建。

在物理上，一个的列族成员在文件系统上都是存储在一起。因为存储优化都是针对列族级别的，这就意味着，一个column family的所有成员的是用相同的方式访问的。

【注】hbase并非ACID兼容数据库[^1]。

- Atomicity（原子性）原子不可分的操作属性，要不全部完成，要不全部不完成。
- Consistency（一致性）系统从一个有效状态到另一个有效状态的操作属性。
- Isolation（隔离性）两个操作的执行不不干扰。例如，同时在一个对象上不会出现两个写操作，写操作会顺序发生而不会同时发生。
- Durability（持久性）数据一旦写入，确保可以读回，且不会丢失。

### 1.4.3 自动分区

hbase中扩展和负载均衡的基本单元称为region，region本质上是以行键排序的连续存储的区间（类似数据库中的range partition）。
如果region太大，系统就会把它们动态拆分（auto-sharding），相反会把多个region合并，减少存储文件数量。（类似leveldb的compact啊？）

每台服务器中region最佳加载数量是10~100，每个region最佳大小是1~2GB。由 `hbase.hregion.max.filesize` 设置。

hbase构成：客户端库、一台主服务器、多台region服务器。


数十亿行 x 数百万列 x 数千版本 = TB或PB级的存储

hbase每行数据只由一台服务器维护，所以具备**强一致性**。

# 2 安装

hbase依赖特定版本的hadoop，因为它们之间会通过RPC通信，不同版本的RPC接口会有变化。


创建表：

```
create 'test table', 'colfam1'
list 'test table'
put 'test table', 'myrow-1', 'colfam1:q1', 'value-1'
scan 'test table'
get 'test table', 'myrow-1'
delete 'test table', 'myrow-1', 'colfam1:q1'
disable 'test table'
drop 'test table'
exit
```

# 3 客户端API：基础知识


```java
import org.apache.hadoop.conf.Configuration;
import org.apache.hadoop.hbase.HBaseConfiguration;
import org.apache.hadoop.hbase.client.HTable;
import org.apache.hadoop.hbase.client.Put;
import org.apache.hadoop.hbase.util.Bytes;

import org.apache.hadoop.conf.Configuration;
import org.apache.hadoop.hbase.HBaseConfiguration;
import org.apache.hadoop.hbase.client.HTable;
import org.apache.hadoop.hbase.client.Put;
import org.apache.hadoop.hbase.util.Bytes;

import java.io.IOException;

public class PutExample {
    public static void main(String[] args) throws IOException {
        Configuration conf = HBaseConfiguration.create();
        HTable table = new HTable(conf, "test table");
        Put put = new Put(Bytes.toBytes("row1"));
        put.add(Bytes.toBytes("colfam1"), Bytes.toBytes("qual1"), Bytes.toBytes("val1"));
        table.put(put);
    }
}
```

所有的数据修改操作保证**行级别**的原子性。

创建[HTable](https://hbase.apache.org/devapidocs/org/apache/hadoop/hbase/client/HTable.html)的代价较高，建议每个线程只创建一个HTable实例，然后复用之。

### 写入数据

```java
void put(Put put) throws IOException;
Put(byte[] row);       // 初始化Put对象，其中row是唯一行键(row key)
Put.add(byte[] family, byte[] qualifier, byte[] value);  // 往Put对象填充数据
```

数据版本化：HBase默认会保留3个版本的数据，可以指定版本号或时间戳来获取之前版本的数据。

[KeyValue](https://hbase.apache.org/devapidocs/org/apache/hadoop/hbase/KeyValue.html)类：是数据的精确座标（coordinate），一般不直接使用，可以认为是种raw格式。

一个`KeyValue`类构造函数示例：

```java
KeyValue(byte[] row, byte[] family, byte[] qualifier, int qoffset, int qlength, long timestamp, KeyValue.Type type, byte[] value, int voffset, int vlength, byte[] tags)
```

### 客户端缓冲区

每个put操作都是一次RPC，考虑LAN一次round-trip时间大约1ms，所以必须要缓冲提升RPC性能。

强制刷写缓冲区：`flushCommits()`

配置客户端写缓冲区大小：`setWriteBufferSize(long writeBufferSize)`，默认大小2MB（配置项 `hbase.client.write.buffer`）

### 原子性操作（Compare-And-Set, CAS）

[checkAndPut](https://hbase.apache.org/devapidocs/org/apache/hadoop/hbase/client/HTable.html#checkAndPut(byte%5B%5D,%20byte%5B%5D,%20byte%5B%5D,%20byte%5B%5D,%20org.apache.hadoop.hbase.client.Put)) 检查成功则put，否则放弃修改，保证put的原子性。常用于账户结余、状态转换或数据处理等场景，即在读取数据的同时需要处理数据。

类似的还有删除操作：checkAndDelete

### 读取数据

```java
Result get(Get get) throws IOException;
Get(byte[] row);      // 初始化Get对象
```

get返回的数据封装在[Result](https://hbase.apache.org/devapidocs/org/apache/hadoop/hbase/client/Result.html)对象里：

```java
byte[] getValue(byte[] family, byte[] qualifier);    // 获取最新版本的数据
```

### 批量操作

```java
void batch(List<Row> actions, Object[] result)
Object[] batch(List<Row> actions)
```

其中，类Row是Get, Put, Delete的父类。也就是说batch函数可以接收一系列的CRUD操作，然后批量执行。

## 3.4 行锁

```java
RowLock lockRow(byte[] row) throws IOException
void unlockRow(RowLock rl) throws IOException
```

当使用put访问服务器的时候，实际服务端会创建一个短暂的锁；而RowLock是客户端显式的对单行数据操作加锁。

## 3.5 扫描

除了get外还可以用scan来读取数据，区别是scan不需要指定行键。scan类似数据库系统的cursor，利用了hbase提供的底层顺序存储的数据结构来访问数据（hbase的行键是按照字典序排列的）。

Scan可以指定要扫描的列，以及起始和终止行键。

【注】实际新版hbase的get内部都是由scan实现的，因为实际hbase没有直接访问特定行或列的索引，HFile的最小单元是块。详见8.4 读路径。

# 4 客户端API：高级特性

过滤器，搭配scan或get使用，让查询数据更加方便。

所有的过滤器都在服务器端生效，叫做谓词下推（predicate push down），保证被滤掉的数据不会传到客户端。

比较运算符（CompareFilter）：

比较器（comparator）：

比较过滤器（[CompareFilter](https://hbase.apache.org/0.94/apidocs/org/apache/hadoop/hbase/filter/CompareFilter.html)）

比较过滤器 | 说明
--|--
RowFilter             |  筛选行键
FamilyFilter          | 筛选列族
QualiferFilter        | 筛选列，即只返回筛选出来的列，注意和下面的SingleColumnValueFilter区分
ValueFilter           | 筛选特定的值
DependentColumnFilter | 不是根据用户指定的信息筛选，而是指定一个参考列，并它再去筛选其他列

专用过滤器

专用过滤器  |  说明
--|--
SingleColumnValueFilter        | 用某列的值决定该行数据是否被过滤
SingleColumnValueExcludeFilter | 和上面的过滤器相反
PrefixFilter                   | 返回前缀匹配的行
PageFilter                     | 指定每次返回的行数，客户端会记录本次扫描的最后一行，便于迭代访问
KeyOnlyFilter                  | 只返回结果中KeyValue实例的键，而不返回具体的值
FirstKeyOnlyFilter             | 只返回第一列
InclusiveStopFilter            | 一般扫描操作终止行被排除在外，这个扫描器会把终止行也返回
TimestampsFilter               | 可以对版本进行细粒度控制
ColumnCountGetFilter           | 限制每行最多返回的列数
ColumnPaginationFilter         | 类似PageFilter功能，对一行的列进行分页
ColumnPrefixFilter             | 类似PrefixFilter功能，返回前缀匹配的列
RandomRowFilter                | 随机返回，传入一个[0,1]的数

附加过滤器（decoration filter，和其他过滤器组合使用）

附加过滤器 | 说明
--|--
SkipFilter       | 包括一个过滤器，当过滤器发现某行中的某列需要过滤时，会直接过滤该行
WhileMatchFilter | 当一条数据过滤掉，会直接放弃本次扫描操作

组合过滤器

FilterList

### 4.1.6 自定义过滤器

```
public interface Filter extends writable
```

实现`Filter`接口 或 直接继承 `FilterBase 类。

【注】要使得自定义过滤器生效，需要把jar包分发到所有region server，同时重启hbase守护进程。

## 4.2 计数器

计数器适用于一些实时统计的场景。

类似前面的CAS操作，计数器支持read-and-modify操作。

incr指令格式：`incr '<table>', '<row>', '<column>', [<increment-value>]`

```
create 'counters', 'daily', 'weekly', 'monthly'
incr 'counter', '20110101', 'daily:hits', 1
incr 'counter', '20110101', 'daily:hits', 20
get_counter 'counters', '20110101', 'daily:hits'
```

【注】计数器数据类型为整型，如果不小心put进去一个字符串，会导致计数器得到一个错误值。

单计数器

```java
long incrementColumnValue(byte[] row, byte[] family, byte[] qualifier, long amount)
```

多计数器

## 4.3 协处理器

与自定义过滤器不同的是，协处理器可以由hbase集群自动加载，执行region级的操作。

observer，类似RDBMS中的trigger
endpoint，类似RDBMS中的存储过程

# 5 客户端API：管理功能

表描述符

`HTableDescriptor();`

逻辑上Hbase表由行列组成，但物理上，表存储在不同分区（region）。

通过addFamily增加列族：

```java
void addFamily(HColumnDescriptor family);
```

![](http://image.jqian.net/hbase_book_arch.png)

可以通过HBaseAdmin管理表。

# 7 与MapReduce集成

可以使用maven编译出一个胖jar，包含所有依赖的jar包（借助assembly plugin）：

```
$ mvn package -Dfatjar
```

某些不需要打包的依赖可以将`<scope>`属性设置为`provided`。例如：

```
<dependency>
  <groupId>org.apache.hadoop</groupId>
  <artifactId>hadoop-core</artifactId>
  <version>0.20-append-r1044525</version>
  <scope>provided</scope>
</dependency>
```

# 8 架构

B+树

LSM树

【注】LSM树使用日志文件和内存存储把随机写转换成顺序写，因此可以保证稳定的数据插入效率。

数据库有两种范式：

- 利用存储的随机查找能力
- 利用存储的连续传输能力

随机查找在RDBMS中是由B+树数据结构组织，它的工作速度受限于磁盘的寻道速度，每次查找需要访问磁盘log(N)次。
连续传输被LSM树使用，以一定传输速率排序和合并文件，需要执行log(updates)操作。

所以，在没有太多的修改时，B+树表现得很好，因为这些修改要求执行高代价的优化操作以保证查询能在有限时间内完成。在任意位置添加数据的规模越大、速度越快，这些页成为碎片的速度就越快。
LSM树以磁盘传输速率工作并能较好的扩展以处理大量数据，它使用日志文件和内存存储来将随机写转换成顺序写，因此能保证稳定的数据插入速率。由于读写独立，因此这两种操作之间没有冲突。
基于LSM树的系统强调成本透明：假如有5个存储文件，一次访问需要最多5次磁盘寻道。反观RDBMS，即使在有索引的情况下，它也没法确定一次查询需要的磁盘寻道次数。

## 8.2 存储

![HDFS](http://image.jqian.net/hbase_book_hdfs.png)

Hbase处理两种文件：预写日志（Write-Ahead-Log，WAL） 和 实际的数据文件。

- 根级文件。由HLog实例管理的WAL，位于 `/hbase/.logs` 目录。
- 表级文件。每张表目录下 `.tableinfo` 文件，对应序列化后的 `HTableDescriptor` 实例。
- region级文件。每个列族都有单独的目录，目录名是一部分region名的MD5值。

当region文件增长到大于 `hbase.hregion.max.filesize`，则该region会分裂成两个。

HFile格式（类似Google SSTable）

![HFile](http://image.jqian.net/hbase_book_hfile.png)

块大小由HColumnDescriptor配置，默认是64KB。

【注】这里的块区别于HDFS的块的概念（默认64MB，用于分布式存储和MR计算），HFile的块用于高效加载和缓存数据，且只用于HBase内部。类似RDBMS的 *存储单元页* 或 文件系统的 *页表*。也可以参考5.1.3 列族 块大小说明。

虽然HFile保存在HDFS上，但HDFS并不理解HFile，对它只是单纯的二进制文件而已。可以用如下命令检查一个HFile的健康状况：

```
$ ./bin/hbase org.apache.hadoop.hbase.io.hfile.HFile -f /path/to/hfile -v -m -p
```

KeyValue格式

![KeyValue](http://image.jqian.net/hbase_book_keyvalue.png)


## 8.3 WAL

WAL类似MySQL的binlog（即LSM树里的顺序日志文件）。

当memstore（即LSM树的内存存储部分）达到一定大小或时间后，异步顺序的写入HDFS。

8.7 zookeeper

hbase在zk里的默认路径是 `/hbase`。

```
$ $ZK_HOME/bin/zkCli.sh -server  <quorum-server>
```

查看集群关闭时间： `get /hbase/shutdown`

# 9 高级用法

### 行键设计

建议设计高表，而不是宽表。因为宽表可能导致一行数据就超过了HFile限制，这样该HFile无法拆分，同时也导致region无法在合适的位置进行拆分。所以行键设计比较有技巧，一个行键设计示例：

```
<userId>-<date>-<messageId>-<attachmendId>
```

【注】应该保证行键中的每个字段的值都被补齐到这个字段所设的长度，这样字典序才会按预期排列（按二进制内容比较，升序排列）。

宽表的优势在于有修改操作，应该把需要修改的属性放在同一行，因为Hbase能保证数据操作的行级原子性。

参考：http://hbase.apache.org/0.94/book/rowkey.design.html

### 避免数据热点

对于按时间序列组织的数据（行键是连续时间序列），写入时会集中在一个region，而由于一个region只能由一台服务器维护，这就会导致系统产生读写热点，由于写入数据过分集中而导致整个hbase系统性能下降。

要解决这个问题，就应该想办法把写数据分散到所有region服务器上。有这样一些方法：

- 对行键增加salting前缀
- 字段交换，把时间戳字段右移
- 随机化，只适合随机读取而不需要连续扫描的场景

目标是寻找顺序读写性能的平衡点。

### 附加索引

对于需要按某列排序的情况，可以额外增加一个列族来存储索引。

# 11 性能优化

memstore刷写大小：`hbase.hregion.memstore.flush.size`

启用MSLAB：`hbase.hregion.memstore.mslab.enable`

设置region分裂大小：`hbase.hregion.max.filesize=100GB`

需要避免region合并风暴，即很多个region同时分裂合并，可以考虑手动执行split或major_compact来做拆分。

解决region热点，可以把一张表拆分到10个region：

```
$ ./bin/hbase org.apache.hadoop.hbase.util.RegionSplitter -c 10 -f colfam1 testtable
```

# 12 集群管理

在集群间迁移数据：

```
$ hadoop jar $HBASE_HOME/hbase.jar export testtable /user/work/backup-testtable
$ hadoop distcp /user/work/backup-testtable hdfs://path/to/another-hdfs
$ hadoop jar $HBASE_HOME/hbase.jar import /path/to/backup-testtable
```

批量导入数据（bulkimport）：

```
$ hadoop jar $HBASE_HOME/hbase.jar importtsv
```


[^1]: http://hbase.apache.org/acid-semantics.html
