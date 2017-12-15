---
title: 线程同步机制条件变量的使用与思考
Antuor: AnSwEr(Weijie Yuan)
toc: true
date: 2017-12-15 22:23:08
categories: C
tags: pthread
---
条件变量是*Linux*线程同步的一种机制，与互斥量一起使用时，允许线程以无竞争的方式等待特定条件的发生

------
<!--more-->

[TOC]

## 关键函数
### 初始化与注销
```
#include <pthread.h>

// 静态初始化
pthread_cond_t cond = PTHREAD_COND_INITIALIZER;

// 动态初始化
int pthread_cond_init(thread_cond_t *cond, 
                      const pthread_condattr_t *attr);

// 反初始化，即注销
int pthread_cond_destroy(pthread_cond_t *cond);

返回值: 若成功，返回0；否则，返回错误编码
```
注意：
+ 只有在没有线程在该条件变量上等待时，才可以注销条件变量，否则会返回`EBUSY`
+  `Linux`在实现条件变量时，并没有为条件变量分配资源，所以在注销一个条件变量时，只需要注意该变量是否仍有等待线程即可

### 线程等待
```
#include <pthread.h>

int pthread_cond_wait(pthread_cond_t *cond, 
                      pthread_mutex_t *mutex);

int pthread_cond_timedwait(pthread_cond_t *cond, 
                           pthread_mutex_t *mutex, 
                           const struct timespec *abstime);

返回值: 若成功，返回0；否则，返回错误编码
```
执行过程如下：
1. 调用者把锁住的互斥量传给函数，然后函数自动把调用线程放到等待条件的线程列表上
2. 对互斥量进行解锁，线程挂起进入等待(不占用`CPU`时间)　
3. 函数被唤醒返回时，会自动对互斥量进行加锁

> `pthread_cond_timedwait`只是多了一个等待超时时间，通过`timespec`指定，超时返回错误`ETIMEDOUT`

### 线程唤醒
```
#include <pthread.h>

int pthread_cond_signal(pthread_cond_t *cond);

int pthread_cond_broadcast(pthread_cond_t *cond);

返回值: 若成功，返回0；否则，返回错误编码
```
+ `pthread_cond_signal`至少能唤醒一个等待该条件的线程
+ `pthread_cond_broadcast`则能唤醒等待该条件的所有线程
> 需要注意的是，一定要在改变条件状态以后再给线程发信号

## 示例
示例代码可参考我的[github](https://github.com/AnSwErYWJ/DogFood/blob/24acbfdd45e80032c988ccd05e3b12f9cfe01849/C/thread/t_cond.c)，由于篇幅原因，不在此贴出

## 一些思考
### 条件变量实质是什么
条件变量实质是利用线程间共享的全局变量进行同步的一种机制

### 互斥量保护的是什么
示例中的相关代码
```
pthread_mutex_lock(&(test->mut));

while (test->condition == 0)
{
  pthread_cond_wait(&(test->cond), &(test->mut));
}
    
pthread_mutex_unlock(&(test->mut));
```
互斥量是用来保护条件`test->condition`在读取时，它的值不被其它线程修改，如果条件成立，则此线程进入等待条件的线程队列，对互斥量进行解锁并开始等待

### 为什么用while来判断条件
如上面的代码所示，使用`while`对条件进行判断的原因如下：
1. 若先解锁互斥量，再唤醒等待线程，则条件可能被其它线程更改，使得等待条件再次成立，需要继续等待
2. `pthread_cond_wait`可能存在意外返回的情况，则此时条件并没有被更改，需要继续等待。
> 造成意外返回的原因是`Linux`中带阻塞功能的系统调用都会在进程收到`signal`后返回

### 先唤醒线程还是先解锁
示例代码：
1. 情况一：先唤醒
```
pthread_mutex_lock(&(test->mut));
test->condition = 1
pthread_cond_signal(&(test->cond));
pthread_mutex_unlock(&(test->mut));
```

2. 情况二：先解锁
```
pthread_mutex_lock(&(test->mut));
test->condition = 1
pthread_mutex_unlock(&(test->mut));
pthread_cond_signal(&(test->cond));
```
两种情况各有缺点：
+ 情况一在唤醒等待线程后，再解锁，使得等待线程在被唤醒后试图对互斥量进行加锁时，互斥量还未解锁，则线程又进入睡眠，待互斥量解锁成功后，再次被唤醒并对互斥量加锁，这样就会发生两次上下文切换，影响性能
+ 情况二在唤醒等待线程前先解锁，使得其它线程可能先于等待线程获取互斥量，并对条件进行更改，使得条件变量失去作用

## Reference
- [关于pthread_cond_wait使用while循环判断的理解](https://www.cnblogs.com/leijiangtao/p/4028338.html)
- [Linux线程同步之条件变量pthread_cond_t](https://www.cnblogs.com/zhx831/p/3543633.html)
- [APUE]()

## About me
[![forthebadge](http://forthebadge.com/images/badges/ages-20-30.svg)](http://forthebadge.com)
- GitHub：[AnSwErYWJ](https://github.com/AnSwErYWJ)
- Blog：[http://www.answerywj.com](http://www.answerywj.com)
- Email：[yuanweijie1993@gmail.com](https://mail.google.com)
- Weibo：[@AnSwEr不是答案](http://weibo.com/1783591593)
- CSDN：[AnSwEr不是答案的专栏](http://blog.csdn.net/u011192270)

<a rel="license" href="http://creativecommons.org/licenses/by-sa/4.0/"><img alt="Creative Commons License" style="border-width:0" src="https://i.creativecommons.org/l/by-sa/4.0/88x31.png" /></a> This work is licensed under a <a rel="license" href="http://creativecommons.org/licenses/by-sa/4.0/">Creative Commons Attribution-ShareAlike 4.0 International License</a>.  
本作品采用知识共享署名-相同方式共享 4.0 国际许可协议进行许可。

