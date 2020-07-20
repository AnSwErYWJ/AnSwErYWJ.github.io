---
title: UNIX网络编程-connect函数及其包裹函数介绍
Antuor: AnSwEr(Weijie Yuan)
comments: true
toc: true
tags:
  - tcp
  - connect
date: 2016-07-14 14:22:25
categories: C/C++
---

本文将介绍UNIX网络编程中`connect`函数及其包裹函数。

----------
<!--more-->

## 函数简介
```C
#include<sys/socket.h>
#include<sys/types.h>

int connect(int sockfd, const struct sockaddr* server_addr, socklen_t addrlen);
									返回值：若成功返回0;若失败则返回-1.
```

`connect`函数用于客户端建立tcp连接，发起三次握手过程。其中`sockfd`标识了主动套接字，`server_addr`是该套接字要连接的主机地址和端口号，`addrlen`为`server_addr`缓冲区的长度。


连接失败时，可以根据以下`errno`值判断失败的原因：
```
EBADF：参数sockfd 非合法socket处理代码;
EFAULT：参数serv_addr指针指向无法存取的内存空间;
ENOTSOCK：参数sockfd为一文件描述词，非socket;
EISCONN：参数sockfd的socket已是连线状态;
ECONNREFUSED：连线要求被server端拒绝;
ETIMEDOUT：企图连线的操作超过限定时间仍未有响应;
ENETUNREACH：无法传送数据包至指定的主机;
EAFNOSUPPORT：sockaddr结构的sa_family不正确;
EALREADY：socket为不可阻塞且先前的连线操作还未完成;
```

## 包裹函数([下载](https://github.com/AnSwErYWJ/UNP/blob/master/TCP/Connect.c))
```C
#include<sys/socket.h>
#include<sys/types.h>
#include<stdlib.h>

#define MAXSLEEP 128

int my_connect(int sockfd,const struct sockaddr *servaddr,socklen_t addrlen)
{
    int nsec;
    for(nsec = 1;nsec <= MAXSLEEP;nsec <<= 1)
    {
        if(connect(sockfd,servaddr,addrlen) == 0)
            return 0;//connection accepted
        if(nsec <= MAXSLEEP/2)//sleep nesc,then connect retry
            sleep(nsec);
    }
    return -1;
}
```

包裹函数为`connect`函数设置了超时重连的机制，如果连接成功，则成功返回。如果连接失败，则每次等待1、2、4、8。。。秒后继续尝试重新连接，直到`MAXSLEEP`为止。

## About me
[![forthebadge](http://forthebadge.com/images/badges/ages-20-30.svg)](http://forthebadge.com)
- GitHub：[AnSwErYWJ](https://github.com/AnSwErYWJ)
- Blog：[http://www.answerywj.com](http://www.answerywj.com)
- Email：[yuanweijie1993@gmail.com](https://mail.google.com)
- Weibo：[@AnSwEr不是答案](http://weibo.com/1783591593)
- CSDN：[AnSwEr不是答案的专栏](http://blog.csdn.net/u011192270)

<a rel="license" href="http://creativecommons.org/licenses/by-sa/4.0/"><img alt="Creative Commons License" style="border-width:0" src="https://i.creativecommons.org/l/by-sa/4.0/88x31.png" /></a> This work is licensed under a <a rel="license" href="http://creativecommons.org/licenses/by-sa/4.0/">Creative Commons Attribution-ShareAlike 4.0 International License</a>.
本作品采用知识共享署名-相同方式共享 4.0 国际许可协议进行许可。






