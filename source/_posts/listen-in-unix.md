---
title: UNIX网络编程-listen函数及其包裹函数介绍
Antuor: AnSwEr(Weijie Yuan)
comments: true
toc: true
tags:
  - tcp
  - listen
date: 2017-02-23 17:14:17
categories: C/C++
---
本文将介绍UNIX网络编程中`listen`函数及其包裹函数。

----------
<!--more-->

### 函数简介
```
#include<sys/socket.h>

int listen(int sockfd,int backlog);
                                返回：若成功则为0，若出错则为-1
```
目前``listen``函数仅为``TCP``服务器调用，主要完成两个任务：
1. 将``socket``函数创建的还未建立连接的主动套接字转换为被动(监听)套接字，使内核接受指向该套接字的连接。
2. 使用第二个参数规定了内核为相应套接字排队的最大连接个数。



> tips：``socket``函数创建的套接字被默认为一个主动套接字，即该套接字为将调用``connect``函数发起连接的客户套接字。而``listen``函数导致该套接字从``CLOSED``状态转换为``LISTEN``状态。


### 包裹函数([下载](https://github.com/AnSwErYWJ/UNP/blob/master/TCP/Listen.c))
历史上总是将``backlog``设为5，但已无法满足现在服务器的需求了，所以需要指定一个较大的``backlog``才能满足繁忙的需求。一种方法是使用一个常值，可是每次增长都需要重新编译，比较麻烦；另一种方法是设定默认值，然后允许通过命令行或环境变量覆盖默认值：
```
#include<stdlib.h>
#include<sys/socket.h>

void Listen(int fd,int backlog)
{
    char *ptr;
    if((ptr = getenv("LISTENQ")) != NULL)
        backlog = atoi(ptr);

    if(listen(fd,backlog) == -1)
        perror("Listen error");
}
```
这样就可以通过设置环境变量``LISTENQ``来动态配置``backlog``的大小。
> tips：``backlog``为0不代表就不会有客户连接到你的机器。如果不想让客户连接，请直接关闭该套接字。

### About me
[![forthebadge](http://forthebadge.com/images/badges/ages-20-30.svg)](http://forthebadge.com)
- GitHub：[AnSwErYWJ](https://github.com/AnSwErYWJ)
- Blog：[http://www.answerywj.com](http://www.answerywj.com)
- Email：[yuanweijie1993@gmail.com](https://mail.google.com)
- Weibo：[@AnSwEr不是答案](http://weibo.com/1783591593)
- CSDN：[AnSwEr不是答案的专栏](http://blog.csdn.net/u011192270)

<a rel="license" href="http://creativecommons.org/licenses/by-sa/4.0/"><img alt="Creative Commons License" style="border-width:0" src="https://i.creativecommons.org/l/by-sa/4.0/88x31.png" /></a> This work is licensed under a <a rel="license" href="http://creativecommons.org/licenses/by-sa/4.0/">Creative Commons Attribution-ShareAlike 4.0 International License</a>.
本作品采用知识共享署名-相同方式共享 4.0 国际许可协议进行许可。


