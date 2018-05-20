---
title: 在Web页上播放视频
tags: Web Programming
---

如果想要在web上嵌入视频播放，也就是通过各种浏览器来看视频，我觉得HTML5已经是大势所趋。至少从码农的角度来看是个相对完美的方案，在以前浏览器对视频的支持没有标准，所以往常在浏览器上看到的视频并非由浏览器驱动，而是由一堆混乱的第三方插件来支持的，比如flash、realplayer、quicktime等等解决方案。所以，我们经常看到视频边框有各家的标识，常常你没有安装某个插件，视频就播放不了，这对用户就很不友好了。但现在由于移动端的开拓，教主直接拍死了flash，HTML5给出了视频标准（统一的`<video>`标签），同时各大主流浏览器也争先恐后的开始支持HTML5，种种合力给web视频播放推向一个好的未来。我们从各大视频网站youtube、youku对移动设备的支持就可以看出来。 然而，如果我们想把一段视频放到网站，或者说你想开发另一个youtube（当然是不可能的），整个流程该怎么做呢？本文很多内容学习自[Dive into html5](http://diveintohtml5.info/video.html)视频这一章，感兴趣的也可自行翻阅。

## 视频

两个概念：container 和 codec

### 容器(container)

我们经常听人说视频是avi格式或者mp4格式，但其实avi或者mp4只是一种视频容器格式，并非视频编码格式。就像zip一样，容器可以包含各种文件，可以是视频，也可以是音频，它只是定义*怎样存储*数据，而不定义数据的格式。一个视频文件（或者说一个容器）一般包含多个track：一个视频track 和 一到多个音轨。具体track内容由各自视频和音频编码格式确定。

我们常见的容器有这些：

- [MPEG 4](http://en.wikipedia.org/wiki/MPEG-4_Part_14) (.mp4, .m4v) 非常流行的格式，基于apple的QuickTime格式 (.mov)，移动设备流行后，我们熟悉的mp4就是属于这种格式。
- [Ogg](http://en.wikipedia.org/wiki/Ogg) (.ogv)  免费，强大，Firefox 3.5, Chrome 4和Opera 10.5都原生支持，Linux用户最爱的格式。
- [WebM](http://www.webmproject.org/) (.webm) 免费，为HTML5而生的格式，google主推。
- [Flash](http://en.wikipedia.org/wiki/Flash_Video) (.flv) 需要flash插件才能播放，这个我们最熟悉，也是之前各大视频站点支持的格式，同时获得MacOS用户最痛恨视频格式提名。值得一提的是，以前的flash插件只支持.flv格式，但现在也开始支持MPEG 4格式了。
- [avi](http://en.wikipedia.org/wiki/AVI) (.avi) 一种比较老的格式，最早由微软制定，但由于格式很老很简陋，导致很多厂商借助这个瓶子增加各种不兼容的功能，所以这个格式的文件可能我们看到很多，但有的文件能够播放，有的却不能播放。
- [asf](http://en.wikipedia.org/wiki/Advanced_Systems_Format) (.asf) 同样由微软发明的格式，增加了DRM，说白了就是看这种视频需要授权，幸好这种格式我们基本也看不见了。


### 视频编码(video codec)

通常我们看视频，视频播放一般是这个步骤：

1. 解析视频文件的容器格式，找到视频track和音轨；
2. 解码视频track，把一系列的图片显示到显示器上；
3. 解析音频track，包括用于同步的标识，把声音输出到音响上。

所谓视频编码就是应用在第二个步骤中，是一套把视频流转换到数据的编码算法。视频播放器根据视频流的编码格式解码到视频帧，然后逐帧输出。

常见的视频编码格式有：

-   [H.264](http://en.wikipedia.org/wiki/H.264) 即 MPEG-4 part 10，需要授权使用。可以嵌入各种容器，包括.mp4、.mkv（我们熟悉的各种0day视频）等。H.264解码一般都有硬件支持；其中x264是H.264编码的开源软件实现。H.264一套标准有多种profile适用于不同平台：
    -   Baseline Profile 适用于iPhone之类的移动设备，手机上的H.264一般都是硬件codec
    -   Main Profile 适用于Apple TV之类的播放器设备
    -   High Profile 适用于PC，比如Flash插件、Blu-Ray等
-   [Theora](http://en.wikipedia.org/wiki/Theora) 源自[VP3](http://en.wikipedia.org/wiki/Theora#History)格式，免费，可以嵌入各种容器，一般搭配.ogv使用。Firefox3.5+原生支持。
-   [VP8](http://en.wikipedia.org/wiki/VP8) 和Theora同源自VP3格式，免费，一般搭配webm使用。媲美H.264，相比H.264 Baseline解码更简单。

### 音频编码(audio codec)

音频有个区别于视频的概念：声道(channels)。比如，一般笔记本左右侧各有一音响，即对应了左右声道。音频编码可以把不同的音轨文件输出到不同的声道，即我们所熟悉的立体声。

常见的音频格式有：

- [MP3](http://en.wikipedia.org/wiki/MPEG-1_Audio_Layer_3) 最多两个声道，固定码率，最高320kbps。需要授权使用（所以Linux发行版默认不支持mp3播放）。mp3可以搭配任何容器使用。
- [ACC](http://en.wikipedia.org/wiki/Advanced_Audio_Coding) 最多48声道，编码类似H.264，也有多种profile支持。Apple iTunes Store里下载音乐所用的格式，常搭配mp4使用。
- [Vorbis](http://en.wikipedia.org/wiki/Vorbis) 不限声道。免费。常搭配 ogg 和 webm 使用，也可用于mp4、mkv等。

## 把视频放到网上

目前主流浏览器原生支持格式列表：

编码/容器          | IE | FIREFOX | SAFARI | CHROME | OPERA | IPHONE | ANDROID
------------------|----|---------|--------|--------|-------|--------|---------
Theora+Vorbis+Ogg |    | 3.5+    |        | 5.0+   | 10.5+ |        |
H.264+ACC+MP4     |9.0+|         | 3.0+   | 5.0+   |       | 3.0+   | 2.0+
WebM              |9.0+| 4.0+    |        | 6.0+   | 10.6+ |        | 2.3+

可以看出，没有一种视频格式被所有浏览器原生支持，所以如果你希望你的视频能被所有浏览器都支持，那么也许需要转换出多种视频格式。当然，如果你只想支持Chrome，那么你任选一种格式转换即可。

-   生成 Theora/Vorbis/Ogg 格式：

        $ ffmpeg2theora --videobitrate 200 --max_size 320x240 --output pr6.ogv pr6.dv

-   生成 H.264/AAC/MP4 格式

        $ HandBrakeCLI --preset "iPhone & iPod Touch" --vb 200 --width 320 --two-pass --turbo --optimize --input pr6.dv --output pr6.mp4

-   生成 VP8/Vorbis/WebM 格式

        $ ffmpeg -pass 1 -passlogfile pr6.dv -threads 16  -keyint_min 0 -g 250 -skip_threshold 0 -qmin 1 -qmax 51 -i pr6.dv -vcodec libvpx -b 204800 -s 320x240 -aspect 4:3 -an -f webm -y NUL
        $ ffmpeg -pass 2 -passlogfile pr6.dv -threads 16  -keyint_min 0 -g 250 -skip_threshold 0 -qmin 1 -qmax 51 -i pr6.dv -vcodec libvpx -b 204800 -s 320x240 -aspect 4:3 -acodec libvorbis -ac 2 -y pr6.webm

然后，在网页里插入如下代码即可，借用了[flowplayer](http://flowplayer.org/)首页视频：

    <video controls>
      <source src="http://stream.flowplayer.org/bauhaus/624x260.webm" type="video/webm; codecs=vp8,vorbis" />
      <source src="http://stream.flowplayer.org/bauhaus/624x260.ogv" type="video/ogg; codecs=theora,vorbis" />
      <source src="http://stream.flowplayer.org/bauhaus/624x260.mp4" type="video/mp4" />
      <!-- flash failback begin -->
      <object type="application/x-shockwave-flash" data="http://releases.flowplayer.org/swf/flowplayer-3.2.16.swf">
        <param name="movie" value="http://releases.flowplayer.org/swf/flowplayer-3.2.16.swf" />
        <param name="allowfullscreen" value="true" />
        <param name="flashvars" value="config={'clip': {'url': 'http://stream.flowplayer.org/bauhaus/624x260.mp4', 'autoPlay':false, 'autoBuffering':true}}" />
        <p>Download video as <a href="http://stream.flowplayer.org/bauhaus/624x260.mp4">MP4</a>, <a href="http://stream.flowplayer.org/bauhaus/624x260.webm">WebM</a>, or <a href="http://stream.flowplayer.org/bauhaus/624x260.ogv">Ogg</a>.</p>
      </object>
      <!-- flash failback end -->
    </video>

这里之所以还添加了一个flash播放器，也是因为兼容性考虑，希望覆盖到所有的浏览器，哪怕是ie6，使用flash播放器作为后备。推荐播放器[flow player](http://flowplayer.org/)、[jw flv player](http://longtailvideo.com/players/jw-flv-player/)。

上面示例代码的效果：

<video controls>
  <source src="http://stream.flowplayer.org/bauhaus/624x260.webm" type="video/webm; codecs=vp8,vorbis" />
  <source src="http://stream.flowplayer.org/bauhaus/624x260.ogv" type="video/ogg; codecs=theora,vorbis" />
  <source src="http://stream.flowplayer.org/bauhaus/624x260.mp4" type="video/mp4" />
  <object type="application/x-shockwave-flash" data="http://releases.flowplayer.org/swf/flowplayer-3.2.16.swf">
    <param name="movie" value="http://releases.flowplayer.org/swf/flowplayer-3.2.16.swf" />
    <param name="allowfullscreen" value="true" />
    <param name="flashvars" value="config={'clip': {'url': 'http://stream.flowplayer.org/bauhaus/624x260.mp4', 'autoPlay':false, 'autoBuffering':true}}" />
    <p>Download video as <a href="http://stream.flowplayer.org/bauhaus/624x260.mp4">MP4</a>, <a href="http://stream.flowplayer.org/bauhaus/624x260.webm">WebM</a>, or <a href="http://stream.flowplayer.org/bauhaus/624x260.ogv">Ogg</a>.</p>
  </object>
</video>

### 快速播放

对于mp4格式，如果希望支持faststart和pseudo-streaming，就是还没有下载完成就可以随意定位到某个位置开始播放，则会相对复杂一些，需要两部分都支持：视频格式 和 Web服务器。[^1]

- 对于mp4视频格式，有一个MOOV帧记录该视频里视频流和音频流的metadata，需要把MOOV放到该视频的开头，该索引信息首先被解码器读到，才能支持pseudo-streaming。如果MOOV在视频结尾，可以使用 [mp4box](http://gpac.wp.mines-telecom.fr/mp4box/) 或者 [qtfaststart](https://github.com/danielgtaylor/qtfaststart) 这样的工具进行修复。
- 需要为apache或nginx安装[H.264 streaming module](http://h264.code-shop.com/trac/wiki)，才能在浏览器上任意拖动未下载完成的视频进度（即所谓pseudo-streaming）。

## 参考

- [Dive into HTML5: video on the web](http://diveintohtml5.info/video.html)
- [Video for everyone](http://camendesign.com/code/video_for_everybody)
- [All tutorials related to S3 Amazon and cloudFront with emphasis on video and audio](http://www.miracletutorials.com/category/s3-amazon-cloudfront/)


[^1]: [Creating MP4 videos ready for HTTP streaming](http://superuser.com/questions/438390/creatingmp4-videos-ready-forhttp-streaming)
