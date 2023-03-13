FROM ubuntu:20.04 

LABEL maintainer="answerywj" 

ENV DIR="/data/blog" TZ="Asia/Shanghai"

WORKDIR $DIR

COPY ./package.json ./ 
COPY ./package-lock.json ./ 

RUN set -x \
&& apt-get update \
######## date ########
&& apt-get install tzdata \
&& ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone \
######## git ########
&& apt-get install -y git \
######## nodejs 12.x ####
&& apt -y install curl dirmngr apt-transport-https lsb-release ca-certificates \
&& curl -sL https://deb.nodesource.com/setup_12.x | bash - \    
&& apt-get install -y nodejs \
######### hexo ##########
&& npm install -g hexo-cli \
&& npm install \
####### cleanup #########
&& apt autoremove \
&& apt-get clean \
&& apt-get autoremove --purge
#########################

EXPOSE 9696

VOLUME ["$DIR"]

CMD ["/bin/bash"]