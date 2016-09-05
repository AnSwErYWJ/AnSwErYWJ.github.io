---
title: Shell脚本浮点运算
Antuor: AnSwEr(Weijie Yuan)
comments: true
toc: true
tags:
  - script
date: 2016-09-05 14:58:50
categories: Linux
---

本文将介绍几种Linux下通过Shell脚本进行浮点数计算的方法。
---------------------
## Why
Bash Shell本身不具备处理浮点计算的能力, 如`expr`命令只支持整数运算 :
```
#!/bin/bash
a=59
b=60
expr $a / $b
```
运行结果 :
```
$ ./cal.sh
0
$
```

## Plan A
使用``bc``进行处理。
代码 :
```
#!/bin/bash

a=59
b=60
echo "scale=4; $a / $b" | bc
```
运行结果 :
```
$ ./bc.sh
.9833
$
```
> ``scale``表示结果的小数精度。

## Plan B
使用``awk``进行处理。
代码 :
```
#!/bin/bash
a=59
b=60
awk 'BEGIN{printf "%.2f\n",('$a'/'$b')}'
```

运行结果 :
```
$ ./awk.sh
0.98
$
```


## Compare
使用bc :
| 执行次数     | real time  |  user time  | sys time |
| ------------- |:---:| :-----:| :-----:|
| 10      | 0.100 s | 0.002 s | 0.005 s|
| 100      | 0.296 s |   0.074 s | 0.175 s|
| 1000 | 1.144 s  |    0.158 s | 0.524 s|
| 10000 | 16.252 s      |    3.286 s | 8.769 s|

使用awk :
| 执行次数     | real time  |  user time  | sys time |
| ------------- |:---:| :-----:| :-----:|
| 10      | 0.029 s | 0.007 s | 0.017 s|
| 100      | 0.250 s     |   0.069 s | 0.119 s|
| 1000 | 0.765 s      |    0.105 s | 0.185 s|
| 10000 | 7.389 s      |    0.790 s | 1.509 s|

> 可以看出使用``awk``的效率更高,特别是运算次数比较大时。

## About me
[![forthebadge](http://forthebadge.com/images/badges/ages-20-30.svg)](http://forthebadge.com)
- GitHub：[AnSwErYWJ](https://github.com/AnSwErYWJ)
- Blog：[http://www.answerywj.com](http://www.answerywj.com)
- Email：[yuanweijie1993@gmail.com](https://mail.google.com)
- Weibo：[@AnSwEr不是答案](http://weibo.com/1783591593)
- CSDN：[AnSwEr不是答案的专栏](http://blog.csdn.net/u011192270)

<a rel="license" href="http://creativecommons.org/licenses/by-sa/4.0/"><img alt="Creative Commons License" style="border-width:0" src="https://i.creativecommons.org/l/by-sa/4.0/88x31.png" /></a> This work is licensed under a <a rel="license" href="http://creativecommons.org/licenses/by-sa/4.0/">Creative Commons Attribution-ShareAlike 4.0 International License</a>.
本作品采用知识共享署名-相同方式共享 4.0 国际许可协议进行许可。
