---
title: C代码覆盖率测试教程
Antuor: AnSwEr(Weijie Yuan)
toc: true
date: 2018-09-25 18:48:49
categories: C
tags: 代码覆盖率
---

代码覆盖率测试反映了测试的广度与深度，量化了测试和开发质量，是十分有必要的，业界目前有针对各种语言的覆盖率测试工具，本文主要介绍`C/C++`相关的覆盖率测试工具`Gcov`和`Lcov`。
<!--more-->

## Gcov


## Reference
- [cJson源码和源码分析](https://github.com/faycheng/cJSON)


## About me
[![forthebadge](http://forthebadge.com/images/badges/ages-20-30.svg)](http://forthebadge.com)
- GitHub：[AnSwErYWJ](https://github.com/AnSwErYWJ)
- Blog：[http://www.answerywj.com](http://www.answerywj.com)
- Email：[yuanweijie1993@gmail.com](https://mail.google.com)
- Weibo：[@AnSwEr不是答案](http://weibo.com/1783591593)
- CSDN：[AnSwEr不是答案的专栏](http://blog.csdn.net/u011192270)

<a rel="license" href="http://creativecommons.org/licenses/by-sa/4.0/"><img alt="Creative Commons License" style="border-width:0" src="https://i.creativecommons.org/l/by-sa/4.0/88x31.png" /></a> This work is licensed under a <a rel="license" href="http://creativecommons.org/licenses/by-sa/4.0/">Creative Commons Attribution-ShareAlike 4.0 International License</a>.  
本作品采用知识共享署名-相同方式共享 4.0 国际许可协议进行许可。


gcovr的下载地址是：https://blog.csdn.net/zhouzhaoxiong1227/article/details/50352944?utm_source=copy 

代码覆盖率
-fprofile-arcs -ftest-coverage

分支覆盖率
gcovr -r . –branches

展示覆盖率的XML文件
gcovr -r . –xml-pretty

展示覆盖率的HTML文件
gcovr -r . –html -o FindStackDirection.html
添加“–html-details”选项为代码工程中的每个文件生成一个独立的web页