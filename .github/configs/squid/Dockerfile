FROM ubuntu AS build

RUN sed -i 's/Types: deb/Types: deb deb-src/g' /etc/apt/sources.list.d/ubuntu.sources

RUN apt-get update -qq ;\
    apt build-dep -y squid ;\
    apt-get install -y -qq \
        autoconf automake libtool-bin build-essential g++ \
        libdb-dev libgnutls28-dev libkrb5-dev libldap2-dev \
        libpam0g-dev libsasl2-dev libtdb-dev ed pkg-config \
        ruby rename curl ; \
        gem install --no-document fpm

ARG SQUID_VERSION

RUN TAG=SQUID_$(echo ${SQUID_VERSION#v} | tr '.' '_') ; \
    URL=https://github.com/squid-cache/squid/archive/refs/tags/$TAG.tar.gz ; \
    curl -L -o /tmp/squid.tar.gz "$URL" ; \
    tar -xzf /tmp/squid.tar.gz -C /tmp ; \
    mv /tmp/squid-$TAG /tmp/squid_code

WORKDIR /tmp/squid_code

RUN ./bootstrap.sh ; \
    ./configure \
        --prefix=/usr \
        --localstatedir=/var \
        --with-logdir=/var/log/squid \
        --with-pidfile=/run/squid.pid \
        --with-swapdir=/var/spool/squid \
        --disable-option-checking \
        --disable-silent-rules \
        --disable-maintainer-mode \
        --disable-dependency-tracking \
        --with-build-environment=default \
        --enable-build-info="Built by https://github.com/pooneyy/Container-Images-Publisher" \
        --enable-inline \
        --disable-arch-native \
        --enable-async-io=8 \
        --enable-storeio="ufs,aufs,diskd,rock" \
        --enable-removal-policies="lru,heap" \
        --enable-delay-pools \
        --enable-cache-digests \
        --enable-icap-client \
        --enable-follow-x-forwarded-for \
        --enable-auth-basic="DB,fake,getpwnam,LDAP,NCSA,PAM,POP3,RADIUS,SASL,SMB" \
        --enable-auth-digest="file,LDAP" \
        --enable-auth-negotiate="kerberos,wrapper" \
        --enable-auth-ntlm="fake" \
        --enable-external-acl-helpers="file_userip,kerberos_ldap_group,LDAP_group,session,SQL_session,time_quota,unix_group,wbinfo_group" \
        --enable-security-cert-validators="fake" \
        --enable-storeid-rewrite-helpers="file" \
        --enable-url-rewrite-helpers="fake" \
        --enable-eui \
        --enable-esi \
        --enable-icmp \
        --enable-zph-qos \
        --disable-translation \
        --with-filedescriptors=65536 \
        --with-large-files \
        --with-default-user=proxy \
        --enable-linux-netfilter \
        --with-gnutls \
        --with-openssl \
        CPPFLAGS="-D_FORTIFY_SOURCE=3"

RUN make -j$(nproc)

RUN mkdir -p /tmp/squid-pkg ; \
    make install-strip DESTDIR=/tmp/squid-pkg ; \
    fpm -s dir -t deb -n squid -v 1 --iteration 1 \
        -d libkrb5-3 -d libgssapi-krb5-2 -d libnetfilter-conntrack3 -d libltdl7 \
        -C /tmp/squid-pkg . ; \
    rename 's/.*/squid.deb/' *.deb

FROM ubuntu

COPY --from=build /tmp/squid_code/squid.deb /tmp/squid.deb
RUN apt-get update -qq ;\
    apt-get install -y apache2-utils openssl /tmp/squid.deb ;\
    apt-get clean ;\
    rm -rf /var/lib/apt/lists/*

ENV SQUID_CACHE_DIR=/var/spool/squid \
    SQUID_LOG_DIR=/var/log/squid \
    SQUID_USER=proxy

COPY entrypoint.sh /sbin/entrypoint.sh
RUN chmod 755 /sbin/entrypoint.sh

EXPOSE 3128/tcp
ENTRYPOINT ["/sbin/entrypoint.sh"]