#!/bin/bash
YELLOW='\033[1;33m'  # 黄色
BOLD='\033[1m'       # 加粗
GREEN='\033[0;32m'   # 绿色
RED='\033[0;31m'     # 红色
BLUE='\033[1;34m'    # 蓝色且加粗
RESET='\033[0m'      # 重置样式

echo -e "${BOLD}${YELLOW}请保持网络畅通${RESET}"
ping -c3 -W1 -w1 -i0.3 www.github.com >/dev/null 2>&1

if [ $? -ne 0 ]; then
    echo -e "${RED}请检查网络${RESET}"
    exit 1
fi
        echo -e "${BOLD}${GREEN}安装必要的软件${RESET}"
        rpm -Uvh --force --nodeps /root/files/localinstall/yuminstall/*.rpm
echo -e "${BOLD}${YELLOW}接下来开始安装Docker和Ansible{1 开始安装|2 退出安装}, 请选择序号或字符方式${RESET}"
read select
select=$(echo $select | tr -d ' ')  # 去除空格

if [[ -z "$select" ]]; then
    echo -e "${BOLD}${RED}输入不能为空, 请重新输入${RESET}"
    exit 1
fi

if [ "$select" -eq 1 ] || [ "$select" = "开始安装" ]; then
    if [ -f /usr/bin/wget ]; then
        echo -e "${BOLD}${GREEN}下载Centos7.9 Repo${RESET}"
        curl -o /etc/yum.repos.d/CentOS-Base.repo https://mirrors.aliyun.com/repo/Centos-7.repo
        yum-config-manager --add-repo https://mirrors.aliyun.com/docker-ce/linux/centos/docker-ce.repo
        sed -i 's+download.docker.com+mirrors.aliyun.com/docker-ce+' /etc/yum.repos.d/docker-ce.repo
        echo -e "${BOLD}${GREEN}更新本地Repo数据库${RESET}"
        sed -i -e '/mirrors.cloud.aliyuncs.com/d' -e '/mirrors.aliyuncs.com/d' /etc/yum.repos.d/CentOS-Base.repo
        yum clean all && yum makecache
        echo -e "${BOLD}${GREEN}开始本地安装Docker${RESET}"
    else
        echo -e "${RED}wget 未安装，请先安装 wget${RESET}"
        exit 1
    fi

    echo -e "${BOLD}${GREEN}开始安装Docker${RESET}"
    rpm -Uvh --force --nodeps /root/files/localinstall/yumdocker/*.rpm
    version=$(docker version | grep Version | awk '{print $NF; exit}')
    echo -e "${BOLD}${BLUE}Docker当前版本是 $version ${RESET}"
    mkdir -p /etc/docker
    cat > /etc/docker/daemon.json <<EOF
{
  "registry-mirrors": [
    "https://docker.anyhub.us.kg",
    "https://dockerhub.icu",
    "https://docker.awsl9527.cn"
  ],
  "max-concurrent-downloads": 10,
  "log-driver": "json-file",
  "log-level": "warn",
  "log-opts": {
    "max-size": "10m",
    "max-file": "3"
  },
  "data-root": "/var/lib/docker"
}
EOF
    echo "启动Docker"
    systemctl enable docker && systemctl start docker

    echo "Docker安装完毕"
    echo -e "${BOLD}${GREEN}开始安装Ansible${RESET}"
    rpm -Uvh --force --nodeps /root/files/localinstall/yumansible/*.rpm
    mkdir /etc/ansible
    rm -rf /etc/ansible/ansible.cfg
    cat >> /etc/ansible/ansible.cfg <<EOF
    [defaults]
inventory = /root/ansible/inventory.ini
remote_user = root
ask_pass = false
host_key_checking = false
[privilege_escalation]
become = true
become_method = sudo
become_user = root
become_ask_pass = false
[paramiko_connection]
record_host_keys = false
[ssh_connection]
ssh_args = -o ControlMaster=auto -o ControlPersist=60s
control_path = %(directory)s/%%h-%%r
[persistent_connection]
command_timeout = 30
[colors]
highlight = white
verbose = blue
[diff]
always = true
context = 3
[inventory]
#enable_plugins = vmware_vm_inventory
EOF

    version=$(ansible --version | grep 2.9.27 | awk '{print $NF; exit}')
    echo -e "${BOLD}${BLUE}Ansible当前版本是 $version ${RESET}"
    echo "Docker和Ansible安装完毕"

else
    echo -e "${RED}退出安装${RESET}"
    exit 0
fi

echo -e "${BOLD}${YELLOW}接下来设置IP和计算机名{1 需要设置|2 不需要}, 请选择序号或字符方式${RESET}"
read select
select=$(echo $select | tr -d ' ')  # 去除空格

if [[ -z "$select" ]]; then
    echo -e "${BOLD}${RED}输入不能为空, 请重新输入${RESET}"
    exit 1
fi

# 获取当前的IP地址、网关等
IPADDRESS=$(ip a | grep dynamic | awk '{print $2}' | cut -d'/' -f1 | head -n 1)
HOSTNAME=$(hostname)
ETH=$(ip a | grep dynamic | awk -F "dynamic" '{print $2}' | xargs | awk '{print $1}' | head -n 1)
GATEWAY=$(ip route | grep default | awk '{print $3}')

if [ "$select" -eq 1 ] || [ "$select" = "需要设置" ]; then
    read -p "$(echo -e "${BOLD}${GREEN}当前IP是 $IPADDRESS ${RESET}, 请输入你想要修改的IP地址: ")" address
    echo "Address is: $address"  # 调试打印，确认地址输入
    sed -i "s/dhcp/static/g" /etc/sysconfig/network-scripts/ifcfg-$ETH
    sed -i "/^ONBOOT=yes/a IPADDR=$address" /etc/sysconfig/network-scripts/ifcfg-$ETH
    sed -i "/^IPADDR=/a NETMASK=255.255.255.0" /etc/sysconfig/network-scripts/ifcfg-$ETH
    sed -i "/^NETMASK=/a GATEWAY=$GATEWAY" /etc/sysconfig/network-scripts/ifcfg-$ETH
    sed -i "/^GATEWAY=/a DNS1=114.114.114.114" /etc/sysconfig/network-scripts/ifcfg-$ETH
    sed -i "/^DNS1=/a DNS2=8.8.8.8" /etc/sysconfig/network-scripts/ifcfg-$ETH
    awk '!seen[$0]++' /etc/sysconfig/network-scripts/ifcfg-$ETH > /etc/sysconfig/network-scripts/ifcfg-$ETH.tmp && mv /etc/sysconfig/network-scripts/ifcfg-$ETH.tmp /etc/sysconfig/network-scripts/ifcfg-$ETH  
    read -p "$(echo -e "${BOLD}${GREEN}当前主机名是 $HOSTNAME ${RESET}, 请输入你想要修改的主机名:")" hostname
    hostnamectl set-hostname $hostname
    echo "修改后的IP是 $address, 主机名是 $hostname"

    # 去重配置文件中的重复行
    CONFIG_FILE="/etc/sysconfig/network-scripts/ifcfg-$ETH"
    if [ -f "$CONFIG_FILE" ]; then
        TEMP_FILE=$(mktemp)
        awk '!seen[$0]++' "$CONFIG_FILE" > "$TEMP_FILE"
        mv "$TEMP_FILE" "$CONFIG_FILE"
    else
        echo -e "${RED}配置文件 $CONFIG_FILE 不存在${RESET}"
    fi

    echo -e "${BOLD}${YELLOW}设置完成。按 Enter 键重新启动系统，按其他键退出并不重新启动系统${RESET}"
    read -n 1 key
    if [ "$key" = "" ]; then
        echo "重新启动系统..."
        reboot
    else
        echo "退出，不重新启动系统。"
        exit 0
    fi
fi

