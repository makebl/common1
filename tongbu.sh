#!/bin/bash

# 同步上游操作

# 第一步下载上游仓库
if [[ "${TONGBU_CANGKU}" == "1" ]]; then
  mv -f repogx/build DIY-SETUP
else
  rm -rf shangyou && git clone -b main https://github.com/makebl/op shangyou
  if [[ ! -d "DIY-SETUP" ]]; then
    cp -Rf shangyou/build DIY-SETUP
    BENDI_SHANCHUBAK="1"
  fi
fi

# 删除上游的.config和备份diy-part.sh、settings.ini
rm -rf shangyou/build/*/{.config,diy,files,patches}
for X in $(find "DIY-SETUP" -name "diy-part.sh" |sed 's/\/diy-part.sh//g'); do mv "${X}"/diy-part.sh "${X}"/diy-part.sh.bak; done
for X in $(find "DIY-SETUP" -name "settings.ini" |sed 's/\/settings.ini//g'); do mv "${X}"/settings.ini "${X}"/settings.ini.bak; done


# 从上游仓库覆盖文件到本地仓库
for X in $(grep "\"COOLSNOWWOLF\"" -rl "DIY-SETUP" |grep "settings.ini" |sed 's/\/settings.*//g' |uniq); do cp -Rf shangyou/build/Lede/* "${X}"; done
for X in $(grep "\"LIENOL\"" -rl "DIY-SETUP" |grep "settings.ini" |sed 's/\/settings.*//g' |uniq); do cp -Rf shangyou/build/Lienol/* "${X}"; done
for X in $(grep "\"IMMORTALWRT\"" -rl "DIY-SETUP" |grep "settings.ini" |sed 's/\/settings.*//g' |uniq); do cp -Rf shangyou/build/Immortalwrt/* "${X}"; done
for X in $(grep "\"XWRT\"" -rl "DIY-SETUP" |grep "settings.ini" |sed 's/\/settings.*//g' |uniq); do cp -Rf shangyou/build/Xwrt/* "${X}"; done
for X in $(grep "\"OFFICIAL\"" -rl "DIY-SETUP" |grep "settings.ini" |sed 's/\/settings.*//g' |uniq); do cp -Rf shangyou/build/Official/* "${X}"; done
for X in $(grep "\"AMLOGIC\"" -rl "DIY-SETUP" |grep "settings.ini" |sed 's/\/settings.*//g' |uniq); do cp -Rf shangyou/build/Amlogic/* "${X}"; done

# 云仓库的修改文件
case "${TONGBU_CANGKU}" in
1)
  cp -Rf ${GITHUB_WORKSPACE}/shangyou/README.md repogx/README.md
  cp -Rf ${GITHUB_WORKSPACE}/shangyou/LICENSE repogx/LICENSE
  
  if [[ -n "$(ls -A "${GITHUB_WORKSPACE}/repogx/.github/workflows/build-openwrt.yml" 2>/dev/null)" ]]; then
    CRON2="$(grep -A 1 'schedule:' repogx/.github/workflows/build-openwrt.yml |awk 'NR==2' |sed 's/^[ ]*//g' |sed s/^#// |sed 's/^[ ]*//g' |cut -d "#" -f1 |sed 's/\//\\&/g' |sed 's/\*/\\&/g')"
    CRON1="$(grep -A 1 'schedule:' shangyou/.github/workflows/build-openwrt.yml |awk 'NR==2' |sed 's/^[ ]*//g' |sed s/^#// |sed 's/^[ ]*//g' |sed 's/\//\\&/g' |sed 's/\*/\\&/g')"
    if [[ `grep 'cron:' repogx/.github/workflows/build-openwrt.yml |sed 's/^[ ]*//g' |grep '^-\ cron'` ]]; then
      sed -i 's/^#\(.*schedule:\)/\1/' shangyou/.github/workflows/build-openwrt.yml
      sed -i 's/^#\(.*- cron:\)/\1/' shangyou/.github/workflows/build-openwrt.yml
    fi
    TARGET1="$(grep 'target: \[' shangyou/.github/workflows/build-openwrt.yml  |sed 's/^[ ]*//g' |grep '^target' |cut -d '#' -f1 |sed 's/\[/\\&/' |sed 's/\]/\\&/')"
    TARGET2="$(grep 'target: \[' repogx/.github/workflows/build-openwrt.yml |sed 's/^[ ]*//g' |grep '^target' |cut -d '#' -f1 |sed 's/\[/\\&/' |sed 's/\]/\\&/')"
    QIDONG1="$(grep -A 1 'paths:' shangyou/.github/workflows/compile.yml |awk 'NR==2' |sed 's/^[ ]*//g' |sed 's/\//\\&/g')"
    QIDONG2="- 'config'"
    TARGE1="$(grep 'target: \[' shangyou/.github/workflows/compile.yml |sed 's/^[ ]*//g' |grep '^target' |cut -d '#' -f1 |sed 's/\[/\\&/' |sed 's/\]/\\&/')"
    TARGE2="$(grep 'target: \[' repogx/.github/workflows/compile.yml |sed 's/^[ ]*//g' |grep '^target' |cut -d '#' -f1 |sed 's/\[/\\&/' |sed 's/\]/\\&/')"
    BEIYONG1="$(grep -A 2 'target:' shangyou/.github/workflows/build-openwrt.yml |grep '\# \[.*\]' | sed -r 's/\# \[(.*)\]/\1/' |sed 's/^[ ]*//g')"
    BEIYONG2="$(grep -A 2 'target:' repogx/.github/workflows/build-openwrt.yml |grep '\# \[.*\]' | sed -r 's/\# \[(.*)\]/\1/' |sed 's/^[ ]*//g')"
  fi
  
  if [[ -n "$(ls -A "${GITHUB_WORKSPACE}/repogx/.github/workflows/build-openwrt.yml" 2>/dev/null)" ]]; then
    if [[ -n "${BEIYONG1}" ]] && [[ -n "${BEIYONG2}" ]]; then
      sed -i "s/${BEIYONG1}/${BEIYONG2}/g" shangyou/.github/workflows/build-openwrt.yml
    fi
    if [[ -n "${CRON1}" ]] && [[ -n "${CRON2}" ]]; then
      sed -i "s/${CRON1}/${CRON2}/g" shangyou/.github/workflows/build-openwrt.yml
    fi
    if [[ -n "${TARGET1}" ]] && [[ -n "${TARGET2}" ]]; then
      sed -i "s/${TARGET1}/${TARGET2}/g" shangyou/.github/workflows/build-openwrt.yml
    fi
    if [[ -n "${TARGE1}" ]] && [[ -n "${TARGE2}" ]]; then
      sed -i "s/${TARGE1}/${TARGE2}/g" shangyou/.github/workflows/compile.yml
    fi
    if [[ -n "${QIDONG1}" ]] && [[ -n "${QIDONG2}" ]]; then
      sed -i "s/${QIDONG1}/${QIDONG2}/g" shangyou/.github/workflows/compile.yml
    fi
  fi
  
  cp -Rf ${GITHUB_WORKSPACE}/shangyou/.github/workflows/* ${GITHUB_WORKSPACE}/repogx/.github/workflows
;;
esac

# 修改本地文件
if [[ ! "${TONGBU_CANGKU}" == "1" ]]; then
rm -rf DIY-SETUP/*/start-up
for X in $(find "DIY-SETUP" -name "settings.ini" |sed 's/\/settings.ini//g'); do 
  [[ -f "${X}/.config" ]] && mv "${X}/.config" "${X}/config"
  mkdir -p "${X}/version"
  echo "BENDI_VERSION=${BENDI_VERSION}" > "${X}/version/bendi_version"
  echo "bendi_version文件为检测版本用,请勿修改和删除" > "${X}/version/README.md"
done
for X in $(find "DIY-SETUP" -name "settings.ini"); do
  sed -i 's/.config/config/g' "${X}"
  sed -i '/SSH_ACTIONS/d' "${X}"
  sed -i '/UPLOAD_CONFIG/d' "${X}"
  sed -i '/UPLOAD_FIRMWARE/d' "${X}"
  sed -i '/UPLOAD_WETRANSFER/d' "${X}"
  sed -i '/UPLOAD_RELEASE/d' "${X}"
  sed -i '/INFORMATION_NOTICE/d' "${X}"
  sed -i '/CACHEWRTBUILD_SWITCH/d' "${X}"
  sed -i '/COMPILATION_INFORMATION/d' "${X}"
  sed -i '/UPDATE_FIRMWARE_ONLINE/d' "${X}"
  echo 'MODIFY_CONFIGURATION="true"            # 是否每次都询问您要不要设置自定义文件（true=开启）（false=关闭）' >> "${X}"
  if [[ `echo "${PATH}" |grep -c "Windows"` -ge '1' ]]; then
    echo 'WSL_ROUTEPATH="false"          # 关闭询问改变WSL路径（true=开启）（false=关闭）' >> "${X}"
  fi
done
fi

# 恢复settings.ini设置
# N1
for X in $(grep "\"AMLOGIC\"" -rl "DIY-SETUP" |grep "settings.ini" |sed 's/\/settings.*//g' |uniq); do
  aa="$(grep "REPO_BRANCH" "${X}/settings.ini" |sed 's/^[ ]*//g' |grep -v '^#' |awk '{print $(1)}')"
  bb="$(grep "REPO_BRANCH" "${X}/settings.ini.bak" |sed 's/^[ ]*//g' |grep -v '^#' |awk '{print $(1)}')"
  if [[ -n "${aa}" ]] && [[ -n "${bb}" ]]; then
   sed -i "s?${aa}?${bb}?g" "${X}/settings.ini"
  fi
  cc="$(grep "CONFIG_FILE" "${X}/settings.ini.bak" |sed 's/^[ ]*//g' |grep -v '^#' |cut -d '"' -f2)"
  if [[ ! "${cc}" == ".config" ]]; then
    aa="$(grep "CONFIG_FILE" "${X}/settings.ini" |sed 's/^[ ]*//g' |grep -v '^#' |awk '{print $(1)}')"
    bb="$(grep "CONFIG_FILE" "${X}/settings.ini.bak" |sed 's/^[ ]*//g' |grep -v '^#' |awk '{print $(1)}')"
    if [[ -n "${aa}" ]] && [[ -n "${bb}" ]]; then
     sed -i "s?${aa}?${bb}?g" "${X}/settings.ini"
    fi
  fi
  aa="$(grep "DIY_PART_SH" "${X}/settings.ini" |sed 's/^[ ]*//g' |grep -v '^#' |awk '{print $(1)}')"
  bb="$(grep "DIY_PART_SH" "${X}/settings.ini.bak" |sed 's/^[ ]*//g' |grep -v '^#' |awk '{print $(1)}')"
  if [[ -n "${aa}" ]] && [[ -n "${bb}" ]]; then
   sed -i "s?${aa}?${bb}?g" "${X}/settings.ini"
  fi
  aa="$(grep "COLLECTED_PACKAGES" "${X}/settings.ini" |sed 's/^[ ]*//g' |grep -v '^#' |awk '{print $(1)}')"
  bb="$(grep "COLLECTED_PACKAGES" "${X}/settings.ini.bak" |sed 's/^[ ]*//g' |grep -v '^#' |awk '{print $(1)}')"
  if [[ -n "${aa}" ]] && [[ -n "${bb}" ]]; then
   sed -i "s?${aa}?${bb}?g" "${X}/settings.ini"
  fi
  aa="$(grep "MODIFY_CONFIGURATION" "${X}/settings.ini" |sed 's/^[ ]*//g' |grep -v '^#' |awk '{print $(1)}')"
  bb="$(grep "MODIFY_CONFIGURATION" "${X}/settings.ini.bak" |sed 's/^[ ]*//g' |grep -v '^#' |awk '{print $(1)}')"
  if [[ -n "${aa}" ]] && [[ -n "${bb}" ]]; then
   sed -i "s?${aa}?${bb}?g" "${X}/settings.ini"
  fi
  aa="$(grep "PACKAGING_FIRMWARE" "${X}/settings.ini" |sed 's/^[ ]*//g' |grep -v '^#' |awk '{print $(1)}')"
  bb="$(grep "PACKAGING_FIRMWARE" "${X}/settings.ini.bak" |sed 's/^[ ]*//g' |grep -v '^#' |awk '{print $(1)}')"
  if [[ -n "${aa}" ]] && [[ -n "${bb}" ]]; then
   sed -i "s?${aa}?${bb}?g" "${X}/settings.ini"
  fi
  aa="$(grep "WSL_ROUTEPATH" "${X}/settings.ini" |sed 's/^[ ]*//g' |grep -v '^#' |awk '{print $(1)}')"
  bb="$(grep "WSL_ROUTEPATH" "${X}/settings.ini.bak" |sed 's/^[ ]*//g' |grep -v '^#' |awk '{print $(1)}')"
  if [[ -n "${aa}" ]] && [[ -n "${bb}" ]]; then
   sed -i "s?${aa}?${bb}?g" "${X}/settings.ini"
  fi
  
  aa="$(grep "SSH_ACTIONS" "${X}/settings.ini" |sed 's/^[ ]*//g' |grep -v '^#' |awk '{print $(1)}')"
  bb="$(grep "SSH_ACTIONS" "${X}/settings.ini.bak" |sed 's/^[ ]*//g' |grep -v '^#' |awk '{print $(1)}')"
  if [[ -n "${aa}" ]] && [[ -n "${bb}" ]]; then
   sed -i "s?${aa}?${bb}?g" "${X}/settings.ini"
  fi
  aa="$(grep "UPLOAD_CONFIG" "${X}/settings.ini" |sed 's/^[ ]*//g' |grep -v '^#' |awk '{print $(1)}')"
  bb="$(grep "UPLOAD_CONFIG" "${X}/settings.ini.bak" |sed 's/^[ ]*//g' |grep -v '^#' |awk '{print $(1)}')"
  if [[ -n "${aa}" ]] && [[ -n "${bb}" ]]; then
   sed -i "s?${aa}?${bb}?g" "${X}/settings.ini"
  fi
  aa="$(grep "UPLOAD_FIRMWARE" "${X}/settings.ini" |sed 's/^[ ]*//g' |grep -v '^#' |awk '{print $(1)}')"
  bb="$(grep "UPLOAD_FIRMWARE" "${X}/settings.ini.bak" |sed 's/^[ ]*//g' |grep -v '^#' |awk '{print $(1)}')"
  if [[ -n "${aa}" ]] && [[ -n "${bb}" ]]; then
   sed -i "s?${aa}?${bb}?g" "${X}/settings.ini"
  fi
  aa="$(grep "UPLOAD_WETRANSFER" "${X}/settings.ini" |sed 's/^[ ]*//g' |grep -v '^#' |awk '{print $(1)}')"
  bb="$(grep "UPLOAD_WETRANSFER" "${X}/settings.ini.bak" |sed 's/^[ ]*//g' |grep -v '^#' |awk '{print $(1)}')"
  if [[ -n "${aa}" ]] && [[ -n "${bb}" ]]; then
   sed -i "s?${aa}?${bb}?g" "${X}/settings.ini"
  fi
  aa="$(grep "UPLOAD_RELEASE" "${X}/settings.ini" |sed 's/^[ ]*//g' |grep -v '^#' |awk '{print $(1)}')"
  bb="$(grep "UPLOAD_RELEASE" "${X}/settings.ini.bak" |sed 's/^[ ]*//g' |grep -v '^#' |awk '{print $(1)}')"
  if [[ -n "${aa}" ]] && [[ -n "${bb}" ]]; then
   sed -i "s?${aa}?${bb}?g" "${X}/settings.ini"
  fi
  aa="$(grep "INFORMATION_NOTICE" "${X}/settings.ini" |sed 's/^[ ]*//g' |grep -v '^#' |awk '{print $(1)}')"
  bb="$(grep "INFORMATION_NOTICE" "${X}/settings.ini.bak" |sed 's/^[ ]*//g' |grep -v '^#' |awk '{print $(1)}')"
  if [[ -n "${aa}" ]] && [[ -n "${bb}" ]]; then
   sed -i "s?${aa}?${bb}?g" "${X}/settings.ini"
  fi
  aa="$(grep "CACHEWRTBUILD_SWITCH" "${X}/settings.ini" |sed 's/^[ ]*//g' |grep -v '^#' |awk '{print $(1)}')"
  bb="$(grep "CACHEWRTBUILD_SWITCH" "${X}/settings.ini.bak" |sed 's/^[ ]*//g' |grep -v '^#' |awk '{print $(1)}')"
  if [[ -n "${aa}" ]] && [[ -n "${bb}" ]]; then
   sed -i "s?${aa}?${bb}?g" "${X}/settings.ini"
  fi
  aa="$(grep "UPDATE_FIRMWARE_ONLINE" "${X}/settings.ini" |sed 's/^[ ]*//g' |grep -v '^#' |awk '{print $(1)}')"
  bb="$(grep "UPDATE_FIRMWARE_ONLINE" "${X}/settings.ini.bak" |sed 's/^[ ]*//g' |grep -v '^#' |awk '{print $(1)}')"
  if [[ -n "${aa}" ]] && [[ -n "${bb}" ]]; then
   sed -i "s?${aa}?${bb}?g" "${X}/settings.ini"
  fi
  aa="$(grep "COMPILATION_INFORMATION" "${X}/settings.ini" |sed 's/^[ ]*//g' |grep -v '^#' |awk '{print $(1)}')"
  bb="$(grep "COMPILATION_INFORMATION" "${X}/settings.ini.bak" |sed 's/^[ ]*//g' |grep -v '^#' |awk '{print $(1)}')"
  if [[ -n "${aa}" ]] && [[ -n "${bb}" ]]; then
   sed -i "s?${aa}?${bb}?g" "${X}/settings.ini"
  fi
done

# 天灵
for X in $(grep "\"IMMORTALWRT\"" -rl "DIY-SETUP" |grep "settings.ini" |sed 's/\/settings.*//g' |uniq); do
  aa="$(grep "REPO_BRANCH" "${X}/settings.ini" |sed 's/^[ ]*//g' |grep -v '^#' |awk '{print $(1)}')"
  bb="$(grep "REPO_BRANCH" "${X}/settings.ini.bak" |sed 's/^[ ]*//g' |grep -v '^#' |awk '{print $(1)}')"
  if [[ -n "${aa}" ]] && [[ -n "${bb}" ]]; then
   sed -i "s?${aa}?${bb}?g" "${X}/settings.ini"
  fi
  cc="$(grep "CONFIG_FILE" "${X}/settings.ini.bak" |sed 's/^[ ]*//g' |grep -v '^#' |cut -d '"' -f2)"
  if [[ ! "${cc}" == ".config" ]]; then
    aa="$(grep "CONFIG_FILE" "${X}/settings.ini" |sed 's/^[ ]*//g' |grep -v '^#' |awk '{print $(1)}')"
    bb="$(grep "CONFIG_FILE" "${X}/settings.ini.bak" |sed 's/^[ ]*//g' |grep -v '^#' |awk '{print $(1)}')"
    if [[ -n "${aa}" ]] && [[ -n "${bb}" ]]; then
     sed -i "s?${aa}?${bb}?g" "${X}/settings.ini"
    fi
  fi
  aa="$(grep "DIY_PART_SH" "${X}/settings.ini" |sed 's/^[ ]*//g' |grep -v '^#' |awk '{print $(1)}')"
  bb="$(grep "DIY_PART_SH" "${X}/settings.ini.bak" |sed 's/^[ ]*//g' |grep -v '^#' |awk '{print $(1)}')"
  if [[ -n "${aa}" ]] && [[ -n "${bb}" ]]; then
   sed -i "s?${aa}?${bb}?g" "${X}/settings.ini"
  fi
  aa="$(grep "COLLECTED_PACKAGES" "${X}/settings.ini" |sed 's/^[ ]*//g' |grep -v '^#' |awk '{print $(1)}')"
  bb="$(grep "COLLECTED_PACKAGES" "${X}/settings.ini.bak" |sed 's/^[ ]*//g' |grep -v '^#' |awk '{print $(1)}')"
  if [[ -n "${aa}" ]] && [[ -n "${bb}" ]]; then
   sed -i "s?${aa}?${bb}?g" "${X}/settings.ini"
  fi
  aa="$(grep "MODIFY_CONFIGURATION" "${X}/settings.ini" |sed 's/^[ ]*//g' |grep -v '^#' |awk '{print $(1)}')"
  bb="$(grep "MODIFY_CONFIGURATION" "${X}/settings.ini.bak" |sed 's/^[ ]*//g' |grep -v '^#' |awk '{print $(1)}')"
  if [[ -n "${aa}" ]] && [[ -n "${bb}" ]]; then
   sed -i "s?${aa}?${bb}?g" "${X}/settings.ini"
  fi
  aa="$(grep "PACKAGING_FIRMWARE" "${X}/settings.ini" |sed 's/^[ ]*//g' |grep -v '^#' |awk '{print $(1)}')"
  bb="$(grep "PACKAGING_FIRMWARE" "${X}/settings.ini.bak" |sed 's/^[ ]*//g' |grep -v '^#' |awk '{print $(1)}')"
  if [[ -n "${aa}" ]] && [[ -n "${bb}" ]]; then
   sed -i "s?${aa}?${bb}?g" "${X}/settings.ini"
  fi
  aa="$(grep "WSL_ROUTEPATH" "${X}/settings.ini" |sed 's/^[ ]*//g' |grep -v '^#' |awk '{print $(1)}')"
  bb="$(grep "WSL_ROUTEPATH" "${X}/settings.ini.bak" |sed 's/^[ ]*//g' |grep -v '^#' |awk '{print $(1)}')"
  if [[ -n "${aa}" ]] && [[ -n "${bb}" ]]; then
   sed -i "s?${aa}?${bb}?g" "${X}/settings.ini"
  fi
  
  aa="$(grep "SSH_ACTIONS" "${X}/settings.ini" |sed 's/^[ ]*//g' |grep -v '^#' |awk '{print $(1)}')"
  bb="$(grep "SSH_ACTIONS" "${X}/settings.ini.bak" |sed 's/^[ ]*//g' |grep -v '^#' |awk '{print $(1)}')"
  if [[ -n "${aa}" ]] && [[ -n "${bb}" ]]; then
   sed -i "s?${aa}?${bb}?g" "${X}/settings.ini"
  fi
  aa="$(grep "UPLOAD_CONFIG" "${X}/settings.ini" |sed 's/^[ ]*//g' |grep -v '^#' |awk '{print $(1)}')"
  bb="$(grep "UPLOAD_CONFIG" "${X}/settings.ini.bak" |sed 's/^[ ]*//g' |grep -v '^#' |awk '{print $(1)}')"
  if [[ -n "${aa}" ]] && [[ -n "${bb}" ]]; then
   sed -i "s?${aa}?${bb}?g" "${X}/settings.ini"
  fi
  aa="$(grep "UPLOAD_FIRMWARE" "${X}/settings.ini" |sed 's/^[ ]*//g' |grep -v '^#' |awk '{print $(1)}')"
  bb="$(grep "UPLOAD_FIRMWARE" "${X}/settings.ini.bak" |sed 's/^[ ]*//g' |grep -v '^#' |awk '{print $(1)}')"
  if [[ -n "${aa}" ]] && [[ -n "${bb}" ]]; then
   sed -i "s?${aa}?${bb}?g" "${X}/settings.ini"
  fi
  aa="$(grep "UPLOAD_WETRANSFER" "${X}/settings.ini" |sed 's/^[ ]*//g' |grep -v '^#' |awk '{print $(1)}')"
  bb="$(grep "UPLOAD_WETRANSFER" "${X}/settings.ini.bak" |sed 's/^[ ]*//g' |grep -v '^#' |awk '{print $(1)}')"
  if [[ -n "${aa}" ]] && [[ -n "${bb}" ]]; then
   sed -i "s?${aa}?${bb}?g" "${X}/settings.ini"
  fi
  aa="$(grep "UPLOAD_RELEASE" "${X}/settings.ini" |sed 's/^[ ]*//g' |grep -v '^#' |awk '{print $(1)}')"
  bb="$(grep "UPLOAD_RELEASE" "${X}/settings.ini.bak" |sed 's/^[ ]*//g' |grep -v '^#' |awk '{print $(1)}')"
  if [[ -n "${aa}" ]] && [[ -n "${bb}" ]]; then
   sed -i "s?${aa}?${bb}?g" "${X}/settings.ini"
  fi
  aa="$(grep "INFORMATION_NOTICE" "${X}/settings.ini" |sed 's/^[ ]*//g' |grep -v '^#' |awk '{print $(1)}')"
  bb="$(grep "INFORMATION_NOTICE" "${X}/settings.ini.bak" |sed 's/^[ ]*//g' |grep -v '^#' |awk '{print $(1)}')"
  if [[ -n "${aa}" ]] && [[ -n "${bb}" ]]; then
   sed -i "s?${aa}?${bb}?g" "${X}/settings.ini"
  fi
  aa="$(grep "CACHEWRTBUILD_SWITCH" "${X}/settings.ini" |sed 's/^[ ]*//g' |grep -v '^#' |awk '{print $(1)}')"
  bb="$(grep "CACHEWRTBUILD_SWITCH" "${X}/settings.ini.bak" |sed 's/^[ ]*//g' |grep -v '^#' |awk '{print $(1)}')"
  if [[ -n "${aa}" ]] && [[ -n "${bb}" ]]; then
   sed -i "s?${aa}?${bb}?g" "${X}/settings.ini"
  fi
  aa="$(grep "UPDATE_FIRMWARE_ONLINE" "${X}/settings.ini" |sed 's/^[ ]*//g' |grep -v '^#' |awk '{print $(1)}')"
  bb="$(grep "UPDATE_FIRMWARE_ONLINE" "${X}/settings.ini.bak" |sed 's/^[ ]*//g' |grep -v '^#' |awk '{print $(1)}')"
  if [[ -n "${aa}" ]] && [[ -n "${bb}" ]]; then
   sed -i "s?${aa}?${bb}?g" "${X}/settings.ini"
  fi
  aa="$(grep "COMPILATION_INFORMATION" "${X}/settings.ini" |sed 's/^[ ]*//g' |grep -v '^#' |awk '{print $(1)}')"
  bb="$(grep "COMPILATION_INFORMATION" "${X}/settings.ini.bak" |sed 's/^[ ]*//g' |grep -v '^#' |awk '{print $(1)}')"
  if [[ -n "${aa}" ]] && [[ -n "${bb}" ]]; then
   sed -i "s?${aa}?${bb}?g" "${X}/settings.ini"
  fi
done

# 大雕
for X in $(grep "\"COOLSNOWWOLF\"" -rl "DIY-SETUP" |grep "settings.ini" |sed 's/\/settings.*//g' |uniq); do
  aa="$(grep "REPO_BRANCH" "${X}/settings.ini" |sed 's/^[ ]*//g' |grep -v '^#' |awk '{print $(1)}')"
  bb="$(grep "REPO_BRANCH" "${X}/settings.ini.bak" |sed 's/^[ ]*//g' |grep -v '^#' |awk '{print $(1)}')"
  if [[ -n "${aa}" ]] && [[ -n "${bb}" ]]; then
   sed -i "s?${aa}?${bb}?g" "${X}/settings.ini"
  fi
  cc="$(grep "CONFIG_FILE" "${X}/settings.ini.bak" |sed 's/^[ ]*//g' |grep -v '^#' |cut -d '"' -f2)"
  if [[ ! "${cc}" == ".config" ]]; then
    aa="$(grep "CONFIG_FILE" "${X}/settings.ini" |sed 's/^[ ]*//g' |grep -v '^#' |awk '{print $(1)}')"
    bb="$(grep "CONFIG_FILE" "${X}/settings.ini.bak" |sed 's/^[ ]*//g' |grep -v '^#' |awk '{print $(1)}')"
    if [[ -n "${aa}" ]] && [[ -n "${bb}" ]]; then
     sed -i "s?${aa}?${bb}?g" "${X}/settings.ini"
    fi
  fi
  aa="$(grep "DIY_PART_SH" "${X}/settings.ini" |sed 's/^[ ]*//g' |grep -v '^#' |awk '{print $(1)}')"
  bb="$(grep "DIY_PART_SH" "${X}/settings.ini.bak" |sed 's/^[ ]*//g' |grep -v '^#' |awk '{print $(1)}')"
  if [[ -n "${aa}" ]] && [[ -n "${bb}" ]]; then
   sed -i "s?${aa}?${bb}?g" "${X}/settings.ini"
  fi
  aa="$(grep "COLLECTED_PACKAGES" "${X}/settings.ini" |sed 's/^[ ]*//g' |grep -v '^#' |awk '{print $(1)}')"
  bb="$(grep "COLLECTED_PACKAGES" "${X}/settings.ini.bak" |sed 's/^[ ]*//g' |grep -v '^#' |awk '{print $(1)}')"
  if [[ -n "${aa}" ]] && [[ -n "${bb}" ]]; then
   sed -i "s?${aa}?${bb}?g" "${X}/settings.ini"
  fi
  aa="$(grep "MODIFY_CONFIGURATION" "${X}/settings.ini" |sed 's/^[ ]*//g' |grep -v '^#' |awk '{print $(1)}')"
  bb="$(grep "MODIFY_CONFIGURATION" "${X}/settings.ini.bak" |sed 's/^[ ]*//g' |grep -v '^#' |awk '{print $(1)}')"
  if [[ -n "${aa}" ]] && [[ -n "${bb}" ]]; then
   sed -i "s?${aa}?${bb}?g" "${X}/settings.ini"
  fi
  aa="$(grep "PACKAGING_FIRMWARE" "${X}/settings.ini" |sed 's/^[ ]*//g' |grep -v '^#' |awk '{print $(1)}')"
  bb="$(grep "PACKAGING_FIRMWARE" "${X}/settings.ini.bak" |sed 's/^[ ]*//g' |grep -v '^#' |awk '{print $(1)}')"
  if [[ -n "${aa}" ]] && [[ -n "${bb}" ]]; then
   sed -i "s?${aa}?${bb}?g" "${X}/settings.ini"
  fi
  aa="$(grep "WSL_ROUTEPATH" "${X}/settings.ini" |sed 's/^[ ]*//g' |grep -v '^#' |awk '{print $(1)}')"
  bb="$(grep "WSL_ROUTEPATH" "${X}/settings.ini.bak" |sed 's/^[ ]*//g' |grep -v '^#' |awk '{print $(1)}')"
  if [[ -n "${aa}" ]] && [[ -n "${bb}" ]]; then
   sed -i "s?${aa}?${bb}?g" "${X}/settings.ini"
  fi
  
  aa="$(grep "SSH_ACTIONS" "${X}/settings.ini" |sed 's/^[ ]*//g' |grep -v '^#' |awk '{print $(1)}')"
  bb="$(grep "SSH_ACTIONS" "${X}/settings.ini.bak" |sed 's/^[ ]*//g' |grep -v '^#' |awk '{print $(1)}')"
  if [[ -n "${aa}" ]] && [[ -n "${bb}" ]]; then
   sed -i "s?${aa}?${bb}?g" "${X}/settings.ini"
  fi
  aa="$(grep "UPLOAD_CONFIG" "${X}/settings.ini" |sed 's/^[ ]*//g' |grep -v '^#' |awk '{print $(1)}')"
  bb="$(grep "UPLOAD_CONFIG" "${X}/settings.ini.bak" |sed 's/^[ ]*//g' |grep -v '^#' |awk '{print $(1)}')"
  if [[ -n "${aa}" ]] && [[ -n "${bb}" ]]; then
   sed -i "s?${aa}?${bb}?g" "${X}/settings.ini"
  fi
  aa="$(grep "UPLOAD_FIRMWARE" "${X}/settings.ini" |sed 's/^[ ]*//g' |grep -v '^#' |awk '{print $(1)}')"
  bb="$(grep "UPLOAD_FIRMWARE" "${X}/settings.ini.bak" |sed 's/^[ ]*//g' |grep -v '^#' |awk '{print $(1)}')"
  if [[ -n "${aa}" ]] && [[ -n "${bb}" ]]; then
   sed -i "s?${aa}?${bb}?g" "${X}/settings.ini"
  fi
  aa="$(grep "UPLOAD_WETRANSFER" "${X}/settings.ini" |sed 's/^[ ]*//g' |grep -v '^#' |awk '{print $(1)}')"
  bb="$(grep "UPLOAD_WETRANSFER" "${X}/settings.ini.bak" |sed 's/^[ ]*//g' |grep -v '^#' |awk '{print $(1)}')"
  if [[ -n "${aa}" ]] && [[ -n "${bb}" ]]; then
   sed -i "s?${aa}?${bb}?g" "${X}/settings.ini"
  fi
  aa="$(grep "UPLOAD_RELEASE" "${X}/settings.ini" |sed 's/^[ ]*//g' |grep -v '^#' |awk '{print $(1)}')"
  bb="$(grep "UPLOAD_RELEASE" "${X}/settings.ini.bak" |sed 's/^[ ]*//g' |grep -v '^#' |awk '{print $(1)}')"
  if [[ -n "${aa}" ]] && [[ -n "${bb}" ]]; then
   sed -i "s?${aa}?${bb}?g" "${X}/settings.ini"
  fi
  aa="$(grep "INFORMATION_NOTICE" "${X}/settings.ini" |sed 's/^[ ]*//g' |grep -v '^#' |awk '{print $(1)}')"
  bb="$(grep "INFORMATION_NOTICE" "${X}/settings.ini.bak" |sed 's/^[ ]*//g' |grep -v '^#' |awk '{print $(1)}')"
  if [[ -n "${aa}" ]] && [[ -n "${bb}" ]]; then
   sed -i "s?${aa}?${bb}?g" "${X}/settings.ini"
  fi
  aa="$(grep "CACHEWRTBUILD_SWITCH" "${X}/settings.ini" |sed 's/^[ ]*//g' |grep -v '^#' |awk '{print $(1)}')"
  bb="$(grep "CACHEWRTBUILD_SWITCH" "${X}/settings.ini.bak" |sed 's/^[ ]*//g' |grep -v '^#' |awk '{print $(1)}')"
  if [[ -n "${aa}" ]] && [[ -n "${bb}" ]]; then
   sed -i "s?${aa}?${bb}?g" "${X}/settings.ini"
  fi
  aa="$(grep "UPDATE_FIRMWARE_ONLINE" "${X}/settings.ini" |sed 's/^[ ]*//g' |grep -v '^#' |awk '{print $(1)}')"
  bb="$(grep "UPDATE_FIRMWARE_ONLINE" "${X}/settings.ini.bak" |sed 's/^[ ]*//g' |grep -v '^#' |awk '{print $(1)}')"
  if [[ -n "${aa}" ]] && [[ -n "${bb}" ]]; then
   sed -i "s?${aa}?${bb}?g" "${X}/settings.ini"
  fi
  aa="$(grep "COMPILATION_INFORMATION" "${X}/settings.ini" |sed 's/^[ ]*//g' |grep -v '^#' |awk '{print $(1)}')"
  bb="$(grep "COMPILATION_INFORMATION" "${X}/settings.ini.bak" |sed 's/^[ ]*//g' |grep -v '^#' |awk '{print $(1)}')"
  if [[ -n "${aa}" ]] && [[ -n "${bb}" ]]; then
   sed -i "s?${aa}?${bb}?g" "${X}/settings.ini"
  fi
done

# LI大
for X in $(grep "\"LIENOL\"" -rl "DIY-SETUP" |grep "settings.ini" |sed 's/\/settings.*//g' |uniq); do
  aa="$(grep "REPO_BRANCH" "${X}/settings.ini" |sed 's/^[ ]*//g' |grep -v '^#' |awk '{print $(1)}')"
  bb="$(grep "REPO_BRANCH" "${X}/settings.ini.bak" |sed 's/^[ ]*//g' |grep -v '^#' |awk '{print $(1)}')"
  if [[ -n "${aa}" ]] && [[ -n "${bb}" ]]; then
   sed -i "s?${aa}?${bb}?g" "${X}/settings.ini"
  fi
  cc="$(grep "CONFIG_FILE" "${X}/settings.ini.bak" |sed 's/^[ ]*//g' |grep -v '^#' |cut -d '"' -f2)"
  if [[ ! "${cc}" == ".config" ]]; then
    aa="$(grep "CONFIG_FILE" "${X}/settings.ini" |sed 's/^[ ]*//g' |grep -v '^#' |awk '{print $(1)}')"
    bb="$(grep "CONFIG_FILE" "${X}/settings.ini.bak" |sed 's/^[ ]*//g' |grep -v '^#' |awk '{print $(1)}')"
    if [[ -n "${aa}" ]] && [[ -n "${bb}" ]]; then
     sed -i "s?${aa}?${bb}?g" "${X}/settings.ini"
    fi
  fi
  aa="$(grep "DIY_PART_SH" "${X}/settings.ini" |sed 's/^[ ]*//g' |grep -v '^#' |awk '{print $(1)}')"
  bb="$(grep "DIY_PART_SH" "${X}/settings.ini.bak" |sed 's/^[ ]*//g' |grep -v '^#' |awk '{print $(1)}')"
  if [[ -n "${aa}" ]] && [[ -n "${bb}" ]]; then
   sed -i "s?${aa}?${bb}?g" "${X}/settings.ini"
  fi
  aa="$(grep "COLLECTED_PACKAGES" "${X}/settings.ini" |sed 's/^[ ]*//g' |grep -v '^#' |awk '{print $(1)}')"
  bb="$(grep "COLLECTED_PACKAGES" "${X}/settings.ini.bak" |sed 's/^[ ]*//g' |grep -v '^#' |awk '{print $(1)}')"
  if [[ -n "${aa}" ]] && [[ -n "${bb}" ]]; then
   sed -i "s?${aa}?${bb}?g" "${X}/settings.ini"
  fi
  aa="$(grep "MODIFY_CONFIGURATION" "${X}/settings.ini" |sed 's/^[ ]*//g' |grep -v '^#' |awk '{print $(1)}')"
  bb="$(grep "MODIFY_CONFIGURATION" "${X}/settings.ini.bak" |sed 's/^[ ]*//g' |grep -v '^#' |awk '{print $(1)}')"
  if [[ -n "${aa}" ]] && [[ -n "${bb}" ]]; then
   sed -i "s?${aa}?${bb}?g" "${X}/settings.ini"
  fi
  aa="$(grep "PACKAGING_FIRMWARE" "${X}/settings.ini" |sed 's/^[ ]*//g' |grep -v '^#' |awk '{print $(1)}')"
  bb="$(grep "PACKAGING_FIRMWARE" "${X}/settings.ini.bak" |sed 's/^[ ]*//g' |grep -v '^#' |awk '{print $(1)}')"
  if [[ -n "${aa}" ]] && [[ -n "${bb}" ]]; then
   sed -i "s?${aa}?${bb}?g" "${X}/settings.ini"
  fi
  aa="$(grep "WSL_ROUTEPATH" "${X}/settings.ini" |sed 's/^[ ]*//g' |grep -v '^#' |awk '{print $(1)}')"
  bb="$(grep "WSL_ROUTEPATH" "${X}/settings.ini.bak" |sed 's/^[ ]*//g' |grep -v '^#' |awk '{print $(1)}')"
  if [[ -n "${aa}" ]] && [[ -n "${bb}" ]]; then
   sed -i "s?${aa}?${bb}?g" "${X}/settings.ini"
  fi
  
  aa="$(grep "SSH_ACTIONS" "${X}/settings.ini" |sed 's/^[ ]*//g' |grep -v '^#' |awk '{print $(1)}')"
  bb="$(grep "SSH_ACTIONS" "${X}/settings.ini.bak" |sed 's/^[ ]*//g' |grep -v '^#' |awk '{print $(1)}')"
  if [[ -n "${aa}" ]] && [[ -n "${bb}" ]]; then
   sed -i "s?${aa}?${bb}?g" "${X}/settings.ini"
  fi
  aa="$(grep "UPLOAD_CONFIG" "${X}/settings.ini" |sed 's/^[ ]*//g' |grep -v '^#' |awk '{print $(1)}')"
  bb="$(grep "UPLOAD_CONFIG" "${X}/settings.ini.bak" |sed 's/^[ ]*//g' |grep -v '^#' |awk '{print $(1)}')"
  if [[ -n "${aa}" ]] && [[ -n "${bb}" ]]; then
   sed -i "s?${aa}?${bb}?g" "${X}/settings.ini"
  fi
  aa="$(grep "UPLOAD_FIRMWARE" "${X}/settings.ini" |sed 's/^[ ]*//g' |grep -v '^#' |awk '{print $(1)}')"
  bb="$(grep "UPLOAD_FIRMWARE" "${X}/settings.ini.bak" |sed 's/^[ ]*//g' |grep -v '^#' |awk '{print $(1)}')"
  if [[ -n "${aa}" ]] && [[ -n "${bb}" ]]; then
   sed -i "s?${aa}?${bb}?g" "${X}/settings.ini"
  fi
  aa="$(grep "UPLOAD_WETRANSFER" "${X}/settings.ini" |sed 's/^[ ]*//g' |grep -v '^#' |awk '{print $(1)}')"
  bb="$(grep "UPLOAD_WETRANSFER" "${X}/settings.ini.bak" |sed 's/^[ ]*//g' |grep -v '^#' |awk '{print $(1)}')"
  if [[ -n "${aa}" ]] && [[ -n "${bb}" ]]; then
   sed -i "s?${aa}?${bb}?g" "${X}/settings.ini"
  fi
  aa="$(grep "UPLOAD_RELEASE" "${X}/settings.ini" |sed 's/^[ ]*//g' |grep -v '^#' |awk '{print $(1)}')"
  bb="$(grep "UPLOAD_RELEASE" "${X}/settings.ini.bak" |sed 's/^[ ]*//g' |grep -v '^#' |awk '{print $(1)}')"
  if [[ -n "${aa}" ]] && [[ -n "${bb}" ]]; then
   sed -i "s?${aa}?${bb}?g" "${X}/settings.ini"
  fi
  aa="$(grep "INFORMATION_NOTICE" "${X}/settings.ini" |sed 's/^[ ]*//g' |grep -v '^#' |awk '{print $(1)}')"
  bb="$(grep "INFORMATION_NOTICE" "${X}/settings.ini.bak" |sed 's/^[ ]*//g' |grep -v '^#' |awk '{print $(1)}')"
  if [[ -n "${aa}" ]] && [[ -n "${bb}" ]]; then
   sed -i "s?${aa}?${bb}?g" "${X}/settings.ini"
  fi
  aa="$(grep "CACHEWRTBUILD_SWITCH" "${X}/settings.ini" |sed 's/^[ ]*//g' |grep -v '^#' |awk '{print $(1)}')"
  bb="$(grep "CACHEWRTBUILD_SWITCH" "${X}/settings.ini.bak" |sed 's/^[ ]*//g' |grep -v '^#' |awk '{print $(1)}')"
  if [[ -n "${aa}" ]] && [[ -n "${bb}" ]]; then
   sed -i "s?${aa}?${bb}?g" "${X}/settings.ini"
  fi
  aa="$(grep "UPDATE_FIRMWARE_ONLINE" "${X}/settings.ini" |sed 's/^[ ]*//g' |grep -v '^#' |awk '{print $(1)}')"
  bb="$(grep "UPDATE_FIRMWARE_ONLINE" "${X}/settings.ini.bak" |sed 's/^[ ]*//g' |grep -v '^#' |awk '{print $(1)}')"
  if [[ -n "${aa}" ]] && [[ -n "${bb}" ]]; then
   sed -i "s?${aa}?${bb}?g" "${X}/settings.ini"
  fi
  aa="$(grep "COMPILATION_INFORMATION" "${X}/settings.ini" |sed 's/^[ ]*//g' |grep -v '^#' |awk '{print $(1)}')"
  bb="$(grep "COMPILATION_INFORMATION" "${X}/settings.ini.bak" |sed 's/^[ ]*//g' |grep -v '^#' |awk '{print $(1)}')"
  if [[ -n "${aa}" ]] && [[ -n "${bb}" ]]; then
   sed -i "s?${aa}?${bb}?g" "${X}/settings.ini"
  fi
done

# 官方的
for X in $(grep "\"OFFICIAL\"" -rl "DIY-SETUP" |grep "settings.ini" |sed 's/\/settings.*//g' |uniq); do
  aa="$(grep "REPO_BRANCH" "${X}/settings.ini" |sed 's/^[ ]*//g' |grep -v '^#' |awk '{print $(1)}')"
  bb="$(grep "REPO_BRANCH" "${X}/settings.ini.bak" |sed 's/^[ ]*//g' |grep -v '^#' |awk '{print $(1)}')"
  if [[ -n "${aa}" ]] && [[ -n "${bb}" ]]; then
   sed -i "s?${aa}?${bb}?g" "${X}/settings.ini"
  fi
  cc="$(grep "CONFIG_FILE" "${X}/settings.ini.bak" |sed 's/^[ ]*//g' |grep -v '^#' |cut -d '"' -f2)"
  if [[ ! "${cc}" == ".config" ]]; then
    aa="$(grep "CONFIG_FILE" "${X}/settings.ini" |sed 's/^[ ]*//g' |grep -v '^#' |awk '{print $(1)}')"
    bb="$(grep "CONFIG_FILE" "${X}/settings.ini.bak" |sed 's/^[ ]*//g' |grep -v '^#' |awk '{print $(1)}')"
    if [[ -n "${aa}" ]] && [[ -n "${bb}" ]]; then
     sed -i "s?${aa}?${bb}?g" "${X}/settings.ini"
    fi
  fi
  aa="$(grep "DIY_PART_SH" "${X}/settings.ini" |sed 's/^[ ]*//g' |grep -v '^#' |awk '{print $(1)}')"
  bb="$(grep "DIY_PART_SH" "${X}/settings.ini.bak" |sed 's/^[ ]*//g' |grep -v '^#' |awk '{print $(1)}')"
  if [[ -n "${aa}" ]] && [[ -n "${bb}" ]]; then
   sed -i "s?${aa}?${bb}?g" "${X}/settings.ini"
  fi
  aa="$(grep "COLLECTED_PACKAGES" "${X}/settings.ini" |sed 's/^[ ]*//g' |grep -v '^#' |awk '{print $(1)}')"
  bb="$(grep "COLLECTED_PACKAGES" "${X}/settings.ini.bak" |sed 's/^[ ]*//g' |grep -v '^#' |awk '{print $(1)}')"
  if [[ -n "${aa}" ]] && [[ -n "${bb}" ]]; then
   sed -i "s?${aa}?${bb}?g" "${X}/settings.ini"
  fi
  aa="$(grep "MODIFY_CONFIGURATION" "${X}/settings.ini" |sed 's/^[ ]*//g' |grep -v '^#' |awk '{print $(1)}')"
  bb="$(grep "MODIFY_CONFIGURATION" "${X}/settings.ini.bak" |sed 's/^[ ]*//g' |grep -v '^#' |awk '{print $(1)}')"
  if [[ -n "${aa}" ]] && [[ -n "${bb}" ]]; then
   sed -i "s?${aa}?${bb}?g" "${X}/settings.ini"
  fi
  aa="$(grep "PACKAGING_FIRMWARE" "${X}/settings.ini" |sed 's/^[ ]*//g' |grep -v '^#' |awk '{print $(1)}')"
  bb="$(grep "PACKAGING_FIRMWARE" "${X}/settings.ini.bak" |sed 's/^[ ]*//g' |grep -v '^#' |awk '{print $(1)}')"
  if [[ -n "${aa}" ]] && [[ -n "${bb}" ]]; then
   sed -i "s?${aa}?${bb}?g" "${X}/settings.ini"
  fi
  aa="$(grep "WSL_ROUTEPATH" "${X}/settings.ini" |sed 's/^[ ]*//g' |grep -v '^#' |awk '{print $(1)}')"
  bb="$(grep "WSL_ROUTEPATH" "${X}/settings.ini.bak" |sed 's/^[ ]*//g' |grep -v '^#' |awk '{print $(1)}')"
  if [[ -n "${aa}" ]] && [[ -n "${bb}" ]]; then
   sed -i "s?${aa}?${bb}?g" "${X}/settings.ini"
  fi
  
  aa="$(grep "SSH_ACTIONS" "${X}/settings.ini" |sed 's/^[ ]*//g' |grep -v '^#' |awk '{print $(1)}')"
  bb="$(grep "SSH_ACTIONS" "${X}/settings.ini.bak" |sed 's/^[ ]*//g' |grep -v '^#' |awk '{print $(1)}')"
  if [[ -n "${aa}" ]] && [[ -n "${bb}" ]]; then
   sed -i "s?${aa}?${bb}?g" "${X}/settings.ini"
  fi
  aa="$(grep "UPLOAD_CONFIG" "${X}/settings.ini" |sed 's/^[ ]*//g' |grep -v '^#' |awk '{print $(1)}')"
  bb="$(grep "UPLOAD_CONFIG" "${X}/settings.ini.bak" |sed 's/^[ ]*//g' |grep -v '^#' |awk '{print $(1)}')"
  if [[ -n "${aa}" ]] && [[ -n "${bb}" ]]; then
   sed -i "s?${aa}?${bb}?g" "${X}/settings.ini"
  fi
  aa="$(grep "UPLOAD_FIRMWARE" "${X}/settings.ini" |sed 's/^[ ]*//g' |grep -v '^#' |awk '{print $(1)}')"
  bb="$(grep "UPLOAD_FIRMWARE" "${X}/settings.ini.bak" |sed 's/^[ ]*//g' |grep -v '^#' |awk '{print $(1)}')"
  if [[ -n "${aa}" ]] && [[ -n "${bb}" ]]; then
   sed -i "s?${aa}?${bb}?g" "${X}/settings.ini"
  fi
  aa="$(grep "UPLOAD_WETRANSFER" "${X}/settings.ini" |sed 's/^[ ]*//g' |grep -v '^#' |awk '{print $(1)}')"
  bb="$(grep "UPLOAD_WETRANSFER" "${X}/settings.ini.bak" |sed 's/^[ ]*//g' |grep -v '^#' |awk '{print $(1)}')"
  if [[ -n "${aa}" ]] && [[ -n "${bb}" ]]; then
   sed -i "s?${aa}?${bb}?g" "${X}/settings.ini"
  fi
  aa="$(grep "UPLOAD_RELEASE" "${X}/settings.ini" |sed 's/^[ ]*//g' |grep -v '^#' |awk '{print $(1)}')"
  bb="$(grep "UPLOAD_RELEASE" "${X}/settings.ini.bak" |sed 's/^[ ]*//g' |grep -v '^#' |awk '{print $(1)}')"
  if [[ -n "${aa}" ]] && [[ -n "${bb}" ]]; then
   sed -i "s?${aa}?${bb}?g" "${X}/settings.ini"
  fi
  aa="$(grep "INFORMATION_NOTICE" "${X}/settings.ini" |sed 's/^[ ]*//g' |grep -v '^#' |awk '{print $(1)}')"
  bb="$(grep "INFORMATION_NOTICE" "${X}/settings.ini.bak" |sed 's/^[ ]*//g' |grep -v '^#' |awk '{print $(1)}')"
  if [[ -n "${aa}" ]] && [[ -n "${bb}" ]]; then
   sed -i "s?${aa}?${bb}?g" "${X}/settings.ini"
  fi
  aa="$(grep "CACHEWRTBUILD_SWITCH" "${X}/settings.ini" |sed 's/^[ ]*//g' |grep -v '^#' |awk '{print $(1)}')"
  bb="$(grep "CACHEWRTBUILD_SWITCH" "${X}/settings.ini.bak" |sed 's/^[ ]*//g' |grep -v '^#' |awk '{print $(1)}')"
  if [[ -n "${aa}" ]] && [[ -n "${bb}" ]]; then
   sed -i "s?${aa}?${bb}?g" "${X}/settings.ini"
  fi
  aa="$(grep "UPDATE_FIRMWARE_ONLINE" "${X}/settings.ini" |sed 's/^[ ]*//g' |grep -v '^#' |awk '{print $(1)}')"
  bb="$(grep "UPDATE_FIRMWARE_ONLINE" "${X}/settings.ini.bak" |sed 's/^[ ]*//g' |grep -v '^#' |awk '{print $(1)}')"
  if [[ -n "${aa}" ]] && [[ -n "${bb}" ]]; then
   sed -i "s?${aa}?${bb}?g" "${X}/settings.ini"
  fi
  aa="$(grep "COMPILATION_INFORMATION" "${X}/settings.ini" |sed 's/^[ ]*//g' |grep -v '^#' |awk '{print $(1)}')"
  bb="$(grep "COMPILATION_INFORMATION" "${X}/settings.ini.bak" |sed 's/^[ ]*//g' |grep -v '^#' |awk '{print $(1)}')"
  if [[ -n "${aa}" ]] && [[ -n "${bb}" ]]; then
   sed -i "s?${aa}?${bb}?g" "${X}/settings.ini"
  fi
done

# x_wrt
for X in $(grep "\"XWRT\"" -rl "DIY-SETUP" |grep "settings.ini" |sed 's/\/settings.*//g' |uniq); do
  aa="$(grep "REPO_BRANCH" "${X}/settings.ini" |sed 's/^[ ]*//g' |grep -v '^#' |awk '{print $(1)}')"
  bb="$(grep "REPO_BRANCH" "${X}/settings.ini.bak" |sed 's/^[ ]*//g' |grep -v '^#' |awk '{print $(1)}')"
  if [[ -n "${aa}" ]] && [[ -n "${bb}" ]]; then
   sed -i "s?${aa}?${bb}?g" "${X}/settings.ini"
  fi
  cc="$(grep "CONFIG_FILE" "${X}/settings.ini.bak" |sed 's/^[ ]*//g' |grep -v '^#' |cut -d '"' -f2)"
  if [[ ! "${cc}" == ".config" ]]; then
    aa="$(grep "CONFIG_FILE" "${X}/settings.ini" |sed 's/^[ ]*//g' |grep -v '^#' |awk '{print $(1)}')"
    bb="$(grep "CONFIG_FILE" "${X}/settings.ini.bak" |sed 's/^[ ]*//g' |grep -v '^#' |awk '{print $(1)}')"
    if [[ -n "${aa}" ]] && [[ -n "${bb}" ]]; then
     sed -i "s?${aa}?${bb}?g" "${X}/settings.ini"
    fi
  fi
  aa="$(grep "DIY_PART_SH" "${X}/settings.ini" |sed 's/^[ ]*//g' |grep -v '^#' |awk '{print $(1)}')"
  bb="$(grep "DIY_PART_SH" "${X}/settings.ini.bak" |sed 's/^[ ]*//g' |grep -v '^#' |awk '{print $(1)}')"
  if [[ -n "${aa}" ]] && [[ -n "${bb}" ]]; then
   sed -i "s?${aa}?${bb}?g" "${X}/settings.ini"
  fi
  aa="$(grep "COLLECTED_PACKAGES" "${X}/settings.ini" |sed 's/^[ ]*//g' |grep -v '^#' |awk '{print $(1)}')"
  bb="$(grep "COLLECTED_PACKAGES" "${X}/settings.ini.bak" |sed 's/^[ ]*//g' |grep -v '^#' |awk '{print $(1)}')"
  if [[ -n "${aa}" ]] && [[ -n "${bb}" ]]; then
   sed -i "s?${aa}?${bb}?g" "${X}/settings.ini"
  fi
  aa="$(grep "MODIFY_CONFIGURATION" "${X}/settings.ini" |sed 's/^[ ]*//g' |grep -v '^#' |awk '{print $(1)}')"
  bb="$(grep "MODIFY_CONFIGURATION" "${X}/settings.ini.bak" |sed 's/^[ ]*//g' |grep -v '^#' |awk '{print $(1)}')"
  if [[ -n "${aa}" ]] && [[ -n "${bb}" ]]; then
   sed -i "s?${aa}?${bb}?g" "${X}/settings.ini"
  fi
  aa="$(grep "PACKAGING_FIRMWARE" "${X}/settings.ini" |sed 's/^[ ]*//g' |grep -v '^#' |awk '{print $(1)}')"
  bb="$(grep "PACKAGING_FIRMWARE" "${X}/settings.ini.bak" |sed 's/^[ ]*//g' |grep -v '^#' |awk '{print $(1)}')"
  if [[ -n "${aa}" ]] && [[ -n "${bb}" ]]; then
   sed -i "s?${aa}?${bb}?g" "${X}/settings.ini"
  fi
  aa="$(grep "WSL_ROUTEPATH" "${X}/settings.ini" |sed 's/^[ ]*//g' |grep -v '^#' |awk '{print $(1)}')"
  bb="$(grep "WSL_ROUTEPATH" "${X}/settings.ini.bak" |sed 's/^[ ]*//g' |grep -v '^#' |awk '{print $(1)}')"
  if [[ -n "${aa}" ]] && [[ -n "${bb}" ]]; then
   sed -i "s?${aa}?${bb}?g" "${X}/settings.ini"
  fi
  
  aa="$(grep "SSH_ACTIONS" "${X}/settings.ini" |sed 's/^[ ]*//g' |grep -v '^#' |awk '{print $(1)}')"
  bb="$(grep "SSH_ACTIONS" "${X}/settings.ini.bak" |sed 's/^[ ]*//g' |grep -v '^#' |awk '{print $(1)}')"
  if [[ -n "${aa}" ]] && [[ -n "${bb}" ]]; then
   sed -i "s?${aa}?${bb}?g" "${X}/settings.ini"
  fi
  aa="$(grep "UPLOAD_CONFIG" "${X}/settings.ini" |sed 's/^[ ]*//g' |grep -v '^#' |awk '{print $(1)}')"
  bb="$(grep "UPLOAD_CONFIG" "${X}/settings.ini.bak" |sed 's/^[ ]*//g' |grep -v '^#' |awk '{print $(1)}')"
  if [[ -n "${aa}" ]] && [[ -n "${bb}" ]]; then
   sed -i "s?${aa}?${bb}?g" "${X}/settings.ini"
  fi
  aa="$(grep "UPLOAD_FIRMWARE" "${X}/settings.ini" |sed 's/^[ ]*//g' |grep -v '^#' |awk '{print $(1)}')"
  bb="$(grep "UPLOAD_FIRMWARE" "${X}/settings.ini.bak" |sed 's/^[ ]*//g' |grep -v '^#' |awk '{print $(1)}')"
  if [[ -n "${aa}" ]] && [[ -n "${bb}" ]]; then
   sed -i "s?${aa}?${bb}?g" "${X}/settings.ini"
  fi
  aa="$(grep "UPLOAD_WETRANSFER" "${X}/settings.ini" |sed 's/^[ ]*//g' |grep -v '^#' |awk '{print $(1)}')"
  bb="$(grep "UPLOAD_WETRANSFER" "${X}/settings.ini.bak" |sed 's/^[ ]*//g' |grep -v '^#' |awk '{print $(1)}')"
  if [[ -n "${aa}" ]] && [[ -n "${bb}" ]]; then
   sed -i "s?${aa}?${bb}?g" "${X}/settings.ini"
  fi
  aa="$(grep "UPLOAD_RELEASE" "${X}/settings.ini" |sed 's/^[ ]*//g' |grep -v '^#' |awk '{print $(1)}')"
  bb="$(grep "UPLOAD_RELEASE" "${X}/settings.ini.bak" |sed 's/^[ ]*//g' |grep -v '^#' |awk '{print $(1)}')"
  if [[ -n "${aa}" ]] && [[ -n "${bb}" ]]; then
   sed -i "s?${aa}?${bb}?g" "${X}/settings.ini"
  fi
  aa="$(grep "INFORMATION_NOTICE" "${X}/settings.ini" |sed 's/^[ ]*//g' |grep -v '^#' |awk '{print $(1)}')"
  bb="$(grep "INFORMATION_NOTICE" "${X}/settings.ini.bak" |sed 's/^[ ]*//g' |grep -v '^#' |awk '{print $(1)}')"
  if [[ -n "${aa}" ]] && [[ -n "${bb}" ]]; then
   sed -i "s?${aa}?${bb}?g" "${X}/settings.ini"
  fi
  aa="$(grep "CACHEWRTBUILD_SWITCH" "${X}/settings.ini" |sed 's/^[ ]*//g' |grep -v '^#' |awk '{print $(1)}')"
  bb="$(grep "CACHEWRTBUILD_SWITCH" "${X}/settings.ini.bak" |sed 's/^[ ]*//g' |grep -v '^#' |awk '{print $(1)}')"
  if [[ -n "${aa}" ]] && [[ -n "${bb}" ]]; then
   sed -i "s?${aa}?${bb}?g" "${X}/settings.ini"
  fi
  aa="$(grep "UPDATE_FIRMWARE_ONLINE" "${X}/settings.ini" |sed 's/^[ ]*//g' |grep -v '^#' |awk '{print $(1)}')"
  bb="$(grep "UPDATE_FIRMWARE_ONLINE" "${X}/settings.ini.bak" |sed 's/^[ ]*//g' |grep -v '^#' |awk '{print $(1)}')"
  if [[ -n "${aa}" ]] && [[ -n "${bb}" ]]; then
   sed -i "s?${aa}?${bb}?g" "${X}/settings.ini"
  fi
  aa="$(grep "COMPILATION_INFORMATION" "${X}/settings.ini" |sed 's/^[ ]*//g' |grep -v '^#' |awk '{print $(1)}')"
  bb="$(grep "COMPILATION_INFORMATION" "${X}/settings.ini.bak" |sed 's/^[ ]*//g' |grep -v '^#' |awk '{print $(1)}')"
  if [[ -n "${aa}" ]] && [[ -n "${bb}" ]]; then
   sed -i "s?${aa}?${bb}?g" "${X}/settings.ini"
  fi
done


if [[ "${BENDI_SHANCHUBAK}" == "1" ]]; then
  for X in $(find "DIY-SETUP" -name "settings.ini" |sed 's/\/settings.ini//g'); do rm -rf "${X}"/*.bak; done
fi

# 上游仓库用完，删除了
if [[ "${TONGBU_CANGKU}" == "1" ]]; then
  mv -f DIY-SETUP repogx/build
else
  rm -rf shangyou
fi

exit 0
