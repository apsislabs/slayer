FROM ruby:3.1.2-alpine
MAINTAINER contact@apsis.io

RUN apk add --no-cache --update \
    bash \
    alpine-sdk \
    sqlite-dev

ENV APP_HOME /app
WORKDIR $APP_HOME

COPY . $APP_HOME/

EXPOSE 3000

CMD ["bash"]
