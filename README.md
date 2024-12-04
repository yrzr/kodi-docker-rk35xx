# Kodi Docker RK35XX

This project provides a Docker container for running Kodi (GBM mode) on headless RK35XX devices with full **hardware transcoding** enabled.

Successfully tested hardware decoding and playback of H.264 1080p and H.265 4K HDR10 videos on Rock 5B and Rock 5C. Need more tests information from other devices.

- Source code: https://github.com/yrzr/gitlab-ce-arm64v8-docker

- Docker image: https://hub.docker.com/repository/docker/yrzr/kodi-gbm

## Prerequisites

- RK35XX devices with video output capability;
- Rockchip BSP/Vendor kernel 5.10 or 6.1 are need for [ffmpeg-rockchip](https://github.com/nyanmisaka/ffmpeg-rockchip);
- Docker installed on your system;
- Docker Compose (optional, for easier management).

## Getting Started

### Option A. Use docker run command

```bash
docker run -d \
  --name kodi-gbm \
  --privileged \
  --restart unless-stopped \
  -e WEBSERVER_ENABLED=true \
  -e WEBSERVER_PORT=8080 \
  -e WEBSERVER_AUTHENTICATION=true \
  -e WEBSERVER_USERNAME=kodi \
  -e WEBSERVER_PASSWORD=kodi \
  -p 8080:8080 \
  -p 9090:9090 \
  -p 9777:9777/udp \
  -v /etc/localtime:/etc/localtime:ro \
  -v /media:/media:ro \
  -v /path/to/kodi/data:/usr/local/share/kodi/portable_data \
  yrzr/kodi-gbm:rk35xx
```

### Option B. Use docker compose

Checkout the project.

```bash
git clone --depth=1 https://github.com/yrzr/kodi-docker-rk35xx.git
cd kodi-docker-rk35xx
```

Then modify `compose.yml` and start container with docker compose

```bash
edit compose.yml
docker compose up -d
```

### Option C. Build the docker image by your own

Checkout the project.

```bash
git clone --depth=1 https://github.com/yrzr/kodi-docker-rk35xx.git
cd kodi-docker-rk35xx
```

Build the image

```bash
docker compose build
```

Bring up the container

```bash
docker compose up -d
```

## Environment Variables

- WEBSERVER_ENABLED

Whether allow control of Kodi via HTTP

- WEBSERVER_PORT

The port of Webserver

- WEBSERVER_AUTHENTICATION

Whether to use HTTP's Basic Access Authentication

- WEBSERVER_USERNAME

The username of the webserver access authentication

- WEBSERVER_PASSWORD

The password of the webserver access authentication

## Contributing

Contributions are welcome! Please open an issue or submit a pull request.

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.

## Acknowledgements

- [ffmpeg-rockchip](https://github.com/nyanmisaka/ffmpeg-rockchip) - FFmpeg with async and zero-copy Rockchip MPP & RGA support.
