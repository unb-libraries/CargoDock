FROM alpine:3.6

RUN apk update && apk add \
  doxygen \
  graphviz \
  ttf-ubuntu-font-family

ADD ./doxygen /app
ADD ./tree/html /app/html

WORKDIR /app

CMD doxygen config.doxy
