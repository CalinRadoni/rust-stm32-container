FROM docker.io/library/rust:slim

LABEL author="Calin Radoni, https://calinradoni.github.io/"

RUN apt-get -qq update \
    && apt-get -qq -y --no-install-recommends install \
        gdb-multiarch \
        openocd \
        libssl-dev pkg-config libusb-dev libusb-1.0 \
    && apt-get -qq -y clean \
    && rustup target add thumbv6m-none-eabi \
    && rustup target add thumbv7m-none-eabi \
    && rustup target add thumbv7em-none-eabi \
    && rustup target add thumbv7em-none-eabihf \
    && cargo install cargo-binutils \
    && rustup component add llvm-tools-preview \
    && cargo install cargo-generate \
    && cargo install cargo-flash --no-default-features

CMD ["/bin/bash"]
