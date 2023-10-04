docker build -t minio-loongarch64 .
docker run --rm -v "$(pwd)"/dist:/dist minio-loongarch64
ls -al "$(pwd)"/dist