#!/bin/bash

# 同步上游操作

# 第一步下载上游仓库
if [[ "${TONGBU_CANGKU}" == "1" ]]; then
  mv -f repogx/build DIY-SETUP
else
  rm -rf shangyou && git clone -b main https://github.com/shidahuilang/openwrt shangyou
  if [[ ! -d "DIY-SETUP" ]]; then
    cp -Rf shangyou/build DIY-SETUP
    BENDI_SHANCHUBAK="1"
  fi
fi

function tongbu_1() {
# 删除上游的.config和备份diy-part.sh、settings.ini
rm -rf shangyou/build/*/{diy,files,patches,seed}
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
  for X in $(ls -1 ${GITHUB_WORKSPACE}/repogx/.github/workflows |grep -Eo .*.yml); do 
    cp -Rf ${GITHUB_WORKSPACE}/repogx/.github/workflows/${X} ${GITHUB_WORKSPACE}/repogx/.github/workflows/${X}.bak
  done 
  
  for X in $(grep -Eo 'SOURCE_CODE: AMLOGIC' -rl "${GITHUB_WORKSPACE}/repogx/.github/workflows"); do 
    yml_name="$(grep 'name:' "${X}"  |grep -v '^#' |awk 'NR==1')"
    cp -Rf ${GITHUB_WORKSPACE}/shangyou/.github/workflows/Amlogic.yml ${X}
    sed -i "s?name: Amlogic-编译晶晨系列?${yml_name}?g" "${X}"
  done
  
  for X in $(grep 'SOURCE_CODE: OFFICIAL' -rl "${GITHUB_WORKSPACE}/repogx/.github/workflows"); do 
    yml_name="$(grep 'name:' "${X}"  |grep -v '^#' |awk 'NR==1')"
    cp -Rf "${GITHUB_WORKSPACE}/shangyou/.github/workflows/Official.yml" "${X}"
    sed -i "s?name: openwrt-官方?${yml_name}?g" "${X}"
  done
  
  for X in $(grep 'SOURCE_CODE: XWRT' -rl "${GITHUB_WORKSPACE}/repogx/.github/workflows"); do 
    yml_name="$(grep 'name:' "${X}"  |grep -v '^#' |awk 'NR==1')"
    cp -Rf "${GITHUB_WORKSPACE}/shangyou/.github/workflows/Xwrt.yml" "${X}"
    sed -i "s?name: Xwrt-源码?${yml_name}?g" "${X}"
  done
  
  for X in $(grep 'SOURCE_CODE: IMMORTALWRT' -rl "${GITHUB_WORKSPACE}/repogx/.github/workflows"); do 
    yml_name="$(grep 'name:' "${X}"  |grep -v '^#' |awk 'NR==1')"
    cp -Rf "${GITHUB_WORKSPACE}/shangyou/.github/workflows/Immortalwrt.yml" "${X}"
    sed -i "s?name: Immortalwrt-天灵?${yml_name}?g" "${X}"
  done
  
  for X in $(grep 'SOURCE_CODE: LIENOL' -rl "${GITHUB_WORKSPACE}/repogx/.github/workflows"); do 
    yml_name="$(grep 'name:' "${X}"  |grep -v '^#' |awk 'NR==1')"
    cp -Rf "${GITHUB_WORKSPACE}/shangyou/.github/workflows/Lienol.yml" "${X}"
    sed -i "s?name: Lienol-源码?${yml_name}?g" "${X}"
  done
  
  for X in $(grep 'SOURCE_CODE: COOLSNOWWOLF' -rl "${GITHUB_WORKSPACE}/repogx/.github/workflows"); do 
    yml_name="$(grep 'name:' "${X}"  |grep -v '^#' |awk 'NR==1')"
    cp -Rf "${GITHUB_WORKSPACE}/shangyou/.github/workflows/Lede.yml" "${X}"
    sed -i "s?name: Lede-大雕?${yml_name}?g" "${X}"
  done
  
  cp -Rf ${GITHUB_WORKSPACE}/shangyou/.github/workflows/compile.yml ${GITHUB_WORKSPACE}/repogx/.github/workflows/compile.yml
  cp -Rf ${GITHUB_WORKSPACE}/shangyou/.github/workflows/synchronise.yml ${GITHUB_WORKSPACE}/repogx/.github/workflows/synchronise.yml
;;
esac

# 修改本地文件
if [[ ! "${TONGBU_CANGKU}" == "1" ]]; then
rm -rf DIY-SETUP/*/relevance
for X in $(find "DIY-SETUP" -name "settings.ini" |sed 's/\/settings.ini//g'); do 
  mkdir -p "${X}/version"
  echo "BENDI_VERSION=${BENDI_VERSION}" > "${X}/version/bendi_version"
  echo "bendi_version文件为检测版本用,请勿修改和删除" > "${X}/version/README.md"
done
for X in $(find "DIY-SETUP" -name "settings.ini"); do
  sed -i '/SSH_ACTIONS/d' "${X}"
  sed -i '/UPLOAD_FIRMWARE/d' "${X}"
  sed -i '/UPLOAD_WETRANSFER/d' "${X}"
  sed -i '/UPLOAD_RELEASE/d' "${X}"
  sed -i '/INFORMATION_NOTICE/d' "${X}"
  sed -i '/CACHEWRTBUILD_SWITCH/d' "${X}"
  sed -i '/COMPILATION_INFORMATION/d' "${X}"
  sed -i '/UPDATE_FIRMWARE_ONLINE/d' "${X}"
  sed -i '/CPU_SELECTION/d' "${X}"
  sed -i '/RETAIN_DAYS/d' "${X}"
  sed -i '/KEEP_LATEST/d' "${X}"
  echo 'MODIFY_CONFIGURATION="true"            # 是否每次都询问您要不要设置自定义文件（true=开启）（false=关闭）' >> "${X}"
  if [[ `echo "${PATH}" |grep -c "Windows"` -ge '1' ]]; then
    echo 'WSL_ROUTEPATH="false"          # 关闭询问改变WSL路径（true=开启）（false=关闭）' >> "${X}"
  fi
  echo 'MAKE_CONFIGURATION="false"            # 单纯制作.config配置文件,不编译固件（true=开启）（false=关闭）' >> "${X}"
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
  aa="$(grep "CPU_SELECTION" "${X}/settings.ini" |sed 's/^[ ]*//g' |grep -v '^#' |awk '{print $(1)}')"
  bb="$(grep "CPU_SELECTION" "${X}/settings.ini.bak" |sed 's/^[ ]*//g' |grep -v '^#' |awk '{print $(1)}')"
  if [[ -n "${aa}" ]] && [[ -n "${bb}" ]]; then
   sed -i "s?${aa}?${bb}?g" "${X}/settings.ini"
  fi
  aa="$(grep "RETAIN_DAYS" "${X}/settings.ini" |sed 's/^[ ]*//g' |grep -v '^#' |awk '{print $(1)}')"
  bb="$(grep "RETAIN_DAYS" "${X}/settings.ini.bak" |sed 's/^[ ]*//g' |grep -v '^#' |awk '{print $(1)}')"
  if [[ -n "${aa}" ]] && [[ -n "${bb}" ]]; then
   sed -i "s?${aa}?${bb}?g" "${X}/settings.ini"
  fi
  aa="$(grep "KEEP_LATEST" "${X}/settings.ini" |sed 's/^[ ]*//g' |grep -v '^#' |awk '{print $(1)}')"
  bb="$(grep "KEEP_LATEST" "${X}/settings.ini.bak" |sed 's/^[ ]*//g' |grep -v '^#' |awk '{print $(1)}')"
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
  aa="$(grep "CPU_SELECTION" "${X}/settings.ini" |sed 's/^[ ]*//g' |grep -v '^#' |awk '{print $(1)}')"
  bb="$(grep "CPU_SELECTION" "${X}/settings.ini.bak" |sed 's/^[ ]*//g' |grep -v '^#' |awk '{print $(1)}')"
  if [[ -n "${aa}" ]] && [[ -n "${bb}" ]]; then
   sed -i "s?${aa}?${bb}?g" "${X}/settings.ini"
  fi
  aa="$(grep "RETAIN_DAYS" "${X}/settings.ini" |sed 's/^[ ]*//g' |grep -v '^#' |awk '{print $(1)}')"
  bb="$(grep "RETAIN_DAYS" "${X}/settings.ini.bak" |sed 's/^[ ]*//g' |grep -v '^#' |awk '{print $(1)}')"
  if [[ -n "${aa}" ]] && [[ -n "${bb}" ]]; then
   sed -i "s?${aa}?${bb}?g" "${X}/settings.ini"
  fi
  aa="$(grep "KEEP_LATEST" "${X}/settings.ini" |sed 's/^[ ]*//g' |grep -v '^#' |awk '{print $(1)}')"
  bb="$(grep "KEEP_LATEST" "${X}/settings.ini.bak" |sed 's/^[ ]*//g' |grep -v '^#' |awk '{print $(1)}')"
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
  aa="$(grep "CPU_SELECTION" "${X}/settings.ini" |sed 's/^[ ]*//g' |grep -v '^#' |awk '{print $(1)}')"
  bb="$(grep "CPU_SELECTION" "${X}/settings.ini.bak" |sed 's/^[ ]*//g' |grep -v '^#' |awk '{print $(1)}')"
  if [[ -n "${aa}" ]] && [[ -n "${bb}" ]]; then
   sed -i "s?${aa}?${bb}?g" "${X}/settings.ini"
  fi
  aa="$(grep "RETAIN_DAYS" "${X}/settings.ini" |sed 's/^[ ]*//g' |grep -v '^#' |awk '{print $(1)}')"
  bb="$(grep "RETAIN_DAYS" "${X}/settings.ini.bak" |sed 's/^[ ]*//g' |grep -v '^#' |awk '{print $(1)}')"
  if [[ -n "${aa}" ]] && [[ -n "${bb}" ]]; then
   sed -i "s?${aa}?${bb}?g" "${X}/settings.ini"
  fi
  aa="$(grep "KEEP_LATEST" "${X}/settings.ini" |sed 's/^[ ]*//g' |grep -v '^#' |awk '{print $(1)}')"
  bb="$(grep "KEEP_LATEST" "${X}/settings.ini.bak" |sed 's/^[ ]*//g' |grep -v '^#' |awk '{print $(1)}')"
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
  aa="$(grep "CPU_SELECTION" "${X}/settings.ini" |sed 's/^[ ]*//g' |grep -v '^#' |awk '{print $(1)}')"
  bb="$(grep "CPU_SELECTION" "${X}/settings.ini.bak" |sed 's/^[ ]*//g' |grep -v '^#' |awk '{print $(1)}')"
  if [[ -n "${aa}" ]] && [[ -n "${bb}" ]]; then
   sed -i "s?${aa}?${bb}?g" "${X}/settings.ini"
  fi
  aa="$(grep "RETAIN_DAYS" "${X}/settings.ini" |sed 's/^[ ]*//g' |grep -v '^#' |awk '{print $(1)}')"
  bb="$(grep "RETAIN_DAYS" "${X}/settings.ini.bak" |sed 's/^[ ]*//g' |grep -v '^#' |awk '{print $(1)}')"
  if [[ -n "${aa}" ]] && [[ -n "${bb}" ]]; then
   sed -i "s?${aa}?${bb}?g" "${X}/settings.ini"
  fi
  aa="$(grep "KEEP_LATEST" "${X}/settings.ini" |sed 's/^[ ]*//g' |grep -v '^#' |awk '{print $(1)}')"
  bb="$(grep "KEEP_LATEST" "${X}/settings.ini.bak" |sed 's/^[ ]*//g' |grep -v '^#' |awk '{print $(1)}')"
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
  aa="$(grep "CPU_SELECTION" "${X}/settings.ini" |sed 's/^[ ]*//g' |grep -v '^#' |awk '{print $(1)}')"
  bb="$(grep "CPU_SELECTION" "${X}/settings.ini.bak" |sed 's/^[ ]*//g' |grep -v '^#' |awk '{print $(1)}')"
  if [[ -n "${aa}" ]] && [[ -n "${bb}" ]]; then
   sed -i "s?${aa}?${bb}?g" "${X}/settings.ini"
  fi
  aa="$(grep "RETAIN_DAYS" "${X}/settings.ini" |sed 's/^[ ]*//g' |grep -v '^#' |awk '{print $(1)}')"
  bb="$(grep "RETAIN_DAYS" "${X}/settings.ini.bak" |sed 's/^[ ]*//g' |grep -v '^#' |awk '{print $(1)}')"
  if [[ -n "${aa}" ]] && [[ -n "${bb}" ]]; then
   sed -i "s?${aa}?${bb}?g" "${X}/settings.ini"
  fi
  aa="$(grep "KEEP_LATEST" "${X}/settings.ini" |sed 's/^[ ]*//g' |grep -v '^#' |awk '{print $(1)}')"
  bb="$(grep "KEEP_LATEST" "${X}/settings.ini.bak" |sed 's/^[ ]*//g' |grep -v '^#' |awk '{print $(1)}')"
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
  aa="$(grep "CPU_SELECTION" "${X}/settings.ini" |sed 's/^[ ]*//g' |grep -v '^#' |awk '{print $(1)}')"
  bb="$(grep "CPU_SELECTION" "${X}/settings.ini.bak" |sed 's/^[ ]*//g' |grep -v '^#' |awk '{print $(1)}')"
  if [[ -n "${aa}" ]] && [[ -n "${bb}" ]]; then
   sed -i "s?${aa}?${bb}?g" "${X}/settings.ini"
  fi
  aa="$(grep "RETAIN_DAYS" "${X}/settings.ini" |sed 's/^[ ]*//g' |grep -v '^#' |awk '{print $(1)}')"
  bb="$(grep "RETAIN_DAYS" "${X}/settings.ini.bak" |sed 's/^[ ]*//g' |grep -v '^#' |awk '{print $(1)}')"
  if [[ -n "${aa}" ]] && [[ -n "${bb}" ]]; then
   sed -i "s?${aa}?${bb}?g" "${X}/settings.ini"
  fi
  aa="$(grep "KEEP_LATEST" "${X}/settings.ini" |sed 's/^[ ]*//g' |grep -v '^#' |awk '{print $(1)}')"
  bb="$(grep "KEEP_LATEST" "${X}/settings.ini.bak" |sed 's/^[ ]*//g' |grep -v '^#' |awk '{print $(1)}')"
  if [[ -n "${aa}" ]] && [[ -n "${bb}" ]]; then
   sed -i "s?${aa}?${bb}?g" "${X}/settings.ini"
  fi
done
}

function tongbu_2() {
  for X in $(find "DIY-SETUP" -name "settings.ini" |sed 's/\/settings.ini//g'); do rm -rf "${X}"/*.bak; done
  rm -rf ${GITHUB_WORKSPACE}/repogx/.github/workflows/*.bak
  
}

function tongbu_3() {
# 上游仓库用完，删除了
if [[ "${TONGBU_CANGKU}" == "1" ]]; then
  mv -f DIY-SETUP repogx/build
else
  rm -rf shangyou
fi
}


if [[ "${BENDI_SHANCHUBAK}" == "1" ]]; then
  tongbu_2
  tongbu_3
elif [[ "${BENDI_SHANCHUBAK}" == "2" ]]; then
  tongbu_1
  tongbu_3
elif [[ "${BENDI_SHANCHUBAK}" == "3" ]]; then
  tongbu_1
  tongbu_2
  tongbu_3
fi


