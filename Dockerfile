ARG PERL_BUILD_VERSION=5.30-buster
ARG UBUNTU_VERSION=23.04

##### Builder image
FROM docker.io/library/perl:${PERL_BUILD_VERSION} as builder

WORKDIR /usr/local/src

COPY . /usr/local/src

RUN \
  ./bootstrap.sh && \
  ./configure --prefix=/opt/znapzend && \
  make && \
  make install

##### Runtime image
FROM docker.io/library/ubuntu:${UBUNTU_VERSION} as runtime

RUN \
  # nano is for the interactive "edit" command in znapzendzetup if preferred over vi
  apt update && \
  apt install zfsutils-linux curl autoconf automake nano perl openssh-client mbuffer && \
  apt clean && \
  ln -s /dev/stdout /var/log/syslog && \
  ln -s /usr/bin/perl /usr/local/bin/perl

COPY --from=builder /opt/znapzend/ /opt/znapzend

RUN \
  ln -s /opt/znapzend/bin/znapzend /usr/bin/znapzend && \
  ln -s /opt/znapzend/bin/znapzendzetup /usr/bin/znapzendzetup && \
  ln -s /opt/znapzend/bin/znapzendztatz /usr/bin/znapzendztatz

ENTRYPOINT [ "/bin/bash", "-c" ]
CMD [ "znapzend --logto=/dev/stdout" ]

##### Tests
FROM builder as test

RUN \
  ./test.sh
