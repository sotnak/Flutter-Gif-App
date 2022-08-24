#!/bin/sh

prefix="build/linux/x64/release/bundle";
zip -r "build/linux-release.zip" "$prefix/data/" "$prefix/lib/" "$prefix/nsfw_flutter"