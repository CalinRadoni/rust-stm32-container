# rust-stm32-container

This is a container for programming STM32 controllers in Rust.

It adds to the official Rust image:

- gdb-multiarch
- openocd
- cargo-binutils
- cargo-generate
- llvm-tools-preview rustup component

and the following rustup targets:

- `thumbv6m-none-eabi` for Cortex-M0 and Cortex-M0+
- `thumbv7m-none-eabi` for Cortex-M3
- `thumbv7em-none-eabi` for Cortex-M4 and Cortex-M7 (no FPU)
- `thumbv7em-none-eabihf` for Cortex-M4F and Cortex-M7F (with FPU)

## Building the container

The container can be build locally with the `build.sh` script.
You need `buildah` or `docker` to build it.
The container's repository will be `localhost/calinradoni/rust-stm32` and the tag will be `1.44`.

You can also get it from [Docker Hub](https://hub.docker.com/r/calinradoni/rust-stm32) .

## Usage

- For flashing or debugging software use [With connected board](#with-connected-board)
- For building only use [Without connected board](#without-connected-board) or [With connected board](#with-connected-board)
- Use [Simple usage](#simple-usage) for testing this image. It can also be used for building, if you wish.

Read about `CARGO HOME` environment variable: [CARGO HOME](https://doc.rust-lang.org/cargo/guide/cargo-home.html) functions as a download and
source cache. When building a crate, Cargo stores downloaded build dependencies in the Cargo home.

**Note:** I use [Podman](https://podman.io/). To use [Docker](https://www.docker.com/) just replace `podman` with `docker` in examples.

### Simple usage

The following code will mount current directory as the `/source` directory in the container.

Go to your project directory then start the container:

```sh
podman run --rm -it \
    --env USER=$USER \
    --volume $PWD:/source \
    --workdir /source \
    calinradoni/rust-stm32:1.44
```

In this case `CARGO HOME` is inside the container and is not persistent.
After every start of the container, to build the crates, `cargo build` will have to download and compile build dependencies.

### Without connected board

To persist the `CARGO HOME`, rust's download and source cache, I use the `~/.cargo` directory on the host.
Make sure you have this directory or create it:

```sh
mkdir -p ~/.cargo
```

before starting the container with:

```sh
podman run --rm -it \
    --env USER=$USER \
    --env CARGO_HOME=/cargo \
    --volume $PWD:/source \
    --volume $HOME/.cargo:/cargo \
    --workdir /source \
    calinradoni/rust-stm32:1.44
```

### With connected board

#### ST-LINK access permissions

You need to set some udev permissions to be able to access the ST-LINK from a non-root account.

See the better approach from my [Non-root access for ST-LINK and USB-to-serial devices](https://calinradoni.github.io/pages/200616-non-root-access-usb.html) article or use the *quick* procedure from this section.

On the host, create and execute this script:

```sh
#!/bin/bash

sudo tee /etc/udev/rules.d/70-st-link.rules > /dev/null <<'EOF'
# ST-LINK V2
SUBSYSTEMS=="usb", ATTRS{idVendor}=="0483", ATTRS{idProduct}=="3748", MODE="600", TAG+="uaccess", SYMLINK+="stlinkv2_%n"

# ST-LINK V2.1
SUBSYSTEMS=="usb", ATTRS{idVendor}=="0483", ATTRS{idProduct}=="374b", MODE="600", TAG+="uaccess", SYMLINK+="stlinkv2-1_%n"
SUBSYSTEMS=="usb", ATTRS{idVendor}=="0483", ATTRS{idProduct}=="3752", MODE="600", TAG+="uaccess", SYMLINK+="stlinkv2-1_%n"

# ST-LINK V3
SUBSYSTEMS=="usb", ATTRS{idVendor}=="0483", ATTRS{idProduct}=="374d", MODE="600", TAG+="uaccess", SYMLINK+="stlinkv3loader_%n"
SUBSYSTEMS=="usb", ATTRS{idVendor}=="0483", ATTRS{idProduct}=="374e", MODE="600", TAG+="uaccess", SYMLINK+="stlinkv3_%n"
SUBSYSTEMS=="usb", ATTRS{idVendor}=="0483", ATTRS{idProduct}=="374f", MODE="600", TAG+="uaccess", SYMLINK+="stlinkv3_%n"
SUBSYSTEMS=="usb", ATTRS{idVendor}=="0483", ATTRS{idProduct}=="3753", MODE="600", TAG+="uaccess", SYMLINK+="stlinkv3_%n"
EOF

sudo udevadm control --reload-rules
```

If a ST-LINK board was plugged, unplug it then plug it again.

#### Usage

With a board connected through a ST-LINK interface, run `ls /dev/stlink*` to find the corresponding device then start the container
with the `--device` option.

**Example** for a ST-LINK V2 interface:

```bash
$ ls /dev/stlink*
/dev/stlinkv2_5
```

start the container with:

```sh
podman run --rm -it \
    --env USER=$USER \
    --env CARGO_HOME=/cargo \
    --volume $PWD:/source \
    --volume $HOME/.cargo:/cargo \
    --workdir /source \
    --device=/dev/stlinkv2_5 \
    calinradoni/rust-stm32:1.44
```

## License

This is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
