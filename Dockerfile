FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential   \
    nasm              \
    gdb               \
    strace            \
    binutils          \
    make              \
    git               \
    ca-certificates   \
    curl              \
    && rm -rf /var/lib/apt/lists/*

ENV RUSTUP_HOME=/usr/local/rustup \
    CARGO_HOME=/usr/local/cargo   \
    PATH=/usr/local/cargo/bin:$PATH

RUN curl --proto '=https' --tlsv1.2 -sSf https://rustup.rs | sh -s -- -y \
    --default-toolchain stable \
    --profile minimal   \
    --component clippy rustfmt

WORKDIR /work

CMD ["/bin/bash"]