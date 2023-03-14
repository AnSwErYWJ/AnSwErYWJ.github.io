---
title: getrusage-进程资源统计函数
author: AnSwErYWJ
comments: true
category_bar: true
toc: true
tags:
  - getrusage
categories: C/C++
abbrlink: 16953
date: 2021-06-23 15:41:07
---

`getrusage`用于统计系统资源使用情况，即进程执行直到调用该函数时的资源使用情况，如果在不同的时间调用该函数，会得到不同的结果。

<!--more-->

## 简介
`getrusage`用于统计系统资源使用情况，即进程执行直到调用该函数时的资源使用情况，如果在不同的时间调用该函数，会得到不同的结果。
> 目前在`Linux`和`macOS`支持该函数。



## 函数说明
### 原型
```c
#include <sys/time.h>
#include <sys/resource.h>

int getrusage(int who, struct rusage *usage);
```
> `sys/time.h`：为了得到`timeval`结构体的声明，这个结构体实际上在`bits/time.h`中声明。



### 参数
**`who`**：资源统计的对象，有如下取值：

- `RUSAGE_SELF`：返回调用进程的资源使用统计信息，即该进程中所有线程使用的资源总和；
- `RUSAGE_CHILDREN`：返回调用进程所有已终止且被回收子进程的资源使用统计信息。如果进程有孙子进程或更远的后代进程，且这些后代进程和这些后代进程与调用进程之间的中间进程也已终止且被回收，那么这些后代进程的资源使用统计信息也会被统计；
- `RUSAGE_THREAD`（`Linux 2.6.26`起支持）：返回调用线程的资源使用统计信息；


| 宏定义 | 取值 |
| --- | --- |
| RUSAGE_SELF | 0 |
| RUSAGE_CHILDREN | -1 |
| RUSAGE_THREAD | 1 |



> 宏定义在`sys/resource.h`-> `bits/resource.h`。

**`usage`**：资源使用统计信息，用如下结构体的形式返回到该指针指向的内存空间：
```c
struct rusage {
    struct timeval ru_utime; /* user CPU time used */
    struct timeval ru_stime; /* system CPU time used */
    long   ru_maxrss;        /* maximum resident set size */
    long   ru_ixrss;         /* integral shared memory size */
    long   ru_idrss;         /* integral unshared data size */
    long   ru_isrss;         /* integral unshared stack size */
    long   ru_minflt;        /* page reclaims (soft page faults) */
    long   ru_majflt;        /* page faults (hard page faults) */
    long   ru_nswap;         /* swaps */
    long   ru_inblock;       /* block input operations */
    long   ru_oublock;       /* block output operations */
    long   ru_msgsnd;        /* IPC messages sent */
    long   ru_msgrcv;        /* IPC messages received */
    long   ru_nsignals;      /* signals received */
    long   ru_nvcsw;         /* voluntary context switches */
    long   ru_nivcsw;        /* involuntary context switches */
};
```
结构体`struct rusage`各个成员释义如下：

- `ru_utime`：返回进程在用户模式下的执行时间，以`timeval`结构的形式返回（该结构体在`bits/timeval`中声明）；
- `ru_stime`：返回进程在内核模式下的执行时间，以`timeval`结构的形式返回（该结构体在`bits/timeval`中声明）；
- `ru_maxrss`（`Linux 2.6.32`起支持）：返回`rss`（实际使用物理内存，包含共享库占用的内存）的大小，单位为`KB`；当`who`被指定为`RUSAGE_CHILDREN`时，返回各子进程`rss`的大小中最大的一个，而不是进程树中最大的`rss`；
- `ru_ixrss`：目前不支持；
- `ru_idrss`：目前不支持；
- `ru_isrss`：目前不支持；
- `ru_minflt`：缺页中断的次数，且处理这些中断不需要进行`I/O`，不需要进行`I/O`操作的原因是系统使用`reclaiming`的方式在物理内存中得到了之前被淘汰但是未被修改的页框。（第一次访问`bss`段时也会产生这种类型的缺页中断）；
- `ru_majflt`：缺页中断的次数，且处理这些中断需要进行`I/O`；
- `ru_nswap`：目前不支持；
- `ru_inblock`（`Linux 2.6.22`起支持）：文件系统需要进行输入操作的次数；
- `ru_oublock`（`Linux 2.6.22`起支持）：文件系统需要进行输出操作的次数；
- `ru_msgsnd`：目前不支持；
- `ru_msgrcv`：目前不支持；
- `ru_nsignals`：目前不支持；
- `ru_nvcsw`（`Linux 2.6`起支持）：因进程自愿放弃处理器时间片而导致的上下文切换的次数（通常是为了等待请求的资源）；
- `ru_nivcsw`（`Linux 2.6`起支持）：因进程时间片使用完毕或被高优先级进程抢断导致的上下文切换的次数；
> 其中有些结构体成员目前并不被`Linxu`支持，但是为了兼容其它系统以及未来扩展，仍被保留了下来，这些结构体成员在函数执行后会被内核默认设置为`0`。

### 返回值
**成功**：`0`；
**失败**：`-1`，并设置`errno`的值，包含如下两种错误：

- `EFAULT`：`usage`指针指向不可访问地址；
- `EINVAL`：`who`被指定为无效值；

### 属性
`getrusage`函数是线程安全的。
​
## 示例
```c
#include <stdio.h>

/* include for getrusage */
#ifndef _WIN32
#include <sys/time.h>
#include <sys/resource.h>
#endif

static void print_rusage() {
#ifndef _WIN32
	int ret;

	struct rusage usage;
    ret = getrusage(RUSAGE_SELF, &usage);
	if (0 != ret) {
		printf("getrusage failed\n");
		goto end;
	}

	printf("%s: %.3fms\n", "ru_utime", (usage.ru_utime.tv_sec * 1000.0 + usage.ru_utime.tv_usec / 1000.0));
	printf("%s: %.3fms\n", "ru_stime", (usage.ru_stime.tv_sec * 1000.0 + usage.ru_stime.tv_usec / 1000.0));
	printf("%s: %.3fM\n", "ru_maxrss", (usage.ru_maxrss / 1024.0));
	printf("%s: %ld\n", "ru_ixrss", usage.ru_ixrss);
	printf("%s: %ld\n", "ru_idrss", usage.ru_idrss);
	printf("%s: %ld\n", "ru_isrss", usage.ru_isrss);
	printf("%s: %ld\n", "ru_minflt", usage.ru_minflt);
	printf("%s: %ld\n", "ru_majflt", usage.ru_majflt);
	printf("%s: %ld\n", "ru_nswap", usage.ru_nswap);
	printf("%s: %ld\n", "ru_inblock", usage.ru_inblock);
	printf("%s: %ld\n", "ru_oublock", usage.ru_oublock);
	printf("%s: %ld\n", "ru_msgsnd", usage.ru_msgsnd);
	printf("%s: %ld\n", "ru_msgrcv", usage.ru_msgrcv);
	printf("%s: %ld\n", "ru_nsignals", usage.ru_nsignals);
	printf("%s: %ld\n", "ru_nvcsw", usage.ru_nvcsw);
	printf("%s: %ld\n", "ru_nivcsw", usage.ru_nivcsw);

#endif

end:
	return;
}
```
> 完整代码：[https://github.com/AnSwErYWJ/DogFood/blob/master/C/getrusage.c](https://github.com/AnSwErYWJ/DogFood/blob/master/C/getrusage.c)。

-----

<a href="#"><img src="https://img.shields.io/badge/Author-AnSwErYWJ-blue" alt="Author"></a>
- GitHub：[AnSwErYWJ](https://github.com/AnSwErYWJ)
- Blog：[https://www.answerywj.com](https://www.answerywj.com) 
- Email：[yuanweijie1993@gmail.com](https://mail.google.com)
- Weibo：[AnSwEr不是答案](https://weibo.com/1783591593)