---
title: Linux下脚本录制工具——script和scriptreplay
author: AnSwErYWJ
comments: true
category_bar: true
toc: true
tags:
  - script
  - scriptreplay
categories: 系统配置
abbrlink: 12413
date: 2016-07-14 14:04:51
---

在Linux开发环境下，想要录制一段屏幕视屏不是特别方便。这里分享给大家一种方便而且快捷的方法。

<!--more-->

## 使用
Linux下有script和scriptreplay这两个工具组合用于录制命令行。在新版本系统中，已经集成了这两个工具，所以直接使用即可：
```
$ script -t 2>timing.log -a >output.session
$ <command>
$ <command>
$ exit
$ scriptreplay timing.log output.session
```

说明：
- 选项-t用于存储时序文件，这里导入到stderr，再重定向到timing.log。
- 选项-a用于将命令输出信息，重定向到output.session文件。
- 这两个文件很小，可以拷贝到需要播放的机器上进行播放。
