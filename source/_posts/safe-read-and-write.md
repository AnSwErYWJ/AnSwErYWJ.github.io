---
title: UNIX编程安全读写函数
author: AnSwErYWJ
comments: true
category_bar: true
toc: true
tags:
  - read
  - write
categories: C/C++
abbrlink: 64660
date: 2016-07-14 14:19:20
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

-----

<a href="#"><img src="https://img.shields.io/badge/Author-AnSwErYWJ-blue" alt="Author"></a>
- GitHub：[AnSwErYWJ](https://github.com/AnSwErYWJ)
- Blog：[https://www.answerywj.com](https://www.answerywj.com) 
- Email：[yuanweijie1993@gmail.com](https://mail.google.com)
- Weibo：[AnSwEr不是答案](https://weibo.com/1783591593)