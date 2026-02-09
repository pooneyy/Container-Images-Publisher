FROM ubuntu AS build

RUN apt-get update -qq && apt-get install -y -qq \
        autoconf automake libtool-bin build-essential g++ \
        libdb-dev libecap3-dev libgnutls28-dev libkrb5-dev \
        libldap2-dev libpam0g-dev libsasl2-dev libtdb-dev \
        pkg-config checkinstall rename curl

# renovate: datasource=github-tags depName=squid-cache/squid
ARG SQUID_VERSION=7.2

RUN TAG=SQUID_$(echo ${SQUID_VERSION#v} | tr '.' '_') ; \
    URL=https://github.com/squid-cache/squid/archive/refs/tags/$TAG.tar.gz ; \
    curl -L -o /tmp/squid.tar.gz "$URL" ; \
    tar -xzf /tmp/squid.tar.gz -C /tmp ; \
    mv /tmp/squid-$TAG /tmp/squid_code

RUN cd /tmp/squid_code ; \
    ./bootstrap.sh ; \
    ./configure \
        --prefix=/usr \
        --includedir=/usr/include \
        --mandir=/usr/share/man \
        --infodir=/usr/share/info \
        --sysconfdir=/etc \
        --localstatedir=/var \
        --disable-option-checking \
        --disable-silent-rules \
        --disable-shared \
        --enable-static \
        --runstatedir=/run \
        --disable-maintainer-mode \
        --disable-dependency-tracking \
        --with-build-environment=default \
        --enable-build-info="Build by https://github.com/pooneyy/Container-Images-Publisher" \
        --datadir=/usr/share/squid \
        --sysconfdir=/etc/squid \
        --libexecdir=/usr/lib/squid \
        --mandir=/usr/share/man \
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
        --with-swapdir=/var/spool/squid \
        --with-logdir=/var/log/squid \
        --with-pidfile=/run/squid.pid \
        --with-filedescriptors=65536 \
        --with-large-files \
        --with-default-user=proxy \
        --enable-linux-netfilter \
        --with-gnutls \
        PKG_CONFIG="pkg-config" \
        CFLAGS="-O2 -flto=auto -fPIC -ffat-lto-objects -fstack-protector-strong -fstack-clash-protection -Wformat -Werror=format-security -fcf-protection -Wno-error -Wno-unused-parameter -Wno-error=deprecated-declarations" \
        LDFLAGS="-static" \
        CPPFLAGS="-D_FORTIFY_SOURCE=3" \
        CXXFLAGS="-O2 -flto=auto -fPIC -ffat-lto-objects -fstack-protector-strong -fstack-clash-protection -Wformat -Werror=format-security -fcf-protection -Wno-error -Wno-unused-parameter -Wno-error=deprecated-declarations" ; \
    make -j$(nproc) ; \
    checkinstall  \
        --pkgname=squid \
        --pkgversion=1 \
        --pkgrelease=1 \
        --default \
        --fstrans=no \
        --install=no \
        make install ; \
    rename 's/.*/squid.deb/' *.deb

FROM ubuntu

COPY --from=build /tmp/squid_code/squid.deb /tmp/squid.deb
RUN dpkg -i /tmp/squid.deb

COPY entrypoint.sh /sbin/entrypoint.sh
RUN chmod 755 /sbin/entrypoint.sh

EXPOSE 3128/tcp
ENTRYPOINT ["/sbin/entrypoint.sh"]