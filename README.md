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

Please start `Docker.app` before running the following command.

```
bash 00-bootstrap.sh
```

# Deployment

Finally, run these commands to deploy our magento app and its relevant db.

```
bash 01-deploy.sh db mariadb
bash 01-deploy.sh db elasticsearch
bash 01-deploy.sh app magento
```

Then you can access your application at http://localhost:31380/
