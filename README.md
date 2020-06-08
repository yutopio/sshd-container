# sshd Container

This repository contains a definition for a docker container to run OpenSSH server.

## Intended usecase

The container is intended mainly for development / testing purpose to provide a backdoor access for other pods and nodes by running an SSH-accepting container within your cluster.

## Usage

Generate your `known_hosts` and `authorized_keys` for incoming SSH connections. Your SSH public key should be listed in the `authorized_keys`. You must also generate a new SSH host key to be used within the container. You can use the generate public key to identify the SSH container when you connect to it. The following commands illustrates how to deploy the container to your Kubernetes cluster assuming you have a proper connection configuration.

```
kubectl create configmap ssh-config --from-file=configs/known_hosts --from-file=configs/authorized_keys
ssh-keygen -f configs/ssh_host_ecdsa_key -N '' -t ecdsa -b 521
kubectl create secret generic ssh-host-key --from-file=configs/ssh_host_ecdsa_key
kubectl apply -f kubernetes.yaml
```

This container will be publicly available at [my Docker Hub repository](https://hub.docker.com/r/yutotakei/sshd). You can pull the container alone by the following command.

```
docker pull yutotakei/sshd:latest
docker run -d -p 22:22 -v "$(pwd)/configs:/tmp/configs:ro" yutotakei/sshd:latest
```

# Security considerations

The container is designed to only accept public-key authentication. You must specify your SSH public keys in `authorized_keys` before you start the container.

It is recommended to limit IP ranges from where the container is accepting connections. You can specify the whitelist of IP addresses to allow connections by applying [network policy](https://kubernetes.io/docs/concepts/services-networking/network-policies/). This repository includes an example configuration of such policy.

```
kubectl apply -f sshd-policy.yaml
```

# Restrictions

* SSH user name is always `user`.
* You cannot change who can SSH while the container is running. You need to recreate the container with updated configuration.
