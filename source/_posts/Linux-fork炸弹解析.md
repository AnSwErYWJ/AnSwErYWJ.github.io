---
title: Linux fork炸弹解析
Antuor: AnSwEr(Weijie Yuan)
comments: true
toc: true
tags:
  - shell
date: 2016-07-14 13:52:31
categories: Shell
---

# Linux Fork Bomb
**:(){ :|: & };:**是一个bash函数，以Fork Bomb闻名，是一个拒绝服务攻击 的Linux 系统。如果你好奇地去执行了这个命令，那么赶快重启系统吧~！

## 命令解析
```
:()
{
	: | : &
};:
```
1. **：**在这里是一个函数名，我们定义之，并在后面执行它。
2. **：|：&**，：函数的输出通过管道传给另一个冒号函数作为输入，并且在后台执行。
3. **{ };**标识着里面的内容是一个函数主体。
4. 最后一个**：**为定义完成后的一次函数执行。

## 原理解析
1. 首先需要说明的是**:**是一个shell内置命令，所以上面这段代码只有在bash中才可能产生fork炸弹，因为在其他一些shell中，内置命令的优先级高于函数，所以执行*:*，总是执行内置命令。（**：**是一个空命令，while true等同于 while **：**，常用作占位符）
2.  先来看看函数的主体**：|：&**，使用管道的时候是两个进程同时开始执行。
3.  所以当执行一个**：**函数时，产生两个新进程，然后一个原来的进程退出，这样不停地递归下去，就产生了一个无限递归。按照这个增长模式的化，其增长趋势约为$2^n$。

## 总结
Linux中还有很多这样存在这陷阱的命令，这也正是我喜欢Linux系统的原因，充满着探索性。

## About me
[![forthebadge](http://forthebadge.com/images/badges/ages-20-30.svg)](http://forthebadge.com)
- GitHub：[AnSwErYWJ](https://github.com/AnSwErYWJ)
- Blog：[http://www.answerywj.com](http://www.answerywj.com)
- Email：[yuanweijie1993@gmail.com](https://mail.google.com)
- Weibo：[@AnSwEr不是答案](http://weibo.com/1783591593)
- CSDN：[AnSwEr不是答案的专栏](http://blog.csdn.net/u011192270)

<a rel="license" href="http://creativecommons.org/licenses/by-sa/4.0/"><img alt="Creative Commons License" style="border-width:0" src="https://i.creativecommons.org/l/by-sa/4.0/88x31.png" /></a> This work is licensed under a <a rel="license" href="http://creativecommons.org/licenses/by-sa/4.0/">Creative Commons Attribution-ShareAlike 4.0 International License</a>.
本作品采用知识共享署名-相同方式共享 4.0 国际许可协议进行许可。


