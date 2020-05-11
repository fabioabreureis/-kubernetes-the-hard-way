#!/bin/bash

source ./bash_vars

if [ ! -f $CERTDIR ]; then
mkdir $CERTDIR
fi 


if [ ! -f $CERTDIR/ca-config.json ]; then

cd $CERTDIR && cat > ca-config.json <<EOF
{
  "signing": {
    "default": {
      "expiry": "8760h"
    },
    "profiles": {
      "kubernetes": {
        "usages": ["signing", "key encipherment", "server auth", "client auth"],
        "expiry": "8760h"
      }
    }
  }
}
EOF
fi 

if [ ! -f $CERTDIR/ca-csr.json ]; then
cd $CERTDIR && cat > ca-csr.json <<EOF
{
  "CN": "Kubernetes",
  "key": {
    "algo": "rsa",
    "size": 2048
  },
  "names": [
    {
      "C": "${C}",
      "L": "${L}",
      "O": "Kubernetes",
      "OU": "CA",
      "ST": "${ST}"
    }
  ]
}
EOF

cd $CERTDIR && cfssl gencert -initca $CERTDIR/ca-csr.json | cfssljson -bare ca ;
fi 



if [ ! -f $CERTDIR/admin-csr.json ]; then
cd $CERTDIR && cat > admin-csr.json <<EOF
{
  "CN": "admin",
  "key": {
    "algo": "rsa",
    "size": 2048
  },
  "names": [
    {
      "C": "${C}",
      "L": "${L}",
      "O": "system:masters",
      "OU": "Kubernetes The Hard Way",
      "ST": "${ST}"
    }
  ]
}
EOF

cd $CERTDIR && cfssl gencert  -ca=$CERTDIR/ca.pem  -ca-key=$CERTDIR/ca-key.pem \
  -config=$CERTDIR/ca-config.json -profile=kubernetes $CERTDIR/admin-csr.json | cfssljson -bare admin;
fi


for instance in $WORKER1 $WORKER2 $WORKER3; do
if [ ! -f $CERTDIR/${instance}-csr.json ]; then
cd  $CERTDIR && cat > ${instance}-csr.json <<EOF

{
  "CN": "system:node:${instance}.${DOMAIN}",
  "key": {
    "algo": "rsa",
    "size": 2048
  },
  "names": [
    {
      "C": "${C}",
      "L": "${L}",
      "O": "system:nodes",
      "OU": "Kubernetes The Hard Way",
      "ST": "${ST}"
    }
  ]
}
EOF

NODE_IP=$(ssh ${instance} hostname --ip-address)
cd $CERTDIR && cfssl gencert \
  -ca=$CERTDIR/ca.pem \
  -ca-key=$CERTDIR/ca-key.pem \
  -config=$CERTDIR/ca-config.json \
  -hostname=${instance}.${DOMAIN},${instance},${NODE_IP} \
  -profile=kubernetes $CERTDIR/${instance}-csr.json | cfssljson -bare ${instance}

fi
done


if [ ! -f $CERTDIR/kube-controller-manager-csr.json ]; then
 cd $CERTDIR && cat > kube-controller-manager-csr.json <<EOF
{
  "CN": "system:kube-controller-manager",
  "key": {
    "algo": "rsa",
    "size": 2048
  },
  "names": [
    {
      "C": "${C}",
      "L": "${L}",
      "O": "system:kube-controller-manager",
      "OU": "Kubernetes The Hard Way",
      "ST": "${ST}"
    }
  ]
}
EOF

 cd $CERTDIR && cfssl gencert \
  -ca=$CERTDIR/ca.pem \
  -ca-key=$CERTDIR/ca-key.pem \
  -config=$CERTDIR/ca-config.json \
  -profile=kubernetes $CERTDIR/kube-controller-manager-csr.json | cfssljson -bare kube-controller-manager
fi 


if [ ! -f $CERTDIR/kube-proxy-csr.json ]; then
 cd $CERTDIR && cat > kube-proxy-csr.json <<EOF
{
  "CN": "system:kube-proxy",
  "key": {/
    "algo": "rsa",
    "size": 2048
  },
  "names": [
    {
      "C": "ES",
      "L": "Barcelona",
      "O": "system:node-proxier",
      "OU": "Kubernetes The Hard Way",
      "ST": "Spain"
    }
  ]
}
EOF


 cd $CERTDIR && cfssl gencert \
  -ca=$CERTDIR/ca.pem \
  -ca-key=$CERTDIR/ca-key.pem \
  -config=$CERTDIR/ca-config.json
  -profile=kubernetes \
  kube-proxy-csr.json | cfssljson -bare kube-proxy
fi 



if [ ! -f $CERTDIR/kube-scheduler-csr.json ]; then
cd $CERTDIR && cat > kube-scheduler-csr.json <<EOF
{
  "CN": "system:kube-scheduler",
  "key": {
    "algo": "rsa",
    "size": 2048
  },
  "names": [
    {
      "C": "${C}",
      "L": "${L}",
      "O": "system:kube-scheduler",
      "OU": "Kubernetes The Hard Way",
      "ST": "${ST}"
    }
  ]
}
EOF


 cd $CERTDIR && cfssl gencert \
  -ca=$CERTDIR/ca.pem \
  -ca-key=$CERTDIR/ca-key.pem \
  -config=$CERTDIR/ca-config.json \
  -profile=kubernetes \
  kube-scheduler-csr.json | cfssljson -bare kube-scheduler
fi


if [ ! -f $CERTDIR/kubernetes-csr.json ]; then
cat > kubernetes-csr.json <<EOF
{
  "CN": "kubernetes",
  "key": {
    "algo": "rsa",
    "size": 2048
  },
  "names": [
    {
      "C": "${C}",
      "L": "${L}",
      "O": "Kubernetes",
      "OU": "Kubernetes The Hard Way",
      "ST": "${ST}"
    }
  ]
}
EOF


 cd $CERTDIR && cfssl gencert \
  -ca=$CERTDIR/ca.pem \
  -ca-key=$CERTDIR/ca-key.pem \
  -config=$CERTDIR/ca-config.json \
  -hostname=${LOADBALANCER}.${DOMAIN},KUBINTCLUSTER_RANGE.1,$(ssh ${MASTER1} hostname --ip-address),$(ssh ${MASTER2} hostname --ip-address),$(ssh ${MASTER3} hostname --ip-address),$(ssh ${LOADBALANCER} hostname --ip-address),${KUBERNETES_BAREMETAL_ADDRESS},127.0.0.1,${KUBERNETES_HOSTNAMES} \
  -profile=kubernetes \
  kubernetes-csr.json | cfssljson -bare kubernetes
fi 


if [ ! -f $CERTDIR/service-account-csr.json ]; then
cd $CERTDIR && cat > service-account-csr.json <<EOF
{
  "CN": "service-accounts",
  "key": {
    "algo": "rsa",
    "size": 2048
  },
  "names": [
    {
      "C": "${C}",
      "L": "${L}",
      "O": "Kubernetes",
      "OU": "Kubernetes The Hard Way",
      "ST": "${ST}"
    }
  ]
}
EOF

 cd $CERTDIR && cfssl gencert \
  -ca=$CERTDIR/ca.pem \
  -ca-key=$CERTDIR/ca-key.pem \
  -config=$CERTDIR/ca-config.json \
  -profile=kubernetes \
  service-account-csr.json | cfssljson -bare service-account
fi 



# Distribute all certificates for workers 
 for NODE in $WORKER1 $WORKER2 $WORKER3; do
    ssh  ${NODE} "mkdir /opt/certs"
  	for key in ${NODE}-key.pem ${NODE}.pem kube-proxy-key.pem kube-proxy.pem; do 
            cd $CERTDIR
	    scp -r  ${key} ${node}:/opt/certs
	done
  done

cd $CERTDIR
# Distribute all certificates for masters
 for NODE in $MASTER1 $MASTER2 $MASTER3; do 
    ssh  ${NODE} "mkdir /opt/certs"
  	for KEY in ca.pem ca-key.pem kubernetes-key.pem kubernetes.pem service-account-key.pem service-account.pem; do 
            cd $CERTDIR
            scp -r  ${KEY} ${NODE}:/opt/certs
        done 
  done

if [ -f /etc/redhat-release ]; then
for NODE in $MASTER1 $MASTER2 $MASTER3 $WORKER1 $WORKER2 $WORKER3 $LOADBALANCER; do 
	scp -r  $CERTDIR/ca.pem $NODE:/etc/pki/ca-trust/source/anchors/ && ssh $NODE update-ca-trust extract ;
done 
fi 

if [ -f /etc/lsb-release ]; then
for NODE in $MASTER1 $MASTER2 $MASTER3 $WORKER1 $WORKER2 $WORKER3 $LOADBALANCER; do 
   scp -r  $CERTDIR/ca.pem $NODE:/usr/local/share/ca-certificates && ssh $NODE update-ca-certificates ; 
done
fi 
