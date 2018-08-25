---
title: Proximal Gradient Descent
tags: MachineLearning Optimization
---

论文：Proximal Algorithms, Boyd   https://web.stanford.edu/~boyd/papers/pdf/prox_algs.pdf

参考：https://www.zhihu.com/question/38426074/answer/76683857
参考：http://www.cnblogs.com/ooon/p/5839730.html
参考：http://breezedeus.github.io/2013/11/16/breezedeus-proximal-gd.html
参考：http://blog.csdn.net/lanyanchenxi/article/details/50448640

----

Proximity Gradient Descent 用来解决 L1 正则中 0 点不可导的问题

参考：https://math.stackexchange.com/a/511106/440346
参考：http://jocelynchi.com/soft-thresholding-operator-and-the-lasso-solution
近端梯度下降：http://roachsinai.github.io/2016/08/03/1Proximal_Method/

对于目标函数中包含加性的非平滑项并使用SGD求解的问题，可以使用proximal operator求解：

假设目标函数为 $\min_\theta f(\theta)+h(\theta)$，其中 $f(\theta)$可导，而 $h(\theta)$不可导。

$$prox(f,h) = \arg\min_\theta\{\|x-\theta\|^2_2 + \lambda\|\theta\|_1 \}$$

利用subgradient可以推导得

$$
prox(f,h)_i = \theta_i^* = \left\{
\begin{array}{lr}
0 & \text{if } |\theta_i| \leq \lambda \\
\theta_i - \lambda sign(\theta_i) & \text{if } |\theta_i| > \lambda
\end{array}\right.
$$

也可以简写作

$$
prox(f,h)_i = sign(\theta_i)\max(|\theta_i|-\lambda, 0)
$$

![soft thresholding](http://image.jqian.net/proximal-soft-thresholding.png)

可以发觉soft-thresholding方法，把$[-\lambda,\lambda]$内的参数直接置为0，而把之外的参数压缩了$\lambda$大小。
