---
title: Linux下Socket编程---connect（）函数的包裹函数介绍
Antuor: AnSwEr(Weijie Yuan)
comments: true
toc: true
tags:
  - tcp
  - connect
date: 2016-07-14 14:22:25
categories: C
---

这里主要介绍的是在TCP连接中的应用

----------
<!--more-->

## connect（）函数简介

**1. 功能：** 用于客户端建立tcp连接，发起三次握手过程。
**2. 原型：**
```C
#include<sys/socket.h>
#include<sys/types.h>
int connect(int sockfd, const struct sockaddr* server_addr, socklen_t addrlen)
返回值：0──成功， -1──失败。
```
**3. 参数：**
```
sockfd：标识一个套接字。
serv_addr：套接字s想要连接的主机地址和端口号。
addrlen：serv_addr缓冲区的长度。
```
**4. 错误代码：**
```
EBADF 参数sockfd 非合法socket处理代码
EFAULT 参数serv_addr指针指向无法存取的内存空间
ENOTSOCK 参数sockfd为一文件描述词，非socket。
EISCONN 参数sockfd的socket已是连线状态
ECONNREFUSED 连线要求被server端拒绝。
ETIMEDOUT 企图连线的操作超过限定时间仍未有响应。
ENETUNREACH 无法传送数据包至指定的主机。
EAFNOSUPPORT sockaddr结构的sa_family不正确。
EALREADY socket为不可阻塞且先前的连线操作还未完成。
```

## connect（）的包裹函数
### 代码实现
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

### 介绍
这是一个connect超时重连的函数，如果连接成功，则这个函数返回0。如果连接失败，则每次等待1、2、4、8。。。秒后继续尝试重新连接，直到MAXSLEEP为止，则说明连接失败，返回-1。

## 总结
也许你会觉得这样实现会有些麻烦，但这样确实可以使你的程序更加健壮，如果因为一些时间差或者阻塞的原因，使得你的第一次connect失败，利用这个包裹函数就不至于使整个客户端程序错误，而进行重连，消除这些客观因素的影响。

>代码[下载](https://github.com/AnSwErYWJ/DogFood/blob/master/C/network/client.c)

## About me
[![forthebadge](http://forthebadge.com/images/badges/ages-20-30.svg)](http://forthebadge.com)
- GitHub：[AnSwErYWJ](https://github.com/AnSwErYWJ)
- Blog：[http://www.answerywj.com](http://www.answerywj.com)
- Email：[yuanweijie1993@gmail.com](https://mail.google.com)
- Weibo：[@AnSwEr不是答案](http://weibo.com/1783591593)
- CSDN：[AnSwEr不是答案的专栏](http://blog.csdn.net/u011192270)

<a rel="license" href="http://creativecommons.org/licenses/by-sa/4.0/"><img alt="Creative Commons License" style="border-width:0" src="https://i.creativecommons.org/l/by-sa/4.0/88x31.png" /></a> This work is licensed under a <a rel="license" href="http://creativecommons.org/licenses/by-sa/4.0/">Creative Commons Attribution-ShareAlike 4.0 International License</a>.
本作品采用知识共享署名-相同方式共享 4.0 国际许可协议进行许可。






