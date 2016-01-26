FROM alpine:latest
ENV PHOENIX_RELEASE=
RUN apk add --update build-base autoconf perl ncurses-libs ncurses-dev \
  sed git curl wget openssl openssl-dev bash inotify-tools postgresql-client

RUN cd /tmp && \
  git clone https://github.com/erlang/otp.git OTP

RUN cd /tmp/OTP && \
  ./otp_build autoconf && \
  find . -name '*.patch' -exec patch -p1 -N -s -i {} \\; \
  export ERL_TOP=`pwd` && \
  ./configure --disable-hipe && \
  make && \
  make install

RUN cd /tmp; git clone https://github.com/elixir-lang/elixir.git elixir; cd elixir && \
  cd /tmp/elixir && \
  make && \
  make install

RUN cd /tmp; git clone https://github.com/phoenixframework/phoenix.git phoenix
RUN cd /tmp/phoenix && \
  yes | mix local.hex && \
  yes | mix local.rebar && \
  yes | mix hex.info && \
  yes | mix deps.get && \
  yes | mix compile && \
  cd installer && \
  yes | MIX_ENV=prod mix archive.build && \
  yes | mix archive.install

RUN rm -fr /var/cache/apk/*
EXPOSE 4000
