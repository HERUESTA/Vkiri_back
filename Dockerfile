FROM ruby:3.4.4
RUN apt-get update -qq && apt-get install -y nodejs postgresql-client

WORKDIR /app

COPY Gemfile /app/Gemfile
COPY Gemfile.lock /app/Gemfile.lock

RUN grep -A1 "BUNDLED WITH" Gemfile.lock | tail -n1 | xargs gem install bundler -v
RUN bundle install

COPY . /app

COPY entrypoint.sh /usr/bin/
RUN chmod +x /usr/bin/entrypoint.sh
ENTRYPOINT ["entrypoint.sh"]

EXPOSE 3002

CMD ["rails", "server", "-b", "0.0.0.0", "-p", "3002"]