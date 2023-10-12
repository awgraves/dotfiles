#!/bin/bash

which kitty &>/dev/null || curl -L https://sw.kovidgoyal.net/kitty/installer.sh | sed 's/curl/curl --insecure/g' | sh /dev/stdin

echo "kitty now installed!  See the README in this dir for further setup instructions."
