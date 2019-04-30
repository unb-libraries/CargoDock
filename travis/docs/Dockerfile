FROM alpine:3.6

RUN apk update && apk add \
  doxygen \
  graphviz \
  ttf-ubuntu-font-family && \
  rm -rf /app/html

ADD ./doxygen /app
ADD ./tree/ /app/html/

WORKDIR /app

CMD doxygen config.doxy
