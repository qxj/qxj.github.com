---
title: 回溯法
tags: algorithm
---

[TOC]

回溯法的本质应该是暴力求解法(brute-force)，它可以系统搜索问题的所有解或任一解。它在问题的解空间树中，按照DFS策略，从根节点出发搜索解空间。

当需要求所有解时，要回溯到根，且根节点所有子树都搜索完后才结束；而求任一解时，只要搜索到问题的一个解就可以结束。

回溯法适用于求解组合数比较大的问题。

回溯法的关键在于找出问题的解空间树，然后构造出 DFS *递归* 或 *迭代* 逻辑。

回溯法搜索解空间树的时候，通常有两种策略来避免无效搜索，即 *剪枝函数*：

1. 约束函数：在扩展节点处剪去不满足约束的子树，
2. 限界函数：剪去不能得到最优解的子树。

回溯法通常的步骤：

1. 针对所给问题，定义问题的解空间，
2. 确定易于搜索的解空间结构，
3. 以深度优先的方式搜索解空间树，并在搜索过程中利用剪枝函数避免无效搜索。

## DFS递归

回溯法的递归伪代码描述：

    void backtrack(int t)
    {
        if(t > n) output(x);
        else
            for (int i = f(n,t); i <= g(n,t); ++i) {
                x[t] = h(i);
                if(constraint(t) && bound(t)) backtrack(t+1);
            }
    }

其中，

- 参数 `t` 表示递归深度，即当前扩展节点在解空间树中的深度，
- `n` 解空间树的高度，当 t>n 时，表示已搜索到一个叶节点，
- `output(x)` 打印可行解，
- `f(n,t)` 和 `g(n,t)` 分别表示当前扩展节点处子树的起止编号，
- `h(i)` 表示当前扩展节点处 `x[t]` 的第i个可选值，
- `constraint(t)` 和 `bound(t)` 分别为约束函数和限界函数，用于剪枝。

## DFS迭代

回溯法的迭代伪代码描述：

    void iterative_backtrack()
    {
        int t = 1;
        while (t > 0) {
            if (f(n,t) <= g(n,t)) {
                for (int i = f(n,t); i <= g(n, t); ++i) {
                    x[t] = h(i);
                    if (constraint(t) && bound(t)) {
                        if (solution(t)) output(x);
                        else ++t;
                    }
                }
            } else {
                --t;
            }
        }
    }

其中，

-  `solution(t)` 判断当前扩展节点处是否已得到一个可行解。

## 常见回溯问题
### 排列问题

常见问题描述：

> 求字符集合的所有排列。

思路：我们以三个字符abc为例来分析一下求字符串排列的过程。首先固定第一个字符a，求后面两个字符bc的排列。当两个字符bc的排列求好之后，我们把第一个字符a和后面的b交换，得到bac，接着我们固定第一个字符b，求后面两个字符ac的排列。现在是把c放到第一位置的时候了。记住前面我们已经把原先的第一个字符a和后面的b做了交换，为了保证这次c仍然是和原先处在第一位置的a交换，我们在拿c和第一个字符交换之前，先要把b和a交换回来。在交换b和a之后，再拿c和处在第一位置的a进行交换，得到cba。我们再次固定第一个字符c，求后面两个字符b、a的排列。

既然我们已经知道怎么求三个字符的排列，那么固定第一个字符之后求后面两个字符的排列，就是典型的递归思路了。

回溯法处理排列问题的伪代码描述：

    void backtrack(int t)
    {
        if (t > n) output(x);
        else
            for (int i = f(n,t); i <= g(n,t); ++i) {
                swap(x[t], x[i]);
                if (constraint(t) && bound(t)) backtrack(t+1);
                swap(x[t], x[i]);
            }
    }

实现示例：

    // 打印字符串排列，S是输入字符串，pos是开始排列的字符位置
    void permutation(std::vector<char>& S, int pos = 0)
    {
        if (pos == S.size()) {
            std::copy(S.begin(), S.end(), std::ostream_iterator<char>(std::cout, " "));
            std::cout << "\n";
        } else {
            for (int i = pos; i < S.size(); ++i) {
                std::swap(S[i], S[pos]);
                permutation(S, pos + 1);
                std::swap(S[i], S[pos]);
            }
        }
    }

### 组合问题

常见问题描述：

> 求字符集合的m种组合。

思路：字符集合可以用一个长度为n的无重复字符的字符串表示。我们从头扫描字符串的第一个字符。针对第一个字符，有两种选择：一是把这个字符放到组合中去，接下来我们需要在剩下的n-1个字符中选取m-1个字符；二是不把这个字符放到组合中去，接下来我们需要在剩下的n-1个字符中选择m个字符。同样用递归的思路解决这个问题。

    void combination(const std::vector<char>& S, std::vector<char>& output, int m, int pos = 0)
    {
        if (m == 0) {
            std::copy(output.begin(), output.end(), std::ostream_iterator<char>(std::cout, " "));
            std::cout << "\n";
            return;
        }

        if (pos == S.size()) return;

        output.push_back(S[pos]);
        combination(S, output, m - 1, pos + 1);
        output.pop_back();
        combination(S, output, m, pos + 1);
    }

### 子集和问题

常见子集和问题描述：

> 给定一个正整数集合A和正整数S，求A所有可能的子集A'，其中A'中所有元素之和等于S。

    void backtrack(const std::vector<int>& A, std::vector<int>& X, int n, int S)
    {
        if (n == A.size() || S <= 0) {
            if(S == 0) output(A, X);
        } else {
            X[n] = 0;
            backtrack(A, X, n+1, S);
            X[n] = 1;
            backtrack(A, X, n+1, S-A[n]);
            X[n] = 0;
        }
    }
    void solve(std::vector<int>& A, int S)
    {
        std::vector<int> X(A.size(), 0);
        backtrack(A, X, 0, S);
    }

扩展一下A'的条件，使得：

> A' = {a<sub>1</sub>,...,a<sub>m</sub>}，满足 a<sub>1</sub>x<sub>1</sub>+...+a<sub>m</sub>x<sub>m</sub> = S，其中x<sub>i</sub>为非负整数，求所有可能的解向量X，其中X={x<sub>1</sub>,...,x<sub>m</sub>}，x<sub>i</sub>为非负整数。

    void backtrack(const std::vector<int>& A, std::vector<int>& X, int k, int S)
    {
        if (k == A.size() || 0 == S) {
            if (0 == S)  output(A, X);
        } else {
            for (; S >= 0; S -= A[k], X[k]++)
                backtrack(A, X, k+1, S);
            X[k] = 0;
        }
    }
    void solve(const std::vector<int>& A, int S)
    {
        std::vector<int> X(A.size(), 0);
        backtrack(A, X, 0, S);
    }

注：此时解空间树从二叉树变成了一棵多叉树。

### 8皇后问题

8皇后的一个关键是确定约束函数，即如何判断某个位置是否可以放置一个皇后。

由于是在棋盘上，考虑利用坐标系解决：如果给这个8*8的矩阵上个坐标，横向(rows)为i = 0 to 7，纵向(columns)为j = 0 to 7。那么可以发现，在每一条斜线(/)方向上，每一个格子的横纵坐标之和(i + j)是一个固定值，从左上到右下的斜线，其值依次是0~14 (0+0; 0+1,1+0; 0+2,1+1,2+0; ... ; 6+7,7+6; 7+7)；同样地，在每一条反斜线(\)方向上，每一个格子的横坐标与纵坐标的关系 (i + (7 - j)) 也是固定值，从右上到左下的斜线，其值依次是0~14。

所以，可以得到这样的代码：

    #include <stdio.h>
    #include <stdlib.h>
    #include <string.h>

    #define N 8

    int count;
    int rows[N],    cols[N],    slash[2 * N - 1], bslash[2 * N - 1];
    // 每行放的位置，纵向不可放，斜向不可放(/)，斜向不可放(\)

    void place(int i)
    {
        int j;
        for (j = 0; j < N; ++j) {
            if (cols[j] == 0 && slash[i + j] == 0 && bslash[i + (N-1) - j] == 0) {
                rows[i] = j;

                cols[j] = 1;
                slash[i + j] = 1;
                bslash[i + (N-1) - j] = 1;

                if (i == N - 1) {
                      /*
                       * int k;
                       * for (k = 0; k < N; ++k) {
                       *     printf("%d ", rows[k]);
                       * }
                       * printf("\n");
                       */
                    count++;
                } else {
                    place(i + 1);
                }

                cols[j] = 0;
                slash[i + j] = 0;
                bslash[i + (N-1) - j] = 0;
            }
        }
    }

    int main ()
    {
        memset(rows, 0, sizeof(rows));
        memset(cols, 0, sizeof(cols));
        memset(slash, 0, sizeof(slash));
        memset(bslash, 0, sizeof(bslash));

        count = 0;
        place(0);
        printf("count = %d\n", count);
        return 0;
    }
