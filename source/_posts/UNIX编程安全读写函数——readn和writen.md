---
title: UNIX编程安全读写函数——readn和writen
Antuor: AnSwEr(Weijie Yuan)
comments: true
toc: true
tags:
  - read
  - write
date: 2016-07-14 14:19:20
categories: C
---

字节流套接字（TCP套接字）上的read和write函数所表现的行为不同于通常的文件I/O。字节流套接字调用read或write输入或输出的字节数可能比请求的数量少，然而这并不是出错的状态。**这是因为内核中用于套接字的缓冲区可能达到了极限。**通常这种情况出现在一次读多于4096个字节或write在非阻塞情况下返回不足字节数。为了不多次调用read或防止write返回不足字节数，我们用下面的两个函数来替代read和write。

----------
<!--more-->

## readn
```C
#include<stdio.h>
#include<unistd.h>
#include<errno.h>

ssize_t safe_read(int fd,void *vptr,size_t n)
{
    size_t nleft;
    ssize_t nread;
    char *ptr;

    ptr=vptr;
    nleft=n;

    while(nleft > 0)
    {
        if((nread = read(fd,ptr,nleft)) < 0)
        {
            if(errno == EINTR) //被信号中断，重读
                nread = 0;
            else //出错
                return -1;
        }
        else if(nread == 0) //EOF
	        break;

        nleft -= nread;
        ptr += nread;
    }
    return (n-nleft);
}
```

## writen
```C
#include<stdio.h>
#include<unistd.h>
#include<errno.h>

ssize_t	safe_write(int fd, const void *vptr, size_t n)
{
    size_t  nleft;
    ssize_t nwritten;
    const char *ptr;

    ptr = vptr;
    nleft = n;

    while(nleft > 0)
    {
    	if((nwritten = write(fd, ptr, nleft)) <= 0)
        {
            if(nwritten < 0 && errno == EINTR) //被信号中断，重写
                nwritten = 0;
            else //error
                return -1;
        }
		nleft -= nwritten;
		ptr   += nwritten;
     }
	return(n);
}
```

## 总结
上面介绍了两个安全读写函数，但是并不意味着这两个函数在任何地方都完全适用，所以不要强迫自己使用。需要注意阻塞、效率等问题，当你只是读写少量字节时，就没必要使用了。

## About me
[![forthebadge](http://forthebadge.com/images/badges/ages-20-30.svg)](http://forthebadge.com)
- GitHub：[AnSwErYWJ](https://github.com/AnSwErYWJ)
- Blog：[http://www.answerywj.com](http://www.answerywj.com)
- Email：[yuanweijie1993@gmail.com](https://mail.google.com)
- Weibo：[@AnSwEr不是答案](http://weibo.com/1783591593)
- CSDN：[AnSwEr不是答案的专栏](http://blog.csdn.net/u011192270)

<a rel="license" href="http://creativecommons.org/licenses/by-sa/4.0/"><img alt="Creative Commons License" style="border-width:0" src="https://i.creativecommons.org/l/by-sa/4.0/88x31.png" /></a> This work is licensed under a <a rel="license" href="http://creativecommons.org/licenses/by-sa/4.0/">Creative Commons Attribution-ShareAlike 4.0 International License</a>.
本作品采用知识共享署名-相同方式共享 4.0 国际许可协议进行许可。
