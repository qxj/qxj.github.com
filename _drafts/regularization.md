---
title: Regularization
tags: MachineLearning
---

何时使用L1、L2、Group Lasso？
https://www.zhihu.com/question/49042518/answer/113975244

如果几个不同变量有很强的相关性。这种情况下，只用l1 norm，或者lasso，会有一个问题就是有相关性的几个变量不会同时变小或者变大；此时，可以再加上一个l2 norm来确保这些相关的变量能同时朝同一个方向变化。这种同时用l1和l2的方法叫做elastic net。

假如在一个问题里面我们已经知道哪些变量会同时变化，那么可以用group lasso。就是把强相关性的变量放到同一个group里面。这时，在一个group里面，假如有一个变量是0了，那么这个group里面的所有其他变量都会成0。

## 正则化的几种解释
### 概率论角度

按照贝叶斯学派理论，Regularization最简单的解释就是加了先验（prior）。在数据少的时候，先验知识可以防止过拟合。

举2个例子：

1. 抛硬币，推断正面朝上的概率。如果只能抛5次，很可能5次全正面朝上，这样你就得出错误的结论：正面朝上的概率是1——过拟合！如果你在模型里加正面朝上概率是0.5的先验，结果就不会那么离谱。这其实就是正则。

2. 最小二乘回归问题：加2范数正则等价于加了高斯分布的先验，加1范数正则相当于加拉普拉斯分布先验。

拿Lasso举例：

$$
w^* = arg\min_w \|y - Xw\|_2^2 + \lambda \|w\|_1
$$

其实就是如下概率模型的最大后验：

$$
y = Xw + \epsilon \\
\epsilon \sim N(0,\sigma^2) \\
w_i \sim DoubleExponential(\lambda)
$$

如果不对w加拉普拉斯分布的先验，最大后验得到的是：

$$
w^* = arg\min_w \|y- Xw\|_2^2
$$

其实正则项就是对w的先验分布。

### 机器学习角度

Regularization是模型bias和variance的trade-off，用于防止overfitting。

一般的监督学习，大概可以抽象成这样的优化问题：

$$
\min loss( y - f(x) ) + \Omega ( f )
$$

$f$ 是要学习的model，$y$ 是监督的target。为了更直观的解释，上面的regularized的形式也可以写成下面constrained的形式:

$$
\min loss(y - f(x))    \qquad   s.t. \Omega(f) \lt \lambda
$$

如果是最简单的线性回归模型，那么就是：

$$
\min || y - wX ||^2  \qquad s.t. ||w|| < \lambda
$$

这里面 $||w||$ 越大，也就说明 $w$ 向量离原点越远，模型的复杂程度越高，方法的bias越大，variance越小，也就会造成我们常说的过拟合。而一些非线性映射，或者KNN算法，则有着更高的模型复杂度。相反，$\lambda$ 越小，方法的bias也越小，能够更好地拟合训练数据，但是方法的variance更大， 输出变量于输出变量期望的差异也更大。

https://www.zhihu.com/question/20700829

从概率的角度来说，对模型的正则化项其实就是对$w$给出一个先验的分布。如果正则化项和损失函数都是L2 norm，其实就给了$w$一个期望是0，协方差矩阵是 $\delta I$ 的先验分布。之后计算$w$，就是在给定$w$的先验、$x$和$y$的情况下，用最大似然估计最大化$w$的后验概率，求出$w$的最优解。$\lambda$ 越大，表示$w$的先验分布的协方差越小，也就是$w$越稳定。其他的正则话项也可以对应其他的先验分布，比如L1的正则话项对应Laplace先验。

### Stein‘s Pheonomenon

高维统计学解释，没看懂……
https://www.zhihu.com/question/20700829/answer/52215762

说人话就是：正则化导致估计量的Shrinkage，Shrinkage导致variance减小，如果variance的减小可以补偿bias则正则化可以改善泛化误差。
