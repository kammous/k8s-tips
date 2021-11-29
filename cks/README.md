# Cetified Kuberntes Security Specialist

## cluster setup

https://github.com/killer-sh/cks-course-environment

- Create master node instance:
```
gcloud compute instances create cks-master --zone=europe-west3-c \
--machine-type=e2-medium \
--image=ubuntu-1804-bionic-v20210702 \
--image-project=ubuntu-os-cloud \
--boot-disk-size=50GB
```
- Create worker node instance:
```
gcloud compute instances create cks-worker --zone=europe-west3-c \
--machine-type=e2-medium \
--image=ubuntu-1804-bionic-v20210702 \
--image-project=ubuntu-os-cloud \
--boot-disk-size=50GB
```
From master node:
kubeadm token create --print-join-command --ttl 0
From worker node:
kubeadm join 10.156.0.2:6443 --token rioas7.mr986vt8k5bccg67     --discovery-token-ca-cert-hash sha256:5c38691a6c8ad250c86aaf8a37b2f39c3c6834886db757681260243c88347817


### Upgrade:
Start with master node:
kubectl drain cks-master --ignore-daemonsets
apt-cache show kubeadm | grep 1.20

apt update
apt-get install kubeadm=1.20.10-00 kubelet=1.20.10-00 kubectl=1.20.10-00

You can also perform this action in beforehand using 'kubeadm config images pull'

kubectl uncordon cks-master

It's worker node turn:
kubectl drain cks-worker --ignore-daemonsets
apt-get install kubeadm=1.20.10-00
kubeadm upgrade node
apt-get install kubelet=1.20.10-00 kubectl=1.20.10-00
kubectl uncordon cks-worker

## Network Policy

- [k8s.io - Network Policies](https://kubernetes.io/docs/concepts/services-networking/network-policies/)
- [k8s.io - Declare Network Policy](https://kubernetes.io/docs/tasks/administer-cluster/declare-network-policy/)
- Ahmet's [git repo](https://github.com/ahmetb/kubernetes-network-policy-recipes) and [KubeCon talk](https://www.youtube.com/watch?v=3gGpMmYeEO8)


GCP:
Il vous reste 254,53 € de crédit et 91 jours d'essai gratuit. 
## Ingress

- [k8s.io - Ingress](https://kubernetes.io/fr/docs/concepts/services-networking/ingress/#tls)
- Create a cert:
```
openssl req -x509 -newkey rsa:4096 -keyout key.pem -out cert.pem -days 365 -nodes
```
- Create a TLS secret:
```
kubectl create secret tls mycert --cert=cert.pem --key=key.pem
```

## Access to Cloud provider Metadata service
We have to block access from cluster VMs to Cloud provider Metadata service. To do so, you need 2 Network Policy rules: 
- Deny Network Policy rule 
```yaml
# all pods in namespace cannot access metadata endpoint
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: cloud-metadata-deny
  namespace: default
spec:
  podSelector: {}
  policyTypes:
  - Egress
  egress:
  - to:
    - ipBlock:
        cidr: 0.0.0.0/0
        except:
        - 169.254.169.254/32
```
- Allow Network Policy rule 
```yaml
# only pods with label are allowed to access metadata endpoint
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: cloud-metadata-allow
  namespace: default
spec:
  podSelector:
    matchLabels:
      role: metadata-accessor
  policyTypes:
  - Egress
  egress:
  - to:
    - ipBlock:
        cidr: 169.254.169.254/32
```
## CIS Benchmarks
Verify that the permissions are 644 or more restrictive
``` bash
stat -c "%a" /etc/kubernetes/manifests/*.yaml
600
```
If needed use `chmod` command to reduce permissions.
``` bash
chmod 644 /etc/kubernetes/manifests/kube-apiserver.yaml
```

## RBAC
How to create a user to call k8s API

1- Generate a key and a csr
```
openssl genrsa -out jane.key 2048
openssl req -new -key jane.key -out jane.csr
```
2- Create a Certificate Signing Request
```yaml
cat <<EOF | kubectl apply -f -
apiVersion: certificates.k8s.io/v1
kind: CertificateSigningRequest
metadata:
  name: jane
spec:
  groups:
  - system:authenticated
  request: $(cat MYCSR.csr | base64 -w 0)
  signerName: kubernetes.io/kube-apiserver-client
  usages:
  - client auth
EOF
```
cat jane.csr | base64 | tr -d "\n"
or
cat jane.csr | base64 -w 0
3- Approuve the certificate
```
kubectl certificate approve jane
```

4- Download jane's cert file.
```
kubectl get csr jane -o jsonpath='{.status.certificate}' | base64 -d > jane.crt
```

## Service Account



1- kubectl create serviceaccount api-explorer

2- k create clusterrole log-reader --verb=get,watch,list --resource=pods,pods/log

3- kubectl create rolebinding api-explorer:log-reader --clusterrole log-reader --serviceaccount default:api-explorer
 
Get the ServiceAccount's token Secret's name
```
SECRET=$(kubectl get serviceaccount api-explorer -o json | jq -Mr '.secrets[].name | select(contains("token"))')
``` 
Extract the Bearer token from the Secret and decode
```
TOKEN=$(kubectl get secret ${SECRET} -o json | jq -Mr '.data.token' | base64 -d)
``` 
Extract, decode and write the ca.crt to a temporary location
```
kubectl get secret ${SECRET} -o json | jq -Mr '.data["ca.crt"]' | base64 -d > /tmp/ca.crt
``` 
Get the API Server location
```
APISERVER=https://$(kubectl -n default get endpoints kubernetes --no-headers | awk '{ print $2 }')
```
Get specified pod logs:
```
curl -s $APISERVER/api/v1/namespaces/default/pods/nginx/log  --header "Authorization: Beer $TOKEN" --cacert ca.crt
```
curl https://kubernetes.default -k -H "Authorization: Bearer $(cat /run/secrets/kubernetes.io/serviceaccount/token)"

ref:
https://programmersought.com/article/19221805006/

## API Server access:
1- extract CA, client cert and key from kubeconfig file
```
grep client-cert ~/.kube/config |cut -d" " -f 6 | base64 -d > client-cert.crt
grep client-key-data ~/.kube/config |cut -d" " -f 6 | base64 -d > client-key.crt
grep certificate-authority-data ~/.kube/config |cut -d" " -f 6 | base64 -d > ca.crt
```
```
curl https://127.0.01:34617 --cacert ca.crt --cert cert.crt --key key.crt
```
Form external host
```
curl https://cks-master:30386/ --cacert ./ca.crt --cert ./cert.crt --key ./key.crt--resolve cks-master:30386:34.141.63.166
```
## Docker image hardening
1- Use specific package version
2- Don't run as root
3- Make filesystem read only
4- Remove shell access
``` docker
FROM ubuntu
ARG DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get install -y golang-go
COPY app.go .
RUN CGO_ENABLED=0 go build app.go

FROM alpine:3.12.1
RUN chmod a-w /etc
RUN addgroup -S appgroup && adduser -S appuser -G appgroup -h /home/appuser
RUN rm -rf /bin/*
COPY --from=0 /app /home/appuser/
USER appuser
CMD ["/home/appuser/app"] 
```
## System Hardening
### AppArmor
Install AppArmor tools:
```
sudo apt-get install apparmor-utils
```

We will use `curl` command as exemple of how to limit a binary usage using `AppArmor` tool.

```
curl k8s-school.fr
```
```html
<!DOCTYPE HTML PUBLIC "-//IETF//DTD HTML 2.0//EN">
<html><head>
<title>302 Found</title>
</head><body>
<h1>Found</h1>
<p>The document has moved <a href="https://k8s-school.fr/">here</a>.</p>
</body></html>
```
Generate a profile for `curl` command:
```
sudo aa-genprof curl
```
Type (F).

Read profile file content:
```bash
cat /etc/apparmor.d/usr.bin.curl
# Last Modified: Sat Aug 28 15:05:42 2021
#include <tunables/global>
/usr/bin/curl {
  #include <abstractions/base>

  /lib/x86_64-linux-gnu/ld-*.so mr,
  /usr/bin/curl mr,
}
```
Run again `curl` command:
```
curl k8s-school.fr
curl: (6) Could not resolve host: k8s-school.fr
```

Process log entries to generate a new profile for `curl` command:
```
aa-logprof
```
Type (A) for Allow then (S) for Save to generate the new `curl`'s profile.
```
cat /etc/apparmor.d/usr.bin.curl
# Last Modified: Sat Aug 28 15:31:28 2021
#include <tunables/global>

/usr/bin/curl {
  #include <abstractions/base>
  #include <abstractions/lxc/container-base>
}
```
Now, `curl` command curns without restriction.
```Shell
curl k8s-school.fr
```
```html
<!DOCTYPE HTML PUBLIC "-//IETF//DTD HTML 2.0//EN">
<html><head>
<title>302 Found</title>
</head><body>
<h1>Found</h1>
<p>The document has moved <a href="https://k8s-school.fr/">here</a>.</p>
</body></html>
```

How to load a profile:
```
sudo apparmor_parser -a /etc/apparmor.d/usr.bin.curl
```
How to remove a profile:
```
sudo apparmor_parser -R /etc/apparmor.d/usr.bin.curl
sudo rm /etc/apparmor.d/usr.bin.curl
sudo rm /var/lib/apparmor/cache/usr.bin.curl
```

**Secure a pod with AppArmor on Kubernetes:**
- Create docker-nginx profile on worker node
```
curl -LO https://raw.githubusercontent.com/killer-sh/cks-course-environment/master/course-content/system-hardening/kernel-hardening-tools/apparmor/profile-docker-nginx
sudo mv profile-docker-nginx /etc/apparmor.d/
```
- load the profile 
```shell
sudo apparmor_parser -a /etc/apparmor.d/profile-docker-nginx
```
- Create a pod and add AppArmor annotation pointing to profile name (not profile file name)
```yaml
apiVersion: v1
kind: Pod
metadata:
  annotations:
    container.apparmor.security.beta.kubernetes.io/secure: "localhost/docker-nginx"
  labels:
    run: secure
  name: secure
spec:
  containers:  - image: nginx
    name: secure
    resources: {}
  dnsPolicy: ClusterFirst
  restartPolicy: Always
status: {}
```
- Create nginx pod using above yaml file:
```
kubectl apply -f secure.yaml
```

- Open a `bash` inside `nginx` pod and try to execute some denied commands by `AppArmor` like `ssh` and `touch`:
```bash
root@cks-master:~/cks# kubectl exec -it secure -- bash
root@secure:/# sh
bash: /bin/sh: Permission denied
root@secure:/# touch /root/test
touch: cannot touch '/root/test': Permission denied
```
**AppArmor links:**
https://kubernetes.io/docs/tutorials/clusters/apparmor/
https://doc.ubuntu-fr.org/apparmor#installation




**References:**
- [Dockerfile best practices](https://docs.docker.com/develop/develop-images/dockerfile_best-practices/)
- (smaller Docker images)[https://learnk8s.io/blog/smaller-docker-images]
https://cloud.google.com/blog/products/containers-kubernetes/
- (7 Google best practices for building containers)[7-best-practices-for-building-containers]

## Static Analysis

Kubesec:
https://kubesec.io/

## Runtime Security - Behavioral Analytics with Falco

[Falco Installation guide:](https://falco.org/docs/getting-started/installation/)

1- Trust the falcosecurity GPG key, configure the apt repository, and update the package list:
```bash 
curl -s https://falco.org/repo/falcosecurity-3672BA8F.asc | apt-key add -
echo "deb https://download.falco.org/packages/deb stable main" | tee -a /etc/apt/sources.list.d/falcosecurity.list
apt-get update -y
```
2- Install kernel headers:
```bash
apt-get -y install linux-headers-$(uname -r)
```
3- Install Falco:
```bash
apt-get install -y falco=0.29.1
```
**Sinon une installation avec un script:**

```bash
curl -o install_falco -s https://falco.org/script/install
```

Install Falco Helm chart 
```
helm repo add falcosecurity https://falcosecurity.github.io/charts
helm repo update
helm install falco falcosecurity/falco
```

Configure Falco:
Default rules:  /etc/falco/falco_rules.yaml
or
Overriding default rules: /etc/falco/falco_rules.local.yaml

**Run Falco:**

falco -k https://API-SERVER:443 -k/var/run/secrets/kubernetes.io/serviceaccount/token
**Videos**

- (k8s-io/falco)[https://v1-17.docs.kubernetes.io/docs/tasks/debug-application-cluster/falco/]
- (Intro: Falco - Loris Degioanni, Sysdig)[https://www.youtube.com/watch?v=zgRFN3o7nJE]
- (Syscall talk by Liz Rice)[https://www.youtube.com/watch?v=8g-NUUmCeGI]

## Runtime Security - Immutable containers
How to enforce immutability:
- remove bash/shell
- Read Only file system
- Run as user and non root
- Override Run/startup command using startupProbe

## Runtime Security - Auditing
1- Create an audit policy yaml file
``` bash
cat << EOF >> /etc/kubernetes/audit/policy.yaml
echo 'apiVersion: audit.k8s.io/v1
kind: Policy
rules:
- level: Metadata
EOF
```

2- Add below param to kube-apiserver
```yaml
spec:
  containers:
  - command:
    - kube-apiserver
    - --audit-policy-file=/etc/kubernetes/audit/policy.yaml       # add
    - --audit-log-path=/etc/kubernetes/audit/logs/audit.log       # add
    - --audit-log-maxsize=500                                     # add
    - --audit-log-maxbackup=5                                     # add
    ...
    volumeMounts:
    - mountPath: /etc/kubernetes/audit      # add
      name: audit                           # add
    ...
  volumes:
  - hostPath:                               # add
      path: /etc/kubernetes/audit           # add
      type: DirectoryOrCreate               # add
    name: audit                             # add
```

[Audit helper script](https://github.com/kubernetes/kubernetes/blob/master/cluster/gce/gci/configure-helper.sh)

## Tools

- [Kube Bench: security best practices checker](https://github.com/aquasecurity/kube-bench)
- [Kube Hunter: Open source penetration tests](github.com/aquasecurity/kube-hunter)
- [CIS Benchmarks](https://www.cisecurity.org/benchmark/kubernetes/) 