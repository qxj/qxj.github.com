---
title: 面试题（面试专用）
---

算法工程师应该具备的技能：

- 机器学习：特征、模型（LR/GBDT/DNN）、评估、工具
- 大数据处理：Hadoop/Spark ETL
- 数据分析：SQL、分析技能plot、python
- 数学功底：微积分、线性代数、概率统计、信息论、最优化理论
- 系统开发：C++/Java开发能力

初试三板斧：项目 + 算法 + 编程

算法工程师应该具备的技能：https://zhuanlan.zhihu.com/p/21276788
如何准备机器学习工程师面试：https://www.zhihu.com/question/23259302
名企面试机器学习岗位必考题：https://zhuanlan.zhihu.com/p/27287957

- 数据敏感性、观察力
- 数学抽象能力，数学建模能力和数学工具的熟练使用的能力
- 能随手编脚本代码的能力，强大的计算机算法编程能力
- 想象力，耐性和信心，较强的语言表达能力，抗打击能力

理解招聘Engineer和Scientist的区别。

[TOC]

## 数据结构

删除单链表中相邻的重复元素。

二叉树翻转

- BST LCA：time O(log n) http://www.geeksforgeeks.org/lowest-common-ancestor-in-a-binary-search-tree/

- 普通二叉树 LCA：二叉树的相关算法.md
 - 两种方法：time O(n^2) / space O(1) 和 time O(n) / space O(n)
 - 即时查询？考察：并查集。

- 设计搜索框instant提示。考察：trie前缀树。扩展：中文提示，压缩trie。
- KNN算法，考察：K-D树。

## 算法

参考面试题：leetcode、《编程之美》
考察：时间复杂度、递归

### 题目

链表逆转

排好序的整数数组，找出a+b=c的三个数。

有n个整数数组，计算中位数、计算第k小元素。http://www.cnblogs.com/TenosDoIt/p/3554479.html
扩展：海量数据，无法完全读入内存。

### 排列组合

回溯法：求解一个数组里元素的所有排列「参考[std::next_permutation()](http://en.cppreference.com/w/cpp/algorithm/next_permutation)」

已知数组如X=[1,2,3,4]，输出其所有子集，如1,2,3,4,12,23,34,123,234,1234。

### 动态规划

2sum：给一个都是正整数的数组，是否存在两个数的和为某个给定的sum?
针对两个数的情况，可以先排序，然后从头尾向中间移动。
N-sum：类似于01背包问题
f[i][k]表示前i个元素中任意k个元素的和的集合，那么有：f[i][k] = f[i-1][k] + (f[i-1][k-1] + array[i])
or:
f[i][v]表示前i个元素中是否存在和的v的子数列，那么有：f[i][v] = 1, only if f[i-1][v]=1 or f[i-1][v-array[i]]=1

LIS / LCS：O(n log n)

### 图算法

判断一个无向图（递进有向图）中是否有环。
图的表示：邻接表、邻接矩阵。

无向图算法：如果存在回路，则必存在一个子图，是一个环路。环路中所有顶点的度>=2。
1. 删除所有度<=1的顶点及相关的边，并将另外与这些边相关的其它顶点的度减一。
2. 将度数变为1的顶点排入队列，并从该队列中取出一个顶点重复步骤一。
3. 如果最后还有未删除顶点，则存在环，否则没有环。

有向图算法：思路是DFS，将DFS的点加一个特殊标记，如果从当前的点往下搜的时候，发现了这个特殊标记，立刻判定有环。

求一个带权图中两个结点之间的最短路径？如果有些权值是负的怎么办？

----

## 数学基础

CMU的自测题：http://www.cs.cmu.edu/~aarti/Class/10701_Spring14/Intro_ML_Self_Evaluation.pdf

高等数学
- 导数四则运算、链式法则：$y=x\sin(z)e^{-x}$ => $\frac{\partial y}{\partial x}=-e^{-x}(x-1)\sin(z)$
- 泰勒展开，无约束优化，约束优化，KKT条件

线性代数
- 矩阵乘法、微积分：http://www.atmos.washington.edu/~dennis/MatrixCalculus.pdf
  - 求一阶导 $a^Tx$=>$a$、$x^TAx$=>$(A+A^T)x$，二阶导呢？
- 判断矩阵是否可逆，满秩、$|X|\neq 0$、非奇异矩阵。 $$X=\begin{bmatrix}
1 & 2 \\
3 & 4
\end{bmatrix}$$
 - 只有$X$是方阵且所有列向量都是线性无关的时候才满足要求，若列向量线性相关，则成该方阵$X$是奇异的。
 - 松弛求解，求最小化误差的一般方法是求残差的平方和最小化，这也就是所谓的线性最小二乘法。

    ```python
    from numpy.linalg import inv
    a = np.array([[1., 2.], [3., 4.]])
    inv(a)  # array([[-2. ,  1. ], [ 1.5, -0.5]])
    ```

- 矩阵的特征值和特征向量。$$X=\begin{bmatrix}
2 & 1 \\
1 & 2
\end{bmatrix}$$

    ```python
    from numpy.linalg import eig
    a = np.array([[2., 1.], [1., 2.]])
    eig(a)[0] # array([3., -1.])
    ```
- 矩阵行列式的物理意义

概率统计
- 概率论：期望、方差、协方差（变量相关vs独立）、条件概率、边缘概率
	- pdf Y轴方向能大于0吗？写出高斯分布pdf
- 常见分布：二项分布、指数分布、高斯分布
- 统计推断：置信区间、假设检验
线性代数：矩阵的逆、矩阵乘法、低秩矩阵、奇异矩阵、矩阵分解（特征值分解、SVD）

### 统计题

题目：投掷一颗骰子300次，得到每面的次数，判断是否公平骰子。
思路：卡方检验 假设检验.md

题目：小流量实验，baseline ctr 5%，经过一天的实验，发觉实验组ctr 5.05%，此时能否判断实验组效果好于baseline？
计算p2-p1的95%置信区间下界。

### 概率题

古典概率：一个班级50个人中存在两人相同生日的概率。$1 - A(365,50) / 365^{50} = 0.97$

集邮问题：若有N种不同的邮票，每次等概率随机抽取一张邮票，问集齐N种邮票抽取的期望次数。

蓄水池抽样：给定一个流式的数据，每次到达一个样本， 问如何采样一个大小为k的样本， 要求采样概率均匀。

假设rand()均匀产生0、1，实现rand1()以25%概率返回0，75%概率返回1。

扩展：给定一个[0,1]区间上的随机数生成器（以概率p产生0，概率1-p产生1），如何生成[1, N]上的均匀分布？

如何用(0,1)的均匀分布生成任意的其他概率分布?  [quantile function](https://en.wikipedia.org/wiki/Cumulative_distribution_function#Inverse_distribution_function_.28quantile_function.29)

如何生成随机数（上）：http://blog.pluskid.org/?p=430

丢一个公平的硬币，哪种情况更可能发生？2/3, 20/30, 200/300。可以根据二项分布pdf求概率。

假设某种病患病概率10%，机器识别准确率90%，问被机器识别为患病者的真实患病概率？
考察：条件概率、贝叶斯公式、全概率公式 https://zhuanlan.zhihu.com/p/26098301
假设 $P(A)=0.1$, $P(B|A)=0.9$，求 $P(A|B)$。
贝叶斯公式：$P(A|B)=P(B|A)P(A)/P(B) = 0.9*0.1/P(B) = 0.5$
全概率公式：$P(B)=P(B|A)P(A)+P(B|A^c)P(A^c)=0.9*0.1+(1-0.9)*(1-0.1)$

你试图找出在自己的网站上放置版头的最佳方案。变量包括版头的尺寸（大、中、小）以及放置的位置（顶部、中间、底部）。假定需要 95% 的置信水平，请问你至少需要多少次访问和点击来确定某个方案比其他的组合都要好？
考察：abtest、假设检验、或者bandit也能解决？

----

## 机器学习

《机器学习面试的那些事儿》https://zhuanlan.zhihu.com/p/22387312

特征工程：
- train set / validation set (n-fold) /  test set
- 特征处理：缺失值、异常值、Scaling、Discretization
- 特征选择：Filter 相关系数、互信息、信息增益；Wrapper AUC、MAE、MSE
    - 工业界LR的做法：特征出现频率、覆盖度、看AUC
- 什么时候需要对数据做norm？量纲？SVM？Why LR coordinate-free？
- GBDT Embedding
- 利用MR计算均值和方差 $Var(X)=E(X^2)-E(X)^2$，MySQL里呢？

模型：LR、决策树、SVM、Kmeans、ItemCF，基本原理，损失函数推导。
- 模型的可解释性
- LR 问题定义，损失函数？logloss
    - logloss为什么能用SGD求解（logloss为什么是凸函数？）
    - LR和指数模型、最大熵模型的关系
- SVM dual problem推导
- LDA Dirichlet分布的作用
  - SVD原理 -> pLSA -> LDA
  - gibbs sampling
- Ensemble模型（GBDT能自动组合特征吗？）
    - 决策树如何处理连续变量？选择分割阈值。
    - RF/GBDT区别、bagging/boosting区别
- loss函数，hingle loss / logloss / 回归 square loss
- 实践：
    - 如何负采样，如何还原？
    - 如何初始化参数？LR和CNN各有啥不同？

优化算法：**凸优化问题**，凸函数定义
- 线性回归，解析解，矩阵求逆 vs  最小化误差，松弛求解
	- 最小二乘法vs梯度下降法 https://www.zhihu.com/question/20822481
- 无约束最优化方法（SGD是万能的吗？）
    - LBFGS实现，Hession逆矩阵的求解
    - L1不可导时，一阶 soft-thresholding（proximal）、二阶 OWL-QN
- SGD、QN 梯度是平面逼近，而牛顿法是曲面逼近
- 线搜索、wolfe条件、算法收敛性、次梯度、Lipschitz连续
- SGD如何设置步长？SGD扩展到adagrad等 SGD优化方法总结.md

正则化：处理**过拟合**，bias/variance trade-off，no-free-lunch
- 概率论角度解释 prior
- L0/L1/L2区别 Regularization.md，elastic-net

评估指标：ACC、RECALL、AUC、LogLoss、RMSE、NDCG
- 画出混淆矩阵，为什么改变正负例比例基本不会改变AUC值？
- 分类、回归、排序使用不同指标

深度学习：
- 哪些情况下需要ReLU？如何防止梯度消失？sigmoid有什么优势？
    - ReLU: f(x) = max(0, x)，所以当x<0的时候用反向传导就会造成梯度消失。Leaky ReLU就此应运而生……
- CNN：卷积、池化、子采样、白化、权值共享、BN
- BP实际计算：BP推导，只用numpy实现两层NN网络 https://gist.github.com/qxj/c1d6d0754b7aa3125b48
- LSTM结构推导，为什么比RNN好？

### 拓展问题

参考：https://zhuanlan.zhihu.com/p/28025097 （优达学城）

- 你用一个给定的数据集训练一个单隐层的神经网络，发现网络的权值在训练中强烈地震荡（有时在负值和正值之间变化）。为了解决这个问题你需要调整哪个参数？
- 支持向量机的训练在本质上是在最优化哪个值？
- 在用反向传播法训练一个 10 层的神经网络时，你发现前 3 层的权值完全没有变化，而 4 ~ 6 层的权值则变化得非常慢。这是为什么？如何解决？（Gradient Vanish）
- 你手上有一个关于小麦产出的数据集，包括年降雨量 R、平均海拔 A 以及小麦产量 O。你经过初步分析认为产量跟年降雨量的平方以及平均海报的对数之间存在关系，即：O = β_0 + β_1 x R^2 + β_2 x log(A)。能用线性回归求出系数 β 吗？
- LR sigmoid可以作为概率吗？https://www.quora.com/Why-is-the-output-of-logistic-regression-interpreted-as-a-probability

----

## 大数据处理

Hadoop技术要点 考察Split、OutputFormat等技术细节

MR过程：Mapper Partition Shuffle Reducer
combiner的作用。
如何处理data skew? 说明原理，combiner，或key sharding后再reducer，或借助hive的skew功能。

题目：10TB的query中找出频率TOP10

题目：统计词之间的互信息值。

1. 互信息的定义 $I(X,Y) = \sum_{x\in X,y\in Y}p(x,y)\log \frac{p(x,y)}{p(x)p(y)}$  衡量词和词之间的相关性
2. 如何用mapreduce计算三个值 $p(x)$，$p(y)$ （词频即可）和 $p(x,y)$ （统计x和y同时出现的频率除以无序对个数）

----

## 算法设计题

### 推荐系统

根据用户数据对用户喜欢的电影类型进行预测？

### 广告召回

根据搜索Query判断用户意图？
考察：Query分类、NER，扩展到查询纠错、改写

### CTR预估

冷启动、E&E
常用特征：ID类、实时类
特征工程：交叉项，连续值
position bias

----

## 体系结构

进程：
- 子进程、僵尸进程、Linux下进程和线程区别
- Linux用户态内核态，进程内存结构（堆、栈、数据等）
- 信号：SIGTERM、SIGCHLD、SIGKILL，信号处理函数（可重入）
- 文件锁、管道

线程：
- 线程私有变量和TLS
- 内存一致性和内存屏障
- mutex、rwlock、condition variable，可以考察 queue 生产者消费者问题
- 线程安全？printf和std::cout

进程间通信：
- 共享内存？socket通信？（golang）actor模型，一种解耦方式。

高性能计算：
- omp
- 浮点数

----

## C++ / Java

熟悉的数据结构？（链表、数组、树）
内存分配（placement new、操作符重载）
异常的作用？如何处理异常？
智能指针的实现、dynamic_cast实现
模版实例化、偏特化、SFINAE、ADL
实现singleton，如何保证线程安全？
C++的多态是如何实现的？如何用C实现？

### 编程细节

- int x = -1 和 int x =1 右移1位
- Java如何处理C++ uint64_t，没有unsigned类型

----

## 工程设计题

题目：1亿的文本如何放在100台机器上两两做相似度计算

题目：40亿数据如何用2G内存排序

题目：实现LRUCache「如何维护key的访问顺序（std::list），注意get和set应该是O(1)」
扩展：如何实现一个thread-safe的LRUCache（读写锁）
扩展：如何高并发下让hash table写操作更有效率（瓶颈在于一张大的写锁锁住整个hash table，可以sharding成多个hash table），参考：http://openmymind.net/Shard-Your-Hash-table-to-reduce-write-locks/

题目：设计一个数据结构，存储一副象棋子的摆放，尽量压缩空间，使得方便通过传输到另外一台机子上然后恢复棋盘。

题目：给敏感词列表，和一大段文本，考虑一个敏感词过滤的算法。

bloom filter应用

参考广点通面试题

----
