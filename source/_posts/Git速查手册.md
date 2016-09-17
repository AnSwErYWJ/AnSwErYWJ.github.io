---
title: Git速查手册
Antuor: AnSwEr(Weijie Yuan)
toc: true
date: 2016-08-28 21:42:40
categories: Git
tags: git
---

本手册旨在记录实际工程项目中使用的git命令，方便查找。

----------

## 配置git
笔者使用的是v2.1.0，推荐大家使用v1.8以上的[版本](https://git-scm.com/downloads)。 查看git版本：
```
$ git --version
```
配置命令``git config``分为三个级别：
```
--system : 系统级,位于 /etc/gitconfig .
--global : 用户级,位于 ~/.gitconfig .
--local : 仓库级,位于 repo/.git/config ,default并且优先级最高.
```
首先需要删除global用户信息,防止不同git软件之间的冲突：
```
$ git config --global --unset user.name
$ git config --global --unset user.email
```
设置用户信息.若同时使用gitlab和github,推荐配置local用户信息：
```
$ git config --local user.name "username"
$ git config --local user.email "email"
```

git支持https和ssh等协议.https除了速度慢以外，还有个最大的麻烦是每次推送都必须输入口令，而ssh支持的原生git协议速度最快。
当ssh配置完成后，再次检查ssh连接情况：
```
$ ssh -T git@github.com
Hi! You’ve successfully authenticated, but GitHub does not provide shell access.
```
若出现上述信息，则表示设置成功。
若使用https访问, 则进行如下配置,并且设置超时时间避免重复输入密码：
```
$ git config --global http.sslverify false
$ git config --global credential.helper 'cache --timeout=3600'
```
设置可视化diff和merge工具, linux系统上推荐使用meld或者diffuse：
```
$ git config --global diff.tool meld
$ git config --global merge.tool meld
```
设置颜色,利于使用：
```
$ git config --global color.ui.true
```
设置别名：
```
$ git config --global alias checkout co 
```
> 上面的命令将``checkout``设置为别名``co``。

最后,查看一下所有的设置：
```
$ git config --local --list
$ git config --global --list
$ git config --system --list
```


## 工作流
![工作流](http://o9zpdspb3.bkt.clouddn.com/git%E5%B7%A5%E4%BD%9C%E6%B5%81.jpg)

工作区就是你的本地仓库文件夹,不过其中的``.git``目录不属于工作区,而是版本库。里面存了很多东西，其中最重要的就是称为stage（或者叫index）的暂存区，还有Git为我们自动创建的第一个分支master，以及指向master的一个指针叫HEAD。  
现在来解释一下前面的添加和提交操作：  
1. ``git add``把文件添加进去，实际上就是把文件修改添加到暂存区；
2. ``git commit``提交更改，实际上就是把暂存区的所有内容提交到当前分支。
因为我们创建Git版本库时，Git自动为我们创建了唯一一个master分支，所以，现在，git commit就是往master分支上提交更改。

## 基本操作
获取远程仓库：
```
$ git clone git@github.com:USERNAME/repo.git
```
将本地的仓库添加到远程：
```
$ cd repo
$ git init
$ git remote add origin git@github.com:USERNAME/repo.git
```
> ``origin``为远程仓库。

添加修改:
```
$ git add <filename> 
$ git add .  # 添加当前目录所有修改过的文件  
$ git add *  # 递归地添加执行命令时所在的目录中的所有文件
```

提交修改:
```
$ git commit -m "commit message"
$ git commit -am "commit message"
```
> ``commit message``的填写可以参考[写好 Git Commit 信息的 7 个建议](http://blog.jobbole.com/92713/)。  
> ``am``将添加和提交合并为一步,但只对本来就存在的文件有效。


推送修改：
```
$ git push -u origin <feature-branch-name>
```
> ``-u``选项可以将本地分支与远程分支关联,下次``git pull``操作时可以不带参数.具体参见[这里](http://stackoverflow.com/questions/5697750/what-exactly-does-the-u-do-git-push-u-origin-master-vs-git-push-origin-ma)。

查看远程仓库：
```
$ git remote -v
origin git@github.com:USERNAME/repo.git (push)
origin git@github.com:USERNAME/repo.git (fetch)
```

fork后同步上游仓库的更新：
```
# 第一次需要添加上游仓库
$ git remote add upstream git@github.com:USERNAME/repo.git
 
$ git remote -v
origin  git@github.com:USERNAME/repo.git (push)
origin  git@github.com:USERNAME/repo.git (fetch)
upstream  git@github.com:USERNAME/repo.git  (push)
upstream  git@github.com:USERNAME/repo.git (fetch)

$ git fetch upstream 
$ git difftool <branch-name> upstream/master
$ git merge upstream/master
$ git mergetool
```

引用公共代码：
代码引用在git上有两种方式：``submodule``和``subtree``，推荐使用[subtree](http://aoxuis.me/post/2013-08-06-git-subtree)方式。
``` 
# 第一次初始化
$ git remote add -f <remote-subtree-repository-name> <remote-subtree-repository-url>
$ git subtree add --prefix=<local-subtree-directory> <remote-subtree-repository> <remote-subtree-branch-name> --squash

# 同步subtree的更新
$ git subtree pull --prefix=<local-subtree-directory> <remote-subtree-repository> <remote-subtree-branch-name> --squash

# 推送到远程subtree库
$ git subtree push --prefix=<local-subtree-directory> <remote-subtree-repository> <remote-subtree-branch-name>
```

## 使用标签
查看标签 ：
```
$ git tag
```

创建标签 ：
``` 
$ git tag -a <tagname> -m "tag message" # 创建标签在当前最新提交的commit上
$ git tag -a <tagname> -m "tag message" <commit id> # 创建标签在指定的commit上
```
推送标签到远程：
```
$ git push origin <tagname> # 推送一个本地标签
$ git push origin --tags # 推送全部未推送过的本地标签
```
删除标签：
```
$ git tag -d <tagname> # 删除一个本地标签；
$ git push origin :refs/tags/<tagname> # 删除一个远程标签。
```

## 撤销与回退
查看当前仓库状态:
```
$ git status
```
查看文件更改：
```
$ git difftool <filename>
$ git mergetool <filename>
```

查看提交历史:
```
$ git log
```

撤销工作区的修改：
```
$ git checkout -- <filename> 
```

回退版本，即回退暂存区的修改：
```
$ git reset --hard <commit-id>
```
> 上一个版本的``commit-id``可以用``HEAD^``表示，上上个版本为``HEAD^^``，以此类推。

从版本库删除文件：
```
$ git rm <filename>
```

## 分支
查看所有分支，有``*``标记的是当前分支：
```
$ git branch -a
```
创建本地分支：
```
$ git checkout <newbranch>
```

创建并切换本地分支：
```
$ git checkout -b <newbranch>
```

删除本地分支：
```
$ git branch -d <branch>
```
> 若当前分支因为有修改未提交或其它情况不能删除，请使用``-D``选项强制删除。

删除远程分支：
```
$ git push origin --delete <remote-branch-name>
```

清除无用的分支：
```
$ git remote prune origin
```
> 说明：remote上的一个分支被其他人删除后，需要更新本地的分支列表。

获取远程分支到本地已有分支：
```
$ git branch --set-upstream <local-branch> origin/branch
```

获取远程分支到本地并新建本地分支：
```
$ git checkout -b <local-branch> <remote-branch>
```

同步当前分支的更新，使用``git pull``并不保险：
```
# 下载最新的代码到远程跟踪分支, 即origin/<branch-name>
$ git fetch origin <branch-name> 
# 查看更新内容
$ git difftool <branch-name> origin/<branch-name>
# 尝试合并远程跟踪分支的代码到本地分支 
$ git merge origin/<branch-name>
# 借助mergetool解决冲突              
$ git mergetool                               
```

同步其它分支的更新，本例拉取``master``分支更新：
```
$ git fetch origin master
$ git difftool <branch-name> origin/master
$ git merge origin/master
$ git mergetool
```

## 其它
查看帮助：
```
$ git --help
```

### 忽略特殊文件
当你的仓库中有一些文件，类似密码或者数据库文件不需要提交但又必须放在仓库目录下，每次``git status``都会提示``Untracked``，看着让人很不爽。解决这个问题只需要在仓库目录创建一个``.gitignore``文件即可，编写规则如下：
``
tmp/  # 忽略tmp文件夹下所有内容
*.ini # 忽略所有ini文件
!data/ #忽略除了data文件夹的所有内容
``
当然你不必从头编写``.gitignore``文件，已经有[模版](https://github.com/github/gitignore)提供使用了。  

本规则只忽略那些原来没有被track的文件，如果某些文件已经被纳入了版本管理中，则修改``.gitignore``是无效的。解决方法就是先把本地缓存删除,改变成未track状态：
```
$ git rm -r --cached .
```

### 处理大型二进制文件

由于git在存储二进制文件时效率不高,所以需要借助[第三方组件](http://www.oschina.net/news/71365/git-annex-lfs-bigfiles-fat-media-bigstore-sym)。

## Reference
1. [廖雪峰老师的git教程](http://www.liaoxuefeng.com/wiki/0013739516305929606dd18361248578c67b8067c8c017b000)
2. [常用Git命令清单](http://www.ruanyifeng.com/blog/2015/12/git-cheat-sheet.html)
3. [Git-Book](https://git-scm.com/book/en/v2)
4. [Git-Reference](https://git-scm.com/docs)


## About me
[![forthebadge](http://forthebadge.com/images/badges/ages-20-30.svg)](http://forthebadge.com)
- GitHub：[AnSwErYWJ](https://github.com/AnSwErYWJ)
- Blog：[http://www.answerywj.com](http://www.answerywj.com)
- Email：[yuanweijie1993@gmail.com](https://mail.google.com)
- Weibo：[@AnSwEr不是答案](http://weibo.com/1783591593)
- CSDN：[AnSwEr不是答案的专栏](http://blog.csdn.net/u011192270)

<a rel="license" href="http://creativecommons.org/licenses/by-sa/4.0/"><img alt="Creative Commons License" style="border-width:0" src="https://i.creativecommons.org/l/by-sa/4.0/88x31.png" /></a> This work is licensed under a <a rel="license" href="http://creativecommons.org/licenses/by-sa/4.0/">Creative Commons Attribution-ShareAlike 4.0 International License</a>.  
本作品采用知识共享署名-相同方式共享 4.0 国际许可协议进行许可。
