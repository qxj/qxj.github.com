---
title: 动态规划算法
tags: algorithm
---

[TOC]

[动态规划算法](http://en.wikipedia.org/wiki/Dynamic_programming)与分治法类似，基本思想也是把待求解问题分解成若干子问题，先求解子问题，然后从子问题的解得到原问题的解。与分治法的区别在于，分解开的若干子问题往往不是相互独立的。动态规划算法中需要用一个表来记录已解决的子问题的解，以避免重复计算，从而得到多项式时间算法。

动态规划算法的使用范围：求解某种具有最优性质的问题。

动态规划算法的有效性依赖于问题的两个重要性质：

- 最优子结构（问题的最优解包含了子问题的最优解）
- 重叠子问题（当递归计算时，每次产生的子问题并非总是新问题，会被反复计算）

动态规划算法与备忘录算法的区别：动态规划算法是自底向上递归的。

动态规划算法有两种实现方式：

- *带备忘的自顶向下法* 按照直观的递归形式编程，但由于会重复求解重叠子问题，所以在递归过程中会额外保存相关子问题的解，即所谓的备忘。
- *自底向上法* 按子问题规模从小到大的顺序求解，并保存这些子问题的解，当到需要求解的问题时，它依赖的所有子问题都已经求解，所以也就可以直接求解该问题了。

这两种实现的区别是，带备忘的自顶向下法一般使用递归形式，依赖递归栈的大小，但它只会计算依赖的子问题；而自底向上法需要求解所有的子问题。

动态规划算法的一般步骤：

1. 找出最优解的性质，并刻画子问题结构特征；
2. 根据子问题递归地定义最优解；
3. 以自顶向下或自底向上计算最优解；
4. 利用计算出的信息构造*一个最优解*。

## 最长公共子序列

最长公共子序列（LCS, Longest Common Subsequence）问题。子序列就是一个序列中去掉零到多个元素得到的序列。

给出两个字符串序列，求解它们LCS的长度。

1) 分析LCS结构，寻找子问题

设序列  $X=\brace{x_1,\dots,x_i}$  和  $Y=\brace{y_1,\dots,y_j}$ 的一个最长公共子序列为  $Z=\brace{z_1,\dots,z_k}$ ，则，

1. 若  $x_i=y_j$ ，则  $z_k=x_i=y_j$ ，且  $Z_{k-1}$ 是  $X_{i-1}$  和  $Y_{j-1}$ 的LCS，
2. 若  $x_i \neq y_j$  ，且  $z_k \neq x_i$ ，则 $Z$  是  $X_{i-1}$  和  $Y$ 的LCS，
3. 若  $x_i \neq y_j$  ，且  $z_k \neq y_j$ ，则 $Z$ 是  $X$ 和  $Y_{j-1}$ 的LCS。


2) 定义子问题的递归结构

关键在于如何记录子问题的解，这里是使用二维数组c[i][j]来记录序列 $X_i$  和  $Y_j$ 的LCS长度，可以利用它来表述最优子结构的递归关系：

$$
c[i][j] =
\begin{cases}
0 & \mbox{ if } i,j=0 \\
c[i-1][j-1] +1 & \mbox{ if } i,j>0 \mbox{ and } x_i=y_i \\
\max(c[i][j-1], c[i-1][j]) & \mbox{ if } i,j >0 \mbox{ and } x_i \neq y_i
\end{cases}
$$

其中，i和j是子问题中两个序列的长度。

<!-- 1. c[i][j]=0; IF i=0, j=0 -->
<!-- 2. c[i][j]=c[i-1][j-1]+1; IF i,j>0; xi=yi -->
<!-- 3. c[i][j]=max{ c[i][j-1], c[i-1][j] }; IF i,j>0; xi!=yi -->

3) 递归计算子问题

带备忘录的自顶向下方法，很直观的翻译上面的递归关系。额外提供一个全局二维数组c，用来备忘递归过程中产生子问题的解。

```c++
int c[100][100];   // 2d array ixj is just fine.

int lcs_length_top_down(char *x, char *y, int i, int j)
{
    if (c[i][j]>0) {
        return c[i][j];
    }
    int len = 0;
    if (i>0 && j>0) {
        if (x[i-1] == y[j-1]) {
            len = lcs_length_top_down(x, y, i-1, j-1) +1;
        } else {
            len = std::max(lcs_length_top_down(x, y, i, j-1),
                           lcs_length_top_down(x, y, i-1, j));
        }
    }
    c[i][j] = len;
    return len;
}
```

自底向上方法

```c++
int lcs_length_bottom_up(char* x, char* y, int m, int n)
{
    int i, j;
    for (i = 1; i <= m; ++i) {
        for (j = 1; j <= n; ++j) {
            if (x[i-1] == y[j-1]) {
                c[i][j] = c[i-1][j-1] + 1;
            }else if (c[i-1][j] >= c[i][j-1]){
                c[i][j] = c[i-1][j];
            }else{
                c[i][j] = c[i][j-1];
            }
        }
    }
    return c[m][n];
}
```

## 0-1背包问题

有n个物品，重量为$w_0\cdots w_i \cdots w_n$，价值为$v_0\cdots v_i \cdots v_n$，要求把物品装入承重量为 w 的背包，并使背包内物品总价值最大。[^01knapsack]

用m[i,w]表示背包内物品总价值，其中i表示装到第i件物品，w表示背包当前物品重量。考虑如下子问题，当装到物品i时，有几种情况：

- 如果背包承重为0或没有物品时，背包内物品总价值显然为0。
- 当该物品重量大于背包总承重，直接跳过。
- 当该物品重量小于背包总承重，那么尝试装入。如果装不下则换出其他物品，看看是否总价值更高；否则保持原状态。

$$
m[i][w] =
\begin{cases}
0 & \mbox{ if } i=0 \mbox{ or } w=0 \\
m[i-1][w]  & \mbox{ if } w_i > w \\
\max(m[i-1][w], c[i-1][w-w_i] + v_i) & \mbox{ if } w_i \leq w
\end{cases}
$$


## 连续子数组最大和

X是长度为n的整数数组，求连续子数组  $X[i],\dots,X[j]$  使得  $\sum_{k=i}^j{X[k]}$ 最大。

这个问题的解法和求解LIS第二种办法类似，用p[i]表示以X[i]结尾的最大子数组的和，则

$$
p[i] =
\begin{cases}
X[i] & \mbox{ if } i=0 \mbox{ or } p[i-1] \leq 0 \\\\
X[i] + p[i-1] & \mbox{ if } i > 0 \mbox{ and } p[i-1] > 0
\end{cases}
$$

同时，使用辅助数组L保存以X[i]结尾的最大子数组的长度。

$$
L[i] =
\begin{cases}
1 & \mbox{ if } i=0 \mbox{ or } p[i-1] \leq 0 \\\\
1 + L[i-1] & \mbox{ if } i > 0 \mbox{ and } p[i-1] > 0
\end{cases}
$$

算法时间复杂度O(n)。

## 最大子矩阵

A是`m*n`的矩阵，求和最大子矩阵。*矩阵的和* 定义为矩阵中所有元素的和。

我们知道，子矩阵可以通过4个数字来定义，用[i,m][j,n]表示 从第i行到第j行、从m列到第n列 的子矩阵，左上角的坐标为[i,m]，右下角的坐标为[j,n]，对应的矩阵和用S[i,m][j,n]表示。最直接的方法就是求出所有的子矩阵和。

$$
S[i,m][j,n] = S[0,0][m,n] - S[0,0][i,j]
$$

算法时间复杂度为O(n<sup>4</sup>)。

可以使用子数组最大和来降低复杂度。把第i行到第j行每一列的值相加，得到一个一维数组，然后使用 *子数组最大和* 的方法求解。这样算法复杂度降低到O(n<sup>3</sup>)。

## 最优二叉搜索树

## 装配线调度

## 矩阵链接乘法

[^01knapsack]: [01背包问题](https://en.wikipedia.org/wiki/Knapsack_problem#0.2F1_knapsack_problem)
