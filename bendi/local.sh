#!/bin/bash

#====================================================
#	System Request:Ubuntu 18.04lts/20.04lts/22.04lts
#	Author:	shidahuilang
#	Dscription: Compile openwrt firmware
#	github: https://github.com/shidahuilang/openwrt
#====================================================

# 字体颜色配置
Green="\033[32m"
Red="\033[31m"
Yellow="\033[33m"
Blue="\033[36m"
Font="\033[0m"
GreenBG="\033[42;37m"
RedBG="\033[41;37m"
OK="${Green}[OK]${Font}"
ERROR="${Red}[ERROR]${Font}"

function print_ok() {
  echo -e " ${OK} ${Blue} $1 ${Font}"
  echo
}
function print_error() {
  echo
  echo -e "${ERROR} ${RedBG} $1 ${Font}"
  echo
}
function ECHOY() {
  echo
  echo -e "${Yellow} $1 ${Font}"
  echo
}
function ECHOG() {
  echo
  echo -e "${Green} $1 ${Font}"
  echo
}
function ECHOB() {
  echo
  echo -e "${Blue} $1 ${Font}"
  echo
}
  function ECHOR() {
  echo
  echo -e "${Red} $1 ${Font}"
  echo
}
function ECHOYY() {
  echo -e "${Yellow} $1 ${Font}"
}
function ECHOGG() {
  echo -e "${Green} $1 ${Font}"
}
  function ECHORR() {
  echo -e "${Red} $1 ${Font}"
}
judge() {
  if [[ 0 -eq $? ]]; then
    print_ok "$1 完成"
    echo
  else
    print_error "$1 失败"
    echo
    exit 1
  fi
}

# 变量
export BENDI_VERSION="2.0"
export GITHUB_WORKSPACE="$PWD"
export HOME_PATH="${GITHUB_WORKSPACE}/openwrt"
export GITHUB_ENV="${GITHUB_WORKSPACE}/GITHUB_ENV"
CURRENT_PATH="${GITHUB_WORKSPACE##*/}"
echo '#!/bin/bash' >${GITHUB_ENV}
sudo chmod +x ${GITHUB_ENV}
if [[ ! "$USER" == "openwrt" ]] && [[ "${CURRENT_PATH}" == "openwrt" ]]; then
  print_error "已在openwrt文件夹内,请在勿在此路径使用一键命令"
  exit 1
fi
if [[ ! -f "/etc/oprelyon" ]]; then
  source /etc/os-release
  case "${UBUNTU_CODENAME}" in
  "bionic"|"focal"|"jammy")
    # Nothing to do
  ;;
  *)
    print_error "请使用Ubuntu 64位系统，推荐 Ubuntu 20.04 LTS 或 Ubuntu 22.04 LTS"
    exit 1
  ;;
  esac
  if [[ "$USER" == "root" ]]; then
  print_error "警告：请勿使用root用户编译，换一个普通用户吧~~"
  exit 1
fi
Google_Check=$(curl -I -s --connect-timeout 8 google.com -w %{http_code} | tail -n1)
if [ ! "${Google_Check}" == 301 ]; then
  print_error "提醒：编译之前请自备梯子，编译全程都需要稳定翻墙的梯子~~"
  exit 1
fi
  if [[ `sudo grep -c "sudo ALL=(ALL:ALL) NOPASSWD:ALL" /etc/sudoers` -eq '0' ]]; then
    sudo sed -i 's?%sudo.*?%sudo ALL=(ALL:ALL) NOPASSWD:ALL?g' /etc/sudoers
  fi
fi


function Bendi_WslPath() {
if [[ `echo "${PATH}" |grep -c "Windows"` -ge '1' ]]; then
  if [[ ! "${WSL_ROUTEPATH}" == 'true' ]] && [[ ! "${MAKE_CONFIGURATION}" == "true" ]]; then
    clear
    echo
    echo
    ECHOR "您的ubuntu为Windows子系统,是否一次性解决路径问题,还是使用临时路径编译?"
    read -t 30 -p " [输入[Y/y]回车结束编译,按说明解决路径问题,任意键使用临时解决方式](不作处理,30秒后继续编译)： " Bendi_Wsl
    case ${Bendi_Wsl} in
    [Yy])
      ECHOYY "请到 https://github.com/shidahuilang/YJBY-openwrt 查看说明"
      exit 0
    ;;
    *)
      ECHOYY "正在使用临时路径解决编译问题！"
    ;;
    esac
  fi
fi
}

function BENDI_Diskcapacity() {
if [[ -d "${GITHUB_WORKSPACE}/DIY-SETUP" ]]; then
  source "DIY-SETUP/${FOLDER_NAME}/settings.ini"
fi

Cipan_Size="$(df -hT $PWD|awk 'NR==2'|awk '{print $(3)}')"
Cipan_Used="$(df -hT $PWD|awk 'NR==2'|awk '{print $(4)}')"
Cipan_Avail="$(df -hT $PWD|awk 'NR==2'|awk '{print $(5)}' |cut -d 'G' -f1)"
ECHOY "磁盘总量为[${Cipan_Size}]，已用[${Cipan_Used}]，可用[${Cipan_Avail}G]"
if [[ "${Cipan_Avail}" -lt "20" ]];then
  print_error "敬告：可用空间小于[ 20G ]编译容易出错,建议可用空间大于20G,是否继续?"
  read -p " 直接回车退出编译，按[Y/y]回车则继续编译： " KJYN
  case ${KJYN} in
  [Yy]) 
    ECHOG  "可用空间太小严重影响编译,请满天神佛保佑您成功吧！"
  ;;
  *)
    ECHOY  "您已取消编译,请清理Ubuntu空间或增加硬盘容量..."
    exit 0
  ;;
  esac
fi
}

function Bendi_Dependent() {
ECHOG "下载common.sh运行文件"
cd ${GITHUB_WORKSPACE}
sudo rm -rf common.sh
wget -O common.sh https://raw.githubusercontent.com/shidahuilang/common/main/common.sh
if [[ $? -ne 0 ]]; then
  curl -fsSL https://raw.githubusercontent.com/shidahuilang/common/main/common.sh > common.sh
fi
if [[ `grep -c "TIME" common.sh` -ge '1' ]]; then
  sudo chmod +x common.sh
  if [[ ! -f "/etc/oprelyon" ]]; then
   clear
   echo
   ECHOY "首次使用本脚本，需要先安装依赖，10秒后开始安装依赖"
   ECHOYY "如果出现 YES OR NO 选择界面，直接按回车即可"
   sleep 10
   echo
   source common.sh && Diy_update
   if [[ -f /etc/ssh/sshd_config ]] && [[ `grep -c "ClientAliveInterval 30" /etc/ssh/sshd_config` -eq '0' ]]; then
      sudo sed -i '/ClientAliveInterval/d' /etc/ssh/sshd_config
      sudo sed -i '/ClientAliveCountMax/d' /etc/ssh/sshd_config
      sudo sh -c 'echo ClientAliveInterval 30 >> /etc/ssh/sshd_config'
      sudo sh -c 'echo ClientAliveCountMax 6 >> /etc/ssh/sshd_config'
      sudo service ssh restart
    fi
  fi
else
  print_error "common.sh下载失败，请检测网络后再用一键命令试试!"
  exit 1
fi
}

function Bendi_DiySetup() {
cd ${GITHUB_WORKSPACE}
export BENDI_SHANCHUBAK="1"
if [[ ! -f "DIY-SETUP/${FOLDER_NAME}/settings.ini" ]]; then
  ECHOG "下载DIY-SETUP自定义配置文件"
  bash <(curl -fsSL https://raw.githubusercontent.com/shidahuilang/common/main/bendi/tongbu.sh)
  judge "DIY-SETUP自定义配置文件下载"
  source "DIY-SETUP/${FOLDER_NAME}/settings.ini"
else
  source "DIY-SETUP/${FOLDER_NAME}/settings.ini"
fi
}

function Bendi_Tongbu() {
cd ${GITHUB_WORKSPACE}
echo "开始同步上游DIY-SETUP文件"
bash <(curl -fsSL https://raw.githubusercontent.com/shidahuilang/common/main/bendi/tongbu.sh)
if [[ $? -ne 0 ]]; then
  ECHOB "同步上游仓库失败，请检查网络"
else
  ECHOB "同步上游仓库完成，请至DIY-SETUP检查设置，设置好最新配置再进行编译"
fi
}

function Bendi_Version() {
  cd ${GITHUB_WORKSPACE}
  if [[ -d "DIY-SETUP" ]]; then
    A="$(grep "BENDI_VERSION=" "DIY-SETUP/${FOLDER_NAME}/version/bendi_version" |grep -Eo "[0-9]+\.[0-9]+")"
    [[ -z ${A} ]] && A="0.9"
    B="${BENDI_VERSION}"
    if [[ `awk -v num1=${A} -v num2=${B} 'BEGIN{print(num1<num2)?"0":"1"}'` -eq '0' ]]; then
      ECHOY "上游DIY-SETUP文件有更新，是否同步更新DIY-SETUP文件?"
      read -p " 按[Y/y]回车同步文件，任意键回车则跳过更新： " TB
      case ${TB} in
      [Yy]) 
        ECHOG "正在同步DIY-SETUP文件，请稍后..."
        Bendi_Tongbu
      ;;
      *)
        ECHOR "您已跳过更新DIY-SETUP文件"
    ;;
    esac
    fi
  fi
}

function Bendi_EveryInquiry() {
if [[ "${MODIFY_CONFIGURATION}" == "true" ]]; then
  clear
  echo
  echo
  ECHOYY "请在 DIY-SETUP/${FOLDER_NAME} 里面设置好自定义文件"
  ECHOY "设置完毕后，按[W/w]回车继续编译"
  ZDYSZ="请输入您的选择"
  while :; do
  read -p " ${ZDYSZ}： " ZDYSZU
  case $ZDYSZU in
  [Ww])
    echo
  break
  ;;
  *)
    ZDYSZ="提醒：确认设置完毕后，请按[W/w]回车继续编译"
  ;;
  esac
  done
fi

clear
echo
echo
if [[ "${MAKE_CONFIGURATION}" == "true" ]]; then
  Menuconfig_Config="true"
  ECHOG "请耐心等待程序运行至窗口弹出进行机型和插件配置!"
else
  ECHOGG "是否需要选择机型和增删插件?"
  read -t 30 -p " [输入[ Y/y ]回车确认，任意键则为否](不作处理,30秒自动跳过)： " Bendi_Diy
  case ${Bendi_Diy} in
  [Yy])
    Menuconfig_Config="true"
    ECHOY "您执行机型和增删插件命令,请耐心等待程序运行至窗口弹出进行机型和插件配置!"
  ;;
  *)
    Menuconfig_Config="false"
    ECHOR "您已关闭选择机型和增删插件设置！"
  ;;
  esac
fi
}

function Bendi_Variable() {
cd ${GITHUB_WORKSPACE}
source common.sh && Diy_variable
judge "变量读取"
source ${GITHUB_ENV}
}

function Bendi_MainProgram() {
ECHOGG "下载扩展文件"
cd ${GITHUB_WORKSPACE}
source "DIY-SETUP/${FOLDER_NAME}/settings.ini"
echo "WSL_ROUTEPATH=${WSL_ROUTEPATH}" >> ${GITHUB_ENV}
source ${GITHUB_ENV}
sudo rm -rf build && cp -Rf DIY-SETUP build
git clone -b main --depth 1 https://github.com/shidahuilang/common build/common
judge "扩展文件下载"
cp -Rf build/common/common.sh build/${FOLDER_NAME}/common.sh
cp -Rf build/common/upgrade.sh build/${FOLDER_NAME}/upgrade.sh
cp -Rf ${GITHUB_WORKSPACE}/build/common/*.sh build/${FOLDER_NAME}/
sudo chmod -R +x build

ECHOGG "检测是否缺少文件"
source common.sh && Diy_settings
[[ -f "${DEFAULT_PATH}" ]] && source common.sh && Diy_wenjian
echo
}

function Bendi_Download() {
ECHOGG "下载${SOURCE_CODE}-${LUCI_EDITION}源码"
cd ${GITHUB_WORKSPACE}
sudo rm -rf ${HOME_PATH}
git clone -b "${REPO_BRANCH}" --single-branch "${REPO_URL}" ${HOME_PATH}
judge "源码下载"
if [[ -d "${GITHUB_WORKSPACE}/build" ]]; then
  cd ${HOME_PATH}
  source ${GITHUB_WORKSPACE}/build/${FOLDER_NAME}/common.sh && Diy_checkout
  mv -f ${GITHUB_WORKSPACE}/build ${HOME_PATH}/build
else
  cd ${HOME_PATH}
  source ${GITHUB_WORKSPACE}/common.sh && Diy_checkout
fi
}

function Bendi_Restore() {
rm -rf ${HOME_PATH}/build
mv -f ${GITHUB_WORKSPACE}/build ${HOME_PATH}/build
if [[ ! -f "${BUILD_PATH}/common.sh" ]]; then
  cp -Rf ${HOME_PATH}/build/common/common.sh ${BUILD_PATH}/common.sh
  cp -Rf ${HOME_PATH}/build/commonupgrade.sh ${BUILD_PATH}/upgrade.sh
  cp -rf ${HOME_PATH}/build/common/*.sh ${BUILD_PATH}/
else
  source ${BUILD_PATH}/common.sh && Diy_distrib
fi
# sed -i '/-rl/d' "${BUILD_PATH}/${DIY_PART_SH}"
}

function Bendi_SourceClean() {
ECHOGG "源码微调"
cd ${HOME_PATH}
source ${GITHUB_ENV}
source ${BUILD_PATH}/common.sh && Diy_menu3
judge "源码微调"
echo
}

function Bendi_UpdateSource() {
ECHOGG "读取自定义文件"
cd ${HOME_PATH}
source ${BUILD_PATH}/$DIY_PART_SH
source ${BUILD_PATH}/common.sh && Diy_Publicarea
judge "读取自定义文件"
ECHOGG "加载files,语言,更新源"
source ${BUILD_PATH}/common.sh && Diy_menu4
judge "加载files,语言,更新源"
}

function Bendi_Menuconfig() {
cd ${HOME_PATH}
if [[ "${Menuconfig_Config}" == "true" ]]; then
  ECHOGG "配置机型，插件等..."
  make menuconfig
  if [[ $? -ne 0 ]]; then
    ECHOY "SSH工具窗口分辨率太小，无法弹出设置机型或插件的窗口"
    ECHOG "请调整SSH工具窗口分辨率后按[Y/y]继续,或者按[N/n]退出编译"
    XUANMA="请输入您的选择"
    while :; do
    read -p " ${XUANMA}：" Bendi_Menu
    case ${Bendi_Menu} in
    [Yy])
      Bendi_Menuconfig
    break
    ;;
    [Nn])
      exit 1
    break
    ;;
    *)
      XUANMA="输入错误,请输入[Y/n]"
    ;;
    esac
    done
  fi
fi
}

function Make_Menuconfig() {
if [[ "${MAKE_CONFIGURATION}" == "true" ]]; then
  make defconfig
  if [[ ! -d "${GITHUB_WORKSPACE}/config" ]]; then
    mkdir -p ${GITHUB_WORKSPACE}/config
  else
    rm -rf ${GITHUB_WORKSPACE}/config/*
  fi
  source ${BUILD_PATH}/common.sh && Make_defconfig
  source ${GITHUB_ENV}
  difffonfig="${FOLDER_NAME}-${LUCI_EDITION}-${TARGET_PROFILE}.config.txt"
  ./scripts/diffconfig.sh > ${GITHUB_WORKSPACE}/config/${difffonfig}
  echo "
  SUCCESS_FAILED="makeconfig"
  FOLDER_NAME2="${FOLDER_NAME}"
  REPO_BRANCH2="${REPO_BRANCH}"
  LUCI_EDITION2="${LUCI_EDITION}"
  TARGET_PROFILE2="${TARGET_PROFILE}"
  " > ${HOME_PATH}/key-buildzu
  sed -i 's/^[ ]*//g' ${HOME_PATH}/key-buildzu
  sudo chmod +x ${HOME_PATH}/key-buildzu
  ECHOG "配置已经存入${GITHUB_WORKSPACE}/config文件夹中"
  exit 0
fi
}

function Bendi_Configuration() {
ECHOGG "检查配置,生成配置"
cd ${HOME_PATH}
source ${GITHUB_ENV}
source ${BUILD_PATH}/common.sh && Diy_menu5
judge "检测配置,生成配置"
rm -rf ${GITHUB_WORKSPACE}/config
}

function Bendi_ErrorMessage() {
cd ${HOME_PATH}
source ${GITHUB_ENV}
if [[ -s "${HOME_PATH}/CHONGTU" ]]; then
  echo
  TIME b "		错误提示"
  echo
  sudo chmod +x ${HOME_PATH}/CHONGTU
  source ${HOME_PATH}/CHONGTU
  echo
  read -t 30 -p " [如需重新编译请输入[ Y/y ]按回车，任意键则为继续编译](不作处理话,30后秒继续编译)： " Bendi_Error
  case ${Bendi_Error} in
  [Yy])
     exit 1
  ;;
  *)
    ECHOG "继续编译中..."
  ;;
  esac
fi
rm -rf ${HOME_PATH}/CHONGTU
}

function Bendi_DownloadDLFile() {
ECHOGG "下载DL文件，请耐心等候..."
cd ${HOME_PATH}
make defconfig
[[ -d "${HOME_PATH}/build_logo" ]] && mkdir -p ${HOME_PATH}/build_logo
make -j8 download |tee ${HOME_PATH}/build_logo/build.log

echo "
SUCCESS_FAILED="xzdl"
FOLDER_NAME2="${FOLDER_NAME}"
REPO_BRANCH2="${REPO_BRANCH}"
LUCI_EDITION2="${LUCI_EDITION}"
TARGET_PROFILE2="${TARGET_PROFILE}"
" > ${HOME_PATH}/key-buildzu
sed -i 's/^[ ]*//g' ${HOME_PATH}/key-buildzu
sudo chmod +x ${HOME_PATH}/key-buildzu

if [[ `grep -c "make with -j1 V=s or V=sc" ${HOME_PATH}/build_logo/build.log` -eq '0' ]] || [[ `grep -c "ERROR" ${HOME_PATH}/build_logo/build.log` -eq '0' ]]; then
  print_ok "DL文件下载成功"
else
  clear
  echo
  print_error "下载DL失败，更换节点后再尝试下载？"
  QLMEUN="请更换节点后按[Y/y]回车继续尝试下载DL，或输入[N/n]回车,退出编译"
  while :; do
    read -p " [${QLMEUN}]： " Bendi_DownloadDL
    case ${Bendi_DownloadDL} in
  [Yy])
    Bendi_DownloadDLFile
  break
  ;;
  [Nn])
    ECHOR "退出编译程序!"
    sleep 1
    exit 1
  break
  ;;
  *)
    QLMEUN="请更换节点后按[Y/y]回车继续尝试下载DL，或现在输入[N/n]回车,退出编译"
  ;;
  esac
  done
fi
}

function Bendi_Compile() {
cd ${HOME_PATH}
source ${GITHUB_ENV}
START_TIME=`date +'%Y-%m-%d %H:%M:%S'`
Model_Name="$(cat /proc/cpuinfo |grep 'model name' |awk 'END {print}' |cut -f2 -d: |sed 's/^[ ]*//g')"
Cpu_Cores="$(cat /proc/cpuinfo | grep 'cpu cores' |awk 'END {print}' | cut -f2 -d: | sed 's/^[ ]*//g')"
RAM_total="$(free -h |awk 'NR==2' |awk '{print $(2)}' |sed 's/.$//')"
RAM_available="$(free -h |awk 'NR==2' |awk '{print $(7)}' |sed 's/.$//')"

echo
ECHOG "您的机器CPU型号为[ ${Model_Name} ]"
ECHOGG "在此ubuntu分配核心数为[ ${Cpu_Cores} ],线程数为[ $(nproc) ]"
ECHOG "在此ubuntu分配内存为[ ${RAM_total} ],现剩余内存为[ ${RAM_available} ]"
echo

[[ -f "${GITHUB_WORKSPACE}/common.sh" ]] && rm -rf ${GITHUB_WORKSPACE}/common.sh
[[ -d "${FIRMWARE_PATH}" ]] && sudo rm -rf ${FIRMWARE_PATH}
if [[ "$(nproc)" -le "12" ]];then
  ECHOY "即将使用$(nproc)线程进行编译固件"
  sleep 8
  if [[ `echo "${PATH}" |grep -c "Windows"` -ge '1' ]]; then
    ECHOG "WSL临时路径编译中"
    PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin make V=s -j$(nproc) |tee ${HOME_PATH}/build_logo/build.log
  else
     make V=s -j$(nproc) |tee ${HOME_PATH}/build_logo/build.log
  fi
else
  ECHOGG "您的CPU线程超过或等于16线程，强制使用16线程进行编译固件"
  sleep 8
  if [[ `echo "${PATH}" |grep -c "Windows"` -ge '1' ]]; then
    ECHO "WSL临时路径编译中"
    PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin make V=s -j16 |tee ${HOME_PATH}/build_logo/build.log
  else
     make V=s -16 |tee ${HOME_PATH}/build_logo/build.log
  fi
fi

if [[ -f "${FIRMWARE_PATH}" ]] && [[ `ls -1 "${FIRMWARE_PATH}" | grep -c "immortalwrt"` -ge '1' ]]; then
  rename -v "s/^immortalwrt/openwrt/" ${FIRMWARE_PATH}/*
fi

sleep 3
if [[ `ls -1 "${FIRMWARE_PATH}" |grep -c "${TARGET_BOARD}"` -eq '0' ]]; then
  print_error "编译失败~~!"
  ECHOY "在 openwrt/build_logo/build.log 可查看编译日志,日志文件比较大,拖动到电脑查看比较方便"
  echo "
  SUCCESS_FAILED="fail"
  FOLDER_NAME2="${FOLDER_NAME}"
  REPO_BRANCH2="${REPO_BRANCH}"
  LUCI_EDITION2="${LUCI_EDITION}"
  TARGET_PROFILE2="${TARGET_PROFILE}"
  " > ${HOME_PATH}/key-buildzu
  sed -i 's/^[ ]*//g' ${HOME_PATH}/key-buildzu
  sudo chmod +x ${HOME_PATH}/key-buildzu
  exit 1
else
  cp -Rf ${FIRMWARE_PATH}/config.buildinfo ${GITHUB_WORKSPACE}/DIY-SETUP/${FOLDER_NAME}/${CONFIG_FILE}
  echo "
  SUCCESS_FAILED="success"
  FOLDER_NAME2="${FOLDER_NAME}"
  REPO_BRANCH2="${REPO_BRANCH}"
  LUCI_EDITION2="${LUCI_EDITION}"
  TARGET_PROFILE2="${TARGET_PROFILE}"
  " > ${HOME_PATH}/key-buildzu
  sed -i 's/^[ ]*//g' ${HOME_PATH}/key-buildzu
  sudo chmod +x ${HOME_PATH}/key-buildzu
fi
}


function Bendi_PackageAmlogic() {
if [[ ${PACKAGING_FIRMWARE} == "true" ]]; then
  source ${BUILD_PATH}/common.sh && Package_amlogic
fi
}

function Bendi_Arrangement() {
ECHOGG "整理固件"
cd ${HOME_PATH}
source ${GITHUB_ENV}
source ${BUILD_PATH}/common.sh && Diy_firmware
judge "整理固件"
}

function Bendi_shouweigongzhong() {
if [[ "${SOURCE_CODE}" == "AMLOGIC" ]]; then
  print_ok "[ N1或晶晨系列盒子专用固件 ]顺利编译完成~~~"
else
  print_ok "[ ${FOLDER_NAME}-${LUCI_EDITION2}-${TARGET_PROFILE} ]顺利编译完成~~~"
fi
ECHOGG "已为您把配置文件替换到DIY-SETUP/${FOLDER_NAME}/${CONFIG_FILE}里"
ECHOY "编译日期：$(date +'%Y年%m月%d号')"
END_TIME=`date +'%Y-%m-%d %H:%M:%S'`
START_SECONDS=$(date --date="$START_TIME" +%s)
END_SECONDS=$(date --date="$END_TIME" +%s)
SECONDS=$((END_SECONDS-START_SECONDS))
HOUR=$(( $SECONDS/3600 ))
MIN=$(( ($SECONDS-${HOUR}*3600)/60 ))
SEC=$(( $SECONDS-${HOUR}*3600-${MIN}*60 ))
if [[ "${HOUR}" == "0" ]]; then
  ECHOGG "编译总计用时 ${MIN}分${SEC}秒"
else
  ECHOGG "编译总计用时 ${HOUR}时${MIN}分${SEC}秒"
fi
ECHOR "提示：再次输入编译命令可进行二次编译"
echo
}

function Bendi_Packaging() {
  cd ${GITHUB_WORKSPACE}
  export FIRMWARE_PATH="${HOME_PATH}/bin/targets/armvirt/64"
  [[ -d "amlogic" ]] && sudo rm -rf amlogic
  if [[ -d "amlogic" ]]; then
    ECHOR "已存在的amlogic文件夹无法删除，请重启系统再来尝试"
    exit 1
  fi
  
  if [[ ! -d "${FIRMWARE_PATH}" ]] || [[ `ls -1 "${FIRMWARE_PATH}" | grep -c "tar.gz"` -eq '0' ]]; then
    mkdir -p "${FIRMWARE_PATH}"
    clear
    ECHOR "没发现 openwrt/bin/targets/armvirt/64 文件夹里存在.tar.gz固件，已为你创建了文件夹"
    ECHORR "请用WinSCP工具将\"openwrt-armvirt-64-default-rootfs.tar.gz\"固件存入文件夹中"
    if [[ `echo "${PATH}" |grep -c "Windows"` -ge '1' ]]; then
      ECHOY "提醒：Windows的WSL系统的话，千万别直接打开文件夹来存放固件，很容易出错的，要用WinSCP工具或SSH工具自带的文件管理器"
    fi
    exit 1
  fi

  ECHOY "正在下载打包所需的程序,请耐心等候~~~"
  git clone --depth 1 https://github.com/ophub/amlogic-s9xxx-openwrt.git ${GITHUB_WORKSPACE}/amlogic
  judge "打包程序下载"
  rm -rf ${GITHUB_WORKSPACE}/amlogic/{router-config,*README*,LICENSE}
  [ ! -d amlogic/openwrt-armvirt ] && mkdir -p amlogic/openwrt-armvirt
  
  ECHOY "全部可打包机型：s922x s922x-n2 s922x-reva a311d s905x3 s905x2 s905x2-km3 s905l3a s912 s912-m8s s905d s905d-ki s905x s905w s905"
  ECHOGG "设置要打包固件的机型[ 直接回车则默认(N1) ]"
  read -p " 请输入您要设置的机型：" amlogic_model
  export amlogic_model=${amlogic_model:-"s905d"}
  ECHOYY "您设置的机型为：${amlogic_model}"
  echo
  ECHOGG "设置打包的内核版本[直接回车则默认 5.15.xx 和 5.10.xx]"
  ECHOY "内核说明：不给您设置定制版本内核的,自动检测您当前写的内核最高版本打包,"
  ECHOYY "比如您要5.15内核的话,您不需要考虑啥,直接写5.15.01就行了,其他版本内核也一样"
  echo
  read -p " 请输入您要设置的内核：" amlogic_kernel
  export amlogic_kernel=${amlogic_kernel:-"5.15.01_5.10.02"}
  if [[ "${amlogic_kernel}" == "5.15.01_5.10.02" ]]; then
    ECHOYY "您设置的内核版本为：5.15.xx 和 5.10.xx "
  else
    ECHOYY "您设置的内核版本为：${amlogic_kernel}"
  fi
  echo
  read -p " 自动打包最新内核：" auto_kernel
  export auto_kernel=${auto_kernel:-"false"}
  if [[ "${auto_kernel}" == "false" ]]; then
    ECHOYY "关闭自动打包最新内核"
  else
    ECHOYY "开启自动打包最新内核"
  fi
  echo
  ECHOGG "设置ROOTFS分区大小[ 直接回车则默认：960 ]"
  read -p " 请输入ROOTFS分区大小：" rootfs_size
  export rootfs_size=${rootfs_size:-"960"}
  ECHOYY "您设置的ROOTFS分区大小为：${rootfs_size}"
  if [[ `ls -1 "${FIRMWARE_PATH}" |grep -c ".*default-rootfs.tar.gz"` == '1' ]]; then
    cp -Rf ${FIRMWARE_PATH}/*default-rootfs.tar.gz ${GITHUB_WORKSPACE}/amlogic/openwrt-armvirt/openwrt-armvirt-64-default-rootfs.tar.gz
  else
    armvirtargz="$(ls -1 "${FIRMWARE_PATH}" |grep ".*tar.gz" |awk 'END {print}')"
    cp -Rf ${FIRMWARE_PATH}/${armvirtargz} ${GITHUB_WORKSPACE}/amlogic/openwrt-armvirt/openwrt-armvirt-64-default-rootfs.tar.gz
  fi
  if [[ `ls -1 "${GITHUB_WORKSPACE}/amlogic/openwrt-armvirt" | grep -c ".tar.gz"` -eq '0' ]]; then
    print_error "amlogic/openwrt-armvirt文件夹没发现openwrt-armvirt-64-default-rootfs.tar.gz固件存在"
    print_error "请检查openwrt/bin/targets/armvirt/64文件夹内有没有openwrt-armvirt-64-default-rootfs.tar.gz固件存在"
    exit 1
  fi
  cd ${GITHUB_WORKSPACE}/amlogic
  sudo chmod +x make
  sudo ./make -d -b ${amlogic_model} -k ${amlogic_kernel} -s ${rootfs_size}
  if [[ $? -eq 0 ]];then
    echo
    print_ok "打包完成，固件存放在[amlogic/out]文件夹"
  else
    print_error "打包失败，请查看当前错误说明!"
  fi
}

function Bendi_Change() {
cd ${HOME_PATH}
sed -i '/^#/d' feeds.conf.default
if [[ ! "${REPO_BRANCH2}" == "${REPO_BRANCH}" ]]; then
  ECHOR "编译分支发生改变,需要重新下载源码,下载源码中..."
  sleep 3
  Bendi_Download
elif [[ ! "${COLLECTED_PACKAGES}" == "true" ]]; then
  if [[ `grep -c "danshui" feeds.conf.default` -ge '1' ]]; then
    ECHOR "您的自定义设置更改为不需要作者收集的插件包,正在清理插件中..."
    sleep 3
    find . -name 'luci-app-openclash' | xargs -i rm -rf {}
    sed -i '/danshui/d' feeds.conf.default
    sed -i '/helloworld/d' feeds.conf.default
    sed -i '/passwall/d' feeds.conf.default
    ./scripts/feeds clean
    ./scripts/feeds update -a
  fi
elif [[ "${COLLECTED_PACKAGES}" == "true" ]]; then
  if [[ `grep -c "danshui" feeds.conf.default` -eq '0' ]]; then
    ECHOG "您的自定义设置更改为需要作者收集的插件包,正在增加插件中..."
    sleep 3
    sed -i '/danshui/d' feeds.conf.default
    sed -i '/helloworld/d' feeds.conf.default
    sed -i '/fw876/d' feeds.conf.default
    sed -i '/passwall/d' feeds.conf.default
    sed -i '/xiaorouji/d' feeds.conf.default
    ./scripts/feeds clean
    ./scripts/feeds update -a
    source ${GITHUB_WORKSPACE}/common.sh && Diy_${SOURCE_CODE}
    source ${GITHUB_WORKSPACE}/common.sh && Diy_chajianyuan
  fi
fi
}

function Bendi_gitpull() {
if [[ "${SOURCE_CODE}" == "OFFICIAL" ]] && [[ "${REPO_BRANCH}" =~ (openwrt-19.07|openwrt-21.02|openwrt-22.03) ]]; then
  echo
else
  ECHOG "同步上游源码"
  git pull
  if [[ $? -ne 0 ]]; then
    ECHOR "同步上游源码失败"
  else
    ECHOB "同步上游源码完成"
  fi
fi
}

function Bendi_xuanzhe() {
  cd ${GITHUB_WORKSPACE}
  if [[ ! -f "/etc/oprelyon" ]]; then
    Bendi_Dependent
  fi
  if [[ ! -d "DIY-SETUP" ]]; then
    ECHOG "没有主要编译程序存在,正在下载中,请稍后..."
    sleep 3
    Bendi_DiySetup
  else
    YY="$(ls -1 "DIY-SETUP" |awk 'NR==1')"
    if [[ ! -f "DIY-SETUP/${YY}/settings.ini" ]]; then
      ECHOG "没有主要编译程序存在,正在下载中,请稍后..."
      sleep 3
      Bendi_DiySetup
    fi
  fi
  clear
  echo 
  echo
  jixingliebiao="$(echo "0、刷新列表" |awk '{print "  " $0}')"
  ls -1 "DIY-SETUP" |awk '$0=NR" "$0' > GITHUB_ENN
  ls -1 "DIY-SETUP" > GITHUB_EVN
  XYZDSZ="$(cat GITHUB_ENN | awk 'END {print}' |awk '{print $(1)}')"
  rm -rf GITHUB_ENN
  echo "${jixingliebiao}"
  ls -1 "DIY-SETUP" |awk '$0=NR"、"$0'|awk '{print "  " $0}'
  echo
  echo
  echo -e "${Blue}  请输入您要编译源码前面对应的数值(1~X),输入[N]则为退出程序${Font}"
  echo
  echo -e "${Green}  您可以自行在DIY-SETUP内建立机型文件夹来进行编译使用(不懂的请查看云编译教程)${Font}"
  echo
  echo -e "${Red}  如果您在这个步骤自建了机型文件夹,请按[0]回车进行刷新机型列表${Font}"
  if [[ `echo "${PATH}" |grep -c "Windows"` -ge '1' ]]; then
    echo
    echo -e "${Yellow}  您使用的为WSL系统,若要自行建立文件夹${Font}"
    echo -e "${Yellow}  请勿直接打开Windows文件夹进行修改,这样修改出来的文件很经常是有问题的${Font}"
    echo -e "${Yellow}  请用WinSCP或者其他工具进行连接,然后建立机型文件夹${Font}"
  fi
  echo
  export YUMINGIP="  请输入数字(1~N)"
  while :; do
  YMXZ=""
  read -p "${YUMINGIP}：" YMXZ
  if [[ "${YMXZ}" == "0" ]]; then
    CUrrenty="0"
  elif [[ "${YMXZ}" == "N" ]] || [[ "${YMXZ}" == "n" ]]; then
    CUrrenty="N"
  elif [[ -z "${YMXZ}" ]]; then
    CUrrenty="x"
  elif [[ "${YMXZ}" -le "${XYZDSZ}" ]]; then
    CUrrenty="Y"
  else
    CUrrenty="x"
  fi
  case $CUrrenty in
  Y)
    export FOLDER_NAME3=$(cat GITHUB_EVN |awk ''NR==${YMXZ}'')
    export FOLDER_NAME="${FOLDER_NAME3}"
    ECHOY " 您选择了使用 ${FOLDER_NAME} 编译固件,3秒后将进行启动编译"
    rm -rf GITHUB_EVN
    sleep 2
    Bendi_menu
  break
  ;;
  N)
    rm -rf GITHUB_ENN
    echo
    exit 0
  break
  ;;
  0)
    Bendi_xuanzhe
    echo
  break
  ;;
  *)
    export YUMINGIP="  敬告,请输入正确数值"
  ;;
  esac
  done
}

function Bendi_menu2() {
BENDI_Diskcapacity
Bendi_Dependent
Bendi_Version
Bendi_WslPath
Bendi_DiySetup
Bendi_EveryInquiry
Bendi_Variable
Bendi_Version
Bendi_Change
Bendi_gitpull
Bendi_MainProgram
Bendi_Restore
Bendi_UpdateSource
Bendi_Menuconfig
Make_Menuconfig
Bendi_Configuration
Bendi_ErrorMessage
Bendi_DownloadDLFile
Bendi_Compile
Bendi_PackageAmlogic
Bendi_Arrangement
Bendi_shouweigongzhong
}

function Bendi_menu() {
BENDI_Diskcapacity
Bendi_Dependent
Bendi_Version
Bendi_WslPath
Bendi_DiySetup
Bendi_EveryInquiry
Bendi_Variable
Bendi_MainProgram
Bendi_Download
Bendi_SourceClean
Bendi_UpdateSource
Bendi_Menuconfig
Make_Menuconfig
Bendi_Configuration
Bendi_ErrorMessage
Bendi_DownloadDLFile
Bendi_Compile
Bendi_PackageAmlogic
Bendi_Arrangement
Bendi_shouweigongzhong
}

function Bendi_UPDIYSETUP() {
cd ${GITHUB_WORKSPACE}
clear
echo 
echo
echo -e "  ${Green}请选择更新方式${Font}"
echo
echo -e "  ${Blue}1${Font}、${Yellow}单文件更新,只更新您所有机型文件夹的diy-part.sh和settings.ini${Font}"
echo
echo -e "  ${Blue}2${Font}、${Yellow}删除您现有的DIY-SETUP文件夹,从上游重新拉取DIY-SETUP文件夹${Font}"
echo
echo -e "  ${Blue}3${Font}、${Yellow}返回上级菜单${Font}"
echo
echo -e "  ${Blue}4${Font}、${Yellow}退出退出程序${Font}"
echo
echo
IYSETUP="  请输入数字确定您的选择"
echo
while :; do
read -p "${IYSETUP}：" Bendi_upsetup
case ${Bendi_upsetup} in
1)
  [[ ! -f "/etc/oprelyon" ]] && Bendi_Dependent
  Bendi_Tongbu
break
;;
2)
  [[ ! -f "/etc/oprelyon" ]] && Bendi_Dependent
  [[ -d "DIY-SETUP" ]] && rm -rf DIY-SETUP
  Bendi_Tongbu
break
;;
3)
  ${BENDI_MEMU}
break
;;
4)
  exit 0
break
;;
*)
  IYSETUP="  输入错误,请输入数字"
;;
esac
done
}

function menu2() {
  clear
  echo
  echo
  if [[ "${SUCCESS_FAILED}" == "success" ]]; then
    echo -e " ${Blue}当前使用源码${Font}：${Yellow}${FOLDER_NAME2}-${LUCI_EDITION2}${Font}"
    echo -e " ${Blue}上回成功编译机型${Font}：${Yellow}${TARGET_PROFILE2}${Font}"
    echo -e " ${Blue}DIY-SETUP/${FOLDER_NAME2}配置文件机型${Font}：${Yellow}${TARGET_PROFILE3}${Font}"
    aaaa="保留缓存,再次编译?"
    bbbbb="编译"
  elif [[ "${SUCCESS_FAILED}" == "makeconfig" ]]; then  
    echo -e " ${Blue}当前使用源码${Font}：${Yellow}${FOLDER_NAME2}-${LUCI_EDITION2}${Font}"
    echo -e " ${Blue}上回制作了${Font}${Yellow}${TARGET_PROFILE2}机型的.config${Font}${Blue}配置文件${Font}"
    echo -e " ${Blue}DIY-SETUP/${FOLDER_NAME2}配置文件机型${Font}：${Yellow}${TARGET_PROFILE3}${Font}"
    aaaa="继续制作.config配置文件"
    bbbbb="制作.config配置文件?"
  elif [[ "${SUCCESS_FAILED}" == "xzdl" ]]; then
    echo -e " ${Blue}当前使用源码${Font}：${Yellow}${FOLDER_NAME2}-${LUCI_EDITION2}${Font}"
    echo -e " ${Red}大兄弟啊,上回下载完DL就没搞成了,继续[${TARGET_PROFILE2}]搞下去?${Font}"
    echo -e " ${Blue}DIY-SETUP/${FOLDER_NAME2}配置文件机型${Font}：${Yellow}${TARGET_PROFILE3}${Font}"
    aaaa="接着上次继续再搞下去?"
    bbbbb="编译"
  else
    echo -e " ${Blue}当前使用源码${Font}：${Yellow}${FOLDER_NAME2}-${LUCI_EDITION2}${Font}"
    echo -e " ${Red}大兄弟啊,上回编译${Yellow}[${TARGET_PROFILE2}]${Font}${Red}于失败告终了${Font}"
    echo -e " ${Blue}DIY-SETUP/${FOLDER_NAME2}配置文件机型${Font}：${Yellow}${TARGET_PROFILE3}${Font}"
    aaaa="保留缓存,再特么的搞一搞?"
    bbbbb="编译"
  fi
  echo
  echo
  echo -e " 1${Red}.${Font}${Green}${aaaa}${Font}"
  echo
  echo -e " 2${Red}.${Font}${Green}重新选择源码${bbbbb}${Font}"
  echo
  echo -e " 3${Red}.${Font}${Green}同步上游DIY-SETUP文件${Font}"
  echo
  echo -e " 4${Red}.${Font}${Green}打包N1或晶晨系列固件(您要有armvirt_64的.tar.gz固件)${Font}"
  echo
  echo -e " 5${Red}.${Font}${Green}退出${Font}"
  echo
  echo
  XUANZop="请输入数字"
  echo
  while :; do
  read -p " ${XUANZop}：" menu_num
  case $menu_num in
  1)
    Bendi_menu2
  break
  ;;
  2)
    Bendi_xuanzhe
  break
  ;;
  3)
    Bendi_UPDIYSETUP
  break
  ;;
  4)
    Bendi_Dependent
    Bendi_Packaging
  break
  ;;
  5)
    echo
    exit 0
  break
  ;;
  *)
    XUANZop="请输入正确的数字编号"
  ;;
  esac
  done
}

function menu() {
cd ${GITHUB_WORKSPACE}
clear
echo
echo
ECHOY " 1. 进行选择编译或制作配置文件源码"
ECHOY " 2. 同步上游DIY-SETUP文件"
ECHOY " 3. 打包N1或晶晨系列固件(您要有armvirt_64的.tar.gz固件)"
ECHOY " 4. 退出编译程序"
echo
XUANZHEOP="请输入数字"
echo
while :; do
read -p " ${XUANZHEOP}： " CHOOSE
case $CHOOSE in
1)
  Bendi_xuanzhe
break
;;
2)
  Bendi_UPDIYSETUP
break
;;
3)
  Bendi_Dependent
  Bendi_Packaging
break
;;
4)
  echo
  exit 0
break
;;
*)
   XUANZHEOP="请输入正确的数字编号"
;;
esac
done
}

function menuoo() {
cd ${GITHUB_WORKSPACE}
if [[ -d "${HOME_PATH}" ]]; then
cat > Update.txt <<EOF
config
include
package
scripts
target
toolchain
tools
EOF
ls -1 ${HOME_PATH} > UpdateList.txt
FOLDERS=`grep -Fxvf UpdateList.txt Update.txt`
FOLDERSX=`echo $FOLDERS | sed 's/ /、/g'`;echo $FOLDERSX
rm -rf {UpdateList.txt,Update.txt}
fi

if [[ -z "${FOLDERS}" ]]; then
  KAIDUAN_JIANCE="1"
else
  KAIDUAN_JIANCE="0"
fi
if [[ -f "${HOME_PATH}/key-buildzu" ]]; then
  KAIDUAN_JIANCE="1"
  source ${HOME_PATH}/key-buildzu
else
  KAIDUAN_JIANCE="0"
fi
if [[ -f "DIY-SETUP/${FOLDER_NAME2}/settings.ini" ]]; then
  KAIDUAN_JIANCE="1"
  source DIY-SETUP/${FOLDER_NAME2}/settings.ini
else
  KAIDUAN_JIANCE="0"
fi
if [[ "${KAIDUAN_JIANCE}" == "1" ]] && [[ -f "DIY-SETUP/${FOLDER_NAME2}/${CONFIG_FILE}" ]]; then
  if [[ `grep -c "CONFIG_TARGET_x86_64=y" "DIY-SETUP/${FOLDER_NAME2}/${CONFIG_FILE}"` -eq '1' ]]; then
    TARGET_PROFILE3="x86-64"
  elif [[ `grep -c "CONFIG_TARGET_x86=y" "DIY-SETUP/${FOLDER_NAME2}/${CONFIG_FILE}"` == '1' ]]; then
    TARGET_PROFILE3="x86-32"
  elif [[ `grep -c "CONFIG_TARGET_armvirt_64_Default=y" "DIY-SETUP/${FOLDER_NAME2}/${CONFIG_FILE}"` -eq '1' ]]; then
    TARGET_PROFILE3="Armvirt_64"
  else
    TARGET_PROFILE3="$(grep -Eo "CONFIG_TARGET.*DEVICE.*=y" "DIY-SETUP/${FOLDER_NAME2}/${CONFIG_FILE}" | sed -r 's/.*DEVICE_(.*)=y/\1/')"
  fi
  [[ -z "${TARGET_PROFILE3}" ]] && TARGET_PROFILE3="未知"
fi
if [[ "${KAIDUAN_JIANCE}" == "1" ]]; then
  FOLDER_NAME="${FOLDER_NAME2}"
  BENDI_MEMU="menu2"
  menu2
else
  FOLDER_NAME=""
  BENDI_MEMU="menu"
  menu
fi
}

menuoo "$@"
