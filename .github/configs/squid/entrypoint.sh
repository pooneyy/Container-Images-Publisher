#!/bin/bash

# ref: https://github.com/sameersbn/docker-squid/blob/master/entrypoint.sh

set -e

copy_config_file() {
  mkdir -p /etc/squid/conf.d
  if [[ ! -f '/etc/squid/squid.conf' ]]; then
    echo "Copy config file..."
    cp --update=none /usr/etc/squid.conf /etc/squid/
    sed -i 's/^http_access deny !Safe_ports/# http_access deny !Safe_ports/' /etc/squid/squid.conf
    sed -i 's/^http_access deny CONNECT !SSL_ports/# http_access deny CONNECT !SSL_ports/' /etc/squid/squid.conf
    awk 'BEGIN { inserted = 0 }
      !inserted && /# INSERT YOUR OWN RULE\(S\) HERE TO ALLOW ACCESS FROM YOUR CLIENTS/ {
          print
          flag = 1
          next
      }
      !inserted && flag == 1 && /^#\s*$/ {
          print
          print ""
          print "include /etc/squid/conf.d/*.conf"
          inserted = 1
          flag = 0
          next
      }
      {
          if (flag == 1) flag = 0
          print
      }' /etc/squid/squid.conf > /tmp/squid.conf && mv /tmp/squid.conf /etc/squid/squid.conf
    sed -i 's/^http_port 3128//' /etc/squid/squid.conf
    sed -i 's/^#\(cache_dir ufs \/var\/spool\/squid 100 16 256\)/\1/' /etc/squid/squid.conf
  fi
}

create_config_auth() {
  if [[ -n ${SQUID_AUTH_USER} && -n ${SQUID_AUTH_PASS} ]]; then
    echo "Create auth config..."
    if [[ ! -f '/etc/squid/passwd' ]]; then > /etc/squid/passwd; fi
    htpasswd -b /etc/squid/passwd ${SQUID_AUTH_USER} ${SQUID_AUTH_PASS}
    if [[ ! -f '/etc/squid/conf.d/auth.conf' ]]; then
      cat > /etc/squid/conf.d/auth.conf << EOF
auth_param basic program $(find /usr -name 'basic_ncsa_auth') /etc/squid/passwd
auth_param basic children 5
auth_param basic realm Squid
auth_param basic credentialsttl 2 hours
acl authenticated proxy_auth REQUIRED
http_access allow authenticated
EOF
    fi
  else
    echo "No auth config..."
    if [[ ! -f '/etc/squid/conf.d/auth.conf' ]]; then
      cat > /etc/squid/conf.d/auth.conf << EOF
# Uncomment allow connections from all clients
# 取消注释后将会允许来自所有客户端的连接
# http_access allow all
EOF
    fi
  fi
}

create_config_ports() {
  if [[ ! -f '/etc/squid/conf.d/ports.conf' ]]; then
    if [[ ${SQUID_ONLY_HTTPS} == true ]]; then
      echo "Configure https on port 3128..."
      cat > /etc/squid/conf.d/ports.conf << EOF
https_port 3128 cert=/etc/squid-ssl/squid.crt key=/etc/squid-ssl/squid.key
# http_port 3128
EOF
    else
      echo "Configure http on port 3128..."
      cat > /etc/squid/conf.d/ports.conf << EOF
# If you want to use HTTPS proxy and disable the HTTP proxy, please uncomment
# the following lines, deploy the certificate and private key in the corresponding
# locations, and then comment out http_port 3128.
# 如果你要使用 https 代理并关闭 http 代理, 请取消注释以下行, 在对应的位置部署证书与私钥,
# 然后注释掉 http_port 3128
# https_port 3128 cert=/etc/squid-ssl/squid.crt key=/etc/squid-ssl/squid.key
http_port 3128
EOF
    fi
  fi
}

create_cache_dir() {
  mkdir -p ${SQUID_CACHE_DIR}
  chown -R ${SQUID_USER}:${SQUID_USER} ${SQUID_CACHE_DIR}
}

create_certificate() {
  mkdir -p /etc/squid-ssl
  if [[ ! -f '/etc/squid-ssl/squid.crt' || ! -f '/etc/squid-ssl/squid.key' ]]; then
    echo "Create certificate..."
    openssl ecparam -name secp384r1 -genkey -noout -out /etc/squid-ssl/squid.key
    openssl req -new -x509 -key /etc/squid-ssl/squid.key -out /etc/squid-ssl/squid.crt -days 36500 \
      -subj "/CN=Squid" \
      -addext "keyUsage=digitalSignature, keyAgreement, keyEncipherment" \
      -addext "extendedKeyUsage=serverAuth"
  fi
}

create_log_dir() {
  mkdir -p ${SQUID_LOG_DIR}
  chmod -R 755 ${SQUID_LOG_DIR}
  chown -R ${SQUID_USER}:${SQUID_USER} ${SQUID_LOG_DIR}
}

copy_config_file
create_cache_dir
create_certificate
create_config_auth
create_config_ports
create_log_dir

if [[ -f '/run/squid.pid' ]]; then
  echo "Delete the pid file..."
  rm -f /run/squid.pid
fi

# allow arguments to be passed to squid
if [[ ${1:0:1} = '-' ]]; then
  EXTRA_ARGS="$@"
  set --
elif [[ ${1} == squid || ${1} == $(which squid) ]]; then
  EXTRA_ARGS="${@:2}"
  set --
fi

# default behaviour is to launch squid
if [[ -z ${1} ]]; then
  if [[ ! -d ${SQUID_CACHE_DIR}/00 ]]; then
    echo "Initializing cache..."
    $(which squid) -N -f /etc/squid/squid.conf -z
  fi
  echo "Starting squid..."
  exec $(which squid) -f /etc/squid/squid.conf -NYCd 1 ${EXTRA_ARGS}
else
  exec "$@"
fi