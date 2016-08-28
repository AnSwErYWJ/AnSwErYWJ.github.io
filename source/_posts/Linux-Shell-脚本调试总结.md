---
title: Linux Shell 脚本调试总结
Antuor: AnSwEr(Weijie Yuan)
comments: true
toc: true
tags:
  - debug
date: 2016-07-14 14:15:14
categories: Linux
---

Shell脚本是用户与Linux操作系统交互的一种方式,在脚本编程过程中自然少不了进行调试工作,本文将介绍三种常用的调试方法.(默认使用bash shell)

-----

## 追踪脚本的执行
使用**-x**选项可以打印出脚本执行的每一行命令以及当前状态.
有如下脚本,打印数字1到10:
```
#!/bin/bash

for i in {1..10}
do
    echo $i
done
```
我们使用**-x**选项进行调试如下:
```
#在每一行前加上行号
export PS4='+${BASH_SOURCE}:${LINENO}:${FUNCNAME[0]}: '
#进行调试
sh -x test.sh
#调试结果
+test.sh:3:: for i in '{1..10}'
+test.sh:5:: echo 1
1
+test.sh:3:: for i in '{1..10}'
+test.sh:5:: echo 2
2
+test.sh:3:: for i in '{1..10}'
+test.sh:5:: echo 3
3
+test.sh:3:: for i in '{1..10}'
+test.sh:5:: echo 4
4
+test.sh:3:: for i in '{1..10}'
+test.sh:5:: echo 5
5
+test.sh:3:: for i in '{1..10}'
+test.sh:5:: echo 6
6
+test.sh:3:: for i in '{1..10}'
+test.sh:5:: echo 7
7
+test.sh:3:: for i in '{1..10}'
+test.sh:5:: echo 8
8
+test.sh:3:: for i in '{1..10}'
+test.sh:5:: echo 9
9
+test.sh:3:: for i in '{1..10}'
+test.sh:5:: echo 10
10
```

有时候,你只需要对脚本的一部分进行调试,那么可以使用如下命令:
```
set -x #在执行时显示参数和命令
set +x #禁止调试
set -v #当命令行读取时显示输入
set +v #禁止打印输入
```
可以使用**set builtin**来启用或者禁止调试打印.
对上文脚本做如下修改:
```
#!/bin/bash

for i in {1..10}
do
    set -x
    echo $i
    set +x
done
```
结果如下:
```
+test.sh:6:: echo 1
1
+test.sh:7:: set +x
+test.sh:6:: echo 2
2
+test.sh:7:: set +x
+test.sh:6:: echo 3
3
+test.sh:7:: set +x
+test.sh:6:: echo 4
4
+test.sh:7:: set +x
+test.sh:6:: echo 5
5
+test.sh:7:: set +x
+test.sh:6:: echo 6
6
+test.sh:7:: set +x
+test.sh:6:: echo 7
7
+test.sh:7:: set +x
+test.sh:6:: echo 8
8
+test.sh:7:: set +x
+test.sh:6:: echo 9
9
+test.sh:7:: set +x
+test.sh:6:: echo 10
10
+test.sh:7:: set +x
```

## 自定义日志
上面这种调试手段是bash内建的,而且输出格式固定而且繁琐.所以我们需要根据需要的信息,自定义格式来显示调试信息,通过设定_DEBUG环境变量来完成:
```
#!/bin/bash

# run:_DEBUG=on sh debug.sh

function DEBUG()
{
    [ "$_DEBUG" == "on" ] && $@ || :
}

for i in {1..5}
do
    DEBUG echo -e "This is debug line!"
    echo $i
done

```
我们将_DEBUG环境变量设定为一个开关,只有打开时才会输出调试日志.
使用如上脚本结果如下:
```
[aidu1602@ResU10 tools]$ _DEBUG=on sh debug.sh
This is debug line!
1
This is debug line!
2
This is debug line!
3
This is debug line!
4
This is debug line!
5
```
这样我们就可以自定义调试信息,并且可以控制调试开关啦.

## 使用专用调试器
如果你需要调试一个非常复杂的脚本,并且需要一个及其专业的调试器,像GDB那样,那么我推荐这款开源的脚本调试器[bashdb](http://bashdb.sourceforge.net/),具体使用可以参考它的[文档](http://bashdb.sourceforge.net/bashdb.html).

## About me
[![forthebadge](http://forthebadge.com/images/badges/ages-20-30.svg)](http://forthebadge.com)
- GitHub：[AnSwErYWJ](https://github.com/AnSwErYWJ)
- Blog：[http://www.answerywj.com](http://www.answerywj.com)
- Email：[yuanweijie1993@gmail.com](https://mail.google.com)
- Weibo：[@AnSwEr不是答案](http://weibo.com/1783591593)
- CSDN：[AnSwEr不是答案的专栏](http://blog.csdn.net/u011192270)

<a rel="license" href="http://creativecommons.org/licenses/by-sa/4.0/"><img alt="Creative Commons License" style="border-width:0" src="https://i.creativecommons.org/l/by-sa/4.0/88x31.png" /></a> This work is licensed under a <a rel="license" href="http://creativecommons.org/licenses/by-sa/4.0/">Creative Commons Attribution-ShareAlike 4.0 International License</a>.
本作品采用知识共享署名-相同方式共享 4.0 国际许可协议进行许可。


