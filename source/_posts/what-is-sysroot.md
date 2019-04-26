---
title: sysroot为何物?
Antuor: AnSwEr(Weijie Yuan)
comments: true
toc: true
tags:
  - ld
  - sysroot
date: 2019-04-26 17:59:57
categories: Compile
---

本文介绍链接过程中sysroot的作用。

-----

<!--more-->

## sysroot为何物
`sysroot`作为逻辑根目录
将`sysroot`配置如下：
```
--sysroot=dir
```

将dir作为逻辑根目录(搜索头文件和库文件)。编译器通常会在 /usr/include 和 /usr/lib 中搜索头文件和库，
使用这个选项后将在 dir/usr/include 和 dir/usr/lib 目录中搜索。


--sysroot 的作用

如果在编译时指定了-sysroot就是为编译时指定了逻辑目录。编译过程中需要引用的库，头文件，如果要到/usr/include目录下去找的情况下，则会在前面加上逻辑目录。

如此处我们指定 -sysroot=/home/shell.albert/tools/toolschain_arm/4.4.3/arm-none-linux-gnueabi/sys-root

则如果在编译过程中需要找stdio.h，则会用/usr/include/目录下去找，因为我们指定了系统目录，则会到下面的路径去找。



如果使用这个选项的同时又使用了 -isysroot 选项，则此选项仅作用于库文件的搜索路径，而 -isysroot 选项将作用于头文件的搜索路径。这个选项与优化无关，但是在 CLFS 中有着神奇的作用。


意思到了，我说的更准确一点 --sysroot只在链接的时候起作用，在预编译（就是头文件展开，宏展开）
的时候不起作用。-I是找头文件的，所以--sysroot不影响 -I


我们在编译的时候会用到一些系统根目录中的文件，例如我们为PC上的Linux编译一些C/C++代码的时候要用到/usr/include中的头文件，还要用到/usr/lib中的一些库，还可能要执行/bin下的一些程序。但是此时我们是要为Android平台进行交叉编译，此时用到的头文件、库等得是Android平台的，因此我们要使用交叉编译工具提供的系统根目录$ANDROID_BUILD/sysroot


       --sysroot=directory
           Use directory as the location of the sysroot, overriding the configure-time
           default.  This option is only supported by linkers that were configured
           using --with-sysroot.


                  -L searchdir
       --library-path=searchdir
           Add path searchdir to the list of paths that ld will search for archive
           libraries and ld control scripts.  You may use this option any number of
           times.  The directories are searched in the order in which they are
           specified on the command line.  Directories specified on the command line
           are searched before the default directories.  All -L options apply to all -l
           options, regardless of the order in which the options appear.  -L options do
           not affect how ld searches for a linker script unless -T option is
           specified.

           If searchdir begins with "=", then the "=" will be replaced by the sysroot
           prefix, controlled by the --sysroot option, or specified when the linker is
           configured.

           The default set of paths searched (without being specified with -L) depends
           on which emulation mode ld is using, and in some cases also on how it was
           configured.

           The paths can also be specified in a link script with the "SEARCH_DIR"
           command.  Directories specified this way are searched at the point in which
           the linker script appears in the command line.


            The linker uses the following search paths to locate required shared
           libraries:

           1.  Any directories specified by -rpath-link options.

           2.  Any directories specified by -rpath options.  The difference between
               -rpath and -rpath-link is that directories specified by -rpath options
               are included in the executable and used at runtime, whereas the
               -rpath-link option is only effective at link time. Searching -rpath in
               this way is only supported by native linkers and cross linkers which
               have been configured with the --with-sysroot option.

           3.  On an ELF system, for native linkers, if the -rpath and -rpath-link
               options were not used, search the contents of the environment variable
               "LD_RUN_PATH".

           4.  On SunOS, if the -rpath option was not used, search any directories
               specified using -L options.

           5.  For a native linker, search the contents of the environment variable
               "LD_LIBRARY_PATH".

           6.  For a native ELF linker, the directories in "DT_RUNPATH" or "DT_RPATH"
               of a shared library are searched for shared libraries needed by it. The
               "DT_RPATH" entries are ignored if "DT_RUNPATH" entries exist.

           7.  The default directories, normally /lib and /usr/lib.

           8.  For a native linker on an ELF system, if the file /etc/ld.so.conf
               exists, the list of directories found in that file.

           If the required shared library is not found, the linker will issue a warning
           and continue with the link.

## About me
[![forthebadge](http://forthebadge.com/images/badges/ages-20-30.svg)](http://forthebadge.com)
- GitHub：[AnSwErYWJ](https://github.com/AnSwErYWJ)
- Blog：[http://www.answerywj.com](http://www.answerywj.com)
- Email：[yuanweijie1993@gmail.com](https://mail.google.com)
- Weibo：[@AnSwEr不是答案](http://weibo.com/1783591593)
- CSDN：[AnSwEr不是答案的专栏](http://blog.csdn.net/u011192270)

<a rel="license" href="http://creativecommons.org/licenses/by-sa/4.0/"><img alt="Creative Commons License" style="border-width:0" src="https://i.creativecommons.org/l/by-sa/4.0/88x31.png" /></a> This work is licensed under a <a rel="license" href="http://creativecommons.org/licenses/by-sa/4.0/">Creative Commons Attribution-ShareAlike 4.0 International License</a>.
本作品采用知识共享署名-相同方式共享 4.0 国际许可协议进行许可。