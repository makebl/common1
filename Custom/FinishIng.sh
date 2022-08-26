
# slim 固件本地 opkg 配置
if ls -l /local_feed/*.ipk &>/dev/null;then
    sed -ri 's@^[^#]@#&@' /etc/opkg/distfeeds.conf
    grep -E '/local_feed' /etc/opkg/customfeeds.conf || echo 'src/gz local file:///local_feed' >> /etc/opkg/customfeeds.conf
    # 取消签名，暂时解决不了
    sed -ri '/check_signature/s@^[^#]@#&@' /etc/opkg.conf
fi

exit 0
