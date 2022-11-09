#!/bin/sh

sed -i 's@^[^#]@#&@' /etc/opkg/distfeeds.conf

sed -i '/check_signature/s@^[^#]@#&@' /etc/opkg.conf
rm -rf /etc/FinishIng.sh

exit 0
