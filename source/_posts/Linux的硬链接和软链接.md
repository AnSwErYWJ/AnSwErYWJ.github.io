---
title: Linux的硬链接和软链接
Antuor: AnSwEr(Weijie Yuan)
comments: true
toc: true
tags:
  - link
date: 2016-08-02 11:46:09
categories: Linux
---

Linux下链接的命令是ln,可以通过```man ln```查看,ln命令会保证每一处的链接同步.

## 硬链接
1. 链接的是索引节点(inode),硬链接文件inode值相同(在Linux的文件系统的文件不管是什么类型都给它分配一个indoe号),所以硬链接文件不占用磁盘空间.相当于创建一个别名.
2. 有两个限制:目录不能创建硬链接;只能在同一个文件系统中进行硬链接.
3. 命令:```ln srouce dest```.
4. 对源文件进行修改或删除,硬链接文件会同步修改.但删除硬链接的源文件,硬链接文件仍然存在.

## 软链接
1. 软链接又称为符号链接,链接的是路径(path),链接文件中包含的是另一个文件的位置信息.
2. 可以是任意文件或者目录,可以链接不同文件系统的文件.
3. 可以链接不存在的文件,这种现象称为"断链";也可以链接自己
4. 命令:```ln -s srouce dest```,```source```最好用绝对路径表示,这样可以在任何目录下进行链接.若使用相对路径，如果当前的工作路径与要创建的符号链接文件所在路径不同，就不能进行链接.
5. 对源文件进行修改或删除,软链接文件会同步修改.

### 缺点:
1. 因为链接文件中包含的是另一个文件的位置信息，所以当源文件从一个目录移到其它目录中,再访问链接文件,系统就找不到了.
2. 需要系统分配额外的空间用于建立新的索引节点和保存源文件的路径.

## 理解
* 与windows类比
1. 硬链接类似复制,但与复制不同的是存在同步机制,一处的更改会同步到另一处,删除一处不会影响另一出.
2. 软链接相当于windows中的快捷方式.

* 硬链接可以防止误删
硬连接的作用是允许一个文件拥有多个有效路径名，因为多个硬链接文件指向同一个索引节点.这样用户就可以建立硬连接到重要文件,以防止“误删”的功能.只删除一个链接并不影响索引节点本身和其它的链接，只有当最后一个链接被删除后，文件的数据块及目录的链接才会被释放。也就是说，文件才会被真正删除。

* 硬链接的两个限制
虽然系统有目录不能创建硬链接的限制,但是命令```ln -d```可以让超级用户对目录作硬连接，这说明系统限制对目录进行硬连接只是一个硬性规定，并不是逻辑上不允许或技术上的不可行。那么为什么要做出这个硬性规定呢?
第一,如果引入了对目录的硬连接就有可能在目录中引入循环，那么在目录遍历的时候系统就会陷入无限循环当中。可是符号连接不也可以引入循环吗？因为在linux系统中，每个文件(目录也是文件)都对应着一个inode结构，其中inode数据结构中包含了文件类型(目录，普通文件，符号连接文件等等)的信息，也就是说操作系统在遍历目录时可以判断出符号连接，既然可以判断出符号连接当然就可以采取一些措施来防范进入过大的循环了，系统在连续遇到8个符号连接后就停止遍历，这就是为什么对目录符号连接不会进入死循环的原因了。但是对于硬连接，由于操作系统中采用的数据结构和算法限制，目前是不能防范这种死循环的。
第二,文件的dentry结构主要包含了文件名,文件的inode号,指向父目录dentry结构的指针和其他一些指针,这里关键是那个指向父目录的指针;系统中所有的dentry结构都是按杂凑值存放在杂凑表中的，这里的杂凑算法很重要，它是取文件名和文件的父目录dentry结构的地址一起杂凑运算出杂凑值的。现在我们假设有两个目录 /a和/b，其中/b是我们通过```ln -d```命令建立起来的对/a的硬连接。这个时候内核空间中就会存在一个/a的dentry结构和一个/b的dentry结构，由上面的知识可知，/a和/b目录下面的每一个文件或目录都各自有对应的dentry结构(因为虽然/a目录下面的文件名没有改变，但是因为dentry结构有指向父目录dentry 的指针和计算杂凑值时考虑了父目录dentry结构的地址，这个时候dentry结构就分身乏术了),而且这种继承还会影响到所有子目录下面的文件，这样下来就会浪费很多系统空间了,特别是如果被硬连接的目录中存在大量文件和子目录的时候就更加明显了.


## About me
[![forthebadge](http://forthebadge.com/images/badges/ages-20-30.svg)](http://forthebadge.com)
- GitHub：[AnSwErYWJ](https://github.com/AnSwErYWJ)
- Blog：[http://www.answerywj.com](http://www.answerywj.com)
- Email：[yuanweijie1993@gmail.com](https://mail.google.com)
- Weibo：[@AnSwEr不是答案](http://weibo.com/1783591593)
- CSDN：[AnSwEr不是答案的专栏](http://blog.csdn.net/u011192270)

<a rel="license" href="http://creativecommons.org/licenses/by-sa/4.0/"><img alt="Creative Commons License" style="border-width:0" src="https://i.creativecommons.org/l/by-sa/4.0/88x31.png" /></a> This work is licensed under a <a rel="license" href="http://creativecommons.org/licenses/by-sa/4.0/">Creative Commons Attribution-ShareAlike 4.0 International License</a>.
本作品采用知识共享署名-相同方式共享 4.0 国际许可协议进行许可。
