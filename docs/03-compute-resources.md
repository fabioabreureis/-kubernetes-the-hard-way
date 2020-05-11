# Provisioning Compute Resources

Kubernetes requires a set of machines to host the Kubernetes control plane and the worker nodes where containers are ultimately run. In this lab you will provision the compute resources required for running a secure and highly available Kubernetes cluster.

## Networking

The Kubernetes supports two types for network model : 

- [networking model](https://kubernetes.io/docs/concepts/cluster-administration/networking/#kubernetes-model) assumes a flat network in which containers and nodes can communicate with each other

- [network policies](https://kubernetes.io/docs/concepts/services-networking/network-policies/) can limit how groups of containers are allowed to communicate with each other and external network endpoints.

> Setting up network policies is out of scope for this tutorial.


### Load Balancer

In order to have a proper Kubernetes high available environment, a Load balancer is required to distribute the API load. In this case we are going to create an specific instance to run a HAProxy loadbalancer service. First, create an instance to host the load balancer service. Below we are about to create a new instance with:


For automated steps use the ansible playbook: 

```
ansible-playbook -i kubecluster haproxy.yml 
```


The following steps shows how to install a load balancer service using HAProxy in the instance previously created.

Install and configure HAProxy:

```
# export DOMAIN="local.lab"
# yum install -y haproxy

# tee /etc/haproxy/haproxy.cfg << EOF
global
    log         127.0.0.1 local2
    chroot      /var/lib/haproxy
    pidfile     /var/run/haproxy.pid
    maxconn     4000
    user        haproxy
    group       haproxy
    daemon
    stats socket /var/lib/haproxy/stats

defaults
    log                     global
    option                  httplog
    option                  dontlognull
    option                  http-server-close
    option                  redispatch
    retries                 3
    timeout http-request    10s
    timeout queue           1m
    timeout connect         10s
    timeout client          1m
    timeout server          1m
    timeout http-keep-alive 10s
    timeout check           10s
    maxconn                 3000

listen stats :9000
    stats enable
    stats realm Haproxy\ Statistics
    stats uri /haproxy_stats
    stats auth admin:password
    stats refresh 30
    mode http

frontend  main *:6443
    default_backend mgmt6443
    option tcplog

backend mgmt6443
    balance source
    mode tcp
    # MASTERS 6443
    server master00.${DOMAIN} 192.168.111.72:6443 check
    server master01.${DOMAIN} 192.168.111.173:6443 check
    server master02.${DOMAIN} 192.168.111.230:6443 check
EOF
```

As the Kubernetes port is 6443, the selinux policy should be modified to allow
haproxy to listen on that particular port:

```
sudo semanage port --add --type http_port_t --proto tcp 6443
```

Verify everything is properly configured:

```
haproxy -c -V -f /etc/haproxy/haproxy.cfg
```

Start and enable the service

```
sudo systemctl enable haproxy --now
```


### Kubernetes Workers

I created three vms was deployed by ansible which will host the Kubernetes worker nodes:

> The Kubernetes cluster CIDR range is defined by the Controller Manager's `--cluster-cidr` flag. In this tutorial the cluster CIDR range will be set to `10.200.0.0/16`, which supports 254 subnets.

> Each worker instance requires a pod subnet allocation from the Kubernetes cluster CIDR range. The pod subnet allocation will be used to configure container networking in a later exercise. The `/home/centos/pod_cidr.txt` file contains the subnet assigned to each worker.


Next: [Provisioning a CA and Generating TLS Certificates](04-certificate-authority.md)
