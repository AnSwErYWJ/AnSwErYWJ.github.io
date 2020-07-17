---
title: pthread-mutex
Antuor: AnSwEr(Weijie Yuan)
comments: true
toc: true
tags:
  - pthread_mutex_lock
  - pthread_mutex_trylock
  - pthread_mutex_unlock
date: 2020-07-17 11:47:23
categories: C/C++
---

summary

-----
<!--more-->

简单的说，互斥锁保护了一个临界区，在这个临界区中，一次最多只能进入一个线程。如果有多个进程在同一个临界区内活动，就有可能产生竞态条件(race condition)导致错误。

`pthread_mutex_trylock` 是 `pthread_mutex_lock` 的非阻塞版本。

`Glibc` 版本号为 `2.28`。

`pthread_mutex_t`  类型定义：
```
typedef union
{
  struct __pthread_mutex_s
  {
    int __lock;
    unsigned int __count;
    int __owner;
#ifdef __x86_64__
    unsigned int __nusers;
#endif
    /* KIND must stay at this position in the structure to maintain
       binary compatibility.  */
    int __kind;
#ifdef __x86_64__
    short __spins;
    short __elision;
    __pthread_list_t __list;
# define __PTHREAD_MUTEX_HAVE_PREV	1
/* Mutex __spins initializer used by PTHREAD_MUTEX_INITIALIZER.  */
# define __PTHREAD_SPINS             0, 0
#else
    unsigned int __nusers;
    __extension__ union
    {
      struct
      {
	short __espins;
	short __elision;
# define __spins __elision_data.__espins
# define __elision __elision_data.__elision
# define __PTHREAD_SPINS         { 0, 0 }
      } __elision_data;
      __pthread_slist_t __list;
    };
#endif
  } __data;
  char __size[__SIZEOF_PTHREAD_MUTEX_T];
  long int __align;
} pthread_mutex_t;
```

关键成员：
- `__lock`： `mutex` 状态，`0` 表示未占用，`1` 表示占用；
- `__count`： 用于可重入锁，记录 `owner` 线程持有锁的次数；
- `__owner`： `owner` 线程 `ID`；
- `__kind`： 记录 `mutex` 的类型，有以下几个取值：
```
　　PTHREAD_MUTEX_TIMED_NP，这是缺省值，也就是普通锁。
　　PTHREAD_MUTEX_RECURSIVE_NP，可重入锁，允许同一个线程对同一个锁成功获得多次，并通过多次unlock解锁。
　　PTHREAD_MUTEX_ERRORCHECK_NP，检错锁，如果同一个线程重复请求同一个锁，则返回EDEADLK，否则与PTHREAD_MUTEX_TIMED_NP类型相同。
　　PTHREAD_MUTEX_ADAPTIVE_NP，自适应锁，自旋锁与普通锁的混合。
```

Mutex可以分为递归锁(recursive mutex)和非递归锁(non-recursive mutex)。可递归锁也可称为可重入锁(reentrant mutex)，非递归锁又叫不可重入锁(non-reentrant mutex)。

二者唯一的区别是，同一个线程可以多次获取同一个递归锁，不会产生死锁。而如果一个线程多次获取同一个非递归锁，则会产生死锁。

Windows下的Mutex和Critical Section是可递归的。Linux下的pthread_mutex_t锁默认是非递归的。可以显示的设置PTHREAD_MUTEX_RECURSIVE属性，将pthread_mutex_t设为递归锁。

pthread_mutex_init就是初始化上述的pthread_mutex_t内存结构 哪个文件



知识点：
`__attribute_noinline__` 

参考：
- https://blog.csdn.net/tlxamulet/article/details/79047717
- /home/yuanweijie/Workspace/glibc/mach/lowlevellock.h
- /home/yuanweijie/Workspace/glibc/nptl/pthread_mutex_lock.c

-----

[![forthebadge](http://forthebadge.com/images/badges/ages-20-30.svg)](http://forthebadge.com)
- GitHub：[AnSwErYWJ](https://github.com/AnSwErYWJ)
- Blog：[http://www.answerywj.com](http://www.answerywj.com)
- Email：[yuanweijie1993@gmail.com](https://mail.google.com)
- Weibo：[@AnSwEr不是答案](http://weibo.com/1783591593)