#!/bin/bash
USER=$1

function help(){
    echo -e "USAGE: ./create_user.sh USERNAME 
Script will create the user's key,csr,create the csr, validate it, thus you need to have a valid kubeconfig file to connect to your cluster.
"
}

if [[ "$#" -lt 1 || "$1" == "-h" ]];then
    help
else
    NAME=$1
    mkdir -p ${NAME}-certs && cd ${NAME}-certs
    echo -e "Creating user key..."
    openssl genrsa -out ${NAME}.key 2048
    echo -e "Creating user certificate request..."
    openssl req -new -key ${NAME}.key  -out ${NAME}.csr -subj "/CN=${NAME}"
    echo -e "Creating cert request in th k8s cluster..."
    cat <<EOF | kubectl apply -f -
apiVersion: certificates.k8s.io/v1
kind: CertificateSigningRequest
metadata:
  name: ${NAME}
spec:
  request: $(cat ${NAME}.csr | base64 | tr -d '\n')
  signerName: kubernetes.io/kube-apiserver-client
  usages:
  - client auth
EOF
    kubectl certificate approve $NAME
    if [[ ! $(kubectl  get csr  | grep $NAME | awk '{print $6}' | grep -w Issued) ]];then
        echo -e "Certs was not issed, check certificate status for details"
    else
        kubectl get csr $NAME -o jsonpath='{$.status.certificate}' | base64 -d | tee ${NAME}.crt
        echo -e "Cleaning csr"
        kubectl delete csr $NAME
        rm $NAME.csr
        echo -e "Adding user to kubeconfig file"
        kubectl config set-credentials $NAME --client-key=${NAME}.key --client-certificate=${NAME}.crt
        CLUSTER=$(kubectl config get-contexts | grep -w "*" | awk '{print $3}')
        CURRENT_CONTEXT=$(kubectl config get-contexts | grep -w "*" | awk '{print $2}')
        CONTEXT=${NAME}-${CLUSTER}
        echo -e "Creating context ${CONTEXT}..."
        kubectl config set-context $CONTEXT --user $NAME --cluster $CLUSTER
        echo -e "#####################################
#####################################
To use the new user on the current cluster, 
$ kubectl config use-context $CONTEXT 
If you are using RBAC, note that the new user won't be able to do anyhting, you can go back the original user by using
$ kubectl config use-context $CURRENT_CONTEXT "

    fi

fi