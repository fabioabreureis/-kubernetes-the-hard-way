# Prerequisites

## Libvirt Platform

This tutorial leverages libvirt and KVM/QEMU to streamline provisioning of the compute infrastructure required to bootstrap a Kubernetes cluster from the ground up. First step is to find a server with enough resources to run a Kubernetes cluster on virtual machines. 

My KVM Hypervisor : 

```
Host: kvm 	
Cpus: Intel(R) Core(TM) i5-2500S CPU @ 2.70GHz	
Memory: 32 GB	
```

Hardware Requirements for Kubernetes as described by official document: 

https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/install-kubeadm/


In my lab I consider using this setup : 

|  VM Name      | Purpose    |   OS     | vCPUs | Memory | Disk  |
| ------------- | ---------- | ---------|-------|--------|-------|
| master1      | controller | CentOS 7 |   2   |  4 GB | 50 GB |
| master2      | controller | CentOS 7 |   2   |  4 GB | 50 GB |
| master3      | controller | CentOS 7 |   2   |  4 GB | 50 GB |
| worker1      | controller | CentOS 7 |   2   |  4 GB | 50 GB |
| worker2      | controller | CentOS 7 |   2   |  4 GB | 50 GB |
| worker3      | controller | CentOS 7 |   2   |  4 GB | 50 GB |
| loadbalancer  | balancer   | CentOS 7 |   2   |  1 GB  | 15 GB |
| domain        | dns        | CentOS 7 |   2   |  1 GB  | 15 GB |


For KVM install I used this steps bellow to configure my KVM : 

```
yum groupinstall "Virtualization Host"
```

Also I suggest to install the libvirtd client in the baremetal server itself in case we need to troubleshoot locally any issue that can arise.

```
yum install libvirt-client
```

Configure the network bridge 

Interface configuration for bridge0 using ens33 :
```
[root@kvm network-scripts]# cat  ifcfg-ens33
TYPE=Ethernet
DEVICE=ens33
ONBOOT=yes
BRIDGE=br0
HWADDR=00:0c:29:00:00:00
```

Bridge configuration: 

```
[root@kvm network-scripts]# cat ifcfg-bridge0
DEVICE=bridge0
TYPE=Bridge
BOOTPROTO=static
ONBOOT=yes
IPADDR=192.168.15.111
NETMASK=255.255.255.0
DELAY=0
GATEWAY=192.168.15.1
```

Enable the bridge0 interface 

```
ip link set dev bridge0 up 
```


Uncomment these options in  /etc/libvirt/libvirtd.conf  file: 

```
listen_tls = 0
listen_tcp = 1
```

Finally, start and enable the systemd service:

```
systemctl enable libvirtd --now

```

## Cluster Vms deploy

For this deployment I using ansible for vms deployment and the playbook project bellow to deploy my vms with cloud-init. 


In this lab I installing  ansible 2.7 ans cloud-utils package as requirement for my ansible kvm role.   

```
yum install centos-release-ansible-27.noarch -y
yum install ansible-2.7.17-1.el7.noarch -y
yum install cloud-utils -y 
```

Create ssh key and copy for kvm host_vars

```
ssh-keygen -t rsa -b 2048


... 

Generating public/private rsa key pair.
Enter file in which to save the key (/root/.ssh/id_rsa): 
Enter passphrase (empty for no passphrase): 
Enter same passphrase again: 
Your identification has been saved in /root/.ssh/id_rsa.
Your public key has been saved in /root/.ssh/id_rsa.pub.
The key fingerprint is:
SHA256:C4/azwZji9RNyQasdfgvs7P0HF4Jj/u0mgcco3A6jVs root@localhost
The key's randomart image is:
+---[RSA 2048]----+
|                 |
|             .o  |
|              ++.|
|        .... +=+.|
|     ..oS.*ooo==o|
|      *++=oE.+.oo|
|     =.=o*+   + .|
|    ..o.=.o   .+ |
|      . .+   oo  |
+----[SHA256]-----+
```

Once an SSH key has been created, the ssh-copy-id command can be used to install it as an authorized key on the server.

```
ssh-copy-id root@localhost
```


Clone repo 

```
cd /opt
git clone https://github.com/fabioabreureis/ansible-kvm-cloudinit-prosivion
cd ansible-kvm-cloudinit-prosivion
```

Configure ansible inventory 

```
vi inventory/hosts

[kvm]
localhost

```


Configure kvm vars in inventory/host_vars/localhost.yml

```
---
# Image url session:
cloudimg_url: https://cloud.centos.org/centos/7/images/CentOS-7-x86_64-GenericCloud-1809.qcow2

# DNS Session 
domain: local.lab
dnsconfig: ok 

# Kvm session
libvirt_dir: /var/lib/libvirt

# Vm session: 
osvariant: centos7.0
enableroot: yes
vm_public_key: "{{lookup('file','~/.ssh/id_rsa.pub')}}"
virtual_machines:
  - name: loadbalancer
    cpu: 1
    mem: 1024
    disk: 15G
    bridge: bridge0
    net:
      ip: 192.168.15.198
      mask: 255.255.255.0
      gateway: 192.168.15.1
      dns: 192.168.15.199
  - name: domain
    cpu: 1
    mem: 1024
    disk: 15G
    bridge: bridge0
    net:
      ip: 192.168.15.199
      mask: 255.255.255.0
      gateway: 192.168.15.1
      dns: 192.168.15.199
  - name: master1 
    cpu: 2
    mem: 5092
    disk: 50G
    bridge: bridge0
    net:
      ip: 192.168.15.150
      mask: 255.255.255.0
      gateway: 192.168.15.1
      dns: 192.168.15.199
  - name: master2
    cpu: 2
    mem: 5092
    disk: 50G
    bridge: bridge0
    net:
      ip: 192.168.15.151
      mask: 255.255.255.0
      gateway: 192.168.15.1
      dns: 192.168.15.199
  - name: master3
    cpu: 2
    mem: 5092
    disk: 50G
    bridge: bridge0
    net:
      ip: 192.168.15.152
      mask: 255.255.255.0
      gateway: 192.168.15.1
      dns: 192.168.15.199
  - name: worker1
    cpu: 2
    mem: 5092
    disk: 50G
    bridge: bridge0
    net:
      ip: 192.168.15.153
      mask: 255.255.255.0
      gateway: 192.168.15.1
      dns: 192.168.15.199
  - name: worker2
    cpu: 2
    mem: 5092
    disk: 50G
    bridge: bridge0
    net:
      ip: 192.168.15.154
      mask: 255.255.255.0
      gateway: 192.168.15.1
      dns: 192.168.15.199
  - name: worker3
    cpu: 2
    mem: 5092
    disk: 50G
    bridge: bridge0
    net:
      ip: 192.168.15.155
      mask: 255.255.255.0
      gateway: 192.168.15.1
      dns: 192.168.15.199
```

Execute the site.yml playbook : 

```
ansible-playbook -i inventory/hosts site.yml 
``` 

Setup the dns.yml like this configuration bellow: 

```
- hosts: nameserver
  vars_files:
    - inventory/host_vars/localhost.yml
  roles:
    - role: ansible-bind
      when: dnsconfig is defined and dnsconfig == 'ok'
```

Deploy a Bind dns server with playbook execution :

```
ansible-playbook -i inventory/hosts dns.yml
``` 


After the  playbook execution you can validate with this command: 

```
[root@kvm ansible-kvm-cloudinit-prosivion]# virsh list --all 
 Id    Name                           State
----------------------------------------------------
 22    loadbalancer                   running
 23    domain                         running
 24    master1                        running
 25    master2                        running
 26    master3                        running
 27    worker1                        running
 28    worker2                        running
 29    worker3                        running
```

