---
title: 求解回归问题：最小二乘和梯度下降
tags: MachineLearning Optimization
---

参考：CS229第一章
参考：《机器学习》周志华，第三章
http://www.jianshu.com/p/40e251127025

[TOC]

$$\newcommand{\T}{\mathsf{T}}
\newcommand{\X}{\boldsymbol{X}}
\newcommand{\x}{\boldsymbol{x}}
\newcommand{\y}{\boldsymbol{y}}
\newcommand{\W}{\boldsymbol{\theta}}
\newcommand{\tr}{\mathrm{tr}}$$

考虑一个典型的有监督机器学习问题，给定数据集$\left\{(x^{(i)}, y^{(i)})\right\}_{i=1}^m$，通过经验风险最小化得到一组权值$\W$，我们要学习的函数可以表示为：

$$
y^{(i)} = h_\W( x^{(i)} )
$$

比如，对线性回归就有 $h_\W( x) = \W\cdot x$ 。

对于线性方程的求解，是属于线性代数的范畴。首先，要判断是否有解及是否有唯一解；其次，具体求解方法则有矩阵消元法，克莱姆法则，逆矩阵及增广矩阵法等等。

对于大多数给定数据集，线性方程有唯一解的概率比较小，多数都是解不存在的**超定方程组**。

对于这种问题，在计算数学中通常将参数求解问题退化为求最小误差问题，找到一个最接近的解，即术语**松弛求解**。

## 损失函数

现在对整个训练集的优化目标（整体的损失函数）可以表示为：

$$
L(\W) = \frac{1}{m} \sum_{i=1}^m l\left(x^{(i)}, y^{(i)}, \theta \right)
$$

其中，$l\left(x^{(i)}, y^{(i)}, \W\right)$ 为单个样本的损失函数，squared loss的话可以表示为：

$$
l\left(x^{(i)}, y^{(i)}, \W\right) = \frac{1}{2}\left(y^{(i)} - h_\W(x^{(i)}) \right)^2 \label{eq:loss}\tag{*}
$$

如果引入L2正则项的话可以表示为（前面的1/2常数项是为了求一阶梯度时方便约去）：

$$
L(\W)=\frac{1}{2m}\left[ \sum_{i=1}^m \left(y^{(i)} - h_\W(x^{(i)})\right)^2 + \lambda \|\W\|^2 \right]
$$

单个样本的损失改写为：

$$
l\left(x^{(i)}, y^{(i)}, \W\right) = \frac{1}{2} \left(y^{(i)} - h_\W(x^{(i)})\right)^2 + \frac{\lambda}{2} \|\W\|^2
$$

## 最小二乘法

上述代价函数$\ref{eq:loss}$中使用的均方误差，其实对应了我们常用的欧几里得的距离（欧式距离 Euclidean Distance），基于均方误差最小化进行模型求解的方法称为“最小二乘法”（Least Square Method），即通过最小化误差的平方和寻找数据的最佳函数匹配。

用矩阵形式重写loss函数：

$$
L(\W)=\frac12(\y-\X\W)^\T(\y-\X\W)
$$

其中，

$$
\X=\begin{bmatrix}
\left(\x^{(1)}\right)^\T \\
\left(\x^{(2)}\right)^\T \\
\vdots \\
\left(\x^{(m)}\right)^\T \\
\end{bmatrix},\quad
\y=\begin{bmatrix}
y^{(1)} \\
y^{(2)} \\
\vdots \\
y^{(m)} \\
\end{bmatrix}
$$

最小化平方损失即当$\W$偏导为0时取得全局极小值，先求梯度：

$$
\begin{aligned}
\nabla_\W L(\W) &= \nabla_\W\frac12\left(\y-\X\W\right)^\T\left(\y-\X\W\right) \\
&= \frac12\frac{\partial}{\partial\W}\left(\left(\y^\T-\W^\T\X^\T\right)\left(\y-\X\W\right)\right) \\
&= \frac12\frac{\partial}{\partial\W}\left(\y^\T\y-\W^\T\X^\T\y-\y^\T\X\W+\W^\T\X^\T\X\W\right) \\
&= \frac12\left(\frac{\partial(\y^\T\y)}{\partial\W} - \frac{\partial(\W^\T\X^\T\y)}{\partial\W} - \frac{\partial(\y^\T\X\W)}{\partial\W} + \frac{\partial(\W^\T\X^\T\X\W)}{\partial\W} \right) \\
&= \frac12\left(0-\X^\T\y-\X^\T\y+2\X^\T\X\W\right) \\
&=\X^\T\X\W-\X^\T\y
\end{aligned}
$$

令上式等于0，即可求得参数$\W$的闭式解（closed-form）：

$$
\W=\left(\X^\T\X\right)^{-1}\X^\T\y
$$

当矩阵 $\X^\T\X$ 满秩或正定矩阵时，有解。否则，需要利用梯度下降或牛顿法等迭代法求解。

### 数学原理

微积分角度来讲，最小二乘法是采用非迭代法，针对代价函数求导数而得出全局极值，进而对所给定参数进行估算。

计算数学角度来讲，最小二乘法的本质上是一个线性优化问题，试图找到一个最优解。

线性代数角度来讲，最小二乘法是求解线性方程组，当方程个数大于未知量个数，其方程本身无解，而最小二乘法则试图找到最优残差。

几何角度来讲，最小二乘法中的几何意义是高维空间中的一个向量在低维子空间的投影。

概率论角度来讲，如果数据的观测误差是/或者满足高斯分布，则最小二乘解就是使得观测数据出现概率最大的解，即最大似然估计（利用已知的样本结果，反推最有可能（最大概率）导致这样结果的参数值）。

----

## 梯度下降法

batch GD、mini-batch GD、SGD、online GD的区别在于训练数据的选择上：

| / | batch  |   mini-batch   | Stochastic  |  Online |
|--|--|--|--|
| 训练集  |  固定 |   固定 |   固定  |  实时更新 |
| 单次迭代样本数  |  整个训练集  |  训练集的子集  |  单个样本  |  根据具体算法定 |
| 算法复杂度 |   高  |  一般  |  低  |  低 |
| 时效性  |  低  |  一般（delta 模型） |   一般（delta 模型） |   高 |
| 收敛性  |  稳定  |  较稳定  |  不稳定  |  不稳定 |

### batch GD

每次迭代的梯度方向计算由所有训练样本共同投票决定。

假设参数 $\theta$ 有 $n$ 维，对L2损失求解第 $j$ 维的一阶偏导数：

$$
{\partial L(\theta) \over \partial \theta_j} =
    \frac{1}{m} \sum_{i=1}^m \left(y^{(i)} - h_\theta(x^{(i)})\right) x_j^{(i)}+ \lambda \theta_j
$$

【注】这里的梯度就是迭代的下降方向。不同优化方法其实主要区别就是这个方向不同，SGD是求解损失函数的一阶导数（梯度，Gradient），牛顿法是二阶导数（海森矩阵，Hessian Matrix）。

训练算法为：

$$
\begin{array}{l}
\text{repeat until convergency } \{ \\
\quad \text{for j=1; j<n; j++ :} \\
\qquad \theta_j : = \theta_j  - \alpha \left(
    \frac{1}{m}\sum_{i = 1}^m \left(  y^{(i)} - h_\theta(x^{(i)})  \right) x_j^{(i)}+ \lambda \theta_j \right) \\
\}
\end{array}
$$

batch GD算法是计算损失函数在**整个训练集**上的梯度方向，沿着该方向搜寻下一个迭代点。batch的含义是每轮迭代会根据所有样本算出梯度，再更新模型，然后才进入下一轮在新模型的基础上继续迭代。

【注】发觉squared loss和log loss推导出的梯度形式是一样的，主体都是 $ \left(  y^{(i)} - h_\theta(x^{(i)})  \right) x_j^{(i)}$。

http://spark.apache.org/docs/latest/mllib-linear-methods.html#loss-functions


###  Stochastic GD （SGD）

随机梯度下降就是每次从所有训练样例中抽取一个样本计算梯度并立刻更新模型，这样每次更新模型并不用遍历所有数据集，迭代速度会很快；但是会增加很多迭代次数，因为每次选取的方向不一定是全局最优的方向。

随机梯度下降算法（SGD）是mini-batch GD的一个特殊应用。SGD等价于b=1的mini-batch GD。即，每个mini-batch中只有一个训练样本。

$$
\begin{array}{l}
\text{repeat until convergency }  \{ \\
\quad \text{random choice sample }i\text{ from whole }m\text{ training samples:} \\
\quad \text{for j=1; j<n; j++ :} \\
\qquad \theta_j : = \theta_j  - \alpha \left(
      \left(  y^{(i)} - h_\theta(x^{(i)})  \right) x_j^{(i)} + \lambda \theta_j \right) \\
\}
\end{array}
$$


### mini-batch GD

这是介于以上两种方法的折中，每次随机选取大小为b的mini-batch(b<m)，算完之后再更新模型，这样既节省了计算整个批量的时间，同时基于mini-batch计算的方向对比单个样本来说也会更加准确。

$$
\begin{array}{l}
\text{repeat until convergency }  \{ \\
\quad \text{random choice }b\text{ samples from whole }m\text{ training samples:} \\
\quad \text{for j=1; j<n; j++ :} \\
\qquad \theta_j : = \theta_j  - \alpha \left(
    \frac{1}{b}\sum_i^{i+b} \left(  y^{(i)} - h_\theta(x^{(i)})  \right) x_j^{(i)} + \lambda \theta_j \right) \\
\}
\end{array}
$$

### Online GD（OGD）

随着互联网行业的蓬勃发展，数据变得越来越“廉价”。很多应用有实时的，不间断的训练数据产生。在线学习（Online Learning）算法就是充分利用实时数据的一个训练算法。

Online GD于mini-batch GD/SGD的区别在于，所有训练数据只用一次，然后丢弃。这样做的好处是可以最终模型的变化趋势。比如搜索广告的点击率(CTR)预估模型，网民的点击行为会随着时间改变。用batch算法（每天更新一次）一方面耗时较长（需要对所有历史数据重新训练）；另一方面，无法及时反馈用户的点击行为迁移。而Online Leaning的算法可以实时的最终网民的点击行为迁移。

想法：OGD和SGD应该都属于在线学习算法。即 **每来一个训练样本，就用该样本产生的loss和梯度对模型迭代一次，一个一个数据地进行训练。**

### 并行SGD

![Parallel SGD](http://image.jqian.net/sgd_parallel.png)


 参考：[Parallelized Stochastic Gradient Descent](https://papers.nips.cc/paper/4006-parallelized-stochastic-gradient-descent.pdf)

![Parallel SGD Spark](http://image.jqian.net/sgd_parallel_spark.png)

参考：https://github.com/blebreton/spark-FM-parallelSGD
