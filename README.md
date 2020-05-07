# kubernetes-the-hard-way

## Differences with the original kubernetes-the-hard-way and others

> **Note:** This tutorial has been forked from [Kubernetes The Hard Way](https://github.com/kelseyhightower/kubernetes-the-hard-way) wrote by Kelsey Hightower and it is based also on [Kubernetes The Hard Way (Openstack Edition)](https://github.com/e-minguez/kubernetes-the-hard-way-openstack) by Eduardo Mínguez. Special thanks to both.

The main difference is that instead of running our cluster on top of an IaaS solution as Google Cloud or OpenStack, we aim to deploy a Kubernetes cluster on a baremetal server. We will leverage the virtualization capabilities that comes with GNU/Linux (libvirt/KVM/QEMU) to easily provide a similar *virtual infrastructure*. Note that in this case, we could use any spare baremetal server or laptop (with enough resources) running a GNU/Linux distribution.

Some other differences in this installation against the original one:

* CentOS 7/8 instead Ubuntu as the operating system of the instances.
* Dedicated instance for load balancing (with HAProxy).


## Target Audience

The target audience for this tutorial is someone planning to support a
production Kubernetes cluster and wants to understand how everything fits
together.

## Cluster Details

Kubernetes The Hard Way guides you through bootstrapping a highly available
Kubernetes cluster with end-to-end encryption between components and RBAC
authentication.

* [Kubernetes](https://github.com/kubernetes/kubernetes) 1.16.2
* [containerd Container Runtime](https://github.com/containerd/containerd) 1.3.0
* [coredns](https://github.com/coredns/coredns) v1.6.2
* [cni](https://github.com/containernetworking/cni) v0.7.3
* [etcd](https://github.com/coreos/etcd) v3.4.0

## Labs

This tutorial assumes you have access to an OpenStack environment. While OSP is
used for basic infrastructure requirements the lessons learned in this tutorial
can be applied to other platforms.

* [Prerequisites](docs/01-prerequisites.md)
* [Installing the Client Tools](docs/02-client-tools.md)
* [Provisioning Compute Resources](docs/03-compute-resources.md)
* [Provisioning the CA and Generating TLS Certificates](docs/04-certificate-authority.md)
* [Generating Kubernetes Configuration Files for Authentication](docs/05-kubernetes-configuration-files.md)
* [Generating the Data Encryption Config and Key](docs/06-data-encryption-keys.md)
* [Bootstrapping the etcd Cluster](docs/07-bootstrapping-etcd.md)
* [Bootstrapping the Kubernetes Control Plane](docs/08-bootstrapping-kubernetes-controllers.md)
* [Bootstrapping the Kubernetes Worker Nodes](docs/09-bootstrapping-kubernetes-workers.md)
* [Configuring kubectl for Remote Access](docs/10-configuring-kubectl.md)
* [Provisioning Pod Network Routes](docs/11-pod-network-routes.md)
* [Deploying the DNS Cluster Add-on](docs/12-dns-addon.md)
* [Smoke Test](docs/13-smoke-test.md)
* [Cleaning Up](docs/14-cleanup.md)
