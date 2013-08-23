---
title: 更改winxp和server2003的远程桌面端口
tags: Windows
---

http://support.microsoft.com/Default.aspx?kbid=306759

winxp:

- 启动注册表编辑器 (Regedt32.exe)。
- 在注册表中找到下面的项：`HKEY_LOCAL_MACHINE\System\CurrentControlSet\Control\TerminalServer\WinStations\RDP-Tcp\PortNumber`
- 在编辑菜单上，单击修改，单击十进制，键入新的端口号，然后单击确定。
- 退出注册表编辑器。

**注意**：当试图使用远程桌面连接来连接到这台计算机时，必须键入新的端口号，格式为"IP:new-port"。

server2003在相似的注册表项。
