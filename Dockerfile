ARG VERSION=v0.3.3-alpha

FROM golang:1.15.5-alpine as builder

ARG VERSION

# Force Go to use the cgo based DNS resolver. This is required to ensure DNS
# queries required to connect to linked containers succeed.
ENV GODEBUG netdns=cgo

# Pass a tag, branch or a commit using build-arg. This allows a docker image to
# be built from a specified Git state. The default image will use the Git tip of
# master by default.
ARG checkout="master"

# Explicitly turn on the use of modules (until this becomes the default).
ENV GO111MODULE on

ENV NODE_VERSION=v12.17.0

# We need some additional proto files with google annotations, the version
# should match what's in lnd's scripts/install_travis_proto.sh
ENV PROTOC_VERSION=3.4.0
ENV PROTOC_URL="https://github.com/protocolbuffers/protobuf/releases/download/v${PROTOC_VERSION}/protoc-${PROTOC_VERSION}-linux-x86_64.zip"

# Install dependencies and install/build lightning-terminal.
RUN apk add --no-cache --update alpine-sdk \
    git \
    make \
    curl \
    bash \
    binutils \
    tar \
    protobuf-dev \
    zip \
&& curl -sfSLO ${PROTOC_URL} \
&& unzip protoc-${PROTOC_VERSION}-linux-x86_64.zip -d /usr/local \
&& rm /usr/local/bin/protoc /usr/local/readme.txt \
&& touch ~/.bashrc \
&& curl -sfSLO https://unofficial-builds.nodejs.org/download/release/${NODE_VERSION}/node-${NODE_VERSION}-linux-x64-musl.tar.xz \
&& tar -xf node-${NODE_VERSION}-linux-x64-musl.tar.xz -C /usr --strip 1 \
&& rm node-${NODE_VERSION}-linux-x64-musl.tar.xz \
&& curl -o- -L https://yarnpkg.com/install.sh | bash \
&& . ~/.bashrc \
&& git clone --branch $VERSION https://github.com/lightninglabs/lightning-terminal /go/src/github.com/lightninglabs/lightning-terminal\
&& cd /go/src/github.com/lightninglabs/lightning-terminal \
&& make install \
&& make go-install-cli

# Start a new, final image to reduce size.
FROM alpine as final

# Define a root volume for data persistence.
VOLUME /root/.lnd

# Expose lightning-terminal and lnd ports (server, rpc).
EXPOSE 8443 10009 9735

# Copy the binaries and entrypoint from the builder image.
COPY --from=builder /go/bin/litd /bin/
COPY --from=builder /go/bin/lncli /bin/
COPY --from=builder /go/bin/frcli /bin/
COPY --from=builder /go/bin/loop /bin/
COPY --from=builder /go/bin/pool /bin/

COPY entrypoint.sh /bin/entrypoint
RUN chmod +x /bin/entrypoint

# Add bash.
RUN apk add --no-cache \
    bash \
    jq \
    ca-certificates

# Specify the start command and entrypoint as the lightning-terminal daemon.
ENTRYPOINT ["/bin/entrypoint"]
