FROM ruby:3.2.2-alpine3.18

RUN apk --no-cache --update --available upgrade

RUN apk add --no-cache --update \
  && apk add build-base \
  git \
  sqlite-dev \
  postgresql-dev \
  postgresql-client \
  tzdata \
  curl bash

WORKDIR /app

COPY Gemfile* ./

RUN bundle install

COPY . .

RUN rails db:migrate

RUN rails db:seed

EXPOSE 3000

CMD [ "rails", "server", "-b", "0.0.0.0" ]