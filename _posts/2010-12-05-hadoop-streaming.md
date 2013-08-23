---
title: Hadoop streaming使用技巧
tags: hadoop
---

### 输入输出

Hadoop streaming框架默认情况下会以 `\t`作为分隔符，将每行第一个 `\t` 之前的部分作为key，其余内容作为value；如果没有 `\t` 分隔符，则整行作为key，value为空。

可以通过参数自定义分隔符和分隔符位置。

参数 | 说明
---|---
`stream.map.input.field.separator`    | 设置map输入中key和value的分隔符
`stream.map.output.field.separator`   | 设置map输出中key和value的分隔符
`stream.num.map.output.key.fields`    | 设置map输出中key的分隔符位置（从1开始）。如：对于`A\tB\tC`，如果`separator=\t,fields=2`，则key是`A\tB`，value是`C`
`stream.reduce.input.field.separator` | 设置reduce输入中key和value的分隔符
`stream.reduce.output.field.separator`| 设置reduce输出中key和value的分隔符
`stream.num.reduce.output.key.fields` | 设置reduce输出中key的分隔符位置（从1开始）
`map.output.key.field.separator`      | 设置map输出中key内部用于分桶的分隔符（配合 `KeyFieldBasedPartitioner` 使用）
`num.key.fields.for.partition`        | 设置map输出中key内部用于分桶的分隔符位置（同上）

【注】参数命名规律，`separator`是设置分隔符，`fields`是设置分隔符位置。

### 传递参数

hadoop streaming不支持给mr传递参数，类似 -mapper "cmd arg1 arg2 .." 这样是非法命令，所以如果想传递参数到mr任务，只能使用环境变量 :(

提交作业时，使用 `-cmdenv` 选项以环境变量的形式将你的参数传递给mapper/reducer，如：

    hadoo jar /path/to/hadoop-0.21.0-streaming.jar \
         -input input \
         -ouput output \
         -cmdenv WORDSEG_PATH=wordseg \
         -cacheArchive hdfs://webboss-10-166-133-95:9100/user/jqian/wordseg.tgz#wordseg \
         ...

可以使用 `getenv()` 函数获取环境变量，如：

```c
const char* segpath = getenv("WORDSEG_PATH");
```

### 加载文件

参考：http://hadoop.apache.org/docs/r0.15.2/streaming.html#Large+files+and+archives+in+Hadoop+Streaming

在mr中读取外部文件有两种方法：

-   使用`-file`参数，把本地文件直接打包到执行包里。

        hadoo jar /path/to/hadoop-0.21.0-streaming.jar \
            -input input \
            -ouput output \
            -file /path/to/dict.txt \
            ...

-   使用`-cacheFile`参数，把HDFS上的文件复制到每个mr执行节点，并可以使用`#`建立一个符号链接。

        hadoo jar /path/to/hadoop-0.21.0-streaming.jar \
            -cacheFile hdfs://path/to/dict.txt#new_dict \
            ...

此外，如果想复制本地一个目录到计算节点，可以先打包put到hdfs，然后使用 `-cacheArchive`参数。目前Hadoop会自动解压zip、jar和 tar.gz 格式，例如：

    -cacheArchive hdfs://webboss-10-166-133-95:9100/user/jqian/dict.tar.gz#dict

执行mr时，dict.tar.gz会自动解压，mr里可以直接访问dict目录。

### 环境变量

在0.21.0版本中，streaming作业执行过程中，JobConf中以[mapreduce开头的属性](http://hadoop.apache.org/mapreduce/docs/r0.21.0/mapred_tutorial.html#Configured+Parameters)（如`mapreduce.job.id`）会作为环境变量传递给mr。其中，属性名字中的“.”会变成“_”，如`mapreduce.job.id`会变为`mapreduce_job_id`。

环境变量               | 说明
----------------------|--------------------------
`HADOOP_HOME`         | 计算节点上配置的Hadoop路径
`LD_LIBRARY_PATH`     | 计算节点上加载库文件的路径列表
`PWD`                 | 当前工作目录
`dfs_block_size`      | 当前设置的HDFS文件块大小
`map_input_file`      | mapper正在处理的输入文件路径
`mapred_job_id`       | 作业ID
`mapred_job_name`     | 作业名
`mapred_tip_id`       | 当前任务的第几次重试
`mapred_task_id`      | 任务ID
`mapred_task_is_map`  | 当前任务是否为map
`mapred_output_dir`   | 计算输出路径
`mapred_map_tasks`    | 计算的map任务数
`mapred_reduce_tasks` | 计算的reduce任务数

例如，有时候多个input的格式不同，可以根据不同的输入文件名使用不同的分隔符：

```python
for line in sys.stdin:
    filename = os.getenv("map_input_file")
    if "m1_set_xunzhang" in filename:
        cols = line.strip().split("\001")
    else:
        cols = line.strip().split()
```

### 计数器

使用streaming计数器，可以参考《Hadoop权威指南》 8.1.3

Streaming mr程序可以通过向stderr发送一行特殊格式的信息来增加计数器的值，格式：`reporter:counter:<group>,<counter>,<amount>`，例如：

```python
sys.stderr.write("reporter:counter:My Counters,Failed-to-Parsed Lines,1\n")
```

### 二次排序

所谓二次排序，就是数据先按第一列排序，然后在第一列相同的情况下，再按第二列排序。

回顾MR过程：Input->Map->Shuffle(按照key排序)->Partition(分桶到reducer)->Reduce->Output。

我们的思路是，把第一列和第二列组成同一个key，在shuffle阶段整体排序（此时整体上就已经完成二次排序了）；然后，利用神器partitioner类`KeyFieldBasedPartitioner`，按照第一列为key分桶到各个reducer（这样保证第一列聚合在一起）。

参数                             | 说明
---------------------------------|-------------------------------------------
`map.output.key.field.separator` | 指定key内部的分隔符
`num.key.fields.for.partition`   | 指定对key分出来的前几部分做partition而不是整个key

示例：

测试数据 data.txt：

    a,2
    a,1
    b,2
    b,1
    a,3

运行mr程序：

    hadoop jar /path/to/hadoop-0.21.0-streaming.jar \
        -D stream.map.output.field.separator=, \
        -D stream.num.map.output.key.fields=2 \
        -D stream.reduce.output.field.separator=, \
        -D map.output.key.field.separator=, \
        -D num.key.fields.for.partition=1 \
        -partitioner org.apache.hadoop.mapred.lib.KeyFieldBasedPartitioner \
        -input /path/to/data.txt  \
        -output /path/to/output \
        -mapper cat  \
        -reducer sort

执行结果，符合预期：

    a,1
    a,2
    a,3
    b,1
    b,2
