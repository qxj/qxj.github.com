---
title: DIY a Hackintosh
tags: Hack
---

前一台攒的ITX主机还是六年前配的H67平台i3-2100T，本来是打算做nas的，但后来选择群晖解决方案后，这台主机也基本废置了，只能偶尔办公或下载使用。最近突然迫切想搞台性能稍微高点的电脑，能运行macOS，能利用GPU跑跑程序，所以打算攒台新机器。除此之外偏好小巧点的机身，放在桌上或者脚底也不碍事。

# 硬件

## 机箱

因为想攒台小钢炮，所以需要先确定机箱。整个攒机基本花了大半时间在挑选机箱，主要关注MATX和ITX机箱，期望容量别超过20L；一定要窄点，宽度别超过200mm；能插长显卡；风道合理，散热良好。

前后选择的机箱有记录的如下：

机箱型号 | 主板规格 | 尺寸 | 电源规格 |散热器高度 | 显卡长度 | 价格 | 备注
----|---------|-----|---------|--------|---------|------|----
乔思伯UMX1P | ITX | 160x300x345 | ATX | 130 | 270 | 500¥ | 电源在右上死角
乔思伯UMX3 | MATX | 188x358x365 | ATX | 163 | 320 | 550¥ | 电源在右上死角
乔思伯RM2  | ATX | 209x302x341 | ATX | 95 | 290 | 300¥ |
乔思伯RM3 | MATX | 215x336x398 | ATX | 170 |300 | 600¥ | ★★★
乔思伯C2 |  MATX | 200x224x262 | ATX | 80 | 210 | 160¥  |
乔思伯C3 | MATX  | 211x287x369 | ATX | 175 | 275 | 300¥ |
乔思伯U1 | ITX   | 170x220x302 | SFX | 133 | 195 | 400¥ |
乔思伯U2 | ITX   | 208x233x319 | ATX | 175 | 220 | 300¥ |
乔思伯U3 | MATX  | 208x270x372 | ATX | 175 | 260 | 360¥ |
乔思伯U4 | ATX   | 205x340x428 | ATX | 170 | 310 | 400¥ | ★★★
乔思伯VR1| ITX   | 238x239x387 | ATX | 190 | 300 | | 主板接口朝上
联立PC-Q25 | ITX | 199x280x366 | ATX | 80 |  340 | 1000¥ |
联立PC-Q34 | ITX | 228x250x330 | ATX | 180 | 220 | 650¥ |
TT启航者S3 | | 182x375x375 | | | 295 | 200¥ |
金河田预见n6-plus | | 182x355x400 | | 153 | 355 | 140¥ |
普力魔P115EA | ITX | 165x280x345 | | 130 | 305 | 500¥ |
追风者PK217E | ITX | 174x270x470 | SFX | 82 | 350 | 900¥ |
银欣PS07 | ITX | 210x374x400 | ATX | | 300+ | 550¥ |
银欣ML07 | ITX | 105x350x382 | SFX | 83 | 330 | 500¥ |
银欣ML08 | ITX | 87x370x380  | SFX | 58 | 320 | 450¥ | 内部和RVZ2一样
银欣RVZ1 | ITX | 105x350x382 | SFX | 83 | 330 | 600¥ |
银欣RVZ2 | ITX | 87x370x380  | SFX | 58 | 320 | 500¥ |
银欣RVZ3 | ITX | 105x350x382 | ATX | 83 | 330 | 650¥ |
FD Node202 | ITX | 82x330x377  | SFX | 56  | 310 | 700¥ | 类似RVZ2
ABEE RS01  | ITX | 162x239x335 | SFX | 110 | 300 | 1500¥ | 建议公版显卡
[NCASE M1](https://www.sfflab.com/products/ncase_m1?variant=32790226825)   | ITX | 160x240x328 | SFX | 110 | 320 | 1600¥ | ★★★★★ 建议公版显卡

其实，一开始看到乔思伯U4机箱的三围挺满意的，虽然实际容量已经接近30L，但看起来和一般ITX机箱差不多大，而且能放入ATX主板，可以上塔式散热+超过300mm的显卡，前侧开了散热孔至少不完全是闷罐了，铝合金机身，价格还便宜。

不过就在快付款之际，发现了银欣小乌鸦系列，并最终选择了ML08B-H。之前没接触过这种类型的机箱，非常薄，但通过转接卡能接320mm的显卡。无风道设计，但同样通过转接卡巧妙的把CPU和显卡分隔在两个散热区域，且基本完全裸露在空气中。装机非常简单，不用考虑风道和风扇问题。缺点是由于机身特别窄，无法上塔式散热器，难以压住大功耗CPU。不是铝合金机箱，做工非常糙。

## 主板

Hackintosh最重要的是主板的选择，根据历史经验技嘉是最好驱动的。此外，显卡尽量和主板统一厂商，兼容性比较好。

可以参考 tonymacx86 论坛的 [buyer's guide](https://www.tonymacx86.com/buyersguide/october/2017/)，但其实也不保证能驱动所有硬件。比如我参考CustoMac Mini Deluxe购买的技嘉GA-Z170N-WIFI，无法驱动板载无线网卡和蓝牙 :(

技嘉GA-Z170N-WIFI这款主板出厂BIOS版本是F4，已经碰到两个bug：

- 每引导一次系统就在引导列表多一条记录，导致引导列表里有十几条一模一样的引导项，估计得逼死处女座。
- 默认关闭键盘启动系统，但实际关机状态只要动一下键盘或拔插usb口都会自动启动系统；最终设置为需要密码启动系统，反而键盘无法启动系统了，这样凑合解决了问题。

但升级BIOS似乎也有风险：http://bbs.pcbeta.com/viewthread-1746011-1-1.html

目前来说270系列主板比170几乎无升级，所以还是选择170系列比较实惠。如果无超频需求，也无需Z系列主板。

主板型号 | 价格
---|---
技嘉 Z170N-Gaming 5  |900¥
华硕 Z170I PRO Gaming  | 700¥
MSI Z170I Gaminig Pro | 700¥
MSI H170I PRO AC | 450¥
技嘉 Z170M-D3H | 650¥
华硕 Z170M-PLUS | 680¥
MSI Z170M-Mortar | 600¥
技嘉 Z170X-UD3 | 650¥
技嘉 Z170-HD3 | 700¥
MSI Z170A GAMING M3 | 700¥

## 散热器

因为机箱的限制，可选的CPU散热器不多，而且ITX主板的散热器很难选择，稍微大一些会和主板IO接口或内存冲突，比较头疼。

散热器型号 | 高度 | 价格 | 备注
---|---|---|---
猫头鹰 NH-L9i | 37 | | ★★★
乔思伯 HP400 | 36 | |
银欣 AR06 | 58 | 250¥ | |
利民 AXP-100 Muscle | 58 | 250¥ | ★★★★★
ID-COOLING IS-60 | 55 | 150¥ | ★★★★
快睿 C7 | 47 | 219¥ |

比较好的选择是使用兼容性非常好的 *采融Samuel 17* 散热片，搭配 AXP-100s的风扇 *利民TY-14013R* （高13mm 直径14cm），低转速更静音，就是要花费点精力。

如果选择更厚的机箱，可以选择塔式：

散热器型号 | 高度 | 价格 | 备注
---|---|---|---
猫头鹰D9L | 90 | 440¥ | ★★★★★ 高度低，静音
玄冰400 | 145 | 100¥ | 性价比高
采融B81 | | 220¥ |

## 光驱

机箱还留有一个光驱位，可以选择任意12.7mm厚度的笔记本光驱安装。如果期望在光驱位添加一颗SSD，也可以上相应的光驱支架，十几块钱搞定。

额外需要注意的是，笔记本光驱（支架）STAT接口是13pin，需要加装一个13转22pin的转接头，用来接机箱内台式机主板的STAT（7pin）+电源（15pin）接口。

## DIY

现在内存、显卡都在高位，攒机不易，DIY优先选择二手。内存在某东539¥拍下，过两天一看新货直接跳到639¥，又过了几天跳到759¥……

最终清单如下，全部花费仅3000¥出头 :D

硬件 | 型号
---|---
CPU | Intel core i5 6600K
主板 | 技嘉 GA-Z170N-WIFI
显卡 | 技嘉 GV-N970G1 GAMING-4GD
内存 | 十铨 冥神 DDR4 3000 8GB x2
SSD | OCZ-TRION100 120GB
硬盘 | 日立 2.5“ 7200转 1TB
散热 | 乔思伯 HP400
电源 | 银欣 SX600-G 600W SFX金牌模组
机箱 | 银欣 ML08B-H

可以看到转接后显卡和主板接口在一个平面上了。Z170N-WIFI的接口还是比较齐全的，可惜macOS上WI-FI驱动不了，一般推荐购买BCM94352HMB（PCI-E接口）或BCM94352Z（m.2接口）无线网卡，或者USB网卡。

![case](http://image.jqian.net/hackintosh-case.jpg)

机箱两面分隔为两个散热区，GPU、CPU和电源风扇均直接从外部吸入冷风，GPU热量从顶部散热孔排出，CPU热量从背后面板侧散热孔排出。光驱位改造一下还可以再挂载一个3.5寸硬盘。由于没有额外定制线缆，电源附近线缆稍杂乱。

![inside](http://image.jqian.net/hackintosh-inside.jpg)

新版鲁大师跑分约25万，CPU 6万+，GPU 14万+；温度压力测试20分钟，CPU和GPU最高温度70℃；室温25℃正常使用CPU核心温度34℃左右，如果用AXP-100可能会更好一些。

# 软件

![high sierra](http://image.jqian.net/hackintosh-high-sierra.jpg)

工欲善其事，必先利其器。Hackintosh只要硬件选择得当，后续的驱动基本都很简单了，参考tonymacx86论坛[install guide](https://www.tonymacx86.com/threads/unibeast-install-macos-high-sierra-on-any-supported-intel-based-pc.235474/)就能得到一个基本可用的系统。

## BIOS

GA-Z170N-WIFI，更新[技嘉主板BIOS](https://www.tonymacx86.com/threads/how-to-update-your-gigabyte-motherboards-bios.131047/)。

## 安装High Sierra

参考tonymacx86的install guide。

依赖文件：Unibeast 8.3.2 + High Sierra 10.13.4

1.  制作安装盘：Unibeast + High Sierra安装文件。
    不一定需要U盘，可以使用移动硬盘划分出一个12G以下的分区替代U盘。
2.  配置BIOS。技嘉Z170N-WIFI主板，BIOS版本f20d，在默认基础上只需要配置：

        Set XHCI Handoff to Enabled

    此外，**安装时不要用独立显卡**，先使用主板内置显卡。BIOS设置有两处：

    - IGFX
    - Internal Graphic Card=Enable

3.  安装系统，一共可能会重新启动两三次。

    - 磁盘建议GPT格式，MBR已经过时了。
    - Disk Utility默认只显示卷，可以通过菜单显示所有设备。

## 安装EFI启动分区

依赖文件：Multibeast for High Sierra

Unibeast实际会在U盘上创建一个EFI分区（即ESP分区），用于安装时boot系统。

所以，装完系统之后，还需要运行Multibeast在新硬盘上创建EFI分区，然后把CLOVER安装进去，才能正常启动系统。同时，也支持Windows10的启动，需要备份好EFI分区下的microsoft目录。


    Quick Start > UEFI Boot Mode
    Drivers > Audio > Realtek ALCxxx > ALC1150
    Drivers > Misc > FakeSMC
    Drivers > Misc > FakeSMC Plugins
    Drivers > Misc > FakeSMC HWMonitor Application
    Drivers > Network > Intel > IntelMausiEthernet v2.3.0
    Drivers > USB > Increase Max Port Limit
    Bootloaders > Clover UEFI Boot Mode + Emulated NVRAM
    Customize > System Definitions > iMac > iMac 17,1
    Drivers > Graphics > NVIDIA Web Drivers Boot Flag


## 驱动显卡

[技嘉GTX970-G1显卡](https://hackintosher.com/guides/properly-install-nvidia-drivers-high-sierra-10-13)

依赖文件：

- [Nvidia web driver](https://hackintosher.com/nvidia-drivers/)
- [Lilu.kext](https://github.com/vit9696/Lilu/releases)
- [NvidiaGraphicsFixup.kext](https://sourceforge.net/projects/nvidiagraphicsfixup/)

安装完Nvidia web driver，重启即可。

另外也可以尝试[webdriver.sh](https://github.com/vulgo/webdriver.sh)自动安装脚本。

## 驱动声卡

技嘉Z170N-WIFI主板[板载realteck声卡](https://www.tonymacx86.com/threads/applehda-realtek-audio-guide.234732)

【注】实际patch系统文件：`/System/Library/Extensions/AppleHDA.kext`，注意先**备份**该驱动文件。

1.  [Disable SIP](https://hackintosher.com/forums/thread/enable-disable-system-integrity-protection-sip-on-a-hackintosh.53/)

    编辑Clover的 `config.plist`，找到`RT Variables > CsrActivateConfig`，禁用`0x67`，启用`0x00`

2.  下载 [audio_CloverALC](https://github.com/toleda/audio_CloverALC)
3.  执行 audio_cloverALC-130.sh

        Confirm Realtek ALC1150: y
        Clover Audio ID Injection: y
        Use Audio ID: 2

￼
实际patch日志：[patch_AppleHDA.kext.log](https://gist.githubusercontent.com/qxj/04de42f5cad1414d7234347e172a62d7/raw/25a3c5ba0b942bd6f2058c7f507aa76f2a361e05/patch_AppleHDA.kext.log)

## 驱动网卡

技嘉主板原装Intel网卡驱动比较困难，需要更换网卡。

推荐 BCM94360CS2（+转接卡）macOS免驱动，Win需[驱动程序](https://pan.baidu.com/s/1RfOFLQYei61a9-ZdnrtSYQ)(5mna)。

其他[NGFF无线网卡候选](http://bbs.pcbeta.com/forum.php?mod=viewthread&tid=1745470)：
bcm4352z、bcm4350、bcm4360、BCM943602 (DW1830)

原装卡+转接卡 这种绝对免驱：
bcm94360cs2、bcm943602cs、bcm94360cd

## CLOVER

驱动所在目录：`/Volumes/EFI/EFI/CLOVER/kexts/Other`

- AppleALC.kext 驱动声卡
- realtekALC.kext 驱动声卡
- FakeSMC.kext  用于HWMonitor
- Lilu.kext  驱动显卡
- NvidiaGraphicsFixup.kext 驱动显卡

对比[tonymacx86](http://tonymacx86.com)和[hacktoinsh](http://hackintosher.com)俩网站提供的hack方案区别仅是config.plist和kexts目录里的驱动。
