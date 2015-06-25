FROM buildpack-deps:jessie
MAINTAINER Nattapon Viroonsri <nattcp@yahoo.com>

# update 
#RUN echo "deb http://archive.ubuntu.com/ubuntu trusty main universe" > /etc/apt/sources.list
#RUN apt-get -y update --quiet
#RUN apt-get install -y software-properties-common curl git
#RUN apt-add-repository ppa:brightbox/ruby-ng
#RUN \
#  apt-get update && \
#  apt-get install -y ruby2.2 ruby-dev ruby-bundler && \
#  rm -rf /var/lib/apt/lists/*

# install python-software-properties (so you can do add-apt-repository)
#RUN DEBIAN_FRONTEND=noninteractive apt-get install -y -q python-software-properties software-properties-common
#RUN apt-get -y install --quiet --assume-yes curl git libpq-dev
#RUN apt-get -y install --quiet --assume-yes curl git ruby ruby-dev 

# install utilities
#RUN apt-get -y install vim git sudo zip bzip2 fontconfig curl
#RUN gpg --keyserver hkp://keys.gnupg.net --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3
#RUN curl -sSL https://get.rvm.io | bash -s stable
#RUN source ~/.rvm/scripts/rvm && rvm install --quiet-curl ruby-2.2.0 && e ruby-2.2.0
#RUN /bin/bash -l -c rvm requirements
#ENV PATH /usr/local/rvm/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
#RUN rvm install --quiet-curl ruby-2.2.0 && rvm use ruby-2.2.0
#RUN gem install bundler && bundle install

#RUN gpg --keyserver hkp://keys.gnupg.net --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3
#RUN curl -sSL https://get.rvm.io | bash -s stable
#RUN /usr/local/rvm/bin/rvm install 2.2.0
#RUN /bin/bash --login
#ENV PATH /usr/local/rvm/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
#RUN rvm use 2.2.0 --default

ENV RUBY_MAJOR 2.2
ENV RUBY_VERSION 2.2.0
ENV RUBY_DOWNLOAD_SHA256 5ffc0f317e429e6b29d4a98ac521c3ce65481bfd22a8cf845fa02a7b113d9b44

# some of ruby's build scripts are written in ruby
# we purge this later to make sure our final image uses what we just built
RUN apt-get update \
	&& apt-get install -y bison libgdbm-dev ruby \
	&& rm -rf /var/lib/apt/lists/* \
	&& mkdir -p /usr/src/ruby \
	&& curl -fSL -o ruby.tar.gz "http://cache.ruby-lang.org/pub/ruby/$RUBY_MAJOR/ruby-$RUBY_VERSION.tar.gz" \
	&& tar -xzf ruby.tar.gz -C /usr/src/ruby --strip-components=1 \
	&& rm ruby.tar.gz \
	&& cd /usr/src/ruby \
	&& autoconf \
	&& ./configure --disable-install-doc \
	&& make -j"$(nproc)" \
	&& make install \
	&& apt-get purge -y --auto-remove bison libgdbm-dev ruby \
	&& rm -r /usr/src/ruby

# skip installing gem documentation
RUN echo 'gem: --no-rdoc --no-ri' >> "$HOME/.gemrc"

# install things globally, for great justice
ENV GEM_HOME /usr/local/bundle
ENV PATH $GEM_HOME/bin:$PATH

ENV BUNDLER_VERSION 1.10.4

RUN gem install bundler --version "$BUNDLER_VERSION" \
	&& bundle config --global path "$GEM_HOME" \
	&& bundle config --global bin "$GEM_HOME/bin"

# don't create ".bundle" in all our apps
ENV BUNDLE_APP_CONFIG $GEM_HOME

COPY ./pushy.tar.gz  /tmp/pushy.tar.gz
RUN pwd && ls -l /tmp
RUN cd /tmp && gzip -dc /tmp/pushy.tar.gz | tar xvf -

EXPOSE 3000
CMD cd /tmp/pushy; bundle exec rackup config.ru -p 3000
