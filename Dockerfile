FROM debian:bookworm-backports AS builder

ENV DEBIAN_FRONTEND=noninteractive

# get https://radxa-repo.github.io/rk3588s2-bookworm/
RUN apt-get update && \
    apt-get -y full-upgrade && \
    apt-get install -y --no-install-recommends curl ca-certificates && \
    keyring="$(mktemp)" && \
    version="$(curl -L https://github.com/radxa-pkg/radxa-archive-keyring/releases/latest/download/VERSION)" && \
    curl -L --output "$keyring" "https://github.com/radxa-pkg/radxa-archive-keyring/releases/latest/download/radxa-archive-keyring_${version}_all.deb" && \
    dpkg -i "$keyring" && \
    rm -f "$keyring" && \
    echo "deb [signed-by=/usr/share/keyrings/radxa-archive-keyring.gpg] https://radxa-repo.github.io/rk3588s2-bookworm/ rk3588s2-bookworm main" > /etc/apt/sources.list.d/70-radxa.list && \
    apt-get autoremove -y && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /workdir

# build ffmpeg-rockchip
RUN apt-get update && \
    apt-get install -y --no-install-recommends build-essential cmake git libdrm-dev librga-dev librockchip-mpp-dev libsdl2*-dev libx264-dev libx265-dev pkg-config librga2 && \
    git clone --depth=1 https://github.com/nyanmisaka/ffmpeg-rockchip && \
    cd ffmpeg-rockchip/ && \
    ./configure --prefix=/usr --enable-gpl --enable-version3 --enable-libdrm --enable-rkmpp --enable-rkrga --enable-libx264 --enable-libx265 --enable-ffplay && \
    make -j$(nproc) && \
    make install

ARG KODI_VERSION

# build kodi
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        autoconf \
        automake \
        libtool \
        clang-format \
        libgtest-dev \
        openssl \
        liblzo2-dev \
        libgif-dev \
        python3-dev \
        libxml2-dev \
        libass-dev \
        libcdio-dev \
        libcdio++-dev \
        libcurl4-openssl-dev \
        libflatbuffers-dev \
        libfmt-dev \
        libfstrcmp-dev \
        libpcre3-dev \
        rapidjson-dev \
        libssl-dev \
        libspdlog-dev \
        libsqlite3-dev \
        libtag1-dev \
        libtinyxml-dev \
        libtinyxml2-dev \
        libinput-dev \
        libdisplay-info-dev \
        libshairplay-dev \
        libavahi-client-dev \
        libbluetooth-dev \
        libbluray-dev \
        libcap-dev \
        libcec-dev \
        libnfs-dev \
        libsmbclient-dev \
        libmicrohttpd-dev \
        libxslt1-dev \
        libplist-dev \
        liblirc-dev \
        liblcms2-dev \
        default-jre-headless \
        swig && \
    git clone --branch ${KODI_VERSION} --depth 1 https://github.com/xbmc/xbmc kodi && \
    mkdir -p kodi-build && cd kodi-build && \
    cmake ../kodi -DCMAKE_INSTALL_PREFIX=/usr/ \
             -DCORE_PLATFORM_NAME=gbm \
             -DAPP_RENDER_SYSTEM=gles \
             -DWITH_FFMPEG=ON \
             -DENABLE_INTERNAL_FFMPEG=OFF \
             -DCMAKE_BUILD_TYPE=Release && \
    cmake --build . -- VERBOSE=1 -j$(getconf _NPROCESSORS_ONLN) && \
    make install DESTDIR=/install/kodi

FROM debian:bookworm-backports

ENV DEBIAN_FRONTEND=noninteractive

# get https://radxa-repo.github.io/rk3588s2-bookworm/
RUN apt-get update && \
    apt-get -y full-upgrade && \
    apt-get install -y --no-install-recommends curl ca-certificates && \
    keyring="$(mktemp)" && \
    version="$(curl -L https://github.com/radxa-pkg/radxa-archive-keyring/releases/latest/download/VERSION)" && \
    curl -L --output "$keyring" "https://github.com/radxa-pkg/radxa-archive-keyring/releases/latest/download/radxa-archive-keyring_${version}_all.deb" && \
    dpkg -i "$keyring" && \
    rm -f "$keyring" && \
    echo "deb [signed-by=/usr/share/keyrings/radxa-archive-keyring.gpg] https://radxa-repo.github.io/rk3588s2-bookworm/ rk3588s2-bookworm main" > /etc/apt/sources.list.d/70-radxa.list && \
    apt-get autoremove -y && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

LABEL maintainer="Christopher L.D. SHEN <shenleidi@gmail.com>"

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        libgl1-mesa-dri \
        fish \
        libbluray2 \
        libmicrohttpd12 \
        libpython3.11 \
        libsmbclient \
        libcdio19 \
        libcdio++1 \
        libflatbuffers2 \
        libfribidi0 \
        liblzo2-2 \
        libtinyxml2.6.2v5 \
        libtinyxml2-9 \
        libinput10 \
        libdisplay-info2 \
        libasound2 \
        libbluetooth3 \
        libcec6 \
        libnfs13 \
        libpulse0 \
        libsndio7.0 \
        libass9 \
        librga2 \
        libx264-164 \
        libx265-199 \
        libdrm2 \
        librockchip-mpp1 \
        libfmt9 \
        libfstrcmp0 \
        libpcre3 \
        libspdlog1.10 \
        libtag1v5 \
        libgbm1 \
        libxkbcommon0 \
        libgles2 \
        libegl1 \
        libshairplay0 \
        libxslt1.1 \
        liblircclient0 \
        libplist3 \
        liblcms2-2 \
        avahi-daemon && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Copy compiled Kodi from the builder stage
COPY --from=builder /install/kodi/usr /usr

VOLUME ["/usr/share/kodi/portable_data"]

# web interface
EXPOSE 8080
# json-rpc
EXPOSE 9090
# EventServer
EXPOSE 9777/udp

COPY entrypoint.sh /entrypoint.sh

RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]

CMD ["--logging=console", "--portable"]
