FROM ruby:2.2.1

RUN mkdir -p /usr/src/app /input

WORKDIR /usr/src/app

COPY Gemfile /usr/src/app/
COPY Gemfile.lock /usr/src/app/
RUN bundle install

ADD . /usr/src/app

ENTRYPOINT ["/usr/src/app/bin/grouper"]
