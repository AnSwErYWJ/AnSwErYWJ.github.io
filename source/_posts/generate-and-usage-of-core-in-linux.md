---
title: Linux下core文件的生成和使用
author: AnSwErYWJ
comments: true
category_bar: true
toc: true
tags:
  - core
  - core dumped
  - gdb
categories: C/C++
abbrlink: 40501
date: 2022-12-20 17:17:11
---

本文对作者`2018`年的博文[Linux下core文件使用](https://answerywj.com/2018/03/07/usage-of-core-in-linux/)做了一系列更新，特别是针对`Ubuntu 20.04`下`core`文件生成异常做了分析与解决。

<!--more-->

## 什么是core文件
在`Linux`下遇到程序异常退出或者中止，操作系统通常会把程序当前的工作状况存储在一个名为`core`的文件中，其中包含了程序运行时的内存、寄存器和堆栈指针等信息，格式为`ELF`，这个过程叫做`coredump`，又称作核心转储。

通过工具分析这个文件，我们可以定位到程序异常退出或者终止时相应的堆栈调用等信息。

## 如何生成core文件
### 查看coredump是否生效
```
$ ulimit -a
...
-c: core file size (blocks)         0
...
```
`0` 表示`core`文件大小限制为`0`，不允许写入，所以无法生成`core`文件，需要修改为正数大小或`unlimited`才可使`coredump`生效。

### 修改core文件大小的限制
取消`core`文件大小限制：
```
ulimit -c unlimited
ulimit -a
...
-c: core file size (blocks)         unlimited
...
```

也可以对`core`文件的大小进行有效限制，单位为`blocks`，一般`1 block=512 bytes`，设置太小可能导致不会生成文件：
```
$ ulimit -c 1024
$ ulimit -a
...
-c: core file size (blocks)         1024
...
```

> 上面对`core`文件的操作仅对当前生效，若需要永久生效，则要将相应操作写入`/etc/profile`。

### 设置core文件存储路径
`core`文件默认存储在程序的工作目录，可以通过命令`cat /proc/sys/kernel/core_pattern
`查看。

在文件`/etc/sysctl.conf`末尾加入如下信息，可以指定`core`文件的存储路径：
```
kernel.core_pattern=/dumpdir/core_%e_%p_%t
```

控制`core`文件的文件名中是否添加`pid`作为扩展：
```
echo "1" > /proc/sys/kernel/core_uses_pid  
```
> `/proc/sys/kernel/core_uses_pid`这个文件的值若为１，则无论是否配置`%p`，最后生成的`core`文件都会添加`pid`。

通常情况下，重启即可生效。

附`core`文件命名使用的参数列表：
```
%p - insert pid into filename  # 添加 pid 
%u - insert current uid into filename  # 添加当前 uid 
%g - insert current gid into filename  # 添加当前 gid 
%s - insert signal that caused the coredump into the filename  # 添加导致产生 core 的信号 
%t - insert UNIX time that the coredump occurred into filename  # 添加 core 文件生成时的 unix 时间 
%h - insert hostname where the coredump happened into filename  # 添加主机名 
%e - insert coredumping executable name into filename  # 添加命令名
```
### 关闭apport.service服务
`Ubuntu 20.04`中，执行完上述操作，会发现还是无法在指定目录生成`core`文件。

查看`core`文件存储路径：
```
$ cat /proc/sys/kernel/core_pattern
|/usr/share/apport/apport %p %s %c %d %P %E
```
发现`core`文件存储路径并非自己设置的，而是由管道交给了一个`apport`的程序，通过查询可知其是`Ubuntu`官方为了自动收集错误，生成程序崩溃报告的一个服务，即`apport.service`。

我们可以关闭`apport.service`这个服务：
```
sudo service apport stop
```
> 使用`sudo service apport start`可以开启这个服务。

如果这个命令无效的话，可以修改`/etc/default/apport`文件，将`enabled`改成`0`。

如上，可以在指定路径生成`core`文件。

## 使用core文件调试
可以使用`gdb`对`core`文件进行调试：
```
$ gdb a.out
...
(gdb) core-file core
...
(gdb) bt 
...

or

$ gdb a.out core
...
(gdb) bt 
...
```
> **编译可执行程序时需要带上`-g`选项。**


如需要在`PC`上调试嵌入式设备产生的`core`文件，则需要选取相应平台的`gdb`工具，并在进入`gdb`后设置符号文件的位置：
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
