#!/bin/bash
images_list='
goharbor/harbor-exporter:v2.11.0
goharbor/redis-photon:v2.11.0
goharbor/trivy-adapter-photon:v2.11.0
goharbor/harbor-registryctl:v2.11.0
goharbor/registry-photon:v2.11.0
goharbor/nginx-photon:v2.11.0
goharbor/harbor-log:v2.11.0
goharbor/harbor-jobservice:v2.11.0
goharbor/harbor-core:v2.11.0
goharbor/harbor-portal:v2.11.0
goharbor/harbor-db:v2.11.0
goharbor/prepare:v2.11.0
calico/typha:v3.26.4
calico/kube-controllers:v3.26.4
calico/apiserver:v3.26.4
calico/cni:v3.26.4
calico/node-driver-registrar:v3.26.4
calico/csi:v3.26.4
calico/pod2daemon-flexvol:v3.26.4
calico/node:v3.26.4
coredns/coredns:1.10.1
registry.aliyuncs.com/google_containers/pause:3.9'
for i in $images_list
do
      docker pull $i
done
make -p /root/files/images/
docker save -o /root/files/images/k8sall.tar $images_list
