# make stage to generate self-signed certificate
FROM alpine:3.23@sha256:51183f2cfa6320055da30872f211093f9ff1d3cf06f39a0bdb212314c5dc7375 AS alpine

RUN apk --no-cache add openssl &&\
  openssl genpkey -algorithm RSA -out privkey.pem &&\
  openssl req -new -key privkey.pem -out csr.pem -subj "/C=JA/ST=tokyo/L=tokyo/O=Org/OU=IT/CN=sample.jp/emailAddress=sample@mail" &&\
  openssl x509 -req -in csr.pem -signkey privkey.pem -out fullchain.pem -days 365

# nginx stage
FROM nginx:1.29.3-alpine3.22@sha256:b3c656d55d7ad751196f21b7fd2e8d4da9cb430e32f646adcf92441b72f82b14

RUN mkdir -p /etc/nginx/key

COPY --from=alpine /privkey.pem /etc/nginx/key/privkey.pem
COPY --from=alpine /fullchain.pem /etc/nginx/key/fullchain.pem

COPY ssl.conf /etc/nginx/conf.d/ssl.conf

CMD ["nginx","-g","daemon off;"]
