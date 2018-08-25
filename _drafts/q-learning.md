---
title: Q-Learning入门
tags: ReinforcementLearning
---

参考：
http://mnemstudio.org/path-finding-q-learning-tutorial.htm
http://blog.csdn.net/itplus/article/details/9361915 （译文）

https://www.zhihu.com/question/26408259


Q-Learning是无监督学习，属于Reinforcement Learning。

RL区别于Supervise Learning是要能方便的试错并收集收据；SL只需要大规模的离线数据就可以了。

三要素：

- 状态（**s**tate）
- 动作（**a**ction）
- 奖励（**R**eward）

矩阵 $R(s,a)$ 表示reward值，矩阵 $Q(s,a)$ 表示agent学习到的经验，一次学习称为 *episode*。

Q-Learning转移规则：

$$
Q_{t+1}(s_t,a_t) = R_t(s_t,a_t) + \gamma \cdot \max_\tilde{a} [ Q_t(s_{t+1}, \tilde{a}) ]
$$

其中，$R(s,a)$ 表示眼前利益；$\max [ Q(s, \tilde{a}) ] $ 表示以往经验中的利益，agent记忆里下一个状态的动作中reward的最大值；学习参数 $\gamma$ 是 $[0,1)$ 常数，用来平衡两者。

添加ε-greedy策略：

$$
Q_{t+1}(s_t,a_t) = (1-\alpha) Q_t(s_t,a_t) + \alpha \left( R_t(s_t,a_t) + \gamma \cdot \max_\tilde{a} [Q_t(s_{t+1}, \tilde{a}) ] \right)
$$
