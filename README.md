# Kodi Docker RK35XX

This project provides a Docker container for running Kodi (GBM mode) on headless RK35XX devices with full **hardware transcoding** enabled.

Successfully tested hardware decoding and playback of H.264 1080p and H.265 4K HDR10 videos on Rock 5B and Rock 5C. Need more tests information from other devices.

- Source code: https://github.com/yrzr/kodi-docker-rk35xx

- Docker image: https://hub.docker.com/repository/docker/yrzr/kodi-gbm

## Prerequisites

- RK35XX devices with video output capability;
- Rockchip BSP/Vendor kernel 5.10 or 6.1 are need for [ffmpeg-rockchip](https://github.com/nyanmisaka/ffmpeg-rockchip);
- Enable `panthor` driver
- Docker installed on your system;
- Docker Compose (optional, for easier management).

The `panthor` driver could be enabled by enabling devicetree `rockchip-rk3588-panthor-gpu.dtbo` through `fdtoverlays` in `extlinux.conf`:

```txt
menu label ... 
linux ...
initrd ...
fdtdir /boot/dtbs/6.1.99-vendor-rk35xx
fdtoverlays /boot/dtbs/6.1.99-vendor-rk35xx/rockchip/overlay/rockchip-rk3588-panthor-gpu.dtbo
append ...
```

Then, download the [firmware file](`https://github.com/armbian/firmware/blob/master/arm/mali/arch10.8/mali_csffw.bin`) and save it to `/lib/firmware/arm/mali/arch10.8/mali_csffw.bin`

After a successful reboot, you will get the following messages in `dmesg` showing that panthor driver is working now:

```bash
$ dmesg -t | grep panthor
panthor fb000000.gpu-panthor: [drm] clock rate = 198000000
panthor fb000000.gpu-panthor: Looking up mali-supply from device tree
panthor fb000000.gpu-panthor: Looking up sram-supply from device tree
panthor fb000000.gpu-panthor: Looking up sram-supply property in node /gpu-panthor@fb000000 failed
panthor fb000000.gpu-panthor: EM: OPP:400000 is inefficient
panthor fb000000.gpu-panthor: EM: OPP:300000 is inefficient
panthor fb000000.gpu-panthor: EM: created perf domain
panthor fb000000.gpu-panthor: [drm] mali-g610 id 0xa867 major 0x0 minor 0x0 status 0x5
panthor fb000000.gpu-panthor: [drm] Features: L2:0x7120306 Tiler:0x809 Mem:0x301 MMU:0x2830 AS:0xff
panthor fb000000.gpu-panthor: [drm] shader_present=0x50005 l2_present=0x1 tiler_present=0x1
panthor fb000000.gpu-panthor: [drm] Firmware protected mode entry not be supported, ignoring
panthor fb000000.gpu-panthor: [drm] Firmware git sha: 814b47b551159067b67a37c4e9adda458ad9d852
panthor fb000000.gpu-panthor: [drm] CSF FW using interface v1.1.0, Features 0x0 Instrumentation features 0x71
[drm] Initialized panthor 1.3.0 20230801 for fb000000.gpu-panthor on minor 2
```

## Getting Started

### Option A. Use docker run command

```bash
docker run -d \
  --name kodi-gbm \
  --privileged \
  --network host \
  --restart unless-stopped \
  -e TZ=Asia/Hong_Kong \
  -e WEBSERVER_ENABLED=true \
  -e WEBSERVER_PORT=8080 \
  -e WEBSERVER_AUTHENTICATION=true \
  -e WEBSERVER_USERNAME=kodi \
  -e WEBSERVER_PASSWORD=kodi \
  -v /path/to/kodi/data:/usr/share/kodi/portable_data \
  -v /media:/media:ro \
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

## Known issue

### Unable to see the OSD while playing a movie

Note: This problem no longer exists since kernel version 6.1.99.

See the issue [here](https://github.com/Joshua-Riek/ubuntu-rockchip/issues/89) and dirty fix [here](https://forum.armbian.com/topic/25957-guide-kodi-on-orange-pi-5-with-gpu-hardware-acceleration-and-hdmi-audio/page/6/#comment-172924)

You can also do the fix manually with the following steps.


- install `device-tree-compiler`

```bash
apt-get update
apt-get install device-tree-compiler 
```

- find the dtb file of your machine

It usually located at `/boot/dtbs/{your kernel version}/rockchip/rk3588{s}-{your machine model}.dtb`, for example it is `/boot/dtbs/6.1.75-vendor-rk35xx/rockchip/rk3588s-rock-5c.dtb` for my Rock 5C. Then backup the original dtb file.

```bash
cd /boot/dtbs/6.1.75-vendor-rk35xx/rockchip/
cp -v rk3588s-rock-5c.dtb rk3588s-rock-5c.dtb.bak
```

- extract dtc source file from dtb file

```bash
dtc -I dtb -O dts -o rk3588s-rock-5c.dtc rk3588s-rock-5c.dtb
```

- edit your dtc file and comment out `plane-mask` and `primary-plane`

```txt
...
    // rockchip,plane-mask = <0x05>;
    // rockchip,primary-plane = <0x02>;
...
```

- compile dts source file to dtb file

```bash
dtc -I dts -O dtb -o rk3588s-rock-5c.dtb rk3588s-rock-5c.dts
```

- reboot the system

```bash
reboot
```

## Contributing

Contributions are welcome! Please open an issue or submit a pull request.

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.

## Acknowledgements

- [ffmpeg-rockchip](https://github.com/nyanmisaka/ffmpeg-rockchip) - FFmpeg with async and zero-copy Rockchip MPP & RGA support.
