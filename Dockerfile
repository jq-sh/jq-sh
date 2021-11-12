FROM frolvlad/alpine-bash
COPY . /app
RUN apk add --no-cache jq make
WORKDIR /app
CMD bash -c 'make test'
