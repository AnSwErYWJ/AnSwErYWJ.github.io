---
title: --hash-style兼容性问题
Antuor: AnSwEr(Weijie Yuan)
comments: true
toc: true
tags:
  - gcc
  - ld
  - hash-style
date: 2020-05-14 15:54:25
categories: 编译链接
---

本文记录了解决 `--hash-style` 兼容性问题的过程。

-----
<!--more-->

## 问题
```
dlopen failed: empty/missing DT_HASH in "libxxx.so" (built with --hash-style=gnu?)
```
最近，稳定性监控平台，被这一行错误日志霸榜，刚看到时也一脸懵逼，下面我们来逐步分析。

## 名词解释
首先需要查阅一下相关文档，了解一下其中的”`新朋友`”。

- `DT_HASH`
```
ELF 中的一个 Sections，保存了一个用于查找符号的散列表，用于支持符号表的访问，能够提高符号搜索速度。
```

- `--hash-style=style`(以下解释摘自 `man ld`)
```
Set the type of linker's hash table(s). style can be either "sysv" for classic ELF ".hash" section, "gnu" for new style GNU ".gnu.hash" section or "both" for both the classic ELF ".hash" and new style GNU ".gnu.hash" hash tables. The default is "sysv".
```

## 实验
通过查阅 `--hash-style=style` 参数，发现 `style` 支持三种配置：`sysv`、`gnu`和`both`，废话不多说，先试一把。

- `gcc -Wl,--hash-style=sysv`
```
$ readelf -S libxxx.so  | grep "hash"
[ 4] .hash             HASH             0000000000003120  00003120
```

- `gcc -Wl,--hash-style=gnu`
```
$ readelf -S libxxx.so  | grep "hash"
[ 4] .gnu.hash         GNU_HASH         0000000000003120  00003120
```

- `gcc -Wl,--hash-style=both`
```
$ readelf -S libxxx.so  | grep "hash"
  [ 4] .gnu.hash         GNU_HASH         0000000000003120  00003120
  [ 5] .hash             HASH             00000000000035f8  000035f8
```

> `-Wl` 用于编译器向链接器传递参数。  
  
如上，发现使用不同的配置，`Sections Name` 不同。

> `.gnu.hash` 段​，提​供了​与 `hash` 段​相​同​的​功​能​；但​是与 `hash` 相比，增加了某些限制（附加规则），​导致了不兼容，带​来​了​ `50%` 的​动​态​链​接​性​能​提​升​，具体参见 [https://blogs.oracle.com/solaris/gnu-hash-elf-sections-v2](https://blogs.oracle.com/solaris/gnu-hash-elf-sections-v2)。

## 分析
结合实验结果，我先翻译一下问题中的那一行错误日志：
```
动态库加载失败，libxxx.so 中 DT_HASH 为空或者丢失，是不是用了 --hash-style=gnu 编译?
```
结合上表，若 `--hash-style=gnu`，那么 `Section Name` 就是 `.gnu.hash` 了，当然找不到`.hash` 了。

再查阅一下 `Makefile` 配置，发现并没有相关配置，怀疑是编译器的默认配置：

```
$ gcc -dumpspecs | grep "hash"
... --hash-style=gnu ...
```

> `-dumpspecs` 参数可以打印编译器的内置规范。

果不其然，默认的 `--hash-style` 配置为了 `gnu`。

## 结论
输出的动态库的 `--hash-style` 为 `gnu`，而目标系统并不能正确读取 `--hash-style` 为 `gnu` 的动态库，导致了如上的错误。

## 解决方案
配置 `--hash-style` 为 `both`：
```
LDFLAGS += -Wl,--hash-style=both
```

## 参考
- [Only one --hash-style in embedded Linux. Why?](https://stackoverflow.com/questions/11741816/only-one-hash-style-in-embedded-linux-why)
- [Binaries built on RHEL5 or FC6 do not work on RHEL4 or FC5!](https://sites.google.com/site/avinesh/binaryincompatibilitybetweenrhel4andrhel)
- [Android NDK UnsatisfiedLinkError: “dlopen failed: empty/missing DT_HASH”](https://stackoverflow.com/questions/28638809/android-ndk-unsatisfiedlinkerror-dlopen-failed-empty-missing-dt-hash)
- [Trouble understanding gcc linker options](https://stackoverflow.com/questions/42068271/trouble-understanding-gcc-linker-options)

-----

[![forthebadge](http://forthebadge.com/images/badges/ages-20-30.svg)](http://forthebadge.com)
- GitHub：[AnSwErYWJ](https://github.com/AnSwErYWJ)
- Blog：[http://www.answerywj.com](http://www.answerywj.com)
- Email：[yuanweijie1993@gmail.com](https://mail.google.com)
- Weibo：[@AnSwEr不是答案](http://weibo.com/1783591593)