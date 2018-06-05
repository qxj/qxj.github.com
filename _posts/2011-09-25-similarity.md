---
title: 文本相似性计算
tags: ml nlp
---

[TOC]

相似性计算常常是聚类分析、数据去重、信息检索以及推荐系统的一个基础工具，这里列举了一些常用的特征提取和相似性计算方法。

## 集合模型

基于集合模型的相似度计算可以先使用所谓[k-Shingling](http://en.wikipedia.org/wiki/W-shingling)的办法，对一个句子或者文档做切片，对于中文文档可以把每个汉字当作一个token，每k个token作为一个切片，然后对得到的切片集合计算[Jaccard系数](http://en.wikipedia.org/wiki/Jaccard_index) [^1]：

$$
J(A,B) = {|A \cap B| \over |A \cup B|}
$$

## 向量空间模型

基于向量空间模型(VSM)的相似度计算一般会先对文档进行分词，然后对每个词计算其权值，常用的办法是[TF-IDF](http://en.wikipedia.org/wiki/Tf%E2%80%93idf)。TF-IDF的主要思想是：如果一个词在一篇文档中出现的频率越高，其他文档中出现越少；或者 如果包含该词的文档越少；则认为该词有很好的类别区分能力，适合用来分类。词频TF、逆文档频率IDF及该词对应权值计算很简单：

$$
\mathrm{tf}(t, d) = \frac{|\{t \in d\}|} {|d|} \\
\mathrm{idf}(t, D) = \log \frac{|D|} {|\{d \in D: t \in d\}|} \\
\mathrm{w}(t,d,D) = \text{tf-idf}(t,d,D) = \mathrm{tf}(t,d) \times \mathrm{idf}(t, D)
$$

其中， $t$  表示词项(term，表示字典里不重复的单词)， $d$ 表示对应文档， $D$ 表示文档集合。这样就可以把一篇文档映射成一个向量： $d \to (w_1,\dots,w_n)$ ，其中， $w_i$ 是构成该文档的词 $t_i$ 的tf-idf权值。

可以使用很多方法计算两个向量的相似度，常用的有欧氏距离，即2-范数(L2 norm)，衡量两个向量终点的距离：

$$
\mathrm{distance}(d_i, d_j) = \sqrt{\sum_{k=1}^{k=n}(w_{i,k} - w_{j,k})^2}
$$

和余弦相似度，衡量两个向量的夹角：

$$
\mathrm{sim}(d_i, d_j) = \cos(\theta) = {d_i \cdot d_j \over \Abs{d_i} \Abs{d_j}} = \frac{ \sum_{k=1}^{n}{w_{i,k} \times w_{j,k}} }{ \sqrt{\sum_{k=1}^{n}{w_{i,k}^2}} \times \sqrt{\sum_{k=1}^{n}{w_{j,k}^2}} }
$$

其中， $w_{i,k}$ 表示文档  $d_i$  中词  $t_k$ 的权值。

一个计算余弦相似度的例子：

```c++
typedef std::pair<std::string, int> TermWeight;
typedef std::vector<TermWeight> DocVector;
typedef std::pair<int, int> WeightPair;

float cosine_similarity(const DocVector& d1,const DocVector& d2)
{
    std::map<std::string, WeightPair> tw;

    std::map<std::string, WeightPair>::iterator itr;
    for (size_t i = 0; i < d1.size(); ++i) {
        const std::string& term = d1[i].first;
        int weight = d1[i].second;
        itr = tw.find(term);
        if(itr != tw.end()){
            itr->second.first += weight;
        }else{
            WeightPair w(weight, 0);
            tw.insert(std::make_pair(term, w));
        }
    }
    for (size_t i = 0; i < d2.size(); ++i) {
        const std::string& term = d2[i].first;
        int weight = d2[i].second;
        itr = tw.find(term);
        if(itr != tw.end()){
            itr->second.second += weight;
        }else{
            WeightPair w(0, weight);
            tw.insert(std::make_pair(term, w));
        }
    }
    // calc
    float sq1 = 0, sq2 = 0, sq = 0;
    for (itr = tw.begin(); itr != tw.end(); ++itr) {
        sq += (itr->second.first * itr->second.second);
        sq1 += (itr->second.first * itr->second.first);
        sq2 += (itr->second.second * itr->second.second);
    }
    if(sq1 && sq2){
        return sq / sqrt(sq1 * sq2);
    }
    return -1;
}
```

## 局部敏感哈希

无论是使用集合模型还是向量空间模型，由于需要两两比较，在计算相似度的时候计算复杂度都比较高，基本都在O(n<sup>2</sup>)量级，在离线计算的时候可能还能接受，但如果要做相对实时的计算的话，压力就比较大了。这里常常就会用到[LSH](http://en.wikipedia.org/wiki/Locality-sensitive_hashing)(Locality-sensitive hashing)，可能有一定的性能损耗，但是在应用中通常能达到O(n)的复杂度，非常适合海量数据应用。

这里给出[Charikar](http://www.cs.princeton.edu/~moses/)对LSH的定义：

> 假定 $h(x)$ 是将物体 $A$ 、 $B$ ，比如向量，映射到一个hash值的hash函数，hash值的每一位相等的概率等于物体 $A$ 、 $B$ 的相似度。

表示为数学形式：

$$
\mathrm{Pr}_{h \in H}[h(A) = h(B)] = \theta(A, B)
$$

等式左边  $\mathrm{Pr}_{h \in H}[h(A)=h(B)]$  表示物体  $A$ 、 $B$  映射后的hash值 $h(A)$ 、 $h(B)$ 相等的概率。等式右边  $\theta(A,B)$  表示物体 $A$ 、 $B$ 的相似度（归一化到[0-1]）。这里无需明确  $\theta(A,B)$  是什么度量方式，因为有各种各样的LSH算法，只要满足上述定义则称作LSH。

显然这种定义天生就使LSH在hash后能够保留原始样本差异程度的信息，相近物体hash值的[汉明距离](http://en.wikipedia.org/wiki/Hamming_distance)就相近。有多相近呢？我们做一个简单的概率变换就能知道：设hash值有比特 $n$ ，两个物体 $A$ 、 $B$ 有 $x$ 位比特相等的概率就是：

$$
\mathrm{Pr}(X=x) = \binom{n}{x} \theta(A,B)^x (1-\theta(A,B))^{n-x}
$$

可以看出 $X$ 是服从参数为 $n$ 和 $\theta(A,B)$ 的[二项分布](https://en.wikipedia.org/wiki/Binomial_distribution)，它的期望值是：

$$
E(X) = n \theta(A,B)
$$

这正说明相近物体的hash值汉明距离也相近。

### minhash

假定 $h(x)$ 是将集合 $A$ 、 $B$ 中的元素 $x$ 映射到一个整数的hash函数； $h_{min}(S)$ 为集合 $S$ 中具有最小 $h(x)$ 函数值的元素。当  $A \cup B$  中具有最小  $h(x)$  值的元素也存在于  $A \cap B$  时，有  $h_{min}(A) = h_{min}(B)$ 。 因此，

$$
\mathrm{Pr}_{h \in H} [h_{min}(A) = h_{min}(B)] = J(A,B)
$$

即集合 $A$ 、 $B$ 的Jaccard相似度为集合 $A$ 、 $B$ 经过 $h(x)$ 映射后最小hash值相等的概率。另一方面来说，如果 $r$ 是一个当  $h_{min}(A) = h_{min}(B)$  时值为1，其它情况下值为0的随机变量，那么 $r$ 可认为是  $J(A,B)$ 的[无偏估计](http://en.wikipedia.org/wiki/Bias_of_an_estimator)。

计算minhash一般有多hash函数和单hash函数映射两种办法，后面一种效率较高。前面我们定义过  $h_{min}(S)$ 为集合 $S$ 中具有最小hash值的元素，那么我们也可以定义 $h_{min(k)}(S)$ 为集合 $S$ 中具有最小hash值的 $K$ 个元素。这样，我们就只需要对每个集合求一次hash，然后取最小的 $K$ 个元素。计算两个集合 $A$ 、 $B$ 的相似度，就是集合 $A$ 中最小的 $K$ 个元素与集合 $B$ 中最小的 $K$ 个元素的交集个数与并集个数的比例。可以看出minhash可以用作降维，因为现在仅需要比较集合映射后的 $K$ 个元素。

### simhash

Simhash也是一种降维技术，可以将高维向量映射到一维的指纹，它最早由Google提出 [^2]，用于网页去重。Simhash算法的输入是一个向量，输出是一个f位的指纹。为了陈述方便，假设输入是一个文档的特征集合，每个特征有对应的权重，simhash算法如下：

1. 将一个f维的向量V初始化为0，f位的二进制数S初始化为0；
2. 对每一个特征：用传统的hash算法对该特征产生一个f位的指纹b，对i=1到f，如果b的第i位为1，则V的第i个元素加上该特征的权重；否则，V的第i个元素减去该特征的权重；
3. 如果V的第i个元素大于0，则S的第i位为1，否则为0；
4. 输出指纹S。

该算法不仅实现降维，而且将相似内容产生的指纹也相似，可进行数据对照。下面是一段代码示例：

```c
uint64_t simhash64(const DocVector& d)
{
    int sign[64];
    memset((char*)aScore,0,sizeof(aScore));
    for (size_t i=0; i<d.size(); ++i) {
        const std::string& term = d[i].first;
        int weight = d[i].second;
        if(weight>0){
            uint64_t hval = hash64_str(term);
            for(int j=0; j<64; ++j){
                if(hval & (1<<j)){
                    sign[j]+=weight;
                }else{
                    sign[j]-=weight;
                }
            }
        }
    }

    uint64_t ret = 0;
    for (size_t j=0; j<64; ++j) {
        if(sign[j]>=0){
            ret=ret|((uint64_t)1<<j);
        }
    }
    return ret;
}
```

## 主题模型

文本的相似性有时候不止看字面上词的是否有重复，常常还取决于文本背后的语义关联。对于这种隐含语义的情况，向量空间模型常常性能不佳，此时需要基于隐性语义分析之类的主题模型。

训练主题模型一般有pLSA(Probabilistic Latent Semantic Analysis)和LDA(Latent Dirichlet Allocation)等方法。

## 参考

- [Mining of Massive Datasets](http://infolab.stanford.edu/~ullman/mmds.html), [Anand Rajaraman](https://twitter.com/anand_raj) and Jeff Ullman


[^1]: [Near-duplicates and shingling](http://nlp.stanford.edu/IR-book/html/htmledition/near-duplicates-and-shingling-1.html)
[^2]: [Detecting Near-Duplicates for Web Crawling](http://www.wwwconference.org/www2007/papers/paper215.pdf)
