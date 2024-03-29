---
title: 置信区间估计
tags: math
---

问题示例：

- 已知样本数据，求解置信区间

【例】一家保险公司收集到36个投保人组成的随机样本，得到每个投保人的年龄，试建立投保人平均年龄90%的置信区间。

- 求解抽样样本容量

【例】根据某城市一次900户随机抽样调查结果，被调查家庭在过去一年中耐用消费品的购买额均值为450元。根据经验估计标准差为120，如果置信系数为0.95且误差在4.5户之内，问样本量应该确定为多少？

## 基本概念

- 虚拟假设、零假设、H0、Ho（Null hypothesis）
- 对立假设、折备假设、H1、Ha（Alternative hypothesis）

- 一型错误（Type I error）  FP
- 二型错误（Type II error）  FN

犯一型错误的概率，称为*显著性水平（Significance level）*：

$$α  = P(\mbox{Type I error}) = P(\mbox{reject H0} | \mbox{H0 is true})$$

犯二型错误的概率：

$$β = P(\mbox{Type II error}) = P(\mbox{accept H0} | \mbox{H0 is false})$$

在一定α下，犯二型错误的概率，称为*检验的势（power）*：

$$π = P(\mbox{reject H0} | \mbox{H1 is true})$$

## 统计推断

假设检验（Hypothesis Testing） 和区间估计（Interval Estimation）

二者都属于*统计推断（Statistical Inference）*——利用样本的数据得到*样本统计量（statistic）*，然后做出对*总体参数（parameter）*的推断。

不同之处在于：

用统计量推断参数时，如果*参数未知*，则这种推断叫*参数估计（点估计与区间估计）*——用统计量估计未知的参数；
如果*参数已知（或假设已知）*，需要利用统计量检验已知的参数是否可靠，此时的统计推断即为*假设检验*。

### 示例：推断全校学生（总体）的平均每天上网时间（参数）

如果事先没有任何关于这方面的信息，则属于参数未知，需要通过抽取300位学生（样本）的数据进行推断，此时进行的就是*参数估计*：由300位学生计算得到样本的平均上网时间（统计量）——比如说是3小时，来估计全校学生平均上网时间。

如果先前有人已得出得出论断，全校学生平均上网时间为5小时，则属于参数已知，而你想验证该已知参数可不可信，这时做的就是*假设检验*：样本得到的平均3小时的上网时间告诉你，先前关于总体的信息很可能是不靠谱的，拒绝该论断。

![P value](/assets/blog-images/confidence-interval-p-value.png)


## 区间估计

区间估计是在一定的置信系数的保证下，根据统计量得到一个取值范围去估计总体的参数。

$$
P(\hat{\theta}_1 \lt \theta \lt \hat{\theta}_2) = 1- \alpha \qquad (0\lt \alpha \lt 1)
$$

其中，$(\hat{\theta}_1 ,\hat{\theta}_2$ 为$\theta$ 的置信区间，$1-\alpha$为置信度，$\hat{\theta}_1$和$\hat{\theta}_2$分别为置信下限和置信下限。

置信系数
: $1-\alpha$使人相信区间包含总体均值的概率，一般取 0.95/0.90/0.99，说明估计的把握性的大小。

置信区间
: 在一定概率的保证下，包含总体均值的区间，区间的宽度说明精度的大小。

临界值
: 置信区间的上限和下限。

### 示例：AB实验指标置信区间估计

目前我们组的策略迭代基本都是小流量实验，观察指标变化情况再决定是否全流量上线。但小流量的数据有两个特点：1. 小流量流量并不大，有些类目的UV只有一万左右；2. 小流量的时间并不长，普遍是两到三天。这样的小流量实验得出来的数据不一定可靠，所以我们决定在AB实验报表里对关键指标加入95%置信区间估计。

假设我们做了一个提升访购率的小流量实验，实验观察实验组 Vs 对照组的访购率指标变化，如果实验组访购率优于对照组访购率，我们就会申请将实验由小流量扩到全流量。

假设实验组累计设备数为N1，购买设备数为UV1，则实验组访购率为P1=UV1/N1；对照组累计设备数为N2，购买设备数为UV2，则对照组访购率为P2=UV2/N2，如果P1-P2>0，我们则认为实验组的访购率要优于对照组，其实由于实验有一定的随机性，我们并不能通过短时间的小流量实验就100%肯定这个结论。为此，我们估计一下P1-P2的置信区间（一般估计置信度为95%的置信区间），如果置信区间的上下限都大于0，我们就可以很肯定（至少95%的肯定）实验组的访购率要优于对照组，否则这个结论的置信度并不高。

实验组 Vs 对照组访购率差的95%置信区间为：

$$
\left[(p_1-p_2)-1.96*\sqrt {\frac {p_1(1-p_1)} {N_1} + \frac {p_2(1-p_2)} {N_2}}, (p_1-p_2)+1.96*\sqrt {\frac {p_1(1-p_1)} {N_1} + \frac {p_2(1-p_2)} {N_2}} \right]
$$

其他指标，如各种点击率也可以类似计算。

解释：两个正态总体，$\sigma_1$、$\sigma_2$已知，求$\mu_1-\mu_2$的置信区间。

$\bar{X}_1 \sim N(\mu_1, \frac{\sigma_1^2}{n_1})$，$\bar{X}_2\sim N(\mu_2,\frac{\sigma_2^2}{n_2})$，其中 $\bar{X}_1$、$\bar{X}_2$ iid。

$$
\implies {(\bar{X}_1-\bar{X}_2) - (\mu_1-\mu_2) \over \sqrt{\frac{\sigma_1^2}{n_1} +\frac{\sigma_2^2}{n_2}} } \sim N(0,1)
$$

则，$\mu_1-\mu_2$的置信区间为

$$
\left[ (\bar{X}_1-\bar{X}_2) - z_\frac\alpha 2 \sqrt{\frac{\sigma_1^2}{n_1} +\frac{\sigma_2^2}{n_2}},
(\bar{X}_1-\bar{X}_2) + z_\frac\alpha 2 \sqrt{\frac{\sigma_1^2}{n_1} +\frac{\sigma_2^2}{n_2}} \right]
$$

继续解释：点击率等都可以建模成Bernoulli实验，均值即参数$p=UV/N$，已知Bernoulli分布的方差是$p(1-p)$，代入上式。

## 参考

- 《数理统计学教程》陈希孺，3. 假设检验 4. 区间估计

统计推断
多重检验（P值校正）
假设检验（P值）
置信区间（Confidence interval）

https://onlinecourses.science.psu.edu/stat414/book/export/html/245
