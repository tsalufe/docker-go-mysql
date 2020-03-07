FROM alpine:3.11

# install golang
RUN apk add --no-cache \
		ca-certificates

# set up nsswitch.conf for Go's "netgo" implementation
# - https://github.com/golang/go/blob/go1.9.1/src/net/conf.go#L194-L275
# - docker run --rm debian:stretch grep '^hosts:' /etc/nsswitch.conf
RUN [ ! -e /etc/nsswitch.conf ] && echo 'hosts: files dns' > /etc/nsswitch.conf

ENV GOLANG_VERSION 1.14

RUN set -eux; \
	apk add --no-cache --virtual .build-deps \
		bash \
		gcc \
		musl-dev \
		openssl \
		go \
	; \
	export \
# set GOROOT_BOOTSTRAP such that we can actually build Go
		GOROOT_BOOTSTRAP="$(go env GOROOT)" \
# ... and set "cross-building" related vars to the installed system's values so that we create a build targeting the proper arch
# (for example, if our build host is GOARCH=amd64, but our build env/image is GOARCH=386, our build needs GOARCH=386)
		GOOS="$(go env GOOS)" \
		GOARCH="$(go env GOARCH)" \
		GOHOSTOS="$(go env GOHOSTOS)" \
		GOHOSTARCH="$(go env GOHOSTARCH)" \
	; \
# also explicitly set GO386 and GOARM if appropriate
# https://github.com/docker-library/golang/issues/184
	apkArch="$(apk --print-arch)"; \
	case "$apkArch" in \
		armhf) export GOARM='6' ;; \
		armv7) export GOARM='7' ;; \
		x86) export GO386='387' ;; \
	esac; \
	\
	wget -O go.tgz "https://golang.org/dl/go$GOLANG_VERSION.src.tar.gz"; \
	echo '6d643e46ad565058c7a39dac01144172ef9bd476521f42148be59249e4b74389 *go.tgz' | sha256sum -c -; \
	tar -C /usr/local -xzf go.tgz; \
	rm go.tgz; \
	\
	cd /usr/local/go/src; \
	./make.bash; \
	\
	rm -rf \
# https://github.com/golang/go/blob/0b30cf534a03618162d3015c8705dd2231e34703/src/cmd/dist/buildtool.go#L121-L125
		/usr/local/go/pkg/bootstrap \
# https://golang.org/cl/82095
# https://github.com/golang/build/blob/e3fe1605c30f6a3fd136b561569933312ede8782/cmd/release/releaselet.go#L56
		/usr/local/go/pkg/obj \
	; \
	apk del .build-deps; \
	\
	export PATH="/usr/local/go/bin:$PATH"; \
	go version

ENV GOPATH /go
ENV PATH $GOPATH/bin:/usr/local/go/bin:$PATH

RUN mkdir -p "$GOPATH/src" "$GOPATH/bin" && chmod -R 777 "$GOPATH"

# install apk packages
RUN apk add curl \
    wget \
    git \
    bash

# install go packages
RUN go get -u github.com/go-sql-driver/mysql \
    github.com/gin-gonic/gin \
    golang.org/x/oauth2/google \
    google.golang.org/api/gmail/v1
# remove redundant google api's and leave gmail api only
RUN mv /go/src/google.golang.org/api /go/src/google.golang.org/temp; \
    mkdir -p /go/src/google.golang.org/api/; \
    mv /go/src/google.golang.org/temp/gmail/ /go/src/google.golang.org/api/; \
    mv /go/src/google.golang.org/temp/googleapi/ /go/src/google.golang.org/api/; \
    mv /go/src/google.golang.org/temp/internal/ /go/src/google.golang.org/api/; \
    mv /go/src/google.golang.org/temp/option/ /go/src/google.golang.org/api/; \
    mv /go/src/google.golang.org/temp/transport/ /go/src/google.golang.org/api/; \
	rm -rf /go/src/google.golang.org/temp/

WORKDIR /gogogodocker
COPY . /gogogodocker
RUN chmod +x ./entrypoint.sh
ENTRYPOINT ./entrypoint.sh
