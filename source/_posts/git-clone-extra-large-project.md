---
title: Git仓库过大导致clone失败的解决方法
Antuor: AnSwEr(Weijie Yuan)
comments: true
toc: true
tags:
  - git仓库过大
date: 2019-09-09 12:00:40
categories: Git
---

本文记录工作中遇到的`clone`大仓库失败的解决过程，以下问题与解决方案均基于`https`访问。

----------

<!--more-->

## 错误一
从`web`端查看仓库大小，大约`1.5G`左右，首先直接执行`git clone`，报错如下：
```
remote: Counting objects: 10994, done.
remote: Compressing objects: 100% (3085/3085), done.
error: RPC failed; curl 56 GnuTLS recv error (-110): The TLS connection was non-properly terminated.
fatal: The remote end hung up unexpectedly
fatal: early EOF
fatal: index-pack failed
```

### 增大postBuffer
在增大`postBuffer`的同时，关闭`ssl`认证：
```
$ git config --global http.postBuffer 2048000000 # 设置为2G
$ git config --global http.sslVerify false # 关闭sslVerify
```
设置成功后，重新`clone`，错误依旧。

### 使用openssl替换gunssl
1.安装相关依赖环境：
```
$ sudo apt-get install build-essential fakeroot dpkg-dev libcurl4-openssl-dev
```

2.获取git源码：
```
$ sudo apt-get source git
```
若出现如下错误：
```
E: You must put some 'source' URIs in your sources.list
```
则需要将设置->`Software & Updates`->`Ubuntu Software`->`Source code`勾选：
![source_code](source_code.png)

若出现如下错误：
```
couldn't be accessed by user '_apt'. - pkgAcquire::Run (13: Permission denied) [duplicate]
```
则需要更改权限：
```
sudo chown _apt /var/lib/update-notifier/package-data-downloads/partial/
```

3.安装`git`的依赖
```
$ sudo apt-get build-dep git
```

4.进入`git`目录，重新编译：
```
$ cd git-2.7.4/
$ vim ./debian/control # 将libcurl4-gnutls-dev修改为libcurl4-openssl-dev
$ vim ./debian/rules # 整行删除TEST=test
$ sudo dpkg-buildpackage -rfakeroot -b -uc -us -j4 # 编译
```

5.回到上一级目录，安装编译好的安装包：
```
$ cd ..
$ sudo dpkg -i git_2.7.4-0ubuntuxxx_amd64.deb # 安装包名字可能有所不同
```

执行完成如上步骤后，重新`clone`，发现依旧报错，请看错误二。

## 错误二
```
remote: Counting objects: 10994, done.
remote: Compressing objects: 100% (3085/3085), done.
error: RPC failed; curl 18 transfer closed with outstanding read data remaining
fatal: The remote end hung up unexpectedly
fatal: early EOF
fatal: index-pack failed
```

重新确认`postBuffer`，配置确实生效了：
```
$ cat ~/.gitconfig

[http]
	sslVerify = false
	postBuffer = 2048000000
```

### 浅层clone
晕，实在搞不定了，采取极端方法，首先`clone`一层：
```
$ git clone --depth=1 http://xxx.git
```
浅层`clone`成功后，再完整拉取：
```
git fetch --unshallow
```

至此，终于成功地`clone`了一个完整的仓库。

## Reference

## About me
[![forthebadge](http://forthebadge.com/images/badges/ages-20-30.svg)](http://forthebadge.com)
- GitHub：[AnSwErYWJ](https://github.com/AnSwErYWJ)
- Blog：[http://www.answerywj.com](http://www.answerywj.com)
- Email：[yuanweijie1993@gmail.com](https://mail.google.com)
- Weibo：[@AnSwEr不是答案](http://weibo.com/1783591593)
- CSDN：[AnSwEr不是答案的专栏](http://blog.csdn.net/u011192270)

<a rel="license" href="http://creativecommons.org/licenses/by-sa/4.0/"><img alt="Creative Commons License" style="border-width:0" src="https://i.creativecommons.org/l/by-sa/4.0/88x31.png" /></a> This work is licensed under a <a rel="license" href="http://creativecommons.org/licenses/by-sa/4.0/">Creative Commons Attribution-ShareAlike 4.0 International License</a>.  
本作品采用知识共享署名-相同方式共享 4.0 国际许可协议进行许可。