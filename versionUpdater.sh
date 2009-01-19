#!/bin/bash

git log | head -n 1 | python -c "import plistlib; f = plistlib.readPlist('info.plist'); f['CFBundleVersion'] = raw_input()[7:15]; plistlib.writePlist(f, 'info.plist')"
