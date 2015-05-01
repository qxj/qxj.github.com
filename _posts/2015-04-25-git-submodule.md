---
title: Git submodule实战
tags: git
---

使用git管理的项目开发中，如果碰到公共库和基础工具，可以用submodule来管理。

## 常用操作

例如，

- 公共库是 `lib.git`，地址：`git@github.com:lib.git`；
- 需要使用公共库的项目是 `proj.git`，地址：`git@github.com:proj.git`。

### 添加

为项目`proj.git`添加submodule，先进到相应的目录下，然后执行如下命令：

    git submodule add git@github.com:lib.git <local path>

其中，`<local path>`是你期望的目录名。

该命令实际会做三件事情：首先，clone `lib.git`到本地；然后，创建一个 `.gitsubmodule` 文件标记submodule的具体信息；同时，更新`.git/config`文件，增加submodule的地址：

    [submodule "lib"]
        url = git@github.com:lib.git

### 删除

首先，需要删除 `.git/config` 和 `.gitsubmodle` 文件里submodule相关的部分，然后执行：

    git rm --cached <local path>

才能将submodule的相关文件从你的本地仓库里清理掉。

### 签出

如果要clone一个附带submodule的项目，submodule的文件不会自动随父项目clone出来（其实只会clone出 `.gitsubmodle` 这个描述文件），还需要执行如下命令取出submodule里的文件：

    git submodule init
    git submodule update

或者，一条组合命令（同样适用于嵌套submodule的情况）：

    git submodule update --init --recursive

### 修改/更新

可能稍微违反直觉的是，如果submodule有更新，默认在本地父项目里执行`git pull`是不会更新submodule的。因为执行`git submodule add xxx`的时候，只是把submodule的当前commit id加入到本地父项目的索引里，如果你期望submodule的commit id同步到最新HEAD，则你还需要重新执行`git add`然后重新提交。

此后，其他开发成员需要执行`git submodule update`更新你刚才的这个submodule commit。这里一个需要注意的地方是，每次在父项目执行`git pull`后，应该执行`git status`查看一下submodule是否有更新；如果submodule有更新，则应该立刻执行`git submodule update`，否则你有可能把submodule的旧依赖提交到仓库里去。一个建议是，尽量不要执行`git commit -a`，它会让你忽略对staged文件的确认过程。

## 实际案例演示

### 常见情况

给出一个在父项目 `proj.git` 里添加submodule项目 `lib.git` 并使用的示例：

_(用户A)_ 创建新的代码仓库：

    mkdir proj
    cd proj
    git init
    git add --all

_(用户A)_ 添加pdlib作为submodule：

    git submodule add git@github.com:lib.git
    git commit -m "first commit with submodule"
    git remote add origin git@github.com:proj.git
    git push origin master

_(用户B)_ 签出刚刚新建的代码仓库并使用：

    git clone git@github.com:proj.git
    cd foo
    git submodule update --init --recursive

_(用户B)_ 发现`lib.git`有修改，他把`proj.git`仓库的`lib.git`也同步到该版本：

    cd lib
    git pull
    git status        # 此时如果lib.git有修改，就可以看到not staged commit
    cd ..
    git add lib
    git commit -m "update lib.git"
    git push origin master

_(用户C)_ 更新`proj.git`仓库，同时也需要更新submodule：

    git pull origin master
    git status        # 记得执行git status，可以看到lib.git的改动
    git submodule update

### 修改lib.git

【注】这种情况下，需要清楚`lib.git`和`proj.git`实际就是两个独立的git仓库，针对`lib.git`的修改，需要在`lib`目录下commit。注意submodule*必须*是在master分支修改，如果`proj.git`在其他分支上开发，那么针对`lib`目录的修改需要先切回master分支。

_(用户D)_ 想直接在`proj.git`仓库里修改`lib`目录的内容：

    cd lib
    git checkout master  # 注意修改lib需要在master分支上
    edit xxx.txt
    git add xxx.txt
    git commit -m "update xxx.txt"
    git push origin master

_(用户D)_ 需要显式的把刚在`lib`目录上的修改添加到`proj.git`仓库里去：

    cd proj
    git status        # 每次在commit之前查看一下status是好习惯
    git add lib
    git commit -m "update lib.git"
    git push origin master

## 技巧

可以通过修改 `~/.gitconfig` 简化一些操作，比如每次`git pull`完自动执行`git submodule update`：

    [alias]
    psu = !git pull && git submodule update

这样，上面示例中用户C如下操作即可：

    git psu

## 参考

- [Git - git-submodule documention](http://git-scm.com/docs/git-submodule)
- [Git Submodules: Adding, Using, Removing, Updating](https://chrisjean.com/git-submodules-adding-using-removing-and-updating/)
