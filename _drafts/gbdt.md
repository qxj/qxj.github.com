---
title: GBDT算法
tags: MachineLearning
---

$$
\newcommand{\x}{\mathrm{x}}
$$

论文：Greedy Function Approximation: A Gradient Boosting Machine (Jerome H. Friedman, 1999)

Gradient Boosing是一个算法框架，论文在这个框架下实现了多种算法。

代码：https://code.google.com/p/simple-gbdt


----

参考：A Gentle Introduction to Gradient Boosting (slides)

square loss -> gradient descent

----

参考：http://blog.csdn.net/a819825294/article/details/51188740

前向分布算法+loss函数导出GBDT算法，以及MPI并行化方法。

----

决策树的节点分裂都是遍历各个feature的各个阈值，但分裂条件有区别：

分类树：Info Gain, Gini
回归树：MSE, Gradient

DT优点：non-parametric，不用担心异常值outliers，或者数据是否线性可分
DT确定：容易过拟合，不能处理高维数据

循环迭代中，模型每次拟合的目标都是**损失函数的梯度**。这就是算法被称为「Gradient Boosting」的原因。

----

GBDT是**non-parametric**学习方法，不同于LR之类的参数学习方法，它不是去估计目标函数的参数，而是直接寻找目标函数$F(\x)$：

$$
F^*=\arg\min_F E_{y,\x} L(y, F(\x))
$$

通常，损失函数$L(y,F(\x))$ 包括square-error、absolute error（回归） 或者 logloss（分类）。

加性模型 + 贪心算法，每步都去最小化该步的loss，即gradient。
