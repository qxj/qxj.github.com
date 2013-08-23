---
title: 最大似然估计方法
tags: ml
---

> 已知[概率密度函数](http://en.wikipedia.org/wiki/Probability_density_function)的形式，估计其参数的这个过程即[参数估计](http://en.wikipedia.org/wiki/Estimation_theory)(Parameter Estimation)。常用的估计方法有 最大似然估计、最大后验估计、贝叶斯估计等。

若设 $\mathrm{x}=(x_1,\dots,x_n)$ 是来自概率密度函数 $p(\mathrm{x}\vert\theta)$ 的独立采样，则其*联合概率*可以表示为：

$$
p(\mathrm{x}|\theta) = \prod_{i=1}^n p(x_i|\theta)
$$

当通过采样已知 $\mathrm{x}$ 概率， $p(\mathrm{x}\vert\theta)$ 是关于未知参数 $\theta$ 的函数，称为样本的[似然函数](http://en.wikipedia.org/wiki/Likelihood_function)，常记作 $L(\theta)$ 。

把似然函数取得*最大值*时的 $\hat\theta$ 用作未知参数 $\theta$ 的估计值的过程，称为[最大似然估计](http://en.wikipedia.org/wiki/Maximum_likelihood)(MLE, maximum-likelihood estimation)。

实际应用过程中为了计算方便，一般都使用对数自然函数：

$$
\begin{align}
\ell(\theta) &= \ln L(\theta) \\
             &= \sum_{i=1}^n \ln p(x_i|\theta) \\
\hat{\theta} &= \arg\max_{\theta} \, \ell(\theta)
\end{align}
$$

具体的求解办法是对参数 $\theta$ 求导，导数为0时，即似然函数的极值点，可求得待估计的参数。

最大似然估计、最小二乘法和正态分布均由高斯发展而来，它解决了求解误差的概率密度分布问题，是19世纪统计学最重要的成就。下面依葫芦画瓢的简单贯通一下它们之间的联系。

## 正态分布的最大似然估计

假定样本服从正态分布，参数向量 $\theta$ 是正态分布的均值和方差 $\theta=(\mu,\sigma^2)$ ，其中 $\theta_1=\mu, \theta_2=\sigma^2$ ，可得单个样本的对数似然函数：

$$
\begin{align}
p(x_i | \theta)    &= \frac{1}{\sqrt{2\pi\theta_2}} e^{-\frac{(x_i-\theta_1)^2}{2\theta_2}} \\
\ell(x_i | \theta) &= -\frac{1}{2} \ln 2\pi \theta_2 - \frac{1}{2\theta_2}(x_i - \theta_1)^2
\end{align}
$$

对向量 $\theta$ 求导，即对参数各自求偏导数：

$$
\nabla_{\theta}\ell = \begin{bmatrix}
\frac{\partial \ell(x_i | \theta)}{\partial \theta_1} \\
\frac{\partial \ell(x_i | \theta)}{\partial \theta_2}
\end{bmatrix} =
\begin{bmatrix}
\frac{x_i - \theta_1}{\theta_2} \\
-\frac{1}{2\theta_2} + \frac{(x_i - \theta_1)^2}{2\theta_2^2}
\end{bmatrix}
$$

当导数等于0的时候，即得到全体样本的对数似然函数的极值条件，求解如下方程组可得参数 $\theta$ ：

$$
\left\{ \, \begin{align}
\sum_{i=1}^n \frac{(x_i - \hat{\theta}_1)}{\hat{\theta}_2} = 0  \\
-\sum_{i=1}^n \frac{1}{\hat{\theta}_2} + \sum_{i=1}^n \frac{(x_i - \hat{\theta}_1)^2}{\hat{\theta}_2^2} = 0
\end{align}\right.
$$

其中， $\hat{\theta}_1$ 和 $\hat{\theta}_2$ 分别是对 $\theta_1$ 和 $\theta_2$ 的最大似然估计。把 $\hat{\theta}_1$ 和 $\hat{\theta}_2$ 分别用 $\hat{\mu}$ 和 $\hat{\sigma}^2$ 替代，就可以得到正态分布的均值和方差的最大似然估计结果：

$$
\begin{align}
\hat{\mu}      &= \frac{1}{n} \sum_{i=1}^n x_i \\
\hat{\sigma}^2 &= \frac{1}{n} \sum_{i=1}^n(x_i - \hat{\mu})^2
\end{align}
$$

可以看出参数均值的最大似然估计就是样本均值，参数方差的最大似然估计就是样本方差。

## 误差平方和最小假设

> 在特定前提下，任一学习算法如果使输出的假设预测和训练数据之间的误差平方最小化，它将输出极大似然假设

平方损失函数(squared loss function)

$$
L(Y,f(X)) = (Y-f(X))^2
$$

假定学习器L工作在输入空间 $X$ 、输出空间 $Y$ 和假设空间 $H$ 上，假设 $H$ 为是 $X$ 到 $Y$ 的映射函数  $f: X \to Y $ 。给定n个训练样本的集合，每个样本的输出值被随机噪声干扰，即每个训练样本可表示为  $(x_i, y_i)$ ，其中 $y_i = f(x_i) + e_i$ 为观察到的输出值， $e_i$ 是代表噪声的随机变量。假定  $e_i$ 是独立抽取且服从零均值的正态分布，即样本输出值 $y_i$ 服从均值 $f(x_i)$ 方差 $\sigma^2$ 的正态分布。要得到极大似然假设  $y_{ML}$ 即对数似然函数  $\ell(x\vert\mu, \sigma^2)$ 取得极大值：

$$
\begin{align} y_{ML} &= \arg\max_{y \in Y} \ell(x|\mu, \sigma^2) \\
        &= \arg\max_{y \in Y} \prod_{i=1}^n p(x_i|\mu, \sigma^2) \\
        &= \arg\max_{y \in Y} \prod_{i=1}^n \frac{1}{\sqrt{2\pi\sigma^2}} \exp \left(- \frac{1}{2\sigma^2} (y_i - \mu)^2\right) \\
        &= \arg\max_{y \in Y} \prod_{i=1}^n \frac{1}{\sqrt{2\pi\sigma^2}} \exp \left(- \frac{1}{2\sigma^2} (y_i - f(x_i))^2 \right) \\
        &= \arg\max_{y \in Y} \sum_{i=1}^n \left\{\ln \frac{1}{\sqrt{2\pi\sigma^2}} - \frac{1}{2\sigma^2} (y_i - f(x_i))^2 \right\} \\
        &= \arg\max_{y \in Y} \sum_{i=1}^n - \frac{1}{2\sigma^2} (y_i - f(x_i))^2 \\
        &= \operatorname*{arg\,min}_{y \in Y} \sum_{i=1}^n \frac{1}{2\sigma^2} (y_i - f(x_i))^2 \\
        &= \operatorname*{arg\,min}_{y \in Y} \sum_{i=1}^n (y_i - f(x_i))^2 \end{align}
$$

证明了极大似然假设  $y_{ML}$  是使训练值  $y_i$  和假设预测值  $f(x_i)$  之间误差平方和最小的那个。也可以看出最大化似然函数最终等价于最小化平方损失函数。

也可以参考[斯坦福机器学习教程](http://cs229.stanford.edu/materials.html)第一章第12～13页的推导。

## 参考

- 模式分类 Duda 第三章 最大似然估计和贝叶斯参数估计
- PRML 3.1.1 Maximum likelihood and least squares
