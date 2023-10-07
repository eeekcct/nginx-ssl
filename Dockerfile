# 自己証明書の作成
FROM alpine:3.18.3 AS alpine

RUN apk --no-cache add openssl &&\
  openssl genpkey -algorithm RSA -out privkey.pem &&\
  openssl req -new -key privkey.pem -out csr.pem -subj "/C=JA/ST=tokyo/L=tokyo/O=Org/OU=IT/CN=sample.jp/emailAddress=sample@mail" &&\
  openssl x509 -req -in csr.pem -signkey privkey.pem -out fullchain.pem -days 365

# nginxの設定
FROM nginx:1.25.2-alpine3.18

COPY --from=alpine /privkey.pem /etc/nginx/key/privkey.pem
COPY --from=alpine /fullchain.pem /etc/nginx/key/fullchain.pem

CMD ["nginx","-g","daemon off;"]
