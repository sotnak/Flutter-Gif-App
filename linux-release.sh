#!/bin/sh

prefix="build/linux/x64/release/bundle";

flutter build linux

zip -r "build/linux-release.zip" "$prefix/data/" "$prefix/lib/" "$prefix/nsfw_flutter"