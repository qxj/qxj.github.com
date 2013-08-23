---
title: 防止音乐被盗链
tags: php Web
---

因为翻看日志的时候发现有很多音乐的referer是从其他网站来的，并且给服务器造成了很大的负担，但是想要重新编写个音乐的上载系统的话，对于那些已经发布出去的链接又会造成太多麻烦，所以想到了下边的方法：

1、采用url rewrite，这个本来在apache上是很容易做的。然而可怜服务器要是用的iis，就得采用helicon的一个[小软件](http://www.helicontech.com/download/)，对于mp3的文件链接重定向，需要加上如下一行。当然，对于你想保护的其他文件可以如法炮制：

    RewriteRule (.*)\.(mp3) /mp3.php\?m=$1 [I,L]

2、写出mp3.php这个用来检查referer的文件，如下：

```php
<?php
//getaudio.php
$m=$_GET[m];
if(strpos($m,"/mp3")!=0 || strlen($m)>30){
    header("location:http://www.site.com");
    exit;
}
header("Content-type: audio/mpeg");
header("Content-disposition:inline; filename=broadcast.mp3");
@readfile("d:/yourmp3directory".$m.".mp3");
exit;
?>
```

因为url若是以mp3结尾，将还会跳转到该检查页面，所以最后把地址作为一个参数，传给getaudio.php，再获取mp3。另外mp3.php文件，将采用streaming方式播出mp3，而不到客户端再缓冲。下边看看取出mp3的脚本：

3、getaudio.php通过传过来的参数获取mp3，交给mp3.php，代码如下：

```php
<?php
//mp3.php
if(strpos($_SERVER[HTTP_REFERER],"site.com")===false){
    $url="http://www.site.com";
    echo "[script]location.href=$url[script]";
    exit;
}else{
    $url=$_GET[m];
    $addr="http://www.site.com";
    if(strlen($url)>40){
        header("location:http://www.site.com");
        exit;
    }
    Header("Content-type: audio/x-mpegurl");
    header("Content-disposition:inline; filename=site.com.m3u");
    printf("#EXTM3U\n");
    echo("#EXTINF:0, site.com\n".$addr."/getaudio.php?m=$url"."\n");
}
?>
```

4、好了，重启web服务，mission accomplished！
