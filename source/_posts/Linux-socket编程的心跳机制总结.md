---
title: Linux socket编程的心跳机制总结
Antuor: AnSwEr(Weijie Yuan)
comments: true
toc: true
tags:
  - socket
date: 2016-07-14 14:23:47
categories: Linux C
---

## 什么是心跳机制
**心跳机制**就是当客户端与服务端建立连接后，每隔几分钟发送一个固定消息给服务端，服务端收到后回复一个固定消息给客户端，如果服务端几分钟内没有收到客户端消息，则视客户端断开。发送方可以是客户端和服务端，看具体需求。

## 为什么要使用
我们都知道在TCP这种长连接情况下下，有可能有一大段时间是没有数据往来的，即处于空闲状态。理论上说，这个连接是一直保持连接的，但是在实际应用中，如果中间节点出现什么故障是难以预测的。更可怕的是，有的节点会自动把一定时间之内没有数据交互的连接切断。所以，需要我们利用心跳机制，来维持长连接，保活通信。

## 实现方法

- **应用层：** 由应用程序自己每隔一定时间向客户/服务端发送一个短小的数据包，然后启动一个线程，在线程中不断检测客户端的回应， 如果在一定时间内没有收到客户/服务端的回应，即认为客户/服务端已经掉线，连接不可用。
- **设置SO_KEEPALIVE套接字选项：**在TCP通信中，存在heartbeat机制。其实就是TCP的选项。当服务/客户端，一方开启KeepAlive功能后，就会自动在规定时间内向对方发送心跳包， 而另一方在收到心跳包后就会自动回复，以告诉对方我仍然在线。
> **注意：**因为开启KeepAlive功能需要消耗额外的宽带和流量，所以TCP协议层默认并不默认开启KeepAlive。KeepAlive超时需要7,200，000 MilliSeconds， 即2小时，探测次数为5次。对于很多应用程序来说，空闲时间太长。因此，我们可以手工开启KeepAlive功能并设置合理的KeepAlive参数。

### 我的实现
这里具体介绍设置SO_KEEPALIVE套接字选项这个方法。

#### SO_KEEPALIVE的三个参数:
1. tcp_keepalive_intvl：探测发包间隔为intvl。
2. tcp_keepalive_idle：连接在idle时间内没有任何数据往来,则进行此TCP层的探测。
3. tcp_keepalive_cnt：尝试探测的次数。

#### setsockopt()函数介绍
1. 用法：设置与某个套接字关联的选 项。选项可能存在于多层协议中，它们总会出现在最上面的套接字层。
2. 函数原型：
```
#include <sys/types.h>
#include <sys/socket.h>
int setsockopt(int sock, int level, int optname, const void *optval, socklen_t optlen);

参数：
sock：将要被设置或者获取选项的套接字。
level：选项所在的协议层。
optname：需要访问的选项名。
optval：对于getsockopt()，指向返回选项值的缓冲。对于setsockopt()，指向包含新选项值的缓冲。
optlen：对于getsockopt()，作为入口参数时，选项值的最大长度。作为出口参数时，选项值的实际长度。对于setsockopt()，现选项的长度。

返回说明：
成功执行时，返回0。失败返回-1，errno被设为以下的某个值
EBADF：sock不是有效的文件描述词
EFAULT：optval指向的内存并非有效的进程空间
EINVAL：在调用setsockopt()时，optlen无效
ENOPROTOOPT：指定的协议层不能识别选项
ENOTSOCK：sock描述的不是套接字
```

#### 具体代码
``` C
int heartbeat(int fd)
{
    int alive,error,idle,cnt,intv;

    /*
     * open keepalive on fd
     */
    Restart:
    alive = 1;//set keepalive open
    ret=setsockopt(fd,SOL_SOCKET,SO_KEEPALIVE,&alive,sizeof(alive));
    if(ret < 0)
    {
        DEBUG("set socket option error.\n");
        goto Restart;
    }

    /*
     * 60S without data,send heartbeat package
     */
    idle = 60;
    ret = setsockopt(fd,SOL_TCP,TCP_KEEPIDLE,&idle,sizeof(idle));
    if(ret < 0)
    {
        DEBUG("set keepalive idle error.\n");
        return -1;
    }

    /*
     * without any respond,3m later resend package
     */
    intv = 180;
    ret = setsockopt(fd,SOL_TCP,TCP_KEEPINTVL,&intv,sizeof(intv));
    if(ret < 0)
    {
        DEBUG("set keepalive intv error.\n");
        return -2;
    }

    /*
     * send 5 times,without any response,mean connect lose
     */
    cnt = 5;
    ret = setsockopt(fd,SOL_TCP,TCP_KEEPCNT,&cnt,sizeof(cnt));
    if(ret < 0)
    {
        DEBUG("set keepalive cnt error.\n");
        return -3;
    }
}
```

## 总结
当然，还是有很多方法去实现心跳机制的，比如利用select实现的超时控制，或者利用守护进程或线程的单独检测。不过我个人认为设置SO_KEEPALIVE实现起来最简单，最方便。如果大家发现有什么问题，也欢迎大家交流。

## About me
[![forthebadge](http://forthebadge.com/images/badges/ages-20-30.svg)](http://forthebadge.com)
- GitHub：[AnSwErYWJ](https://github.com/AnSwErYWJ)
- Blog：[http://www.answerywj.com](http://www.answerywj.com)
- Email：[yuanweijie1993@gmail.com](https://mail.google.com)
- Weibo：[@AnSwEr不是答案](http://weibo.com/1783591593)
- CSDN：[AnSwEr不是答案的专栏](http://blog.csdn.net/u011192270)

<a rel="license" href="http://creativecommons.org/licenses/by-sa/4.0/"><img alt="Creative Commons License" style="border-width:0" src="https://i.creativecommons.org/l/by-sa/4.0/88x31.png" /></a> This work is licensed under a <a rel="license" href="http://creativecommons.org/licenses/by-sa/4.0/">Creative Commons Attribution-ShareAlike 4.0 International License</a>.
本作品采用知识共享署名-相同方式共享 4.0 国际许可协议进行许可。





