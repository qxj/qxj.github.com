---
title: 关于域名注册的事情
tags: 随笔
---

最近因为想要注册个域名来写个人blog，所以接触到一些域名注册的事情。发现了很多自己以前不知道的新鲜内容，拿出来与大家分享一下。我概念里边的域名注册，无非就是自己去一些域名注册商，比如国内的万网、网际互联之类的地方搜索一下自己想要的域名，如果有的话就注册(估计这种情况基本不会发生 :P)；没有就只能选感觉次点的域名，大抵如此。

大家都知道好域名也是稀缺资源，所以事实上也没有这么简单，听说了不少域名卖出天价的事例，必然有很多人也希望靠抢注域名来发财，这跟恶意抢注@live.com之类的思想是一致的，最近水木还风传某某帐号卖￥3000之类的。所以伴随域名注册服务的还有过期域名预定服务(backorder)、域名拍卖、域名过户交易等服务，下边主要说一下.cn域名的情况。

现在的好域名基本已经绝迹了，比如三位数的.com/.cn早已不存在了，所以一旦有这样有潜在价值的域名过期(pendingDelete)的话，基本会被国内某些服务商保留的(clientTransferProhibited)，绝对不会流失出来让普通用户注册掉；因为一个域名一年的费用不过几十块钱而已，前段时间.cn域名甚至免费或者￥1。因此，基本不要期望还可以从国内的域名注册商对外提供的注册页面里注册到短域名了。另外，有些不良的域名注册商会记录你的查询结果，结果你可以想象到的 :) 最好去一些正规的whois服务器去查询域名，比如whois.net或直接用whois命令。

因为资源稀缺，所以在域名注册之外有了过期域名预定服务。一般域名过期之后，在根服务器上会保留一段时间，此时的状态为pendingDelete。其中.com这样的国际域名会保留75天，而.cn域名只会保留15天(精确时间，不会多一天也不可能少一天)；在每天的凌晨4:30，将会删除过期15天，而没有续费或者保留的.cn域名。因此这就产生了一项域名预定服务，被删除的cn域名一般就会在凌晨4:30被国内的[易名中国](http://ename.cn)、[万网](http://www.net.cn)和[66.cn](http://66.cn)抢注掉，然后放到网站去拍卖或者竞价。因此如果你想注册一个好域名，就只能去这些网站注册一个会员，比如易名中国，在你的账户中注入￥50，然后在域名删除的前三天去预定该域名；如果运气不错，直到域名被删除原注册商也没有续费保留，并且刚好被你注册的易名中国抢注成功的话，那么你就有了竞价该域名的资格，这算完成了第一步；如果好多人都预定了这个域名，那么该域名将进行拍卖，你们中出价最高的人才有资格获得该域名。最好的情况就是，刚好没有人跟你争，这样你只需要花￥50就能获得你想要的域名啦。

如果这样你也没能获得你中意的域名，那么可能你还有个希望，就是跟该域名的持有者联系，看看能不能进行域名交易，万网也会做这样的中介代理。当然，唯一你应该做好的就是准备好你的money，然后祈祷对方别要价太高  :) 所以总结来说，一个没有钱的普通学生想注册到一个好域名，那基本蛮难的。

好了，介绍了这么多，下边说一些操作步骤。如果你要注册cn域名，可以去cnnic这个cn域名管理组织查询最近过期和删除的域名信息，对于国际com域名，另外有公布机构和web信息。如果你会每天花一点时间来搜索域名的话，那么我提供两个粗劣的脚本，可能会对你有所帮助。

这个是用来检索最近过期或者删除的4位cn域名的脚本，会在运行目录新建一个domain目录，然后把结果汇聚到a.txt文件中：

```bash
#!/bin/sh

if [ -e "./domain" ]; then rm -rf ./domain; fi

mkdir domain;

wget -q http://www.cnnic.cn/download/registar_list/pendingDel.txt -O domain/pendingDel.txt
wget -q http://www.cnnic.cn/download/registar_list/1todayDel.txt -O domain/1todayDel.txt
wget -q http://www.cnnic.cn/download/registar_list/2todayDel.txt -O domain/2todayDel.txt
wget -q http://www.cnnic.cn/download/registar_list/3todayDel.txt -O domain/3todayDel.txt
wget -q http://www.cnnic.cn/download/registar_list/future1todayDel.txt -O domain/future1todayDel.txt
wget -q http://www.cnnic.cn/download/registar_list/future2todayDel.txt -O domain/future2todayDel.txt

egrep -h '^[^\.]{1,5}\.[^\.]+$' domain/* | sort > a.txt;
echo "Done!";
```

这个是用whois命令来查询域名信息，域名以行分隔保存在b.txt文件中：

```perl
#!/usr/bin/perl

my $res;
my $dom;
open FILE, "./b.txt" or die("Open File Error!");
print "begin whois ...\n";
while(<FILE>){
    chomp;
    $dom = $_;
    print $dom,": ";
    if(/([\w\d]+)\.(cn|com)/i){
        $res=`whois $dom`;
        if($res =~ /Expiration\s+Date:(.+)/){
            print $1;
        }
        sleep 10;
    }
    print "\n";
}
close FILE;
print "\n";
```

最后，我推荐几个个人觉得不错的域名注册商，国内的比如 [中易网天](http://www.cesky.com.cn)和 [买域名](http://maiyuming.cn/)，这俩都是清华北大学生创业搞的，我在上边交易过几个域名，价格厚道，基本信誉还是有保障的。国外的我推荐 [GoDaddy](http://www.godaddy.com), 这上边我也买过好几个域名，注册之后常常有一些rebate代码发送到你信箱，你可以用这些代码购买域名，有时候甚至有30%的折扣；该服务商比国内的域名注册商服务更完备，域名后台管理功能强大；此外，可以transfer/backorder，重要的是可以注册各种域名，比如 .de/.at/.us/.be/.ms/.ws/.cc 等等，甚至 .cn 都可以注册。
