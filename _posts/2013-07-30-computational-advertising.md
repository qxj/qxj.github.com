---
title: 《计算广告学》学习
tags: adtech
---


<iframe src="https://my.mindnode.com/2vKmsL9GGZpfSyHED6eqg6pJpHxtiMVHe7sbGTK3/em#1153,438,-3" frameborder="0" marginheight="0" marginwidth="0" style="border: 1px solid rgb(204, 204, 204); width: 1000px; height: 500px;" onmousewheel=""></iframe>

## 广告的基本知识

广告(Advertising)
: 广告是由已确定的出资人通过各种媒介进行的有关产品(商品、服务和观点)的，通常是有偿的、有组织的、综合的、劝服性的非人员的信息传播活动。

广告的主体：

- 出资人(sponsor) 即广告主(advertiser)
- 媒介(medium)
- 受众(audience)

广告的本质功能：是借助某种有广泛受众的媒体的力量，完成较低成本的用户接触(reach)

### 广告 vs 推荐

广告系统和推荐系统很类似，但也有很大区别。

一个例子：同一广告位同样广告内容的情况下，文字链广告点击率通常大于图片广告，但对推荐来说，图片的推荐效果远远好于单纯的文字推荐。

广告的有效性模型

![广告的有效性模型](/assets/blog-images/comput-ad-effective-model.png)

在线广告的两个评价指标：CTR和CVR （RPM和ROI呢？）

在线广告的特点：精细的受众定向 + 以精确计算为中心

标准化：进行受众定向之后，广告售卖方式由广告位为载体变成以人群为载体。所以希望广告本身的格式、尺寸大小是标准化的。

效果广告 vs 品牌广告：评价指标？收费方式？不同的媒体？

### 在线广告市场

需求方 (Demand)  <---> 供给方 (Supply)

广告主 <---> 媒体

一般media直接接入ad network或者ad exchange，比如一个独立网站接入百度联盟。

由于ad exchange优化都是为其自身利益，所以后来出现了SSP。SSP是为media优化的，它可以同时接入很多ad network，比如百度联盟、adsense、淘宝、广点通等等，具体media的某个广告位可以出不同ad network上的广告。

在线广告的核心计算问题:

Find the best match between a given user (u), in a given context (c), and a suitable ad (a).

$$
\max_{a_1,\cdots,a_T} \sum_{i=1}^T {\rm ROI}(a_i,u_i,c_i)
$$

从优化角度来看

- 特征提取：受众定向  (提取u和c的特征)
- 微观优化：CTR预估  (单次投放的优化)
- 宏观优化：竞价市场机制
- 受限优化：在线分配
- 强化学习：探索与利用 (reinforcement learning)
- 个性化重定向：推荐技术 (retargeting)

搜索、广告与推荐的比较

<table>
  <tr>
    <th>维度</th>
    <th>搜索</th>
    <th>搜索广告</th>
    <th>展示广告</th>
    <th>推荐</th>
  </tr>
  <tr>
    <td>首要准则</td>
    <td>相关性(relevance)</td>
    <td colspan="2">投资回报率(ROI)</td>
    <td>用户兴趣</td>
  </tr>
  <tr>
    <td>其他需求</td>
    <td>各垂直领域独立定义</td>
    <td colspan="2">质量、安全性(Safety)</td>
    <td>多样性(diversity), 新鲜度(freshness)</td>
  </tr>
  <tr>
    <td>索引规模</td>
    <td>~十亿级</td>
    <td>~百万-千万级</td>
    <td>~百万级</td>
    <td>~百万-亿级</td>
  </tr>
  <tr>
    <td>个性化</td>
    <td colspan="2">较少个性化需求</td>
    <td colspan="2">亿级用户规模上的个性化</td>
  </tr>
  <tr>
    <td>检索信号</td>
    <td colspan="2">较为集中</td>
    <td colspan="2">较为丰富</td>
  </tr>
  <tr>
    <td>Downstream优化</td>
    <td colspan="3">不适用</td>
    <td>适用</td>
  </tr>
</table>

### ROI的分解

在线广告系统的ROI

- $Investment = \sharp X \times CPX$
- $Return = \sum_{i=1}^T \mu(a_i,u_i,c_i) v(a_i,u_i)=\sum_{i=1}^Te(a_i,u_i,c_i)$

其中，$\mu$ 点击率(CTR)，$v$ 点击价值(bid)，$e$ eCPM。

优化广告系统ROI的关键就在于提升eCPM（注意不是在说广告主的ROI）

不同的分解对应不同的市场形态：

- CPM市场: 固定eCPM。对media有利，适用于品牌广告。
- CPC市场: 动态CTR，固定click value。supply估计ctr，而demand估计click value。比如google adwords
- CPA/CPS/ROI市场: 动态CTR与动态click value。比如淘宝直通车，统一的转化流程，可以统一的模型。

### 常用统计模型

#### 指数族分布

Canonical form:

$$
p(x|\theta)=h(x)g(\theta)\exp\brace{\theta^T u(x)}
$$

举例: Gaussian, multinomial, maximum entropy

最大似然(Maximum likelihood, ML)估计可以通过*充分统计量*(sufficient statistics)链接到数据

$$
-\nabla\ln g(\theta) = \braket{u(x)}
$$

指数族分布从数据加工出充分统计量后跟数据就不在发生联系了，这之后的运算就可以完全在内存里进行了。比如求高斯分布的均值和方差，那就只需要求两个参数，以后使用这两个参数就可以。而混合高斯分布就没有这样的特性，不可能一次从数据里求出$\theta$？

#### 指数族混合分布

举例: Mixture of Gaussians, Hidden Markov Models, Probabilistic Latent Semantic Analysis (PLSI)

ML估计可以通过EM算法迭代得到. 每个迭代中, 我们使用上一个迭代的*统计量*更新模型.

如果是非指数族分布，就只能使用梯度方法求解。

## 合约广告系统

担保式投送(Guaranteed Delivery, GD)

GD的三个基础功能：CTR预测、流量预测 和 Audience Targeting

广告三方博弈：广告主、媒体、用户

在线分配(Online Allocation)问题，在量一定的情况下优化质 —— 二部图匹配问题

## 受众定向

### 常见受众定向方式

- 人口、地域 都属于传统广告商比较容易接受的定向语言，其实不一定有很好的效果。
- 上下文、行为定向 f(u), f(c), f(u, c)
- 网站、频道定向
- Hyper-local 对应于地域定向，传统地域到城市或省的级别，而Hyper-local是非常细的粒度，比如清华园的主楼级别。
- look-alike 比如银行、汽车网站，给supply提供一些种子人群，映射到supply的海量用户数据，相当于retargeting的一种扩量方式
- 重定向 targeting效果最好，但量很少，完全由广告主网站的流量决定。

### 行为定向 f(u)

利用用户的历史行为，对受众打标签。

九种原始行为：

行为 | 说明
---|---
Transaction, Pre-transaction(如商品浏览)  | 很强。其中Transaction最强，所以淘宝直通车很能赚钱。
Paid search click, Ad click, Search click, Search | 较强
Share, Page View, Ad view | 较弱。PV被动行为，效果较差；ad view经常是一个负系数。

Share虽然是主动行为，但一般很难在demand端找到诉求，对广告主没有意义。
这些行为越往demand对转化越有效，越往supply越弱。没有人比广告主更了解他的用户，媒体虽然有海量数据，但没有广告主的数据有用，所以淘宝的交易数据是最有价值的。

直接使用tagger程序把原始行为简单转化成标签及强度，shallow挖掘即可。

受众定向评测：Reach/CTR曲线。评估标签是否有效。

### 上下文定向 f(c)

和行为定向类似，但行为定向打标签是离线的，而上下文定向是接近在线的，称作near-line上下文定向。

利用在线cache系统存储 url -> 特征表 以提供实时访问。对于cache中不存在的url，返回空特征，同时触发fetcher去爬取页面并提取特征。可以设置cache系统合适的失效时间以完成特征自动更新。

### Topic Model

PLSA, LDA, GaP  经验贝叶斯 Empirical Bayes 是LDA更一般的形式。

- Deterministic inference - VBEM方法
- Probabilistic inference - Gibbs-sampling方法

no free lunch定理

## 竞价广告系统

竞价广告是标签精细化之后的必然选择。

Position auctions

定价机制：VCG, GSP

### 广告网络 (Ad Network)

特征：

- 竞价系统
- 淡化广告位概念。售卖的是人群，淡化媒体。
- 最合适的计价方式是CPC。因为淡化广告位概念，比如百度联盟，广告位位置千奇百怪，曝光率差别巨大，没法估计impression，所以也就没办法使用CPM。（对比实时竞价，是使用CPM）
- 不足：不易支持定制化用户划分。关键词由广告网络制定，广告主需要自己把自己的需求划分到指定的广告词。

Ad network只需要估计ctr，而click value由demand出价。

### 广告检索

布尔表达式检索

长query情况下相关性检索 -  WAND算法

### 点击率预估

点击预测概率模型：

p of click given a, u, c

$$
\mu(a,u,c) = p(click |a,u,c)
$$

新广告的cold start: 利用广告层级结构(creative, solution, campaign, advertiser)，以及广告标签对新广告点击率估计。

由于click是一个binomial变量，大家很直观的去使用LR模型。

- LR模型是Generalized linear model在Binomial error情形下的特例。
- LR模型是Maximum entropy model在类数目等于2的情形下的特例。

### LR优化方法

BFGS (Broyden, Fletcher, Goldfarb, Shanno)

Quasi-Newton方法的一种，思路为用函数值和特征的变化量来近似Hession矩阵，以保证正定性，并减少计算量。

BFGS方法Hession计算公式 (空间复杂度为$O(n^2)$ )：

$$
\begin{align}
H_{k+1}  &= H_k - \frac{H_ky_ky_k^TH_k}{y_k^TH_ky_k}+\frac{s_ks_k^T}{y_k^Ts_k} \\
y_k &= \nabla_{k+1} - \nabla_k \\
s_k &= x_{k+1} -x_k
\end{align}
$$

L(imited memory)-BFGS 是实际使用的算法，在大规模数据中降低空间复杂度的经典方法。

L-BFGS也是LR和最大熵模型求解的最常用方法。

## 搜索广告和广告网络demand技术

### Explore & Exploit

数学上通常描述为Multi-arm Bandit(MAB)问题，基本方法为e-greedy，将e比例的小部分流量用于随机探索。

UCB(upper confidence bound)

arm太多的情况，工程上解决方案：降维。比如不再使用广告a的id号，而是转换成颜色、尺寸等特征矢量。

### 搜索广告

搜索广告就是一个典型的ad network，但由于它太重要了，其相关技术比展示广告之类的ad network要丰富得多。

特点：

- 用户定向标签f(u)，远远弱于上下文f(c)影响，一般可以忽略。（因为用户query意图太强了）
- session内的短时用户搜索行为作用很重要
- 上下文定向标签f(c)：关键词

#### 查询词扩展

主要是搜索广告运营商希望攫取更多利润。比如 “家具” 扩展到“家具店”、“搬家”，1)转化率会变差，词的价值变低，广告主出价不变的话，运营商的利润会更高；2)让广告主竞价词的范围增大，让市场充分竞争，利于市场盘子做大，营收增加。

- 基于推荐的方法，利用搜索数据
- 基于语义的方法，利用其他文档数据
- 基于收益的方法，利用广告数据

### 搜索广告的个性化

一般来说搜索结果不应该做个性化，但搜索广告的展示条数可以深度个性化的。原因在于：即使在美国，也有约一半的用户无法明确区分广告与搜索结果。

### 短时用户行为反馈

session: 短时间内的几次query行为  （需要用到流式计算平台）

- 短时受众定向：根据短时行为为用户打上的标签
- 短时点击反馈：根据短时广告交互计算的动态特征

## 流式计算平台

与Hadoop的区别在于：调度数据而非调度计算。——这决定了storm无法处理海量数据计算。

Hadoop是调度计算，尽量不调度数据。它会把每个执行binary复制到数据所在的node上计算。而Storm的数据会在每个node之间流转。

Trading Desk

为Demand服务，比如如何选择关键词，如何为关键词定价。

EfficientFrontier公司

核心业务：为搜索广告主提供大量关键词情形下的ROI优化服务。

转换为金融领域的Portfolio Optimization问题

## 广告交易市场

### 广告交易平台 (Ad Exchange)

特征：

- 用实时竞价(RTB)方式连接广告和 上下文/用户
- 按照展示上的竞价收取广告主费用(意味着把ctr和click value都交给demand)

Adx无需估计ctr和click value，即eCPM是由demand出价，RTB返回，所以实现逻辑其实比较简单。

潜在问题(对adx)：

- 存在浏览数据的泄漏风险，比如dsp恶意采集用户信息
- 对latency有较大影响(通常最大100ms)，无形中影响了ctr
- 由于adx要多接多家dsp，流量成本有可能直接翻n倍(call out optimization)

call out optimization: 预先估计可能出价并赢得bid的DSP，思路类似GD online allocation问题。

### Cooking Mapping

三个核心问题：谁发起？在哪里发起？谁存mapping表？

- DSP --> ADX --> DSP (存mapping表)
- supply --> DMP --> supply (存mapping表)

### 供应方平台 (Supply Side Platform)

特征：

- 提供媒体端的用户划分和售卖能力
- 可以灵活接入多种变现方式（首先按天排期售卖，排不了的就dynamic allocation，比如接cpm、广告联盟、rtb）
- 收益管理：统一network optimization和RTB

### 需求方平台 (Demand Side Platform)

特征：

- 定制化用户划分(customized audience segmentation)，即DSP需要帮广告主实现在市场日常通用的标签里拿不到的用户划分，比如电商网站需要对老客户做营销，这个老客户即所谓的定制化用户划分。
- 跨媒体流量采购
- 通过ROI估计来支持RTB

DSP的系统会比较复杂，因为它代理广告主的广告库，并且最终根据eCPM出价，既要估计ctr也要估计click value，所以ad retrieval, ranking, yield management这些模块全都需要实现，并且需要做定制化人群划分。

#### click value predict

DSP里的click value估计是要求最高的。

挑战：

- 非常稀疏的训练数据
- 与广告主类型强烈相关的行为模式

比如电商和游戏的转化是完全不同的，在稀疏的数据上还需要分类型训练，所以对ML来说是巨大挑战。

#### retargeting

重定向是customized audience segmentation的一种方式。

- 网站重定向
- 搜索重定向
- 个性化重定向 （购买追踪 + 站外推荐）

### 新客推荐(look-alike)

$f(a, u)$ targeting方式

- 由广告商提供一部分种子用户，DSP通过网络行为的相似性为其找到潜在用户
- 是一种广告商自定义标签，可以视为扩展的重定向
- 在同样reach水平下，效果应好于通用标签
- 应该尽量利用非demand数据，注意避免在竞争对手之间倒卖用户

网络行为的相似性维度：pv, search, ad click, share

## 推荐算法概述

### 协同过滤算法(collaborative filtering)

- 内存方法，或非参数方法      Neighbor-based methods, Item-based/user-based top-N
- 模型方法，或参数方法          Matrix factorization, Bayesian belief nets

### 基于内容算法(Content-based algorithm)

比较适合新闻类推荐。

推荐算法的本质：是对 $\brace{u, a}$ 的co-occurence这一稀疏矩阵的参数或非参数化的描述。

推荐算法举例 SVD++

协同关系矩阵

- 每个元素 $r_{ua}$ 表示u在a上的交互强度
- 此矩阵的大多数元素为未知，推荐算法的目标就是预测这些位置上的强度值

对比Topic Model，协同关系矩阵位置元素的地方，在Topic Model里为0.

## 参考

- 《计算广告学》刘鹏, [网易公开课](http://study.163.com/course/courseMain.htm?courseId=321007)
