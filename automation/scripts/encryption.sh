#!/bin/bash

source ./bash_vars
ENCRYPTION_KEY=$(head -c 32 /dev/urandom | base64)

cd $KUBECTL_CONF_DIR
if [ ! -f $KUBECTL_CONF_DIR/encryption-config.yaml ]; then
cat > encryption-config.yaml <<EOF
kind: EncryptionConfig
apiVersion: v1
resources:
  - resources:
      - secrets
    providers:
      - aescbc:
          keys:
            - name: key1
              secret: ${ENCRYPTION_KEY}
      - identity: {}
EOF
fi


for NODE in $MASTER1 $MASTER2 $MASTER3; do 
	scp -r $KUBECTL_CONF_DIR/encryption-config.yaml $NODE:$KUBECTL_CONF_DIR
  done
