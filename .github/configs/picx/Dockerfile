FROM nginx:stable-alpine-slim
RUN apk update && \
    apk add --no-cache git coreutils && \
    rm -rf /var/cache/apk/* && \
    rm -rf /usr/share/nginx/html/ && \
    git clone -b gh-pages https://github.com/XPoet/picx /usr/share/nginx/html/ && \
    chown -R nginx:nginx /usr/share/nginx/html/ && \
    find /usr/share/nginx/html -type d -exec chmod 755 {} \; && \
    find /usr/share/nginx/html -type f -exec chmod 644 {} \;
WORKDIR /usr/share/nginx/html/
