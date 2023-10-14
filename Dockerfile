FROM golang:1.20-buster AS builder-minio
ARG TARGETARCH
ARG MINIO_VERSION=RELEASE.2023-10-14T05-17-22Z

WORKDIR /opt
RUN set -ex \
    && git clone -b ${MINIO_VERSION} --depth=1 https://github.com/minio/minio.git

ARG GOPROXY=https://goproxy.cn,direct
WORKDIR /opt/minio
RUN set -ex \
    && sed -i 's@minisign@# minisign@g' dockerscripts/verify-minio.sh \
    && MINIO_RELEASE="RELEASE" make build \
    && cp minio minio.${MINIO_VERSION} \
    && echo $(sha256sum minio.${MINIO_VERSION}) > minio.sha256sum \
    && ./minio --version

FROM debian:buster-slim
ARG TARGETARCH

WORKDIR /opt/minio

COPY --from=builder-minio /opt/minio/minio /opt/minio/dist/minio
COPY --from=builder-minio /opt/minio/minio.sha256sum /opt/minio/dist/minio.sha256sum

VOLUME /dist

CMD cp -rf dist/* /dist/