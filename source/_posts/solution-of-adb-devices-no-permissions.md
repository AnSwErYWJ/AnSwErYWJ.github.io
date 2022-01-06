---
title: Linux下adb devices no permissions解决方案
Antuor: AnSwEr(Weijie Yuan)
comments: true
toc: true
tags:
  - adb
date: 2016-07-14 14:11:03
categories: 系统配置
---

Linux下adb工具[下载](http://pan.baidu.com/s/1qYhBG2w)，下载解压到*/usr/bin*目录。

----------
<!--more-->

## 问题
当我们在Linux下连接安卓手机，进行adb调试时，执行
```
$ adb devices
```
会出现如下错误提示：
```
List of devices attached
???????????? no permissions
```

## 解决方案
首先创建一个规则配置文件：
```
$ sudo vi /etc/udev/rules.d/70-android.rules
```
保存并退出。

查看USB设备信息，拔掉设备再查看一次，就可以比较出安卓设备是哪一个了，我的设备信息如下：
```
$ lsusb
Bus 003 Device 011: ID 1f3a:1002 Onda (unverified)
```

打开刚才的规则配置文件，写入如下内容：
```
SUBSYSTEM=="usb",ATTRS{idVendor}=="1f3a",ATTRS{idProduct}=="1002", MODE="0666"
```
其中idvendor和idProduct指的是usb的id号，ID 1f3a是idVendor ，1002就是 idProduct。

然后赋予文件权限
```
$ sudo chmod a+x /etc/udev/rules.d/70-android.rules
```

重启udev：
```
$ sudo /etc/init.d/udev restart
```

 注意，这里一定要拔掉设备再重连！然后执行如下命令：
```
 $ sudo adb kill-server
 $ adb devices
```
显示信息如下：
```
* daemon not running. starting it now on port 5037 *
* daemon started successfully *
List of devices attached
20080411	device
```
那么说明连接成功，可以正常进行调试了。

-----

<a href="#"><img src="https://img.shields.io/badge/Author-AnSwErYWJ-blue" alt="Author"></a>
- GitHub：[AnSwErYWJ](https://github.com/AnSwErYWJ)
- Blog：[https://www.answerywj.com](https://www.answerywj.com) 
- Email：[yuanweijie1993@gmail.com](https://mail.google.com)
- Weibo：[AnSwEr不是答案](https://weibo.com/1783591593)