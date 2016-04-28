FROM outstand/ruby-base:2.2.4-alpine
MAINTAINER Ryan Schlesinger <ryan@outstand.com>

RUN addgroup stockpile && \
    adduser -S -G stockpile stockpile

RUN apk --no-cache add build-base libxml2-dev libxslt-dev
COPY Gemfile consul_stockpile.gemspec /consul_stockpile/
COPY lib/consul_stockpile/version.rb /consul_stockpile/lib/consul_stockpile/
RUN cd /consul_stockpile \
    && bundle config build.nokogiri --use-system-libraries \
    && bundle install
COPY . /consul_stockpile/
RUN cd /consul_stockpile \
    && bundle exec rake install

COPY docker-entrypoint.sh /docker-entrypoint.sh

ENV DUMB_INIT_SETSID 0
ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["consul_stockpile"]
