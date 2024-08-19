相关脚本注意 
  如果你的环境是vmware workstation 请把chapter1.yml - name: Manage VMs in vCenter 到 - name: Disable Firewall && Selinux  （1-98）
  如果你的环境是vmware vcenter 不需要修改设置 可以跳过 1-2步骤
  
1 将ansible.tar 解压到/root/目录,所有目录保持路径保持不变,/root/ 目录下有这几个文件和文件夹 ansible  download.sh  files  install-docker-ansible.sh
  download.sh 是执行下载必要的软件,下载的软件会到/root/files文件夹中,各软件有自己的文件目录,如果有新的软件,各位可以自定义修改,下载不成功再次执行bash download.sh,
  脚本会自动下载未下载成功的软件,实在下载不了的请手动下载放到指定的文件,另外下载了新的软件版本,请注意修改ansible脚本中所对应软件版本号,避免执行错误。

2 接下来在/root/目录有个install-docker-ansible.sh脚本,执行方式 bash /root/install-docker-ansible.sh,
  脚本将自动帮你安装ansible执行环境，环境包括安装必要的软件(vim net-tools wget),另外脚本会安装docker和ansible,脚本会提醒你
  设置计算机名和ip地址,虚拟机尽量不要多网卡,会造成脚本判断网卡名错误。

3 执行ansible脚本时要注意在ansible文件中,原因我已经将相关的配置文件放在ansible文件夹中环境变量也在ansible文件中。
  执行过程中要注意软件版本,如果没有下载新的软件版本,就不需要修改ansible脚本。
  另外执行过程中要主机本机的网卡名和ansible中的所设置的网卡名是否相同,不相同程序会执行错误,譬如ansible脚本中ens33那你的网卡名是ens192那你就需要修改，
  如果需要修改请注意chapter1.yml Copy Network-Config To Dest 和Change IP Address if hostname matches and IP address is different
  ansible/chapter5keepalived.yml  replace keepalived.conf on master

4 整个执行过程中有2次重新动虚拟机
  chapter1.yml 修改计算机名和ip 执行到最后重新过程中报错不用担心,是程序失去ssh链接
  chapter3.yml 升级系统内核   执行到最后重新过程中报错不用担心,是程序失去ssh链接
  另外注意的是请不要一次性执行脚本,由于在笔记本或台式机上执行脚本需要考虑到机器硬盘和cpu内存等要素,机器差的建议间隔30秒执行。
  建议虚拟机最低配置 4C 4G 推荐配置8C 8G

5 相关计算机设置
  计算机不需要进行任何设置DHCP自动获得即可,单网卡,IP地址段可自定义,不过需要修改所有ansible脚本中的ip地址,特别注意的是
  chapter6.yml  chapter7.yml  chapter8.yml 里面的192.168.1.130是master节点的vip
  尽量保持是192.168.1.0网段这样不需要做任何修改.
  创建虚拟机的时候你可以根据你的要求创建可以是3master 1node 也可以是3master 2node以上
  你只需要修改inventory.ini中的设置,按照原由的格式修改,相关内容不建议修改类似于[new],如果你不知道ansible运行逻辑建议别修改,否则每个ansible配置文件都要改
  虚拟机dhcp获得的ip你需要将ip添加到inventory.ini中[old]下,[new]是你最终想要的虚拟机ip,账号密码自己自定义,但是要有权限不是root用户建议修改/etc/sudoers 用户相关设置
  另外也要将dhcp获得的ip放到/root/ansible/vars.yml中,凡是old_ip都是dhcp地址,new_ip是最终虚拟机的ip地址,new_hostname是最终设置的主机名。
  再次强调！！！虚拟机什么都不需要设置,只要查看dhcp地址即可,将dhcp地址添加到/root/ansible/inventory.ini和/root/ansible/vars.yml中
  

6 执行脚本如下

  bash /root/install-docker-ansible.sh  初始化ansible环境,重新启动后注意远程地址已经改变
  我修改的地址是192.168.1.20 计算机名是ansible  如果不和我的一样请修改相关配置,相关配置文件如下
  chapter1.yml  chapter2.yml  chapter3.yml  chapter4.yml  chapter5keepalived.yml  chapter6.yml  chapter7.yml  chapter8.yml  inventory.ini vars.yml
  
  远程到新的地址进入/root/ansible依此执行下面操作
  ansible-playbook -i inventory.ini chapter1.yml   修改ip地址 计算机名 添加hosts解析 请注意你的网卡名是否和系统设置的一样 系统会重新启动,请注意虚拟机启动状态
  
  ansible-playbook -i inventory.ini chapter2.yml   虚拟机之间免密登录 
  测试 ls .ssh/ 查看 known_hosts
  
  ansible-playbook -i inventory.ini chapter3.yml   k8s安装相关参数设置 升级系统内核  系统会重新启动,请注意虚拟机启动状态

  ansible-playbook -i inventory.ini chapter4.yml   安装docker cri-docker cri-docker.socket nerdctl 导入k8s的Calico Coredns镜像

  ansible-playbook -i inventory.ini chapter5keepalived.yml  安装Keepalived  Haproxy ETCD 请注意网卡名称是否和你的虚拟机网卡名称一样，
  测试vip
  http://192.168.1.130:33305/monitor 
  EtCD测试
  
  etcdctl member list -w table
  ETCDCTL_API=3 /usr/local/bin/etcdctl --write-out=table --cacert=/etc/etcd/ssl/ca.pem --cert=/etc/etcd/ssl/etcd.pem --key=/etc/etcd/ssl/etcd-key.pem --endpoints=https://192.168.1.131:2379,https://192.168.1.132:2379,https://192.168.1.133:2379 endpoint status
  ETCDCTL_API=3 /usr/local/bin/etcdctl --write-out=table --cacert=/etc/etcd/ssl/ca.pem --cert=/etc/etcd/ssl/etcd.pem --key=/etc/etcd/ssl/etcd-key.pem --endpoints=https://192.168.1.131:2379,https://192.168.1.132:2379,https://192.168.1.133:2379 endpoint health 
 
  ansible-playbook -i inventory.ini chapter6.yml 安装apiserver Kubectl 
  测试
  
  systemctl status kube-apiserver
  kubectl cluster-info
  kubectl get componentstatuses
  kubectl get all --all-namespaces

  ansible-playbook -i inventory.ini chapter7.yml  安装 Controller-Manager  Kube-Scheduler 
  测试
  
  systemctl status kube-scheduler
  systemctl status kube-controller-manager
  kubectl get componentstatuses

  ansible-playbook -i inventory.ini chapter8.yml  安装 Kubelet KUBE-PROXY      
  测试
  
  systemctl status kubelet 
  systemctl status kube-proxy
  
  登录master主机上执行以下内容
  
  kubectl get csr --no-headers | awk '{print $1}' | xargs -r kubectl certificate approve
  kubectl create -f /root/files/calico/tigera-operator.yaml
  kubectl create -f /root/files/calico/custom-resources.yaml
  kubectl apply -f /root/files/coredns/coredns.yaml 
  测试
  kubectl get nodes
  kubectl get pods -A
  
