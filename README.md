# Introduction 

This project aims to bootstrap a local kubernetes cluster using minikube.

# Prerequisite

First, we need to install some packages.
-  [install docker](https://docs.docker.com/docker-for-mac/install/)
-  [install kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl/)
-  [install virtualbox](https://www.virtualbox.org/wiki/Downloads)
-  [install minikube](https://minikube.sigs.k8s.io/docs/start/)

# Bootstrapping

We will bootstrap a kube cluster using a shell script.

Please start `Docker.app` before running the following commands.

```
./00-bootstrap.sh

# Append minikube ip to /etc/hosts
echo $(minikube ip) localhost-magento.example.com | sudo tee -a /etc/hosts
```

# Deployment

Finally, use `01-deploy.sh` to deploy app and db. For example,

```
./01-deploy.sh db/mysql
./01-deploy.sh db/redis
./01-deploy.sh app/magento
```

Then you can access your application at http://localhost-magento.example.com
