#!/bin/sh

# This script installs the Nix package manager on your system by
# downloading a binary distribution and running its installer script
# (which in turn creates and populates /nix).

{ # Prevent execution if this script was only partially downloaded
oops() {
    echo "$0:" "$@" >&2
    exit 1
}

umask 0022

tmpDir="$(mktemp -d -t nix-binary-tarball-unpack.XXXXXXXXXX || \
          oops "Can't create temporary directory for downloading the Nix binary tarball")"
cleanup() {
    rm -rf "$tmpDir"
}
trap cleanup EXIT INT QUIT TERM

require_util() {
    command -v "$1" > /dev/null 2>&1 ||
        oops "you do not have '$1' installed, which I need to $2"
}

case "$(uname -s).$(uname -m)" in
    Linux.x86_64)
        hash=554a3ed37013ed0f958b6070184f9e0b9835415d2d08a4b1dea922079fdc20a3
        path=85cqmv9xg6zbcbdsi718msvcvb1cg8sw/nix-2.24.7-x86_64-linux.tar.xz
        system=x86_64-linux
        ;;
    Linux.i?86)
        hash=69682e08423d5a4bf7b2df29694547a8a2abbea21f954b31e7a686ed8254b693
        path=bf6ws6zkkid57a6lds27ncc62cg99f4v/nix-2.24.7-i686-linux.tar.xz
        system=i686-linux
        ;;
    Linux.aarch64)
        hash=3498548f2d1a711a49916a3c19ed57041d8119f326990f70ac068242e5941ef7
        path=jpil7l51c4rf1qwwiil3mlf8wl09z8h5/nix-2.24.7-aarch64-linux.tar.xz
        system=aarch64-linux
        ;;
    Linux.armv6l)
        hash=027e9a51214f24ec9b9566a257bfbc0fd7b9b281b3b6ccd9546ad0c7cf3dffb8
        path=yk78m7gqqb05gcaxz1wfsaaihlsr7cp5/nix-2.24.7-armv6l-linux.tar.xz
        system=armv6l-linux
        ;;
    Linux.armv7l)
        hash=8388d4d65e84ffff928c6c4de87f79aa193c129c3320299f9b1dab5a2e343b98
        path=zlfa0jnlly7nxd9jmjvmy3f3494nakfr/nix-2.24.7-armv7l-linux.tar.xz
        system=armv7l-linux
        ;;
    Linux.riscv64)
        hash=0efb1f9238906c68fe0bf69ab0edfcf6484438f6c376f37add2b4439b7e36e3d
        path=j7kcsm7jlj535gd0pg515gccgh48v6ka/nix-2.24.7-riscv64-linux.tar.xz
        system=riscv64-linux
        ;;
    Darwin.x86_64)
        hash=7058094ba24f436960c97d1ac24eb26e28055cc67d05eaf9db8ad4268fac0dec
        path=zw0glikil8ncwb6r7bgdrilk50cval8i/nix-2.24.7-x86_64-darwin.tar.xz
        system=x86_64-darwin
        ;;
    Darwin.arm64|Darwin.aarch64)
        hash=eb850dae13c802b16ca78609d5d3f62db7278ead43794a698435ed503a035de2
        path=6kl4439887d6ggjgrc41h3jqrcvbwlki/nix-2.24.7-aarch64-darwin.tar.xz
        system=aarch64-darwin
        ;;
    *) oops "sorry, there is no binary distribution of Nix for your platform";;
esac

# Use this command-line option to fetch the tarballs using nar-serve or Cachix
if [ "${1:-}" = "--tarball-url-prefix" ]; then
    if [ -z "${2:-}" ]; then
        oops "missing argument for --tarball-url-prefix"
    fi
    url=${2}/${path}
    shift 2
else
    url=https://releases.nixos.org/nix/nix-2.24.7/nix-2.24.7-$system.tar.xz
fi

tarball=$tmpDir/nix-2.24.7-$system.tar.xz

require_util tar "unpack the binary tarball"
if [ "$(uname -s)" != "Darwin" ]; then
    require_util xz "unpack the binary tarball"
fi

if command -v curl > /dev/null 2>&1; then
    fetch() { curl --fail -L "$1" -o "$2"; }
elif command -v wget > /dev/null 2>&1; then
    fetch() { wget "$1" -O "$2"; }
else
    oops "you don't have wget or curl installed, which I need to download the binary tarball"
fi

echo "downloading Nix 2.24.7 binary tarball for $system from '$url' to '$tmpDir'..."
fetch "$url" "$tarball" || oops "failed to download '$url'"

if command -v sha256sum > /dev/null 2>&1; then
    hash2="$(sha256sum -b "$tarball" | cut -c1-64)"
elif command -v shasum > /dev/null 2>&1; then
    hash2="$(shasum -a 256 -b "$tarball" | cut -c1-64)"
elif command -v openssl > /dev/null 2>&1; then
    hash2="$(openssl dgst -r -sha256 "$tarball" | cut -c1-64)"
else
    oops "cannot verify the SHA-256 hash of '$url'; you need one of 'shasum', 'sha256sum', or 'openssl'"
fi

if [ "$hash" != "$hash2" ]; then
    oops "SHA-256 hash mismatch in '$url'; expected $hash, got $hash2"
fi

unpack=$tmpDir/unpack
mkdir -p "$unpack"
tar -xJf "$tarball" -C "$unpack" || oops "failed to unpack '$url'"

script=$(echo "$unpack"/*/install)

[ -e "$script" ] || oops "installation script is missing from the binary tarball!"
export INVOKED_FROM_INSTALL_IN=1
"$script" "$@"

} # End of wrapping
