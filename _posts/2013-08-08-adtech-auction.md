---
title: 计算广告的Auction机制
tags: adtech
---

竞价(Auction)是竞价广告区别于搜索和推荐的重要特点，因为广告涉及平台、用户和流量三方，是一个商业系统，而良好的竞价机制设计是让这个商业系统顺利运转的关键。

## Auction是种博弈

Auction是广告系统售卖流量的一种重要方式，而Auction机制的好坏很大程度决定了广告这个经济系统是否正常稳定运转，以及各方收益是否最优合理。

Auction Theory
: Branch of Game Theory that deals with how participants (players) act in Auction markets.

为了便于理解博弈论(Game Theory)，这里拿最常见的石头(rocks)剪刀(scissors)布(paper)的猜拳游戏来说，player的策略规则如下：

RSP      | Rock | Scissors | Paper
Rock     |  0   |  1       | -1
Scissors | -1   |  0       |  1
Paper    |  1   | -1       |  0

在RSP游戏中，并没有一种绝对优势出拳策略，保证自己的优势。如果有，那随机策略可能以保证对方不能根据上次的行为推断出自己这次的行为（否则对方可以根据上图矩阵，指定确定性的策略压制）。

Nash equilibrium:
: 所有 player都知道 对方在均衡时会采用的策略时候（所谓均衡，就是每个人都考虑有利于自己），没有 player 能单方面改变自己的策略获得更好地收益。

Nash 证明了在 N 个 player 的 game 中如果仅仅存在有限多的 pure strategy，就必然存在一个 mixed strategy 达到 Nash equilibrium。

## 广告Auction机制

常见的 auciton 有：

- First-price sealed-bid
- Second-price sealed-bid auctions (Vickrey auctions)
- Open Ascending-bid auctions (English auctions)
- Open Descending-bid auctions (Dutch auctions)

GFP(Generalized First-Price) 广告主对流量(keyword)进行bid，平台选择最高价格中标，且按**最高价**对广告主计费。这种竞价机制Yahoo!最早用过（Overture 1997），常常会导致买家付出额外的价格，且价格改动过于频繁导致平台收益不稳定(McAdams & Schwarz, 2006)。

[GSP(Generalized Second-Price)](http://en.wikipedia.org/wiki/Generalized_second-price_Auction)与 [VCG(Vickrey-Clarke-Groves)](http://en.wikipedia.org/wiki/Vickrey_Auction) 是目前在竞价广告里讨论得比较多的两种机制，在只有展示*一个广告*情况下，两者是等价的。

GSP机制下，同样是最高出价者中标，但计费规则区别于GFP，按**次高价**计费。GSP鼓励广告主*忠于价值本身出价*，就是自己觉得值多少钱就出多少。

> An auction mechanism is truthful, if the dominant strategy for every player is to truthfully bid their own value.

而VCG的计费规则是，中标者需要支付对其他广告主造成的效用损失。它的优点是可以保证社会整体效率最优，这个还需要进一步理解 :(

Google和Yahoo!使用GSP，而不是VCG的原因：

- VCG计费规则复杂，很难向一般用户解释；
- 在相同bid的情况下，VCG收入是GSP的下限，并且广告主们会逐步延长他们出价的过程；
- 转换到VCG上的收入结果不可预知，这对平台来说难以接受。

BTW: [暗黑3拍卖行](http://d3.178.com/201206/133304618793.html)的竞拍规则就是GSP，暴雪本意是期望玩家能够忠于装备价值本身出价，只是由于在这个虚拟世界由于工作室的存在导致恶性通货膨胀，装备本身价值已经无法正常的用金币衡量和出价了。

### 广告机制设计

广告系统要可持续发展，必须权衡*用户体验*、*广告主ROI* 和 *平台收入*，所以最终广告系统的优化目标（广告排序）是一个涉及三方的函数：

$$
f(user，advertiser，publisher)
$$

因此，仅按广告主出价对广告进行排序是不够的，出价最高的不一定是和用户最相关的。参考Google的机制设计是将cpc乘上广告的*质量分*(Quality Score)进行广告排序，质量分的计算基于CTR和其它因素。并且，每次点击计费是下一名出价加上一个很小的值。淘宝直通车对站内广告计费，也采用类似办法。

![淘宝直通车计费示例](/assets/blog-images/adtech-auction-zhitongche.png)

如下是广告系统里一种比较原始的GSP auction实现：

1. 所有候选广告按 cpm 排序 $cpm_i=bid_i\times ctr_i$
2. 排最末尾的广告收取底价 (Reserved Price, RP)
3. 其他广告按它下一位广告的 $cpm_{i+1}$ 比上它本身的 $ctr_i$ 计费，并保证高于底价，即

   $$
   price_i = \max(\frac{cpm_{i+1}}{ctr_i} + \Delta price , RP)
   $$

## 参考

- Internet Advertising and the Generalized Second-Price Auction, B Edelman, 2005 [屈伟的译文](http://quweiprotoss.blog.163.com/blog/static/40882883201212194938921/)
- Auctions and Bidding A Guide for Computer Scientists, S Parsons, 2011
- http://breadthfirst.wordpress.com/2010/06/09/hegeman-facebook-ad-Auction/
