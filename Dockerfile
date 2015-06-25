FROM      ubuntu:14.04
MAINTAINER Nattapon Viroonsri <nattcp@yahoo.com>

# update 
RUN echo "deb http://archive.ubuntu.com/ubuntu trusty main universe" > /etc/apt/sources.list
RUN apt-get -y update --quiet

# install python-software-properties (so you can do add-apt-repository)
#RUN DEBIAN_FRONTEND=noninteractive apt-get install -y -q python-software-properties software-properties-common
#RUN apt-get -y install --quiet --assume-yes curl git libpq-dev
RUN apt-get -y install --quiet --assume-yes curl git 

# install utilities
RUN apt-get -y install vim git sudo zip bzip2 fontconfig curl
RUN gpg --keyserver hkp://keys.gnupg.net --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3
RUN curl -sSL https://get.rvm.io | bash -s stable
#RUN source ~/.rvm/scripts/rvm && rvm install --quiet-curl ruby-2.2.0 && e ruby-2.2.0
RUN rvm install --quiet-curl ruby-2.2.0 && e ruby-2.2.0
RUN gem install bundler && bundle install

ADD ./pushy.tgz  /root/pushy.tgz
RUN cd /root && tar xvzf pushy.tgz && cd /root/pushy

EXPOSE 3000
CMD cd /root/push; bundle exec rackup config.ru -p 3000
