#!/bin/sh

prefix="build/app/outputs/apk/release"

flutter build apk

zip -r "build/android-release.zip" "$prefix/app-release.apk" "$prefix/output-metadata.json"