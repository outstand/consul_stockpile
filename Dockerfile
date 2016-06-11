FROM outstand/ruby-base:2.3.1-alpine
MAINTAINER Ryan Schlesinger <ryan@outstand.com>

RUN addgroup stockpile && \
    adduser -S -G stockpile stockpile

RUN apk --no-cache add build-base openssh

ENV USE_BUNDLE_EXEC true

COPY Gemfile consul_stockpile.gemspec /consul_stockpile/
COPY lib/consul_stockpile/version.rb /consul_stockpile/lib/consul_stockpile/
RUN cd /consul_stockpile \
    && bundle install \
    && git config --global push.default simple
COPY . /consul_stockpile/
RUN ln -s /consul_stockpile/exe/consul_stockpile /usr/local/bin/consul_stockpile

WORKDIR /consul_stockpile

COPY docker-entrypoint.sh /docker-entrypoint.sh

ENV DUMB_INIT_SETSID 0
ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["help"]
