---
title: 科普|云计算的四种服务模式介绍
Antuor: AnSwEr(Weijie Yuan)
toc: true
date: 2017-03-23 14:18:40
categories: Knowledge
tags: Cloud Computing
---

本文将介绍*SaaS*，*BaaS*，*PaaS*和*IaaS*这四种云计算服务模式，并分析之间的联系和区别。

<!--more-->

## 四种服务模式介绍
- SaaS（Software as a Service）：软件即服务，*SaaS*公司提供完整并可直接使用的应用程序，用户通过网页浏览器即可接入使用。比较知名的*SaaS*有*GoToMeeting*，*WebEx*和*Salesforce*。
- BaaS（Backend as a Service）：后端即服务，为移动应用开发者提供后端云服务，包括云端数据存储、账户管理和消息推送等，简化了应用开发流程。这里推荐一篇对*BaaS*介绍的[文章](http://www.jianshu.com/p/4381f0a0692e)。
- PaaS（Platform as a Service）：平台即服务，也被叫做中间件。用户通过*Internet*可以使用*PaaS*公司在网上提供的各种开发和分发应用的解决方案，比如虚拟服务器和操作系统等，软件的开发和运行都可以在提供的平台上进行。不仅节约了硬件成本，更大大提高了协作开发的效率。比较知名的*PaaS*有*Google App Engine*，*Microsoft Azure*和*AppFog*。
- IaaS（Infrastructure as a Service）：基础设施即服务，用户通过租用*IaaS*公司的服务器，存储和网络硬件，利用*Internet*就可以完善地获取计算机基础设施服务，大大节约了硬件成本。比较知名的*IaaS*有*Amazon*，*Microsoft*和*Aliyun*等。

## 四种服务模式的关系
- *PaaS*构建在*IaaS*之上，在基础架构之外还提供了业务软件的运行环境。
- *SaaS*同*PaaS*的区别在于，使用*SaaS*的不是软件的开发人员，而是软件的最终用户。
- *BaaS*属于*PaaS*的范畴，但两者也有区别。*BaaS*简化了应用开发流程，而*PaaS*简化了应用部署流程。

![](http://o9zpdspb3.bkt.clouddn.com/Introduction-to-four-service-of-cloud-computing.jpg)

## Reference
- [云计算的三种服务模式](http://www.jianshu.com/p/6148c47792c3)
- [三分钟了解什么是 BaaS](http://www.jianshu.com/p/4381f0a0692e)

## About me
[![forthebadge](http://forthebadge.com/images/badges/ages-20-30.svg)](http://forthebadge.com)
- GitHub：[AnSwErYWJ](https://github.com/AnSwErYWJ)
- Blog：[http://www.answerywj.com](http://www.answerywj.com)
- Email：[yuanweijie1993@gmail.com](https://mail.google.com)
- Weibo：[@AnSwEr不是答案](http://weibo.com/1783591593)
- CSDN：[AnSwEr不是答案的专栏](http://blog.csdn.net/u011192270)

<a rel="license" href="http://creativecommons.org/licenses/by-sa/4.0/"><img alt="Creative Commons License" style="border-width:0" src="https://i.creativecommons.org/l/by-sa/4.0/88x31.png" /></a> This work is licensed under a <a rel="license" href="http://creativecommons.org/licenses/by-sa/4.0/">Creative Commons Attribution-ShareAlike 4.0 International License</a>.  
本作品采用知识共享署名-相同方式共享 4.0 国际许可协议进行许可。
