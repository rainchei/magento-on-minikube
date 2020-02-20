# Introduction 

This project aims to bootstrap a local kubernetes cluster using minikube.

# Prerequisite

First, we need to install some packages.
-  [install docker](https://docs.docker.com/docker-for-mac/install/)
-  [install kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl/)
-  [install virtualbox](https://www.virtualbox.org/wiki/Downloads)
-  [install minikube](https://minikube.sigs.k8s.io/docs/start/)

# Bootstrapping

We will bootstrap a kube cluster and install [Istio](https://istio.io).

Please start `Docker.app` before running the following script.

```
bash 00-bootstrap.sh
```
