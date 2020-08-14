---
title: 二叉树相关算法
tags: algorithm
---

[TOC]

二叉树节点的常见定义：

    typedef struct BTreeNode
    {
        DataType data;
        struct BTreeNode* pLeft;
        struct BTreeNode* pRight;
    } *BTreeNodePtr;

## 树的遍历
### DFS (Depth-first search)

深度优先遍历，按访问根节点、左子树和右子树的顺序，分为前序、中序和后序三种遍历方式。

    traversral(node)
        // visit(node.value) // first-order
        if node.left  != null then traversral(node.left)
        // visit(node.value) // in-order
        if node.right != null then traversral(node.right))
        // visit(node.value) // post-order

### BFS (Breadth-first search)

广度优先遍历，前序遍历搭配`std::queue`的实现：

    void level_order_traversal(BTreeNode *root)
    {
        if(!root) return;

        std::deque<BTreeNode*> queue;

        // insert the root at the tail of queue
        queue.push_back(root);

        while(queue.size()) {
            // get a node from the head of queue
            BTreeNode *node = queue.front();
            queue.pop_front();

            visit(node);

            if(node->pLeft) queue.push_back(node->pLeft);
            if(node->pRight) queue.push_back(node->pRight);
        }
    }


## 常见问题

### 问题1

> 给出二叉树的两个节点，求它们的最低公共父节点。

思路1：所谓共同的父结点，就是两个结点都出现在这个结点的子树中。因此我们可以定义一函数，来判断一个结点的子树中是不是包含了另外一个结点。

    bool HasNode(BTreeNode* pHead, BTreeNode* pNode)
    {
        if(pHead == pNode)
            return true;
        bool has = false;
        if(pHead->pLeft != NULL)
            has = HasNode(pHead->pLeft, pNode);
        if(!has && pHead->pRight != NULL)
            has = HasNode(pHead->pRight, pNode);
        return has;
    }

然后，可以从根结点开始，判断以当前结点为根的树中左右子树是不是包含我们要找的两个结点。如果两个结点都出现在它的左子树中，那最低的共同父结点也出现在它的左子树中。如果两个结点都出现在它的右子树中，那最低的共同父结点也出现在它的右子树中。如果两个结点一个出现在左子树中，一个出现在右子树中，那当前的结点就是最低的共同父结点。

由于需要对每个节点调用HasNode，时间复杂度O(n^2)。

思路2：转化为求两个链表的相交节点问题。先得到两条先根遍历的路径，然后再求相交。时间复杂度O(n)，但需要额外两个链表的空间。

### 问题2

> 求二叉树中相距最远的两个节点间的距离。

### 问题3

> 求二叉树的深度。

思路：一颗树的深度是它左右子树深度的较大值再加1。

    int TreeDepth(BTreeNode *pNode)
    {
        if(!pNode) return 0;    // the depth of a empty tree is 0
        int nLeft = TreeDepth(pNode->pLeft);
        int nRight = TreeDepth(pNode->pRight);
        return (nLeft > nRight) ? (nLeft + 1) : (nRight + 1);
    }

### 问题4

> 两棵二叉树A和B，判断树B是不是A的子结构。

思路：可以分为两步，都可以递归解决。

1. 在树A中找到和B的根结点的值一样的结点N（遍历树A）
2. 判断树A中以N为根结点的子树是不是包括和树B一样的结构（遍历N子树，终止条件是A或B的叶节点，或有节点不等）

### 问题5

> 判断二叉树是否平衡。

思路1：根据定义，判断每棵子树的深度是否相差不超过1，时间复杂度O(n^2)。

思路2：当后序遍历的时候，在遍历到一个节点之前，我们已经遍历了它的左右子树；因此，只要我们在遍历每个节点时，记录它的深度，其实是可以一边遍历，一遍判断以此节点为根节点的子树是否平衡。

    bool IsBalanced(BTreeNode* pRoot, int* pDepth)
    {
        if(pRoot == NULL) {
            *pDepth = 0;
            return true;
        }
        int left, right;
        if(IsBalanced(pRoot->pLeft, &left) && IsBalanced(pRoot->pRight, &right)) {
            int diff = left - right;
            if(diff <= 1 && diff >= -1) {
                *pDepth = 1 + (left > right ? left : right);
                return true;
            }
        }
        return false;
    }

### 问题6

> 求二叉树的镜像。

思路：在遍历二元查找树时每访问到一个结点，交换它的左右子树。这种思路用递归不难实现，将遍历二元查找树的代码稍作修改就可以了。

    void MirrorRecursively(BTreeNode *pNode)
    {
        if(!pNode) return;

        // swap the right and left child sub-tree
        BTreeNode *pTemp = pNode->pLeft;
        pNode->pLeft = pNode->pRight;
        pNode->pRight = pTemp;

        // mirror left child sub-tree if not null
        if(pNode->pLeft)
            MirrorRecursively(pNode->pLeft);

        // mirror right child sub-tree if not null
        if(pNode->m_pRight)
            MirrorRecursively(pNode->pRight);
    }

### 问题7

> 把二元查找树转变成排序的双向链表。

思路1：当我们到达某一结点准备调整以该结点为根结点的子树时，先调整其左子树将左子树转换成一个排好序的左子链表，再调整其右子树转换右子链表。最近链接左子链表的最右结点（左子树的最大结点）、当前结点和右子链表的最左结点（右子树的最小结点）。从树的根结点开始递归调整所有结点。

思路2：我们可以中序遍历整棵树。按照这个方式遍历树，比较小的结点先访问。如果我们每访问一个结点，假设之前访问过的结点已经调整成一个排序双向链表，我们再把调整当前结点的指针将其链接到链表的末尾。当所有结点都访问过之后，整棵树也就转换成一个排序双向链表了。

### 问题8

> 根据二叉树的前序遍历和中序遍历重建二叉树。

思路：由前序遍历顺序为“根->左->右”、中序遍历为“左->根->右”可知前序遍历的第一个结点肯定为根结点，根结点在中序遍历中将该二叉树分为左右两颗子树。再对两颗子树分别递归求解即可。如前序遍历序列为“ABDGCEF”，中序遍历序列为“DGBAECF”，先找到根A，然后将该二叉树分为DGB和ECF两颗子树；由前序遍历序列BDG知B为根，可知DG为左子树，右子树为空；又由前序遍历序列DG知D为根，则G为右孩子；同理可将A的右子树恢复。

### 问题9

> 判断两个二叉树是否相等。

思路：同时递归遍历两个子树，判断是否所有的节点内容都相等。
