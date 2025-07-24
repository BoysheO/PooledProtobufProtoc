# === Stage 1: Build & Test ===
FROM ubuntu:22.04 AS builder

RUN apt-get update && apt-get install -y \
    git cmake g++ make unzip autoconf libtool curl pkg-config zlib1g-dev && \
    apt-get clean

COPY . /protobuf
WORKDIR /protobuf

RUN mkdir -p cmake/build && \
    cd cmake/build && \
    cmake ../.. -Dprotobuf_BUILD_TESTS=ON && \
    make -j$(nproc) && \
    ctest --output-on-failure && \
    make install

# === Stage 2: Slim image with only protoc ===
FROM debian:bookworm-slim

COPY --from=builder /usr/local/bin/protoc /usr/local/bin/protoc
COPY --from=builder /usr/local/include/google /usr/local/include/google

RUN apt-get update && apt-get install -y libprotobuf-dev && apt-get clean

ENTRYPOINT ["protoc"]
