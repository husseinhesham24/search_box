FROM ruby:3.2.2-alpine3.19

RUN apk --no-cache --update --available upgrade

RUN apk add --no-cache --update \
  && apk add build-base \
  git \
  postgresql-dev \
  postgresql-client \
  tzdata \
  curl bash

WORKDIR /app

COPY Gemfile* ./

RUN bundle install

COPY . .

EXPOSE 3000

CMD [ "bash" ]

# fly deploy
# CMD [ "rails", "server", "-b", "0.0.0.0" ]
