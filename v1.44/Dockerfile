FROM rust:1.44

LABEL author="Calin Radoni, https://calinradoni.github.io/"

RUN apt-get -qq update \
    && apt-get -qq -y --no-install-recommends install \
        gdb-multiarch \
        openocd \
    && apt-get -qq -y clean \
    && rustup target add thumbv6m-none-eabi \
    && rustup target add thumbv7m-none-eabi \
    && rustup target add thumbv7em-none-eabi \
    && rustup target add thumbv7em-none-eabihf \
    && rustup component add llvm-tools-preview \
    && cargo install cargo-binutils \
    && cargo install cargo-generate

CMD ["/bin/bash"]
