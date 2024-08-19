#!/bin/bash

# 获取脚本的基础名称，不包括.sh后缀。
name=`basename $0 .sh`

# 如果未设置ENABLE_DOWNLOAD环境变量，则默认设置为true。
ENABLE_DOWNLOAD=${ENABLE_DOWNLOAD:-true}

# 获取脚本的绝对路径的目录部分。
BASE_DIR="$( dirname "$( readlink -f "${0}" )" )"

# 如果files目录不存在，则创建该目录。
if [ ! -d /root/files ]; then
    mkdir -p /root/files
fi

# 设置下载文件的目录。
FILES_DIR=/root/files

# 下载文件函数
download() {
    url=$1 # 传递的第一个参数为下载的URL。
    dir=$2 # 传递的第二个参数为存放文件的目录。

    # 获取下载文件的名称。
    filename=$(basename $1)
    
    # 创建指定的目录。
    mkdir -p ${FILES_DIR}/$dir

    # 如果文件不存在，则下载文件。
    if [ ! -e ${FILES_DIR}/$dir/$filename ]; then
        echo "==> download $url"
        # 直接在 curl 中指定输出文件路径，避免使用 cd 命令。
        curl -L -o ${FILES_DIR}/$dir/$filename $url
        # 检查下载是否成功
        if [ $? -eq 0 ]; then
            echo "Successfully downloaded ${filename}"
        else
            echo "Failed to download ${filename}"
        fi
    else
        echo "${filename} already exists, skipping download."
    fi
}

# 下载所有需要的文件
download_files() {
    # 如果ENABLE_DOWNLOAD为true，则执行下载操作。
    if $ENABLE_DOWNLOAD; then
        # 设置各种组件的版本。
        RUNC_VERSION=1.1.10
        CONTAINERD_VERSION=1.7.11
        NERDCTL_VERSION=1.7.1
        CRICTL_VERSION=1.31.0
        CNI_VERSION=1.3.0
        DASHBOARD_VERSION=3.0.0-alpha0
        METRICS_VERSION=0.7.0
        HELM_VERSION=3.14.2
        ETCD_VERSION=3.5.10
        KUBERNETES_VERSION=1.30.1
        CFSSL_VERSION=1.6.4
        CALICO_VERSION=3.26.4
        DOCKER_VERSION=27.1.1
        CRI_DOCKER_VERSION=0.3.8
        CENTOS_KERNEL=4.19.12
        CONTAINERDIO_VERSION=1.2.6-3.3        
        HARBOR_VERSION=2.10.3
        DOCKER_COMPOSE=2.29.1
        # 下载各个组件的文件。
        download https://github.com/goharbor/harbor/releases/download/v${HARBOR_VERSION}/harbor-offline-installer-v${HARBOR_VERSION}.tgz harbor
        download https://github.com/docker/compose/releases/download/v{DOCKER_COMPOSE}/docker-compose-linux-x86_64 docker
        download https://download.docker.com/linux/centos/7/x86_64/edge/Packages/containerd.io-${CONTAINERDIO_VERSION}.el7.x86_64.rpm docker
        download https://raw.githubusercontent.com/projectcalico/calico/v${CALICO_VERSION}/manifests/tigera-operator.yaml calico
        download https://raw.githubusercontent.com/projectcalico/calico/v${CALICO_VERSION}/manifests/custom-resources.yaml calico
        download https://github.com/opencontainers/runc/releases/download/v${RUNC_VERSION}/runc.amd64 runc/v${RUNC_VERSION}
        download https://github.com/containerd/containerd/releases/download/v${CONTAINERD_VERSION}/containerd-${CONTAINERD_VERSION}-linux-amd64.tar.gz docker
        download https://github.com/containerd/nerdctl/releases/download/v${NERDCTL_VERSION}/nerdctl-${NERDCTL_VERSION}-linux-amd64.tar.gz docker
        download https://download.docker.com/linux/static/stable/x86_64/docker-${DOCKER_VERSION}.tgz docker  
        download https://github.com/kubernetes-sigs/cri-tools/releases/download/v${CRICTL_VERSION}/crictl-v${CRICTL_VERSION}-linux-amd64.tar.gz docker
        download https://mirrors.chenby.cn/https://github.com/Mirantis/cri-dockerd/releases/download/v${CRI_DOCKER_VERSION}/cri-dockerd-${CRI_DOCKER_VERSION}.amd64.tgz docker
        download https://github.com/containernetworking/plugins/releases/download/v${CNI_VERSION}/cni-plugins-linux-amd64-v${CNI_VERSION}.tgz kubernetes/cni
        download https://raw.githubusercontent.com/kubernetes/dashboard/v${DASHBOARD_VERSION}/charts/kubernetes-dashboard.yaml kubernetes/dashboard
        download https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/baremetal/deploy.yaml kubernetes/ingress-nginx
        download https://raw.githubusercontent.com/coredns/deployment/master/kubernetes/coredns.yaml.sed coredns
        download https://github.com/kubernetes-sigs/metrics-server/releases/download/v${METRICS_VERSION}/components.yaml kubernetes/metrics-server
        download https://get.helm.sh/helm-v${HELM_VERSION}-linux-amd64.tar.gz kubernetes/helm
        download https://github.com/etcd-io/etcd/releases/download/v${ETCD_VERSION}/etcd-v${ETCD_VERSION}-linux-amd64.tar.gz kubernetes/etcd
        download https://dl.k8s.io/v${KUBERNETES_VERSION}/kubernetes-server-linux-amd64.tar.gz kubernetes
        download https://github.com/cloudflare/cfssl/releases/download/v${CFSSL_VERSION}/cfssl_${CFSSL_VERSION}_linux_amd64 cfssl
        download https://github.com/cloudflare/cfssl/releases/download/v${CFSSL_VERSION}/cfssljson_${CFSSL_VERSION}_linux_amd64 cfssl
        download https://github.com/cloudflare/cfssl/releases/download/v${CFSSL_VERSION}/cfssl-certinfo_${CFSSL_VERSION}_linux_amd64 cfssl
        download https://github.com/projectcalico/calico/releases/download/v${CALICO_VERSION}/calicoctl-linux-amd64 calico
        download https://github.com/projectcalico/calico/archive/v${CALICO_VERSION}.tar.gz calico
        download http://193.49.22.109/elrepo/kernel/el7/x86_64/RPMS/kernel-ml-devel-${CENTOS_KERNEL}-1.el7.elrepo.x86_64.rpm  kernel
        download http://193.49.22.109/elrepo/kernel/el7/x86_64/RPMS/kernel-ml-${CENTOS_KERNEL}-1.el7.elrepo.x86_64.rpm kernel 
   fi 
}

# 只执行下载操作
download_files

