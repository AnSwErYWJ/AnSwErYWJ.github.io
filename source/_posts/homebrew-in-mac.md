---
title: Homebrew
Antuor: AnSwEr(Weijie Yuan)
comments: true
toc: true
tags:
  - mac
  - Homebrew
date: 2020-02-17 20:42:48
categories: Mac
---

本文将介绍`Homebrew`的安装与使用。

----------
<!--more-->

## Homebrew
### 简介
`Homebrew`是`OS X`上类似于`apt-get`和`yum`的软件包管理器，软件源依托于`Github`之上，所以在国内的网络环境之下，常常会出现使用`Homebrew`安装软件时，如`brew install sshfs`，经常会长时间卡在`Updating Homebrew...`。
> `OS X 10.9`开始支持

### 安装
首先安装依赖`Xcode命令行工具`：
```
$ xcode-select --install
```

然后安装`Homebrew`：
```
$ ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
```

### 卸载
```
$ ruby -e "$(curl -fsSL $https://raw.githubusercontent.com/Homebrew/install/master/uninstall)"
$ sudo rm -rf /usr/local/
```

## 解决软件源更新慢问题
### 取消更新
当安装过程中，卡在`Updating Homebrew...`时，我们可以按住`control + c`，来取消本次更新；之后命令行会显示`^C`，表示取消成功，后面会继续安装工作。
> 这个方法是临时，仅在本次安装生效。

### 关闭自动更新
`Homebrew`的软件源更新，是在每次安装时自动执行的，可以通过配置进行关闭。

`zsh`终端方式：
```
$ echo 'export HOMEBREW_NO_AUTO_UPDATE=true' >> ~/.zshrc
$ source ~/.zshrc
```

`bash`终端方式：
```
$ echo 'export HOMEBREW_NO_AUTO_UPDATE=true' >> ~/.bash_profile
$ source ~/.bash_profile
```
> 这个方法是永久的，每次安装都会生效，但弊端是无法获取最新的软件。

### 替换软件源
这里推荐中科大的镜像源，亲测可用。  
#### 替换homebrew源
```
$ cd "$(brew --repo)"
$ git remote set-url origin https://mirrors.ustc.edu.cn/brew.git
```

还原官方源：
```
$ cd "$(brew --repo)"
$ git remote set-url origin https://github.com/Homebrew/brew.git
```

#### 替换homebrew-core源(核心软件仓库)
```
$ cd "$(brew --repo)/Library/Taps/homebrew/homebrew-core"
$ git remote set-url origin https://mirrors.ustc.edu.cn/homebrew-core.git
```

还原官方源：
```
$ cd "$(brew --repo)/Library/Taps/homebrew/homebrew-core"
$ git remote set-url origin https://github.com/Homebrew/homebrew-core.git
```

#### 替换homebrew-cask源(macOS应用)
```
$ cd "$(brew --repo)"/Library/Taps/homebrew/homebrew-cask 
$ git remote set-url origin https://mirrors.ustc.edu.cn/homebrew-cask.git
```
若提示找不到`"$(brew --repo)"/Library/Taps/homebrew/homebrew-cask`，则：
```
$ cd "$(brew --repo)"/Library/Taps/homebrew/
$ git clone https://mirrors.ustc.edu.cn/homebrew-cask.git
```

还原官方源：
```
$ cd "$(brew --repo)"/Library/Taps/homebrew/homebrew-cask  
$ git remote set-url origin https://github.com/Homebrew/homebrew-cask
```

> `brew cask`安装软件，会自动创建软链接到`Application`目录，这样在`Launchpad`中也能查看到安装的软件，方便启动软件

#### 替换homebrew bottles源(预编译二进制软件包)
`zsh`终端方式：
```
$ echo 'export HOMEBREW_BOTTLE_DOMAIN=https://mirrors.ustc.edu.cn/homebrew-bottles' >> ~/.zshrc
$ source ~/.zshrc
```

`bash`终端方式：
```
$ echo 'export HOMEBREW_BOTTLE_DOMAIN=https://mirrors.ustc.edu.cn/homebrew-bottles' >> ~/.bash_profile
$ source ~/.bash_profile
```

还原官方源：进入如上终端配置文件，并删除`HOMEBREW_BOTTLE_DOMAIN`改行配置，并
`source`终端配置文件，使之生效。

## 常见错误
- `Error: Another active Homebrew update process is already in progress.`  
解决方法：`rm -rf /usr/local/var/homebrew/locks`

## 附
### Homebrew常用命令
- 查看Homebrew版本：
```
$ brew -v
```

- Homebrew帮助信息：
```
$ brew [cask] -h
```

- 更新Homebrew：
```
$ brew update
```

- 更新Homebrew cask：
```
$ brew cask upgrade
```

- 安装软件：
```
$ brew [cask] install <packageName>
```

- 卸载软件：
```
$ brew [cask] uninstall <packageName>
```

- 查询可用软件：
```
$ brew search <packageName>
```

- 查看已安装软件：
```
$ brew [cask] list
```

- 查看软件信息：
```
$ brew [cask] info <packageName>
```

### 确认shell版本方式
```
$ echo $SHELL
```
> 输出`/bin/zsh`为`zsh`终端，输出`/bin/bash`为`bash`终端。

## About me
[![forthebadge](http://forthebadge.com/images/badges/ages-20-30.svg)](http://forthebadge.com)
- GitHub：[AnSwErYWJ](https://github.com/AnSwErYWJ)
- Blog：[http://www.answerywj.com](http://www.answerywj.com)
- Email：[yuanweijie1993@gmail.com](https://mail.google.com)
- Weibo：[@AnSwEr不是答案](http://weibo.com/1783591593)
- CSDN：[AnSwEr不是答案的专栏](http://blog.csdn.net/u011192270)

<a rel="license" href="http://creativecommons.org/licenses/by-sa/4.0/"><img alt="Creative Commons License" style="border-width:0" src="https://i.creativecommons.org/l/by-sa/4.0/88x31.png" /></a> This work is licensed under a <a rel="license" href="http://creativecommons.org/licenses/by-sa/4.0/">Creative Commons Attribution-ShareAlike 4.0 International License</a>.  
本作品采用知识共享署名-相同方式共享 4.0 国际许可协议进行许可。