---
title: 频繁集和关联分析
tags: ml
---

[关联分析](http://en.wikipedia.org/wiki/Association_rule_learning)是一种非监督学习算法，最早用于从购物数据库中挖掘有意义的联系，所发现的联系可以用强关联规则或者频繁集的形式表示。

令 $I=\brace{i_1,\dots,i_d}$ 是类似购物篮数据中所有项的集合(比如所有商品的集合)，包含0个或多个项的集合称作项集(itemset)，如果一个项集包含 $k$ 项，则称作 *k-项集*。令 $T=\brace{t_1,\dots,t_N}$ 是所有事务的集合(比如一次购物行为即等同于一个事务)，显然每个事务 $t_i$ 都是一个项集，且是 $I$ 的子集。

事务的宽度定义为事务中出现项的个数。如果项集 $X$ 是事务 $t_j$ 的子集，则称事务 $t_j$ 包括项集 $X$ 。定义项集的*支持度计数*是包含该项集的事务个数：

$$
\sigma(X) = | {t_i | X \subseteq t_i, t_i \in T} |
$$

*关联规则* 是形如 $X \to Y$ 的蕴含表达式，其中 $X$ 和 $Y$ 是不想交的项集，即 $X \cap Y = \emptyset$ 。关联规则的强度可以用*支持度*(support)和*置信度*(confidence)度量。支持度确定规则可以用于给定数据集的频繁程度，而置信度确定 $Y$ 在包含 $X$ 的事务中出现的频繁程度。支持度和置信度这两种度量形式分别定义如下：

$$
s(X \to Y) = \frac{\sigma(X \cup Y)}{N} \\
c(X \to Y) = \frac{\sigma(X \cup Y)}{\sigma(X)}
$$

其中， $N$ 为所有事务的总数。

关联规则的任务通常能分解为如下两个主要子任务：

- 频繁项集的产生：其目标是发现满足最小支持度阈值的所有项集，这些项集称作频繁项集(frequent itemset)。
- 规则的产生：其目标是从上一步发现的频繁项集中提取所有高置信度的规则，这些规则称作强规则(strong rule)。

## Apriori

除了空的项集外，一个包含 $k$ 个项的数据集可能产生 $2^k-1$ 个频繁项集，所以该问题的搜索空间是指数规模的，一般要用一些启发式的算法来降低计算复杂度。Apriori频繁集算法基于如下先验知识：

> 如果一个项集是频繁的，则它的所有子集一定也是频繁的。反之，如果一个项集是非频繁的，那么它的所有超集一定也是非频繁的。

这种性质称作反单调性(anti-monotone)。因此，一旦发现某个项集是频繁的，则整个包含该项集的超集的搜索空间可以立即被剪枝。

Apriori频繁集算法接受两个参数：最小支持度和数据集。大概算法如下：

1. 生成所有候选1-项集列表，扫描事务集合发现所有频繁1-项集(即所有大于最小支持度的1-项集)。
2. 用上一次发现的频繁(k-1)-项集列表生成候选k-项集列表，并发现所有频繁k-项集。
3. 重复上面的步骤，直到没有新的频繁集产生，算法结束。

除了前件或后件为空集的规则外，每个频繁k-项集能够产生 $2^k-2$ 个关联规则，不过关联规则和频繁集一样也具备反单调性，可基于置信度阈值进行剪枝。

### 具体实现

这里有一份频繁集挖掘的[python实现](http://d.pr/n/FNad)。

从频繁(k-1)-项集列表生成候选k-项集列表有一些技巧，即只要(k-1)-项集列表的前k-2个项是相同的，则这两个集合可以合并成新的候选k-项集。

```python
def createC1(dataSet):
    '''生成所有候选1-项集列表，假设输入数据形如：
       dataSet = [[1, 3, 4], [2, 3, 5], [1, 2, 3, 5], [2, 5]]
    '''
    C1 = []
    for transaction in dataSet:
        for item in transaction:
            if not [item] in C1:
                C1.append([item])
    C1.sort()
    return map(frozenset, C1) # 使用frozenset是因为它可以作为dict的key

def scanD(D, Ck, minSupport):
    '''根据最小支持度，扫描事务集合发现所有的频繁k-项集'''
    ssCnt = {}
    for tid in D:
        for can in Ck:
            if can.issubset(tid):
                if not ssCnt.has_key(can): ssCnt[can]=1
                else: ssCnt[can] += 1
    numItems = float(len(D))
    retList = []
    supportData = {}
    for key in ssCnt:
        support = ssCnt[key]/numItems
        if support >= minSupport:
            retList.insert(0,key)
        supportData[key] = support
    return retList, supportData

def aprioriGen(Lk, k):
    '''根据频繁k-1项集列表生成候选k-项集列表'''
    retList = []
    lenLk = len(Lk)
    for i in range(lenLk):
        for j in range(i+1, lenLk):
            L1 = list(Lk[i])[:k-2]; L2 = list(Lk[j])[:k-2]
            L1.sort(); L2.sort()
            if L1==L2:
                retList.append(Lk[i] | Lk[j])
    return retList

def apriori(dataSet, minSupport = 0.5):
    '''最原始的apriori算法，输出频繁集和相应的支持度(可用于计算关联规则)'''
    C1 = createC1(dataSet)
    D = map(set, dataSet)
    L1, supportData = scanD(D, C1, minSupport)
    L = [L1]
    k = 2
    while (len(L[k-2]) > 0):
        Ck = aprioriGen(L[k-2], k)
        Lk, supK = scanD(D, Ck, minSupport)
        supportData.update(supK)
        L.append(Lk)
        k += 1
    return L, supportData
```

相应的关联规则挖掘实现如下：

```python
def calcConf(freqSet, H, supportData, brl, minConf):
    '''输入 频繁集freqSet
            可以出现在规则后件的项列表H
            支持度supportData
            置信度阈值minConf
       满足满足最小置信度阈值的关联规则加入brl
       返回 可以作为规则后件的项列表'''
    prunedH = []
    for conseq in H:
        conf = supportData[freqSet]/supportData[freqSet-conseq]
        if conf >= minConf:
            # print freqSet-conseq,'-->',conseq,'conf:',conf
            brl.append((freqSet-conseq, conseq, conf))
            prunedH.append(conseq)
    return prunedH

def rulesFromConseq(freqSet, H, supportData, brl, minConf):
    '''递归扩展关联规则'''
    m = len(H[0])
    if (len(freqSet) > (m + 1)):
        Hmp1 = aprioriGen(H, m+1) # 生成H中项的无重复组合
        Hmp1 = calcConf(freqSet, Hmp1, supportData, brl, minConf)
        if (len(Hmp1) > 1):
            rulesFromConseq(freqSet, Hmp1, supportData, brl, minConf)

def generateRules(L, supportData, minConf=0.7):
    '''输入 从apriori方法生成的频繁集和支持度数据
       返回 所有强关联规则'''
    bigRuleList = []
    for i in range(1, len(L)):
        for freqSet in L[i]:
            H1 = [frozenset([item]) for item in freqSet]
            if (i > 1):
                rulesFromConseq(freqSet, H1, supportData, bigRuleList, minConf)
            else:
                calcConf(freqSet, H1, supportData, bigRuleList, minConf)
    return bigRuleList
```

## FP-growth

Apriori算法的缺陷在于需要多次扫描事务数据集，通常会带来很高的IO开销。而FP-growth算法只要扫描数据集两次，在大规模数据应用会比标准的Apriori算法快几个数量级，但该算法只能用于发现频繁集，不能用于发现关联规则。

## 频繁子图

## 参考

- 数据挖掘导论 Pan-Ning Tan, 6.关联分析：基本概念和算法 7.关联分析：高级概念
