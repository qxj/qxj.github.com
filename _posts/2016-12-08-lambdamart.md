---
title: LambdaMART算法分享
tags: l2r 树模型
---

组内分享一下在上家公司做搜索排序时对LambdaMART的理解：

<iframe src="//www.slideshare.net/slideshow/embed_code/key/s3hbRJwW6nsxOg" width="595" height="485" frameborder="0" marginwidth="0" marginheight="0" scrolling="no" style="border:1px solid #CCC; border-width:1px; margin-bottom:5px; max-width: 100%;" allowfullscreen> </iframe> <div style="margin-bottom:5px"> <strong> <a href="//www.slideshare.net/Julian.Qian/learning-to-rank-an-introduction-to-lambdamart" title="Learning to Rank: An Introduction to LambdaMART" target="_blank">Learning to Rank: An Introduction to LambdaMART</a> </strong> from <strong><a href="https://www.slideshare.net/Julian.Qian" target="_blank">Julian Qian</a></strong> </div>


学习路径：

- 阅读GBDT论文，需要理解pesudo-response
- 阅读LambdaMART论文，从RankNet到LambdaRak，需要理解lambda梯度
- 阅读Li Hang书LTR for IR&NLP，开阔思路

分享内容：

- L2R、pairwise等基本概念
- GBDT(MART)模型的原理简介 底层训练模型
- lambda梯度概念 pairwise如何体现
- LambdaMART与其它L2R、其它分类模型比较 分类/回归/rank等不同问题、应用现状等
- LambdaMART简单代码实现、工具使用

个人比较喜欢的分享大致包含：

- 理论的介绍(用例子讲明白，而不是公式一摆完事)
- 实现代码的走读(可以是开源，也可以是自己的简单实现版本)
- 应用(找些数据来跑一下，再讲讲实际的应用)
- 参考文献

### 业界应用

搜索排序上，微软和Yahoo研究和应用得比较多。

Yahoo! Learning to Rank Challenge大赛。

但L2R不一定用在搜索，在互联网上还可以解决个性化推荐等其他排序问题。

为什么Google广告上ML很深入和广泛，而搜索上却更偏向人工规则？
https://www.quora.com/Why-is-machine-learning-used-heavily-for-Googles-ad-ranking-and-less-for-their-search-ranking
回答有些老了，2011年的答案，大概意思就是ad有明确的objective function去优化，而search subjective goal: user happiness需要更多的人工决策。

### 问题

#### 为什么IR的指标（NDCG）难以优化？

因为依赖于排序？不连续、不可导？

https://blogs.technet.microsoft.com/machinelearning/2014/07/11/machine-learning-for-industry-a-case-study/

假设一次query经过ranking model之后，每篇文档都有一个score，并根据该score排序。当这些score连续变化时，NDCG值的变化并不连续。

#### Lambda为什么对应梯度？

RankNet在推导的时候只用了Ui比Uj的相关性高还是低（-1, 0, 1），没用上包含位置信息的评估指标（如NDCG），就推出了梯度lambda。所以LambdaMART的lambda，就强硬的在RankNet的lambda上乘上了评估指标的变化（因为评估指标不连续导致目标函数难以推导）。注意RankNet到LambdaMART的目标函数，从代价函数变成了效用函数，所以从使用负梯度变成了正梯度。

Lambda梯度对应的loss function和NDCG之间关系还有待理论验证，参考Tie-Yan Liu @WWW2008

### Q&A

#### NDCG的r(j)的理解

doc的评分

#### 评价指标上NDCG和MAP的选择（经济原因考虑）

NDCG 标注数据获取的代价大
MAP可以通过大量的用户行为进行评价，计算成本低

#### 排序组为什么没用lambdaMART

排序组排序演变：规则->lr->gdbt，lambdaMART效果并无提升，自行实现的gdbt已用久，效果良好。
xgboost是gdbt更高效的实现，训练快

#### lambdaMART补充

MART就是GBDT
小trick，NDCG用于评价指标，loss function不可导，使用lambda代替

#### 特征处理的技巧

缺省值：使用默认值
特征值：按分布离散化取值
pairwise分数不具可比性，可在固定集合上进行评分，每次比较均在固定集合上做对比
