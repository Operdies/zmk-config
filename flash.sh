#!/bin/bash

buildcmd="west build -d build/$1 -b nice_nano_v2 -- -DSHIELD=splitkb_aurora_sweep_$1 -DZMK_CONFIG='/workspaces/zmk-config/config'"
# Supposedly leaving out build arguments excepting the build directory improves incremental build caching,
# but it seems the same number of CMAKE steps are required to rebuild a keymap in both cases
# buildcmd="west build -d build/$1"
container=busy_lehmann
mountdir="/run/media/alex/NICENANO/"

docker exec -it -w /workspaces/zmk/app "$container" $buildcmd || exit 1

case "$1" in
  left)
    [ -d "$mountdir" ] || udisksctl mount -b /dev/disk/by-id/usb-Adafruit_nRF_UF2_63A8080A5572EF73-0:0 || exit 1
    ;;
  right) 
    [ -d "$mountdir" ] || udisksctl mount -b /dev/disk/by-id/usb-Adafruit_nRF_UF2_D704AE2ED9FCFE83-0:0 || exit 1
    ;;
  *) echo Choose left or right
    exit 1
    ;;
esac

firmware="$HOME/repos/zmk/app/build/$1/zephyr/zmk.uf2"
cp "$firmware" "$mountdir"
