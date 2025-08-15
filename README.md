# Use this script to create a user in your cluster with X509 certs authentication

**Requirements:** 

* A k8s cluster
* Using a kubeconfig context with admin rights (approve, create csr )

The script will create a rsa key, a csr, a csr k8s request, approve it, get back the csr from the API, create a context in your kubeconfig file using this new user

## Usage
```
$ ./create_user.sh USERNAME

```

````
$ ./create_user.sh jane
Creating user key...
Creating user certificate request...
Creating cert request in th k8s cluster...
certificatesigningrequest.certificates.k8s.io/jane created
certificatesigningrequest.certificates.k8s.io/jane approved
-----BEGIN CERTIFICATE-----
MIIC9TCCAd2gAwIBAgIRAPT2R9fbhAl2P82xd7a3BMcwDQYJKoZIhvcNAQELBQAw
[...]
O/tHF6m/1hZQHkIEchSS63e2B6+NnDygtn9liD8fN5HHRaUdXPLyqTbHbWli4gfy
7zypb0F0fIa8kziIk6VHC+IyIrzv4F2jQOuK2+o6IllZY1kvJWkikqgMAE2TUEm0
eOSZ0vVRwYMcLMrEr1rTB+GF7QhUASLQPPjeqKl2LFYYPQ+UTHvTrnw=
-----END CERTIFICATE-----
Cleaning csr
certificatesigningrequest.certificates.k8s.io "jane" deleted
Adding user to kubeconfig file
User "jane" set.
Creating context jane-kubernetes...
Context "jane-kubernetes" modified.
#####################################
#####################################
To use the new user on the current cluster, 
$ kubectl config use-context jane-kubernetes 
If you are using RBAC, note that the new user won't be able to do anyhting, you can go back the original user by using
$ kubectl config use-context kubernetes-admin@kubernetes
````

You will be able to find the key/cert in the name-certs folder :D

Alternatively, if you don't want to use k8s API, you could sign the csr with the client-ca key if you have acces to it. 

Reference: https://kubernetes.io/docs/tasks/tls/managing-tls-in-a-cluster/