#!/bin/sh

prefix="build/app/outputs/apk/release";
zip -r "build/android-release.zip" "$prefix/app-release.apk" "$prefix/output-metadata.json"