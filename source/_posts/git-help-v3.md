---
title: Git速查手册（第三版）
author: AnSwErYWJ
comments: true
category_bar: true
toc: true
tags:
  - git
categories: Git
abbrlink: 33963
date: 2020-09-29 15:13:42
---

本文是对[Git速查手册（第二版）](https://answerywj.com/2019/02/12/git-help-v2/)的更新，补充了一些近期使用或者收集的一些命令。

<!--more-->

## 下载与安装
`Git`下载地址：[https://git-scm.com/downloads](https://git-scm.com/downloads)，安装请参考页面说明。
> 建议使用版本`v1.8`及以上。

## 配置
`Git`配置分为三个级别：
- `--system`：系统级，位于 `/etc/gitconfig`；
- `--global`：用户级，位于 `~/.gitconfig`；
- `--local`：仓库级，位于 `[repo]/.git/config`，为*默认级别且优先级最高*；

### 用户信息
删除`global`用户信息，防止不同`Git`服务之间冲突：
```
$ git config --global --unset user.name
$ git config --global --unset user.email
```

配置用户名：
```
$ git config --local user.name "username"
$ git config --local user.email "email"
```

### 克隆协议
一般`Git`服务默认都支持`SSH`和`HTTPS`，`SSH`支持的原生`Git`协议速度最快，`HTTPS`除了速度慢以外，还有个最大的麻烦是每次推送都必须输入口令。

#### SSH
检查本机`SSH`公钥，若存在，则将`id_rsa.pub`添加到`Git`服务的`SSH keys`：
```
$ ls ~/.ssh
```

若不存在，则生成：
- 单个`Git`服务
```
$ ssh-keygen -t rsa -C "your_email@youremail.com"
```
- 多个`Git`服务
```
$ ssh-keygen -t rsa -C "your_email@youremail.com" -f "git1_id_rsa"
$ ssh-keygen -t rsa -C "your_email@youremail.com" -f "git2_id_rsa"
$ cp git1_id_rsa* ~/.ssh/
$ cp git2_id_rsa* ~/.ssh/

# 创建配置文件
$ vi ~/.ssh/config

# git1
Host git1.com
HostName git1.com
PreferredAuthentications publickey
IdentityFile ~/.ssh/git1_id_rsa

# git2
Host git2.com
HostName git2.com
PreferredAuthentications publickey
IdentityFile ~/.ssh/git2_id_rsa
```

配置完成后，将对应的`id_rsa.pub`添加到`Git`服务的`SSH keys`，再次检查ssh连接情况；若不生效，则重启后再尝试：
```
$ ssh -T git@github.com
Hi! You’ve successfully authenticated, but GitHub does not provide shell access.
```
> 若出现上述信息，则表示设置成功。

克隆：
```
$ git clone git@git.server:test.git
```

#### HTTPS
关闭`ssl`校验：
```
$ git config --global http.sslverify false
```

克隆：
```
$ git clone https://git.server/test.git
```

#### 协议切换
查看当前协议：
```
$ git remote -v
```

从`https`切换至`ssh`：
```
git remote set-url origin git@domain:username/ProjectName.git
```

从`ssh`切换至`https`：
```
git remote set-url origin https://domain/username/ProjectName.git
```

### 自定义配置
#### 超时时间
```
$ git config --global credential.helper 'cache --timeout=3600'
```

#### 保存用户凭证

```
$ git config --global credential.helper store
```
执行后，下次操作输入的用户名和密码会被保存，后续不必手动输入用户名和密码。若同时使用不同的`Git`服务，则不推荐使用。

#### 多Git服务
若同时使用不同的`Git`服务，可以根据目录配置用户信息（需要使用`v2.13.0`及以上版本）：
- 首先修改用户目录下的 `.gitconfig`，通过 `includeIf` 配置不同目录的配置文件：
```diff
- [user]
- 	name = weijie.yuan
- 	email = weijie.yuan@gitlab.com

+ [includeIf "gitdir:~/github/"]
+     path = .gitconfig-github
+ [includeIf "gitdir:~/gitlab/"]
+     path = .gitconfig-gitlab
```

- 根据配置的 `path`，分别创建 `.gitconfig-github` 文件和 `.gitconfig-gitlab` 文件：
```
$ vi .gitconfig-github
[user]
	name = weijie.yuan
	email = weijie.yuan@github.com

$ vi .gitconfig-gitlab
[user]
	name = weijie.yuan
	email = weijie.yuan@gitlab.com
```
`includeIf` 配置有如下规则：
- 家目录下的 `.gitconfig` ，`includeIf` 后面的 `path` 最后需要 `/` 结尾；
- 家目录下的 `.gitconfig` ，原有的 `user` 部分需要删除；
- 家目录下的 `.gitconfig` ，`includeIf`中配置的各个目录，不能是包含关系；

#### 文本编辑器
`Linux` or `MacOS`：
```
$ git config --global core.editor vim
```
`Windows`：
```
> git config --global core.editor "'C:/Program Files/Notepad++/notepad++.exe' -multiInst -notabbar -nosession -noPlugin"
```

#### 文本比较合并工具
查看支持的工具集合（推荐使用`meld`）：
```
$ git difftool --tool-help
```

`Linux` or `MacOS`：
```
$ git config --global diff.tool meld
$ git config --global merge.tool meld
```

`Windows`：
```
> git config --global diff.tool meld
> git config --global merge.tool meld
> git config --global difftool.bc3.path 'C:\Program Files (x86)\Meld\Meld.exe'
> git config --global mergetool.meld.path 'C:\Program Files (x86)\Meld\Meld.exe'
> git config --global difftool.meld.path 'C:\Program Files (x86)\Meld\Meld.exe'
```

#### 显示颜色
```
$ git config --global color.ui.true
```

#### 操作别名
示例，将`checkout`设置为别名`co`：
```
$ git config --global alias checkout co 
```

### 查看所有配置
```
$ git config --local --list
$ git config --global --list
$ git config --system --list
```

## 基础操作
### 工作流
![工作流](git-work-flow.jpg)

工作区就是你的本地仓库目录，不过其中的`.git`目录不属于工作区，而是版本库，里面存了很多东西，其中最重要的就是称为`stage`（或者叫`index`）的暂存区，还有`Git`为我们自动创建的第一个分支`master`，以及指向`master`的一个指针叫`HEAD`。  

查看状态：
```
$ git status
```

添加修改到暂存区：
```
$ git add <filename> 
$ git add .  # 添加当前目录所有修改过的文件  
$ git add *  # 递归地添加执行命令时所在的目录中的所有文件
```

提交修改到版本库：
```
$ git commit -m "commit message"
$ git commit -am "commit message" # am：将添加和提交合并为一步，但只对本来就存在的文件有效
```
> ``commit message``的填写可以参考[写好 Git Commit 信息的 7 个建议](http://blog.jobbole.com/92713/)。

现在来解释一下前面的添加和提交操作：  
1. `git add`：把文件修改添加到暂存区；
2. `git commit`：把暂存区的所有内容提交到当前分支，即版本库；

### 版本历史记录
查看当前仓库所有文件的版本历史记录：
```
$ git log
```

查看每个文件的版本历史记录：
```
$ git log <filename>
```

查看包含指定关键字的版本历史记录：
```
$ git log --grep="keywords"
```

查看指定时间段的版本历史记录，如下示例时间段为`2020.9.23`全天：
```
$ git log --after="2020-9-23 00:00:00" --before="2020-9-23 23:59:59"
```

### 暂存
当你需要切换分支时，若当前工作区还有些修改没有完成、又不适合提交的，操作切换分支是会提示出错的，这时就需要将这些修改暂存起来：
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
> ``--index``表示不仅恢复工作区,还会恢复暂存区；``num``是你要恢复的操作的序列号,默认恢复最新进度。

删除进度:
```
$ git stash drop [stash@{num}] # 删除指定进度
$ git stash clear # 删除所有
```

### 撤销与回退
查看当前仓库状态：
```
$ git status
```

查看文件更改：
```
$ git difftool <filename>
$ git mergetool <filename>
```

查看提交历史：
```
$ git log
$ git log --pretty=oneline #只保留commit id 和 commit message
```

撤销工作区``Tracked files``的修改：
```
$ git checkout -- <filename>
```

撤销工作区``Untracked files``的修改：
- n：查看将会删除的文件，防止误删；
- f：`Untracked`的文件；
- d：`Untracked`的目录；
- x：包含`gitignore`的`Untracked`文件和目录一并删掉，慎用！；  

```
git clean -nfd
```

只回退暂存区(`git add`)，不删除工作空间代码：
```
$ git reset HEAD <filename> # 无filename则默认回退全部 
```

回退版本区(`git commit`)和暂存区(`git add`)，不删除工作空间代码：
```
$ git reset --mixed HEAD^ # --mixed为默认参数
$ git reset HEAD^
```

回退版本区(`git commit`)，但是不回退暂存区(`git add`)，不删除工作空间代码：
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

### 使用帮助
查看帮助：
```
$ git --help
```

## 仓库管理
### 推送本地修改到远程仓库
```
$ git push -u origin <feature-branch-name>
```
> ``-u``选项可以将本地分支与远程分支关联,下次``git pull``操作时可以不带参数.具体参见[这里](http://stackoverflow.com/questions/5697750/what-exactly-does-the-u-do-git-push-u-origin-master-vs-git-push-origin-ma)。

### 添加本地仓库到远程
```
$ cd repo
$ git init
$ git remote add origin git@github.com:USERNAME/repo.git
```
> `origin`就是一个名字，是`git`为你默认创建的指向这个远程代码库的标签。

### 获取远程仓库
```
$ git clone git@github.com:USERNAME/repo.git
```

### 查看远程仓库
```
$ git remote -v
origin git@github.com:USERNAME/repo.git (push)
origin git@github.com:USERNAME/repo.git (fetch)
```

### 关联远程仓库
```
$ git remote add upstream git@github.com:USERNAME/repo.git
```

### 同步远程仓库的更新
``` 
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

### 仓库引用（自仓库）
`Git`包含``submodule``和``subtree``两种引用方式，官方推荐使用[subtree](http://aoxuis.me/post/2013-08-06-git-subtree)替代`submodule`：

#### submodule
##### 添加子模块
```
$ git submodule add git@github.com:USERNAME/repo.git <submodule-path>
```
执行成功后，暂存区会有两个修改：`.gitmodules`和命令中`<submodule-path>`指定的路径。

提交更新：
```
$ git commit
$ git push
```

##### 使用子模块
克隆使用了子模块的项目后，默认其子模块目录为空，需要在项目根目录执行如下命令单独下载：
```
$ git submodule update --init --recursive

or

$ git submodule init
$ git submodule update
```

##### 更新子模块
子模块仓库更新后，使用子模块的项目必须手动更新才能同步最新的提交：
```
$ cd <submodule-path>
$ git pull
```

完成后返回项目根目录，可以看到子模块有待提交的更新，执行提交即可：
```
$ git add .
$ git commit
$ git push
```

##### 删除子模块
删除子模块目录及源码：
```
$  rm -rf <submodule-path>
```

删除项目根目录下`.gitmodules`文件中待删除的子模块相关条目：
```
$ vi .gitmodules 
```

删除版本库下的子模块目录，每个子模块对应一个目录，只删除对应的子模块目录即可：
```
rm -rf .git/module/<submodule-path>
```

删除子模块缓存：
```
git rm --cached <submodule-path>
```

提交更新：
```
$ git add .
$ git commit
$ git push
```

#### subtree
``` 
# 第一次初始化
$ git remote add -f <remote-subtree-repository-name> <remote-subtree-repository-url>
$ git subtree add --prefix=<local-subtree-directory> <remote-subtree-repository> <remote-subtree-branch-name> --squash

# 同步subtree的更新
$ git subtree pull --prefix=<local-subtree-directory> <remote-subtree-repository> <remote-subtree-branch-name> --squash

# 推送到远程subtree库
$ git subtree push --prefix=<local-subtree-directory> <remote-subtree-repository> <remote-subtree-branch-name>
```

### 清理仓库
#### 清理本地无效的远程追踪分支
```
$ git pull # 拉取更新
$ git remote prune origin --dry-run # 列出所有可以从本地仓库中删除的远程追踪分支
$ git remote prune origin # 清理本地无效的远程追踪分支
```

#### 清理无用的分支和标签
```
$ git branch -d <branch-name>
$ git tag -d <tag-name>
```

#### 清理大文件
- 查看仓库占用空间：
```
$ git count-objects -v
$ du -sh .git
```

- 寻找大文件`ID`：
```
$ git verify-pack -v .git/objects/pack/*.idx | sort -k 3 -n | tail -10
```
> 输出的第一列是文件`ID`，第二列表示文件（`blob`）或目录（`tree`），第三列是文件大小，此处筛选了最大的10条。

- 根据文件`ID`映射文件名：
```
$ git rev-list --objects --all | grep "$(git verify-pack -v .git/objects/pack/*.idx | sort -k 3 -n | tail -10 | awk '{print$1}')"
```

- 根据文件名，从所有提交中删除文件：
```
$ git filter-branch --force --index-filter 'git rm -rf --cached --ignore-unmatch [FileName]' --prune-empty --tag-name-filter cat -- --all
```

- 删除缓存下来的`ref`和`git`操作记录：
```
$ git for-each-ref --format='delete %(refname)' refs/original | git update-ref --stdin
$ git reflog expire --expire=now --all
```

- 清理`.git`目录并推送到远程：
```
$ git gc --prune=now
$ git push -f --all
```
> 在执行`push`操作时，`git`会自动执行一次`gc`操作，不过只有`loose object`达到一定数量后才会真正调用，建议手动执行。

- 重新查看仓库占用空间，发现较清理前变小很多：
```
$ git count-objects -v
$ du -sh .git
```

#### 清理大型二进制文件
由于`Git`在存储二进制文件时效率不高，所以需要借助[第三方组件](http://www.oschina.net/news/71365/git-annex-lfs-bigfiles-fat-media-bigstore-sym)。

## 分支管理
### 查看分支
查看所有分支：
```
$ git branch -a
```
> 有``*``标记的是当前分支。

查看某个`<commit id>`属于哪个分支:
```
$ git branch -a --contains <commit id>
```

### 创建分支
在本地创建分支：
```
$ git branch <newbranch> # 创建
```

在本地创建分支并切换：
```
$ git checkout -b <newbranch> # 创建并切换
```

从标签创建分支：
```
$ git branch <newbranch> <tagname>
$ git checkout <newbranch> # 切换到新建分支
```

获取远程分支到本地并创建本地分支：
```
$ git checkout -b <local-branch> <remote-branch>
```

推送新建本地分支到远程：
```
$ git push -u origin <remote-branch-name>
  or
$ git push --set-upstream origin <remote-branch-name>
```

### 创建空白分支
创建一个分支，该分支会包含父分支的所有文件，但不会指向任何历史提交：
```
$ git checkout --orphan <newbranch>
```

删除所有文件：
```
$ git rm -rf .
```

提交分支：
```
$ echo '# new branch' >> README.md
$ git add README.md
$ git commit
$ git push origin <remote-branch-name>
```

### 删除分支
删除本地分支：
```
$ git branch -d <branch>
```
> 若当前分支因为有修改未提交或其它情况不能删除，请使用``-D``选项强制删除。

清理无用的本地分支：
```
$ git remote prune origin
```
> 通常在`remote`上的分支被删除后，更新本地分支列表时使用。

删除远程分支(三种方法)：
```
$ git push origin --delete <remote-branch-name>
$ git push origin -d <remote-branch-name>
$ git push origin :<remote-branch-name>
```

### 更新分支
获取远程分支到本地已有分支：
```
$ git branch --set-upstream <local-branch> origin/branch
```

同步当前分支的所有更新，使用``git pull``并不保险：
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

同步其它分支的所有更新，本例拉取``master``分支更新：
```
$ git fetch origin master
$ git difftool <branch-name> origin/master
$ git merge origin/master
$ git mergetool
```

同步其它分支的部分更新，即同步某几次提交：
```
# 同步提交A
$ git cherry-pick <commit id A> 
# 同步提交A和B
$ git cherry-pick <commit id A> <commit id B> 
# 同步提交A到B的所有提交（不包括A），提交A必须早于提交B，否则命令将失败，但不会报错
$ git cherry-pick <commit id A>..<commit id B> 
# 同步提交A到B的所有提交（包括A），提交A必须早于提交B，否则命令将失败，但不会报错
$ git cherry-pick <commit id A>^..<commit id B> 
```

## 标签管理
### 查看标签
```
$ git tag
```

### 创建标签
``` 
$ git tag -a <tagname> -m "tag message" # 创建标签在当前最新提交的commit上
$ git tag -a <tagname> -m "tag message" <commit id> # 创建标签在指定的commit上
```
> 若创建标签基于的`commit`被删除，标签不会被影响，依旧存在。

### 推送标签
推送标签到远程服务器：
```
$ git push origin <tagname> # 推送一个本地标签
$ git push origin --tags # 推送全部未推送过的本地标签
```

### 删除标签
```
$ git tag -d <tagname> # 删除一个本地标签
$ git push origin :refs/tags/<tagname> # 删除一个远程标签
```

## 进阶技巧
### 忽略特殊文件
当你的仓库中有一些文件，类似密码或者数据库文件不需要提交但又必须放在仓库目录下，每次``git status``都会提示``Untracked``，看着让人很不爽，提供两种方法解决这个问题。

#### 本地忽略
在代码仓库目录创建一个``.gitignore``文件，编写规则如下：
```
tmp/  # 忽略tmp文件夹下所有内容
*.ini # 忽略所有ini文件
!data/ #忽略除了data文件夹的所有内容
```
> [``.gitignore``模版](https://github.com/github/gitignore)

#### 全局忽略
在用户目录创建一个``.gitignore_global``文件，编写规则同``.gitignore``，并修改``~/.gitconfig``：
```
[core]
	excludesfile = ~/.gitignore_global
```

如果添加的忽略对象已经`Tracked`，纳入了版本管理中，则需要在代码仓库中先把本地缓存删除,改变成`Untracked`状态:
```
$ git rm -r --cached .
```

### 重写历史（慎用！）
#### 修改历史提交（变基）
```
$ git rebase -i [git-hash| head~n]
$ git push -f # 不强制 push 会多一条 merge 提交信息
```
其中`git-hash`是你要开始进行`rebase`的`commit`的`hash`，而`head~n`则是从`HEAD`向前推`n`个`commit`

#### 修改最近一次提交信息
```
$ git commit --amend
```

#### 修改提交记录中的用户信息 
修改最近一次提交的用户信息：
```
$ git commit --amend --author="GIT_AUTHOR_NAME <GIT_AUTHOR_EMAIL>"
```

全局修改用户信息：
```
$ git filter-branch --commit-filter '
        if [ "$GIT_AUTHOR_EMAIL" = "xxx@localhost" ];
        then
                GIT_AUTHOR_NAME="xxx";
                GIT_AUTHOR_EMAIL="xxx@example.com";
                git commit-tree "$@";
        else
                git commit-tree "$@";
        fi' HEAD --all
```

## Reference
- [廖雪峰老师的git教程](http://www.liaoxuefeng.com/wiki/0013739516305929606dd18361248578c67b8067c8c017b000)
- [常用Git命令清单](http://www.ruanyifeng.com/blog/2015/12/git-cheat-sheet.html)
- [Git-Book](https://git-scm.com/book/en/v2)
- [Git-Reference](https://git-scm.com/docs)
- [Git push与pull的默认行为](https://segmentfault.com/a/1190000002783245)
- [Git飞行规则(Flight Rules)](https://github.com/k88hudson/git-flight-rules/blob/master/README_zh-CN.md)
- [理解Git Submodules](http://www.ayqy.net/blog/%E7%90%86%E8%A7%A3git-submodules/)
- [git中submodule子模块的添加、使用和删除](https://rouroux.github.io/git-submodule/)
- [寻找并删除 Git 记录中的大文件](https://harttle.land/2016/03/22/purge-large-files-in-gitrepo.html)