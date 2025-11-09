# make stage to generate self-signed certificate
FROM alpine:3.22@sha256:4b7ce07002c69e8f3d704a9c5d6fd3053be500b7f1c69fc0d80990c2ad8dd412 AS alpine

RUN apk --no-cache add openssl &&\
  openssl genpkey -algorithm RSA -out privkey.pem &&\
  openssl req -new -key privkey.pem -out csr.pem -subj "/C=JA/ST=tokyo/L=tokyo/O=Org/OU=IT/CN=sample.jp/emailAddress=sample@mail" &&\
  openssl x509 -req -in csr.pem -signkey privkey.pem -out fullchain.pem -days 365

# nginx stage
FROM nginx:1.29.2-alpine3.22@sha256:61e01287e546aac28a3f56839c136b31f590273f3b41187a36f46f6a03bbfe22

RUN mkdir -p /etc/nginx/key

COPY --from=alpine /privkey.pem /etc/nginx/key/privkey.pem
COPY --from=alpine /fullchain.pem /etc/nginx/key/fullchain.pem

COPY ssl.conf /etc/nginx/conf.d/ssl.conf

CMD ["nginx","-g","daemon off;"]
