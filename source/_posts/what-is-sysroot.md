---
title: sysroot为何物?
Antuor: AnSwEr(Weijie Yuan)
comments: true
toc: true
tags:
  - ld
  - sysroot
date: 2019-04-26 17:59:57
categories: Compile
---

本文介绍链接过程中sysroot的作用。

-----

<!--more-->

## sysroot为何物
做过交叉编译的同学们，一定对下面这个错误十分熟悉吧：
```
/cross-compiling/ld: cannot find crt1.o: No such file or directory
/cross-compiling/ld: cannot find crti.o: No such file or directory
```
在我们的`pc`上，这两个文件一般在`/usr/lib`或者`/usr/lib32`中，通过`gcc -print-search-dirs`可以看到这两个路径默认就在库的搜索路径中，所以在`pc`上编译程序时不存在链接器找不到`crt1.o`和`crti.o`的问题。
> `crt1.o`负责应用程序的启动，其中包含了程序的入口函数`_start`以及两个未定义的符号`__libc_start_main`和`main`，由`_start`负责调用`__libc_start_main`初始化`libc`，然后调用我们源代码中定义的`main`函数，`crti.o`负责辅助启动这些代码。

下面我们使用交叉编译工具链来查看库的搜索路径`/cross-compiling/gcc -print-search-dirs`，发现`crt1.o`和`crti.o`的所在目录并不在库的搜索路径中，所以会出现上述的问题。

下面就需要`sysroot`出场了。
`sysroot`被称为逻辑根目录，只在链接过程中起作用，作为交叉编译工具链搜索库文件的根路径，如配置`--sysroot=dir`，则`dir`作为逻辑根目录，链接器将在`dir/usr/lib`中搜索库文件。

> 只有链接器开启了--with-sysroot选项，--sysroot=director才生效


## Reference
- [crti.o file missing](https://stackoverflow.com/questions/91576/crti-o-file-missing)
- [crt1.o, crti.o, crtbegin.o, crtend.o, crtn.o](https://blog.csdn.net/farmwang/article/details/73195951)

## About me
[![forthebadge](http://forthebadge.com/images/badges/ages-20-30.svg)](http://forthebadge.com)
- GitHub：[AnSwErYWJ](https://github.com/AnSwErYWJ)
- Blog：[http://www.answerywj.com](http://www.answerywj.com)
- Email：[yuanweijie1993@gmail.com](https://mail.google.com)
- Weibo：[@AnSwEr不是答案](http://weibo.com/1783591593)
- CSDN：[AnSwEr不是答案的专栏](http://blog.csdn.net/u011192270)

<a rel="license" href="http://creativecommons.org/licenses/by-sa/4.0/"><img alt="Creative Commons License" style="border-width:0" src="https://i.creativecommons.org/l/by-sa/4.0/88x31.png" /></a> This work is licensed under a <a rel="license" href="http://creativecommons.org/licenses/by-sa/4.0/">Creative Commons Attribution-ShareAlike 4.0 International License</a>.
本作品采用知识共享署名-相同方式共享 4.0 国际许可协议进行许可。