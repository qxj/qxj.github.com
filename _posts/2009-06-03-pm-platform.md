---
title: 小型软件项目开发管理平台Trac
tags: 技术 工具
---

## 介绍
一个软件项目的开发一般包括文档管理、代码管理、版本管理、进度管理、bug管理等，这方面的支持工具也很多。我觉得Trac是一个很优秀的代表，用它搭配SVN作为前端工作，差不多可以把这些任务都顺利解决了。Trac有如下一些特点：

### ticket
Trac利用ticket的概念，把feature提交、task分配以及bug管理很完美的整合到了一起。

- 可以设置ticket的优先
- ticket和roadmap结合，并且能够图形化显示项目进度
- 自定义条件生成bug报告

### wiki
wiki功能贯穿在整个工具里，可以很方便的组织说明文档。同时增加了许多bug管理的专用标记，能方便的创建到ticket、代码行甚至修改历史的链接。

### subversion
Trac可以作为subversion的前端，和svn搭配得很好。比如可以在timeline中看到所有的提交记录，可以在source view里方便的对比历史版本，并且具备语法高亮。

## 部署
Trac是基于python的，安装它之前需要python、apache、subversion、openssh、sqlite、swig等一坨软件的支持。幸运的是，得益于apt包管理系统，在ubuntu或者debian环境下搭建和配置这样一个管理平台也很容易，几行命令就可以搞定。

    aptitude install trac apache2 subversion python swig
    aptitude install mod_python python-clearsilver libapache2-svn

就是这么简单，如果在fedora、centos之类就要费点劲了。（建议安装trac-0.11.x 之后的版本，因为其中的admin模块会比较好用）

## 配置
接下来就是配置trac系统，我觉得其中的权限设置可以有一些技巧。首先，对于开发人员，最好使用独立的组，比如 `devteam`，比如我的帐号和组分别就是 `julian:devteam`。

### 配置subversion
这样在为svn创建独立用户的时候，也可以把该svn用户归到devteam中；当然其中svnroot可以不用重设密码，如果不打算登录该用户的话。

    # groupadd devteam
    # useradd svnroot -g devteam -s /usr/sbin/nologin
    # passwd svnroot

在home目录下为svn开辟一个目录，用来放置代码仓库。然后，创建代码仓库，比如 test，默认为 fsfs 文件格式。

    # mkdir -p /home/svnroot/
    # svnadmin create /home/svnroot/test
    # chown -R svnroot:devteam /home/svnroot
    # chmod -R g+w /home/svnroot/test
    # chmod g+s /home/svnroot/test/db

### HTTP方式的配置
这一步为可选。如果你期望通过DAV模块，以HTTP方式管理代码的话（比如[google code](http://code.google.com)提供的svn服务），可以在apache下添加如下站点设置：

    # cat > /etc/apache2/sites-available/svn

然后添加如下内容：

    ### svn settings
    #
    <Location /svn>
        DAV svn
        SVNListParentPath on
        SVNParentPath /home/svnroot
        AuthType Basic
        AuthName "Subversion Repository"
        AuthUserFile /etc/apache2/svntrac.htpasswd
        <LimitExcept GET PROPFIND OPTIONS REPORT>
            Require valid-user
        </LimitExcept>
    </Location>

一些说明：

- `SVNListParentPath on`  允许在网页上显示svn父目录list
- `SVNParentPath /home/svnroot` SVN的父目录
- `AuthType Basic` 连接类型设置
- `LimitExcept` 匿名用户可以浏览，check out代码，但是不能commit，认证用户有commit权限

然后把这个新加的站点激活：

    # cd /etc/apache2/site-enabled
    # ln -s ../site-available/svn 001-svn

#### 为http方式添加svn用户和密码
使用htpasswd创建第一个svn用户，比如用户名为 julian （第一次创建需要 -c 参数）

    # htpasswd -c /etc/apache2/svntrac.htpasswd julian

#### 修改apache启动方式
为了让apache可以管理svn代码，需要apache进程对svn目录有读写权限，所以需要更改apache的启动用户组，比如也改成`svnroot:devteam`，或者至少组改成一致的。

    # vim /etc/apache2/envvars

修改其中的用户 `APACHE_RUN_USER` 和组 `APACHE_RUN_GROUP`，然后重启apache，尝试是否已经可以通过 http://localhost/svn 访问svn代码仓库。

### 仓库目录和项目导入
为了今后项目管理的更加方便，一个技巧是，不要直接导入项目代码，而是首先划分出三个目录 trunk、tags和branches，初始项目代码放在trunk目录下。

    # mkdir /tmp/svn
    # cd /tmp/svn
    # mkdir {trunk,tags,branches}
    # svn import -m "my project init here" [path] http://localhost/svn/test

这就创建了第一个版本，在import之后可以用checkout命令测试一下，就该可以check out刚才import的代码了。

    svn co http://localhost/svn/test/trunk

### SVN+SSH方式的配置
另外有一种更加简单的办法来进行代码管理，这几乎完全不需要像HTTP那样的复杂配置。只要安装了subversion和sshd服务，就可以使用svn+ssh方式来管理代码。这个过程其实是你先连接到sshd服务器，然后sshd进程再调用svnserve进程来管理代码。例如，你要check out代码，就可以这样：

    svn co svn+ssh://svn_server/home/svnroot/test/trunk

这种方式和HTTP的主要差别有这样两点：

- 需要说明代码仓库所在的全路径，而不是http dav方式的虚拟地址
- 这种方式首先需要开发成员有ssh的权限，所以需要在主机上有一个对应的真实用户，而不像http dav方式使用htpasswd来管理的虚拟用户


另外，如果sshd不是标准的22端口时候，有两种解决办法，一是在 `~/.ssh/config` 文件中配置好端口，比如：

    Hostname svn_server
    Port 2022
    ForwardAgent no
    ForwardX11 no

或者是通过环境变量解决：

    $ env SVN_SSH='ssh -p 2022" svn co svn+ssh://svn_server/home/svnroot/test/trunk

### 配置Trac
#### 创建Trac项目
使用 trac-admin 命令可以初始化一个trac项目，一个 trac 项目对应一个 SVN  repository。同样，可以在home目录下为trac建立对应的目录。

    # mkdir /home/trac
    # trac-admin /home/trac/test initenv

然后按提示输入，一般只需要修改仓库路径，比如改为 `/home/svnroot/test`

#### 集成apache服务
Trac 有两种方式提供web服务，一是 trac 自带的 httpd 服务，二是集成到 apache 里面。

如果要用自带的 httpd，只需 `tracd --port 8000 /home/trac/test`，这种方式很简单，但 trac 本身就不建议这样启动。常用的应该是第二种方式.

首先确定你的 apache 配置 cgi-bin 的路径，比如`/usr/lib/cgi-bin/`，然后需要复制两个trac的cgi到该目录下：

    # cp /usr/share/trac/cgi-bin/trac.* /usr/lib/cgi-bin/

然后，你可以再新增加一个站点用于trac，比如：

    # cat > /etc/apache2/sites-available/trac

增加如下内容：

    Alias /trac/chrome/common "/usr/share/trac/htdocs"
    <Directory "/usr/share/trac/htdocs">
    Options Indexes MultiViews
    AllowOverride None
    Order allow,deny
    Allow from all
    </Directory>

    ScriptAlias /trac /usr/lib/cgi-bin/trac.cgi
    <Location "/trac">
    SetEnv TRAC_ENV_PARENT_DIR "/home/trac"
    </Location>

    <Location "/trac/*/login">
    AuthType Basic
    AuthName "Trac Login"
    AuthUserFile /etc/apache2/svntrac.htpasswd
    Require valid-user
    </Location>

同样在 site-enabled 中激活该站点，然后重启apache即可。访问 http://localhost/trac，应该可以看到项目列表。因为密码文件是和svn共享的，所以用svn的用户名登录即可。

### 权限管理
用户权限可以使用Trac中的Admin模块管理，也可以使用`trac-admin`命令管理，后者使用更加便捷。其中一个技巧是不要直接把权限划分到个人，而是先划分组权限，然后再把用户加入不同的组，这类似RBAC的管理方式，例如：

    # trac-admin /home/trac/test permission add devteam BROWSER_VIEW CHANGESET_VIEW CONFIG_VIEW FILE_VIEW LOG_VIEW MILESTONE_ADMIN REPORT_ADMIN ROADMAP_ADMIN ROADMAP_VIEW SEARCH_VIEW TICKET_ADMIN TIMELINE_VIEW WIKI_ADMIN
    # trac-admin /home/trac/test permission add lancer devteam

Trac中有默认的两个组 anonymous 和 authenticated，如果你不希望整个项目在互联网上公开，可以删除 anonymous 组，或者删除浏览权限 BROWSER_VIEW。

### 备份和恢复Trac

Trac系统的备份和恢复也可使用trac-admin工具来完成，还可支持热备份，例如：

    # trac-admin /home/trac/test hotcopy ~/backup

执行该命令时，Trac会自动锁住SQLite数据库，并把/home/trac/test目录拷贝到~/backup目录。恢复备份也很简单，只需停止Trac进程，如Apache服务器或tracd服务器。接着把~/backup整个目录恢复回/data/trac目录就可以了。

## 客户端
如果有喜欢使用IDE的，推荐这样的客户端搭配：eclipse + mylyn(trac) + subclipse

另外，在Windows下还有个很cool的客户端[TortoiseSVN](http://tortoisesvn.tigris.org/)，和资源管理器整合得很好。
