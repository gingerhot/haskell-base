#!/usr/bin/env sh

tarball_dir='ghc-tarballs'
missing_files=0

fail() {
    echo >&2
    echo "$1" >&2
    exit 1
}

download_file() {
    local file_url="$1"
    local dest_file="$2"
    local description="$3"
    local extra_curl_opts="$4"
    local backup_url="$5"
    local dest_dir="$(dirname $dest_file)"

    if ! test -f "${dest_file}"
    then
        local curl_cmd="curl -L ${file_url} -o ${dest_file} --create-dirs -# ${extra_curl_opts}"
        if test -n "${backup_url}"; then
            local curl_cmd_bnk="curl -L ${backup_url} -o ${dest_file} --create-dirs -# ${extra_curl_opts}"
        else
            local curl_cmd_bnk="echo 1"
        fi

        if test "$download" = "0"
        then
            echo "ERROR: Missing ${description}" >&2
            echo "${file_url}"
            missing_files=1
            return
        else
            echo "Downloading ${description} to ${dest_dir}..."
            $curl_cmd || $curl_cmd_bnk || {
                rm -f "${dest_file}"
                fail "ERROR: Download failed."
            }
        fi
    fi

    local sig_file="${dest_file}.sig"
    if test "$sigs" = "1" -a ! -f "$sig_file"
    then
        echo "Downloading ${description} (signature) to ${dest_dir}..."
        local curl_cmd="curl -L ${file_url}.sig -o ${sig_file} --create-dirs -# ${extra_curl_opts}"
        $curl_cmd || {
                rm -f "${dest_file}.sig"
                fail "ERROR: Download failed."
            }
    fi

    if test "$verify" = "1"
    then
        grep "${dest_file}$" mk/win32-tarballs.md5sum | md5sum --quiet -c - ||
            fail "ERROR: ${description} appears to be corrupted, please delete it and try again."
    fi
}

download_mingw() {
    local mingw_base_url_primary="https://downloads.haskell.org/~ghc/mingw"
    local mingw_base_url_secondary="http://repo.msys2.org/mingw"

    if test "$mingw_arch" = "sources"
    then
        mingw_url_tmp=`echo "$1" | sed -e 's/-any\.pkg\.tar\.xz/\.src\.tar\.gz/' \
                                       -e 's/-sources-/-/' \
                                       -e 's/-libwinpthread-git-/-winpthreads-git-/' `
        local mingw_url="${mingw_base_url_primary}/${mingw_url_tmp}"
    else
        local mingw_url="${mingw_base_url_primary}/$1"
        local mingw_url_backup="${mingw_base_url_secondary}/$1"
    fi

    local mingw_toolchain="$(basename $mingw_url)"
    local mingw_w64="${tarball_dir}/${tarball_dest_dir}/${mingw_toolchain}"

    download_file "${mingw_url}" "${mingw_w64}" "${mingw_toolchain}" "" "${mingw_url_backup}"

    # Mark the tree as needing updates by deleting the folder
    if test -d inplace/mingw && test inplace/mingw -ot "$mingw_w64" ; then
        echo "In-tree MinGW-w64 tree requires updates..."
        rm -rf inplace/mingw
    fi
}

download_tarballs() {
    local package_prefix="mingw-w64"
    local format_url="/${mingw_arch}/${package_prefix}-${mingw_arch}"

    download_mingw "${format_url}-crt-git-5.0.0.4795.e3d96cb1-1-any.pkg.tar.xz"
    download_mingw "${format_url}-winpthreads-git-5.0.0.4761.02bea78-1-any.pkg.tar.xz"
    download_mingw "${format_url}-headers-git-5.0.0.4797.31e66d7e-1-any.pkg.tar.xz"
    download_mingw "${format_url}-libwinpthread-git-5.0.0.4761.02bea78-1-any.pkg.tar.xz"
    download_mingw "${format_url}-zlib-1.2.11-1-any.pkg.tar.xz"
    download_mingw "${format_url}-isl-0.17.1-1-any.pkg.tar.xz"
    download_mingw "${format_url}-mpfr-3.1.5.p1-1-any.pkg.tar.xz"
    download_mingw "${format_url}-gmp-6.1.2-1-any.pkg.tar.xz"
    download_mingw "${format_url}-binutils-2.28-1-any.pkg.tar.xz"
    download_mingw "${format_url}-libidn-1.33-1-any.pkg.tar.xz"
    download_mingw "${format_url}-gcc-6.3.0-2-any.pkg.tar.xz"

    # Upstream is unfortunately quite inconsistent in naming
    if test "$mingw_arch" != "sources"; then
        download_mingw "${format_url}-mpc-1.0.3-2-any.pkg.tar.xz"
        download_mingw "${format_url}-gcc-libs-6.3.0-2-any.pkg.tar.xz"
    else
        local format_url="${mingw_base_url}/${mingw_arch}/${package_prefix}"
        download_mingw "${format_url}-i686-mpc-1.0.3-2.src.tar.gz"
        download_mingw "${format_url}-x86_64-mpc-1.0.3-2.src.tar.gz"
    fi

    download_file "https://downloads.haskell.org/~ghc/mingw/ghc-perl-1.tar.gz" "ghc-tarballs/perl/ghc-perl-1.tar.gz" "Windows Perl binary distributions"

    if ! test "$missing_files" = "0"
    then
        exit 2
    fi
}

download_i386() {
    mingw_arch="i686"
    tarball_dest_dir="mingw-w64/x86"
    download_tarballs
}

download_x86_64() {
    mingw_arch="x86_64"
    tarball_dest_dir="mingw-w64/x86_64"
    download_tarballs
}

download_sources() {
    mingw_arch="sources"
    tarball_dest_dir="mingw-w64/sources"
    download_tarballs
}

sync_binaries_and_sources() {
    gpg --recv-key  5F92EFC1A47D45A1

    # ensure sources are downloaded
    sigs=1
    download_i386
    download_x86_64
    verify=0
    download_sources

    for f in $(find ghc-tarballs/mingw-w64 -iname '*.sig'); do
        echo "Verifying $f"
        gpg --verify $f
    done

    md5sum `find ghc-tarballs -type f -a -not -iname '*.sig'` >| mk/win32-tarballs.md5sum
    chmod -R ugo+rX ghc-tarballs

    rsync -av ghc-tarballs/mingw-w64/* downloads.haskell.org:public_html/mingw
    for f in $(find ghc-tarballs/mingw-w64); do
        curl -XPURGE http://downloads.haskell.org/~ghc/mingw/$f
    done
}

usage() {
    echo "$0 - Download GHC mingw toolchain tarballs"
    echo
    echo "Usage: $0 <action> [<arch>]"
    echo
    echo "Where <action> is one of,"
    echo ""
    echo "    download     download the necessary tarballs for the given architecture"
    echo "    fetch        download the necessary tarballs for the given architecture but doesn't verify their md5."
    echo "    verify       verify the existence and correctness of the necessary tarballs"
    echo "    sync         upload packages downloaded with 'fetch mirror' to haskell.org"
    echo ""
    echo "and <arch> is one of i386, x86_64,all or mirror (which includes sources)"
}

case $1 in
    download)
        download=1
        verify=1
        sigs=0
        ;;
    fetch)
        download=1
        verify=0
        ;;
    verify)
        download=0
        verify=1
        ;;
    sync)
        download=1
        verify=0
        sync=1
        ;;
    *)
        usage
        exit 1
        ;;
esac

case $2 in
    i386)
        download_i386
        ;;
    x86_64)
        download_x86_64
        ;;
    all)
        download_i386
        download_x86_64
        ;;
    mirror)
        sigs=1
        download_i386
        download_x86_64
        verify=0
        download_sources
        ;;
    *)
        if test "$sync" = "1"; then
            sync_binaries_and_sources
        else
            usage
            exit 1
        fi
        ;;
esac
