#!/bin/sh

cd ~/lib/Strongbox/Docs/html
ftp -i dravick@ftp.ironie.org:/www/docs/ < ~/lib/Strongbox/ftpCommands.txt
