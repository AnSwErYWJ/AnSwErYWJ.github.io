---
title: Git速查手册（第二版）
author: AnSwErYWJ
comments: true
category_bar: true
toc: true
tags:
  - git
categories: Git
abbrlink: 23935
date: 2019-02-12 12:02:40
---

本文是对之前[Git速查手册](http://answerywj.com/2016/08/28/Git%E9%80%9F%E6%9F%A5%E6%89%8B%E5%86%8C/)的更新，增加了一些这段时间使用到的命令。

<!--more-->

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
检查本机SSH公钥:
```
$ ls ~/.ssh
```
若存在,则将`id_rsa.pub`添加到github的SSH keys中。若不存在,则生成:
```
$ ssh-keygen -t rsa -C "your_email@youremail.com" 
```
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
保存用户名,密码, 避免每次`pull/push`操作都需要手动输入：
```
$ git config --global credential.helper store
# 执行上免的命令后, 下次操作输入的密码会被保存
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
![工作流](git-work-flow.jpg)

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
> ``origin``就是一个名字，是``git``为你默认创建的指向这个远程代码库的标签。

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
$ git log --pretty=oneline #只保留commit id 和 commit message
```

撤销工作区``Tracked files``的修改：
```
$ git checkout -- <filename>
```

撤销工作区``Untracked files``的修改：
```
#####
# n:查看将会删除的文件，防止误删
# f:Untracked的文件
# d:Untracked的目录
# x:包含gitignore的Untracked文件和目录一并删掉，慎用！
#####

git clean -nfd
git clean -fd
```

回退版本区(`git commit`)和暂存区(`git add`)，不删除工作空间代码：
```
$ git reset --mixed HEAD^ # --mixed为默认参数
$ git reset HEAD^
```

回退版本区(`git commit`)，暂存区(`git add`)不回退，不删除工作空间代码：
```
$ git reset --soft HEAD^
```

回退版本区(`git commit`)和暂存区(`git add`)，并删除工作空间代码(不包括``Untracked files``)，执行后直接恢复到指定`<commit-id>`状态：
```
$ git reset --hard <commit-id>
```
> `HEAD`表示当前版本，``HEAD^``表示上个版本，``HEAD^^``表示上上个版本，上100个版本可以表示为``HEAD~100``以此类推。

回退版本后，若需要返回原来的版本，会发现找不到未来的``commit id``，则需要查看操作命令历史进行查找：
```
$ git reflog
```

从版本库删除文件：
```
$ git rm <filename>
```

若你的代码已经``push``到线上，则推荐使用下面这个命令回滚：
```
$ git revert <commit-id>
```
> ``revert``是用一次新的``commit``来回滚之前的``commit``，更安全;``reset``则是直接删除指定的``commit``，若直接``push``会导致冲突。

## 分支
查看所有分支，有``*``标记的是当前分支：
```
$ git branch -a
```
创建本地分支：
```
$ git branch <newbranch>
```

创建并切换本地分支：
```
$ git checkout -b <newbranch>
```

从标签创建分支：
```
$ git branch <branch> <tagname>
$ git checkout <branch> # 切换到新建分支
```

推送新建本地分支到远程：
```
$ git push -u origin <remote-branch-name>
  or
$ git push --set-upstream origin <remote-branch-name>
```

删除本地分支：
```
$ git branch -d <branch>
```
> 若当前分支因为有修改未提交或其它情况不能删除，请使用``-D``选项强制删除。

删除远程分支(三种方法)：
```
$ git push origin --delete <remote-branch-name>
$ git push origin -d <remote-branch-name>
$ git push origin :<remote-branch-name>
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

查看某个`<commit id>`属于哪个分支:
```
$ git branch -a --contains <commit id>
```

## 暂存
当你需要切换分支时,若当前工作区还有些修改没有完成,又不适合提交的,操作切换分支是会提示出错的.这时就需要将这些修改暂存起来:
```
$ git stash save "message"
```

查看:
```
$ git stash list
```

恢复:
```
$ git stash pop [--index] [stash@{num}]　
  or
$ git stash apply [--index] [stash@{num}]　# 不删除已恢复的进度.
```
> ``--index``表示不仅恢复工作区,还会恢复暂存区;``num``是你要恢复的操作的序列号,默认恢复最新进度.

删除进度:
```
$ git stash drop [stash@{num}] # 删除指定进度
$ git stash clear # 删除所有
```

## 清理仓库
### 清理无用的分支和标签
```
$ git branch -d <branch-name>
$ git tag -d <tag-name>
$ git remote prune origin
$ git pull
```

### 清理大文件
- 查看`git`相关文件占用空间：
```
$ git count-objects -v
$ du -sh .git
```

- 寻找大文件`ID`
```
$ git verify-pack -v .git/objects/pack/*.idx | sort -k 3 -n | tail -10
```
> 输出的第一列是文件`I`D，第二列表示文件`（blob）`或目录`（tree）`，第三列是文件大小，此处筛选了最大的10条

- 获取文件名与`ID`映射
```
$ git rev-list --objects --all | grep "$(git verify-pack -v .git/objects/pack/*.idx | sort -k 3 -n | tail -10 | awk '{print$1}')"
```

- 从所有提交中删除文件
```
$ git filter-branch --tree-filter 'rm -rf xxx' HEAD --all
$ git pull
```

- 清理`.git`目录:
```
$ git gc --prune=now
```
>tips: 在执行`push`操作时，`git`会自动执行一次`gc`操作，不过只有`loose object`达到一定数量后才会真正调用，建议手动执行。

### 处理大型二进制文件
由于git在存储二进制文件时效率不高,所以需要借助[第三方组件](http://www.oschina.net/news/71365/git-annex-lfs-bigfiles-fat-media-bigstore-sym)。

## 忽略特殊文件
当你的仓库中有一些文件，类似密码或者数据库文件不需要提交但又必须放在仓库目录下，每次``git status``都会提示``Untracked``，看着让人很不爽，提供两种方法解决这个问题

### 本地
在代码仓库目录创建一个``.gitignore``文件，编写规则如下：
```
tmp/  # 忽略tmp文件夹下所有内容
*.ini # 忽略所有ini文件
!data/ #忽略除了data文件夹的所有内容
```

### 全局
在用户目录创建一个``.gitignore_global``文件，编写规则同``.gitignore``，并修改``~/.gitconfig``
```
[core]
	excludesfile = ~/.gitignore_global
```

如果添加的忽略对象已经`Tracked`，纳入了版本管理中，则需要在代码仓库中先把本地缓存删除,改变成`Untracked`状态
```
$ git rm -r --cached .
```
> [``.gitignore``模版](https://github.com/github/gitignore)

## 奇技淫巧
### 重写历史（慎用！）
```
$ git rebase -i [git-hash| head~n]
```
> 其中`git-hash`是你要开始进行`rebase`的`commit`的`hash`，而`head~n`则是从`HEAD`向前推`n`个`commit`


### 全局更换电子邮件
```
git filter-branch --commit-filter '
        if [ "$GIT_AUTHOR_EMAIL" = "xxx@localhost" ];
        then
                GIT_AUTHOR_NAME="xxx";
                GIT_AUTHOR_EMAIL="xxx@example.com";
                git commit-tree "$@";
        else
                git commit-tree "$@";
        fi' HEAD --all
```

## 帮助
查看帮助：
```
$ git --help
```

## Reference
1. [廖雪峰老师的git教程](http://www.liaoxuefeng.com/wiki/0013739516305929606dd18361248578c67b8067c8c017b000)
2. [常用Git命令清单](http://www.ruanyifeng.com/blog/2015/12/git-cheat-sheet.html)
3. [Git-Book](https://git-scm.com/book/en/v2)
4. [Git-Reference](https://git-scm.com/docs)
5. [Git push与pull的默认行为](https://segmentfault.com/a/1190000002783245)
6. [git stash 详解](http://www.tuicool.com/articles/rUBNBvI)

-----

<a href="#"><img src="https://img.shields.io/badge/Author-AnSwErYWJ-blue" alt="Author"></a>
- GitHub：[AnSwErYWJ](https://github.com/AnSwErYWJ)
- Blog：[https://www.answerywj.com](https://www.answerywj.com) 
- Email：[yuanweijie1993@gmail.com](https://mail.google.com)
- Weibo：[AnSwEr不是答案](https://weibo.com/1783591593)