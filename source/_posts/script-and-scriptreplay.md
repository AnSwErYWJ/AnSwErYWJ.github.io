---
title: Linux下脚本录制工具——script和scriptreplay
Antuor: AnSwEr(Weijie Yuan)
comments: true
toc: true
tags:
  - script
  - scriptreplay
date: 2016-07-14 14:04:51
categories: 系统配置
---

在Linux开发环境下，想要录制一段屏幕视屏不是特别方便。这里分享给大家一种方便而且快捷的方法。

----------
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

## About me
[![forthebadge](http://forthebadge.com/images/badges/ages-20-30.svg)](http://forthebadge.com)
- GitHub：[AnSwErYWJ](https://github.com/AnSwErYWJ)
- Blog：[http://www.answerywj.com](http://www.answerywj.com)
- Email：[yuanweijie1993@gmail.com](https://mail.google.com)
- Weibo：[@AnSwEr不是答案](http://weibo.com/1783591593)
- CSDN：[AnSwEr不是答案的专栏](http://blog.csdn.net/u011192270)

<a rel="license" href="http://creativecommons.org/licenses/by-sa/4.0/"><img alt="Creative Commons License" style="border-width:0" src="https://i.creativecommons.org/l/by-sa/4.0/88x31.png" /></a> This work is licensed under a <a rel="license" href="http://creativecommons.org/licenses/by-sa/4.0/">Creative Commons Attribution-ShareAlike 4.0 International License</a>.
本作品采用知识共享署名-相同方式共享 4.0 国际许可协议进行许可。
