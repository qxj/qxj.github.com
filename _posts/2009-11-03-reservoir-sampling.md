---
title: 蓄水池抽样算法和证明
tags: algorithm
---

蓄水池抽样是一个online sampling问题，还有更复杂的带权重的蓄水池抽样算法，可以参考：Weighted Random Sampling (2005; Efraimidis, Spirakis)

## 问题描述

问题：有个n行的文件，如何*逐行读取*并*随机采样*k行，使得它们是完全随机的。
其中：n很大且大小未知，只能流式读取一次*one pass*，k一般较小。

方法：所谓的蓄水池抽样还是很形象的，蓄水池就是这个k容量的池子，新来的第i号元素总是以k/i的概率替换掉池子里的元素，可以证明最后的k个元素是以等概率k/m留在池子里（当然，如果最终文件从头到全部读完，即m=n，则等概率为k/n）。

注意：问题的表述，必须是整个文件从头到尾n行都*读完*，才能保证蓄水池里的留下来的元素是等概率k/n。如果是完全没有头尾的流式数据，那么只能保证你读取过数据里是等概率的，比如读取了m行，那么就是等概率k/m。理解了这个*样本总体*的概念才能理解证明。

## 算法伪码

```
i = 0
reservoir[]
for ( filestream >> x)
    i++
    if i<=k
        do reservoir.push(x)
    else
        r = rand(1, i) // get a uniform random number between [1,i]
        if (r<=k)
            swap(reservoir[r], x)
```

## 算法证明

我们需要证明的是上述算法：对每一个最终在reservoir中的元素出现的概率都相同, 即 k/n。

先把读到的前k个元素放入reservoir，对于第k+1个元素开始，以k/(k+1)的概率选择该元素，以k/(k+2)的概率选择第k+2个元素，以此类推，以k/m的概率选择第m个元素（m>k）。如果m被选中，则随机替换 reservoir 中的一个元素。最终每个元素被选中的概率均为k/n。

用概率语言描述，这里其实是n次选择事件，第m个元素被选择的概率，由第m次选择事件到第n次选择事件决定，所以求解第m个元素最终被选中的概率，其实是在求这n-m+1次事件的联合概率。

已知：

- 第m个元素在第m步选中自身的概率 $$P_\underline{m} = \frac{k}{m}$$
- 随机替换 reservoir 中元素是相同概率 $$P_\circ = \frac1k$$


根据概率公理3：互斥事件任一发生的概率等于各自概率之和，可知：

第m个元素在第i步没被替换掉的概率($m \lt i \leq n$)，等于 *第i个元素在第i步没有被选中的概率* 加上 *第i个元素在第i步被选中 且 没有替换第m个元素的概率*：

$$
\begin{align}
P_m^i &= \left( 1-P_\underline{i} \right) + \left(P_\underline{i} \times \left(1- P_\circ\right)\right) \\
&= \left(1 - \frac{k}{i}\right) + \left(\frac{k}{i} \times \left(1- \frac1{k}\right) \right)
\end{align}
$$

可知，第m个元素*最终*被选上的联合概率：

$$
\begin{align}
P(m) &= P_\underline{m} \times \prod_{i=m+1}^{n-m} P_m^i \\
&= \frac{k}{m} \times \left(
\left(\frac{m+1-k}{m+1} +\frac{k}{m+1}\times\frac{k-1}k
\right) \times
\left(\frac{m+2-k}{m+2}+\frac{k}{m+2}\times\frac{k-1}k
\right) \times \cdots \times
\left(\frac{n-k}n + \frac{k}n\times\frac{k-1}k
\right)
\right) \\
&= \frac{k}m\times\frac{m}n \\
&= \frac{k}n
\end{align}
$$

得证。

后记：另一个证明见[这里](http://blog.sina.com.cn/s/blog_48e3f9cd01019jyr.html)，利用了后验概率证明，感觉搞复杂了。

### 一个变种

问题：在不知道文件总行数n的情况下，如何从文件中随机的抽取一行？

说明：这其实是蓄水池抽样的退化问题，此时蓄水池容量k=1。

解法：我们总是选择第一个元素，以1/2的概率选择第二个，以1/3的概率选择第三个，以此类推，以1/m的概率选择第m个元素。当该过程结束时，每一个元素具有相同的选中概率，即1/n。

证明：第m个元素最终被选中的概率P=选择m的概率*其后面所有元素不被选择的概率，同上面的蓄水池算法，这也是一个联合概率。
