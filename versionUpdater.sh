#!/bin/bash

python -c "import plistlib; f = plistlib.readPlist('Info.plist'); f['CFBundleVersion'] = str(int(f['CFBundleVersion']) + 1); plistlib.writePlist(f, 'Info.plist')"
