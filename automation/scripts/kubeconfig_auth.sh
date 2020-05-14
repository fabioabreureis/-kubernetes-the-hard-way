#!/bin/bash

source ./bash_vars

if [ ! -f $KUBECTL_CONF_DIR ]; then
mkdir $KUBECTL_CONF_DIR
fi 

cd $KUBECTL_CONF_DIR


#### SET WORKERS AUTH
for instance in $WORKER1 $WORKER2 $WORKER3; do

if [ ! -f $KUBECTL_CONF_DIR/${instance}.kubeconfig ]; then
kubectl config set-cluster $KUBE_CLUSTERNAME \
    --certificate-authority=$CERTDIR/ca.pem \
    --embed-certs=true \
    --server=https://${KUBERNETES_PUBLIC_ADDRESS}:6443 \
    --kubeconfig=${instance}.kubeconfig

  kubectl config set-credentials system:node:${instance}.${DOMAIN} \
    --client-certificate=$CERTDIR/${instance}.pem \
    --client-key=$CERTDIR/${instance}-key.pem \
    --embed-certs=true \
    --kubeconfig=${instance}.kubeconfig

  kubectl config set-context default \
    --cluster=$KUBE_CLUSTERNAME \
    --user=system:node:${instance}.${DOMAIN} \
    --kubeconfig=${instance}.kubeconfig

  kubectl config use-context default --kubeconfig=${instance}.kubeconfig
fi 
done


### SET PROXY AUTH
if [ ! -f $KUBECTL_CONF_DIR/kube-proxy.kubeconfig ]; then
  kubectl config set-cluster $KUBE_CLUSTERNAME \
    --certificate-authority=$CERTDIR/ca.pem \
    --embed-certs=true \
    --server=https://${KUBERNETES_PUBLIC_ADDRESS}:6443 \
    --kubeconfig=kube-proxy.kubeconfig

  kubectl config set-credentials system:kube-proxy \
    --client-certificate=$CERTDIR/kube-proxy.pem \
    --client-key=$CERTDIR/kube-proxy-key.pem \
    --embed-certs=true \
    --kubeconfig=kube-proxy.kubeconfig

  kubectl config set-context default \
    --cluster=$KUBE_CLUSTERNAME \
    --user=system:kube-proxy \
    --kubeconfig=kube-proxy.kubeconfig

  kubectl config use-context default --kubeconfig=kube-proxy.kubeconfig
fi


## SET SCHEDULER AUTH 

if [ ! -f $KUBECTL_CONF_DIR/kube-scheduler.kubeconfig ]; then

  kubectl config set-cluster $KUBE_CLUSTERNAME \
    --certificate-authority=$CERTDIR/ca.pem \
    --embed-certs=true \
    --server=https://127.0.0.1:6443 \
    --kubeconfig=kube-scheduler.kubeconfig

  kubectl config set-credentials system:kube-scheduler \
    --client-certificate=$CERTDIR/kube-scheduler.pem \
    --client-key=$CERTDIR/kube-scheduler-key.pem \
    --embed-certs=true \
    --kubeconfig=kube-scheduler.kubeconfig

  kubectl config set-context default \
    --cluster=$KUBE_CLUSTERNAME \
    --user=system:kube-scheduler \
    --kubeconfig=kube-scheduler.kubeconfig

 kubectl config use-context default --kubeconfig=kube-scheduler.kubeconfig
fi


## SET CONTROLLER
if [ ! -f $KUBECTL_CONF_DIR/kube-controller-manager.kubeconfig ]; then
  kubectl config set-cluster $KUBE_CLUSTERNAME \
    --certificate-authority=$CERTDIR/ca.pem \
    --embed-certs=true \
    --server=https://127.0.0.1:6443 \
    --kubeconfig=kube-controller-manager.kubeconfig

  kubectl config set-credentials system:kube-controller-manager \
    --client-certificate=$CERTDIR/kube-controller-manager.pem \
    --client-key=$CERTDIR/kube-controller-manager-key.pem \
    --embed-certs=true \
    --kubeconfig=kube-controller-manager.kubeconfig

  kubectl config set-context default \
    --cluster=$KUBE_CLUSTERNAME \
    --user=system:kube-controller-manager \
    --kubeconfig=kube-controller-manager.kubeconfig

  kubectl config use-context default --kubeconfig=kube-controller-manager.kubeconfig
fi 

## SET ADMIN USER

if [ ! -f $KUBECTL_CONF_DIR/admin.kubeconfig ]; then
 kubectl config set-cluster $KUBE_CLUSTERNAME \
    --certificate-authority=$CERTDIR/ca.pem \
    --embed-certs=true \
    --server=https://127.0.0.1:6443 \
    --kubeconfig=admin.kubeconfig

  kubectl config set-credentials admin \
    --client-certificate=$CERTDIR/admin.pem \
    --client-key=$CERTDIR/admin-key.pem \
    --embed-certs=true \
    --kubeconfig=admin.kubeconfig

  kubectl config set-context default \
    --cluster=$KUBE_CLUSTERNAME  \
    --user=admin \
    --kubeconfig=admin.kubeconfig

  kubectl config use-context default --kubeconfig=admin.kubeconfig
fi 

# COPY kubeconfig for workers
for NODE in $WORKER1 $WORKER2 $WORKER3
do 
       ssh $NODE mkdir $KUBECTL_CONF_DIR
       scp -r  ${KUBECTL_CONF_DIR}/${NODE}.kubeconfig ${NODE}:${KUBECTL_CONF_DIR}
       scp -r  ${KUBECTL_CONF_DIR}/kube-proxy.kubeconfig ${NODE}:${KUBECTL_CONF_DIR}
done

# COPY kubeconfig for masters
for NODE in $MASTER1 $MASTER2 $MASTER3;do
         ssh $NODE mkdir $KUBECTL_CONF_DIR
       scp -r  ${KUBECTL_CONF_DIR}/* ${NODE}:${KUBECTL_CONF_DIR}
done


