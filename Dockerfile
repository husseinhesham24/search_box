FROM ruby:3.2.2-alpine3.19

RUN apk --no-cache --update --available upgrade

RUN apk add --no-cache --update \
  && apk add build-base \
  git \
  postgresql-dev \
  postgresql-client \
  sqlite-dev \
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