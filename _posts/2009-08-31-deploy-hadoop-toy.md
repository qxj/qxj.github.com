---
title: 部署Hadoop系统
tags: hadoop
---

部署一份Hadoop系统做一些探索，当然只是toy，不是生产环境。确认jdk的版本在1.5以上，推荐1.6。如果在redhat上，装完后可以可能还需要设置环境变量：

    export JAVA_HOME=/usr/java/jdk1.6.0_18
    export PATH=$JAVA_HOME/bin:$PATH
    export CLASSPATH=.:$JAVA_HOME/lib/dt.jar:$JAVA_HOME/lib/tools.jar

使用一台机器作为namenode和jobtracker是为master，其他几台机器作为datanode和tasknode是为slaves

这里这样配置：机器Node1作为master，机器Node3和Node4作为slaves。

首先，为所有机器建立同一用户名，比如hadoop，为了部署方便，可以通过设置authorized_keys保证master和slaves之间ssh调用不需要输入密码。

然后，解压下载的apache-hadoop-r0.21.0.tar.gz包到主目录，为了维护方便，链接到 ~/hadoop， 为了升级后不影响配置文件，可以把~/hadoop/conf复制出来为~/hadoop-conf。

接下来的配置可先在在master机器上进行，然后部署到其他slaves上：

一、设置环境变量，配置 ~/.bashrc

    export HADOOP_CONF_DIR=$HOME/hadoop-conf
    export HADOOP_HOME=$HOME/hadoop

二、配置 hadoop-conf 中的配置文件

1） 配置 ~/hadoop-conf/hadoop-sites.xml

    <configuration>
    <property>
            <name>heartbeat.recheck.interval</name>
            <value>5000</value>
    </property>
    </configuration>

2） 配置 ~/hadoop-conf/core-sites.xml

    <configuration>
    <property>
            <name>fs.default.name</name>
            <value>hdfs://Node1:9000</value>
    </property>
    <property>
            <name>hadoop.tmp.dir</name>
            <value>/home/hadoop/tmp/</value>
    </property>
    </configuration>

3） 配置 ~/hadoop-conf/hdfs-sites.xml

    <configuration>
    <property>
            <name>dfs.replication</name>
            <value>3</value>
    </property>
    <property>
            <name>dfs.name.dir</name>
            <value>/home/hadoop/name/</value>
    </property>
    <property>
            <name>dfs.data.dir</name>
            <value>/home/hadoop/data/</value>
    </property>
    <property>
            <name>dfs.block.size</name>
            <value>67108864</value>
      <description>The default block size for new files.</description>
    </property>
    <property>
            <name>dfs.permissions</name>
            <value>false</value>
    </property>
    <property>
            <name>dfs.web.ugi</name>
            <value>hadoop,supergroup</value>
    </property>
    </configuration>

4） 配置 ~/hadoop-conf/mapred-sites.xml

    <configuration>
    <property>
            <name>mapred.job.tracker</name>
            <value>Node1:9001</value>
    </property>
    <property>
            <name>mapred.child.java.opts</name>
            <value>~Xmx512m</value>
    </property>
    </configuration>

5） 配置 ~/hadoop-conf/hadoop-env.sh （可选）

    export JAVA_HOME=/usr/java/jdk1.6.0_18
    export HADOOP_LOG_DIR=${HADOOP_HOME}/logs

6） 部署到其他slaves上，例如：

    $ scp ~/.bashrc Node3:~/
    $ scp -r ~/hadoop-xxx Node3:~/
    $ scp -r ~/hadoop-conf Node3:~/

部署完成，测试一下是否可用：

    $ cd ~/hadoop
    $ bin/hadoop namenode -format
    $ bin/start-dfs.sh

测试一下文件操作

    $ bin/hadoop dfs -copyFromLocal <local-directory> <remote-directory>
    $ bin/hadoop dfs -ls
    $ bin/hadoop dfs -ls <remote-directory>
    $ bin/hadoop dfs -cat <remote-file>

同时，也可以通过Web UI查看Hadoop运行状态

- http://node1:50030/ – web UI for MapReduce job tracker(s)
- http://node1:50060/ – web UI for task tracker(s)
- http://node1:50070/ – web UI for HDFS name node(s)

创建init.d[启动脚本](http://d.pr/n/vWeM)，这样可以保证hadoop随服务器开机启动。
