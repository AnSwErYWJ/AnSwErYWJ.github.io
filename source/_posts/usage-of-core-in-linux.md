---
title: Linux下core文件使用
Antuor: AnSwEr(Weijie Yuan)
toc: true
date: 2018-03-07 16:16:15
categories: Linux
tags: core dump
---
有时候程序会异常退出而不带任何日志，此时就可以使用`code`文件进行分析，它会记录程序运行的内存，寄存器，堆栈指针等信息

------
<!--more-->

## 什么是core文件
通常在`Linux`下遇到程序异常退出或者中止，我们都会使用`core`文件进行分析，其中包含了程序运行时的内存，寄存器，堆栈指针等信息，格式为`ELF`，可以理解是程序工作当前状态转储成一个文件，通过工具分析这个文件，我们可以定位到程序异常退出或者终止时相应的堆栈调用等信息，为解决问题提供帮助。

## 使用core文件调试
### 生成方法
1. 查看当前`core`文件的状态
```
$ ulimit -a
...
-c: core file size (blocks)         0  # 关闭状态
...
```

2. 打开生成开关
```
ulimit -c unlimited
ulimit -a
...
-c: core file size (blocks)         unlimited
...
```

3. 对`core`文件的大小进行限制，单位为`blocks`，一般`1 block=512 bytes`，设置太小可能导致不会生成文件
```
$ ulimit -c 1024
$ ulimit -a
...
-c: core file size (blocks)         1024
...
```

4. 关闭生成开关
```
ulimit -c 0
ulimit -a
...
-c: core file size (blocks)         0
...
```

> 上面对`core`文件的操作仅对当前生效，若需要永久生效，则要将相应操作写入`/etc/profile`

### 生成路径
`core`文件默认生成在程序的工作目录，可以对生成路径进行设置，需要保证对对应目录有足够空间并具有写权限
```
echo /MyCoreDumpDir/core.%e.%p > /proc/sys/kernel/core_pattern
```
其中命名使用的参数列表
```
%p - insert pid into filename  # 添加 pid 
%u - insert current uid into filename  # 添加当前 uid 
%g - insert current gid into filename  # 添加当前 gid 
%s - insert signal that caused the coredump into the filename  # 添加导致产生 core 的信号 
%t - insert UNIX time that the coredump occurred into filename  # 添加 core 文件生成时的 unix 时间 
%h - insert hostname where the coredump happened into filename  # 添加主机名 
%e - insert coredumping executable name into filename  # 添加命令名
```
> `/proc/sys/kernel/core_uses_pid`这个文件的值若为１，则无论时候配置`%p`,最后生成的`core`文件都会添加`pid`

### 调试方法
可以使用`gdb`对`core`文件进行调试，编译是需要带上`-g`选项
```
$ gdb a.out
...
(gdb) core-file core
...
(gdb) bt 
...
```

如需要在`PC`上调试嵌入式设备产生的`core`文件，则需要选取相应平台的`gdb`工具，并在进入`gdb`后设置符号文件的位置
```
$ xxx-xxx-gdb a.out
...
(gdb) solib-search-path xxx.so:xxx.so
...
(gdb) core-file core
...
(gdb) bt
...
```

## Reference
- [关于pthread_cond_wait使用while循环判断的理解](https://www.cnblogs.com/leijiangtao/p/4028338.html)
- [Linux线程同步之条件变量pthread_cond_t](https://www.cnblogs.com/zhx831/p/3543633.html)
- [APUE]()

## About me
[![forthebadge](http://forthebadge.com/images/badges/ages-20-30.svg)](http://forthebadge.com)
- GitHub：[AnSwErYWJ](https://github.com/AnSwErYWJ)
- Blog：[http://www.answerywj.com](http://www.answerywj.com)
- Email：[yuanweijie1993@gmail.com](https://mail.google.com)
- Weibo：[@AnSwEr不是答案](http://weibo.com/1783591593)
- CSDN：[AnSwEr不是答案的专栏](http://blog.csdn.net/u011192270)

<a rel="license" href="http://creativecommons.org/licenses/by-sa/4.0/"><img alt="Creative Commons License" style="border-width:0" src="https://i.creativecommons.org/l/by-sa/4.0/88x31.png" /></a> This work is licensed under a <a rel="license" href="http://creativecommons.org/licenses/by-sa/4.0/">Creative Commons Attribution-ShareAlike 4.0 International License</a>.  
本作品采用知识共享署名-相同方式共享 4.0 国际许可协议进行许可。
