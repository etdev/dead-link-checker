FROM ruby:2.5.3
MAINTAINER Eric Turner <eric@mercari.com>

ENV APP_HOME /app

RUN apt-get update && \
    apt-get install -y net-tools && \
    apt-get install -y curl && \
    apt-get -y autoclean

COPY Gemfile* /tmp/
WORKDIR /tmp
ADD vendor /tmp/vendor
RUN bundle install

RUN mkdir $APP_HOME
WORKDIR $APP_HOME
ADD . $APP_HOME
