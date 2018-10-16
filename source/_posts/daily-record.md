---
title: Daily Record
Antuor: AnSwEr(Weijie Yuan)
comments: true
toc: true
tags:
  - record
date: 2018-10-16 10:39:14
categories: Working
---

本文主要整理日常遇到的问题

-----

<!--more-->

## 2018.03.27
1. 结构体初始化后需要进行清空
```
	struct mg_send_mqtt_handshake_opts opts;
	memset(&opts, 0, sizeof(opts));
```

## 2018.03.28
1. 宏定义与函数名冲突，若宏定义在函数名的声明或定义之前，则会进行字符串替换，导致编译会报错
2. MQTT QOS 学习
```
qos 0: 最多分发一次，消息可能送达一次也可能根本没送达，取决于底层的网络能力，接收者不会响应，发送者不会重发

qos 1: 至少分发一次，服务质量确保消息至少送达一次，需要PUBACK报文确认

qos 2: 仅分发一次，最高等级的服务质量，消息丢失和重复都是不可接受的
```

## 2018.05.29
1. 布尔值变量的命名尽量使用如下规则：`is_xxx`
2. `lua`字符串拼接操作：若存在大量的字符串拼接操作，如循环等，不要使用`..`，因为每次都会申请临时内存，新建一个新的字符串，会导致内存来不及回收，可以使用`table.insert + table.contact`
3. `sscanf`可以进行字符串分割和字符串数字转数字等，很强大！！！

## 2018.07.19
1. 两个库有相同的符号，同时链接的话，运行时可能串库调用

## 2018.08.17
1. 越界访问内存导致`free`失败的原因

`molloc`一块内存，在`free`的时候只需要传递指针首地址操作系统(或者说C语言)就可以对内存进行释放，那么它是怎么知道应该释放多大的内存呢?  
其实C语言是维护了一个数据结构类似如下的结构，这个结构中主要有两个数据：一个是当前内存块的大小，另外一个是指向下一个空闲内存块：
```
typedef struct Header {
        union header *ptr; /*next block if on free list*/
        unsigned size; /*size of this block*/
    } header;
```
其实我们在`molloc(10)`一块内存的时候，真正申请的不止是`10`个字节大小的内存，而是要加上一个`struct Header`结构体的大小，`molloc`返回给我们的内存想当于是p+sizeof(Header)的指针，而在free的时候，则C语言只需要将`p-sizeof(Header)`就能找到`header`结构，从而知道内存块大小。

## 2018.10.16
1. 使用`valgrind`对可执行程序做内存检查，发现会存在`still reachable`的问题，可排除编码的问题。
```
valgrind --tool=memcheck --leak-check=yes --show-reachable=yes --track-origins=yes a.out
```
查阅资料发现，许多`C++`库都实现了自己的内存分配管理器，在内存释放时不是将其直接还给系统，而是留在内存池中供下次使用，这导致程序退出时会被检测到`still reachable`。将使用`C++`库的地方去除再次验证，无该错误。
参考：[https://stackoverflow.com/questions/30376601/valgrind-memory-still-reachable-with-trivial-program-using-iostream](https://stackoverflow.com/questions/30376601/valgrind-memory-still-reachable-with-trivial-program-using-iostream)


## About me
[![forthebadge](http://forthebadge.com/images/badges/ages-20-30.svg)](http://forthebadge.com)
- GitHub：[AnSwErYWJ](https://github.com/AnSwErYWJ)
- Blog：[http://www.answerywj.com](http://www.answerywj.com)
- Email：[yuanweijie1993@gmail.com](https://mail.google.com)
- Weibo：[@AnSwEr不是答案](http://weibo.com/1783591593)
- CSDN：[AnSwEr不是答案的专栏](http://blog.csdn.net/u011192270)

<a rel="license" href="http://creativecommons.org/licenses/by-sa/4.0/"><img alt="Creative Commons License" style="border-width:0" src="https://i.creativecommons.org/l/by-sa/4.0/88x31.png" /></a> This work is licensed under a <a rel="license" href="http://creativecommons.org/licenses/by-sa/4.0/">Creative Commons Attribution-ShareAlike 4.0 International License</a>.
本作品采用知识共享署名-相同方式共享 4.0 国际许可协议进行许可。


