---
title: UNIX下IO模型分析
author: AnSwErYWJ
comments: true
category_bar: true
toc: true
categories: 科普
tags: IO
abbrlink: 37825
date: 2017-06-27 16:30:40
---

对*UNIX*下的五种常见*IO*模型分析，帮助理解
<!--more-->

## IO操作的两个阶段
以读数据操作为例：
 1. 等待内核数据准备（数据拷贝到内核缓冲区）
 2. 将数据从内核拷贝到用户空间

## IO模型
*UNIX*下共有五种常见的*IO*模型：
![UNIX下共有五种常见的IO模型](io-model.png)

下面以`recvfrom`接口举例

### 阻塞IO
默认情况下，所有的套接字都是阻塞的
![阻塞IO](blocking-io.png)
调用`recvfrom`接口，进程在*IO*操作的两个阶段都会阻塞，直到最终数据拷贝到用户空间或者过程中出现错误才会返回，进程在阻塞状态下是不占用*CPU*资源的
> 最常见的错误是发生系统中断，此时需要重读，可参考[这里](https://github.com/AnSwErYWJ/DogFood/blob/master/C/file/RD.c)

### 非阻塞IO
可以通过`fcntl(sockfd,F_SETFL,O_NONBLOCK)`将套接字设置成非阻塞
![非阻塞IO](no-blocking-io.png)
调用`recvfrom`接口，无论内核缓冲区是否有可用数据，进程都会立即返回，所以在*IO*操作的第一阶段是非阻塞的; 若无数据可用，内核将`errno`设置为为`EWOULDBLOCK`或者`EAGAIN`，进程可以使用轮询的方法，保证内核在数据准备好时，能立即拷贝到用户空间; 若有则立即将数据拷贝到用户空间，进程在数据拷贝到用户空间即*IO*操作的第二阶段是阻塞的;
> 非阻塞*IO*过于消耗*CPU*时间，将大部分时间用于轮询

### 多路复用IO
多路复用系统调用：`select`,`poll`和`epoll`，其中*windows*平台不支持`poll`和`epoll`，使用方法可以参考[I/O 多路复用之select、poll、epoll详解](https://segmentfault.com/a/1190000003063859?hmsr=toutiao.io&utm_medium=toutiao.io&utm_source=toutiao.io#articleHeader14)和[Linux select/poll和epoll实现机制对比](http://www.cnblogs.com/NerdWill/p/4996476.html)
![ 多路复用IO](multi-io.png)
调用`select`，等待内核数据准备，所以*IO*操作的第一个阶段，进程是阻塞的，不过是阻塞在多路复用系统调用上，而不是*IO*系统调用上; 当`select`返回套接字可读条件时，再调用`recvfrom`将数据从内核拷贝到用户空间，*IO*操作的第二阶段，进程是阻塞的

多路复用*IO*和阻塞*IO*，在*IO*操作的两个阶段都是阻塞的，不过多路复用*IO*使用了两个系统调用，而阻塞*IO*只使用了一个，所以在连接数不是很多的情况下，阻塞*IO*可能性能更佳; 多路复用*IO*的优势在于可以同时监控多个用于*IO*的文件描述符。

> 多线程中的阻塞*IO*，与多路复用*IO*极为相似

### 信号驱动IO
![信号驱动IO](signal-io.png)
调用`sigaction`等系统调用安装信号处理函数，并立即返回，所以*IO*操作的第一阶段，进程是非阻塞的; 当内核数据准备好时，内核会产生一个信号，通知进程将数据从内核拷贝到用户空间，*IO*操作的第二阶段，进程是阻塞的

> 使用方法：[IO的多路复用和信号驱动](http://www.cnblogs.com/ittinybird/p/4574397.html)

### 异步IO
异步*IO*有一组以`aio`开头的系统调用，使用方法可参考[Linux AIO机制](http://blog.csdn.net/tq02h2a/article/details/3825114)
![异步IO](asyn-io.png)
调用异步*IO*系统调用，给内核传递描述字、缓冲区指针、缓冲区大小（与`read`相同的三个参数）、文件偏移（与`lseek`类似），告诉内核当整个操作完成时如何通知我们，并立即返回，在*IO*操作的两个阶段，进程都不阻塞

## 总结
![5种IO模式比较](compare-io.png)
- 同步*IO*和异步*IO*的主要区别是将数据从内核拷贝到用户空间是否阻塞，前者会在将数据从内核拷贝到用户空间时即*IO*操作的第二个阶段发生阻塞，而后者则在系统调用后直接返回，直到内核发送信号通知*IO*操作完成，在*IO*操作的两个阶段都没有阻塞
- 阻塞*IO*和非阻塞*IO*的主要区别是系统调用是否立即返回（默认将数据从内核拷贝到用户空间即*IO*操作的第二个阶段是立即返回的），前者会在*IO*操作的两个阶段完成前一直阻塞，后者在内核没有准备好数据的情况下立即返回，即只会在*IO*操作的第二个阶段阻塞
- 信号驱动*IO*和异步*IO*的主要区别在于前者由内核通知我们何时启动一个*IO*操作，在将数据从内核拷贝到用户空间过程中即*IO*操作的第一个阶段依旧是阻塞的，而后者是由内核通知我们*IO*操作何时完成，在*IO*操作的两个阶段都没有阻塞

> [知乎](https://www.zhihu.com/question/19732473/answer/20851256)上有一个比较生动的例子可以说明这几种模型之间的关系。

## Reference
- [UNIX网络编程 卷1：套接字联网API](http://about:blank)
- [Linux IO模式及 select、poll、epoll详解](https://segmentfault.com/a/1190000003063859?hmsr=toutiao.io&utm_medium=toutiao.io&utm_source=toutiao.io)
- [Linux下5种IO模型的小结](http://www.cnblogs.com/ittinybird/p/4666044.html)
- [UNIX网络编程读书笔记：I/O模型（阻塞、非阻塞、I/O复用、信号驱动、异步）](http://www.cnblogs.com/nufangrensheng/p/3588690.html)
- [ IO - 同步，异步，阻塞，非阻塞 （亡羊补牢篇）](http://blog.csdn.net/historyasamirror/article/details/5778378)
- [Linux五种IO模型性能分析](http://blog.csdn.net/jay900323/article/details/18141217)
