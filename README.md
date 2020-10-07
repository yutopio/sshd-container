# sshd Container

This repository contains a definition for a docker container to run OpenSSH server.

## Intended usecase

This container launches an SSH daemon and serves as an entrypoint to the container network. It is to provide a backdoor access for other pods and nodes by running an SSH-accepting container within your cluster. While `docker exec` offers a capability to run a shell inside the specific container, this container provides easier access to the other containers on the same docker network as well.

Important: This container is intended to be used solely for the development and test purpose.

## Usage

Generate your `known_hosts` and `authorized_keys` for incoming SSH connections. Your SSH public key should be listed in the `authorized_keys`. You must also generate a new SSH host key to be used within the container. You can use the generate public key to identify the SSH container when you connect to it. The following commands illustrates how to deploy the container to your Kubernetes cluster assuming you have a proper connection configuration.

### Deploying to localhost using Docker Compose

Following command will start the sshd command.

```
docker-compose up -d
```

Practically, you may want to add other services in the same setup. In such a case, you can pass multiple YAML files and combine them as a single compose file.

```
docker-compose -f compose1.yaml -f compose2.yaml up -d
```

See more at https://docs.docker.com/compose/reference/overview/#use--f-to-specify-name-and-path-of-one-or-more-compose-files

#### Changing the host SSH port

When you try to configure the container to forward the listening port 22 to the host, it will be necessary to change the SSH port of the Docker host not to conflict with the forwarded port.

```
NEW_HOST_PORT=2222
sed -i "s/.*\(Port\)\b.*/\1 $NEW_HOST_PORT/g" /etc/ssh/sshd_config
```

Depending on which port to use as a new SSH port, you may need to substitute `-a` (add) with `-m` (modify) in the command above.

If SELinux is enabled on your host, you need to update the security context of SSH port. You may also need to add a rule to the firewall.

```
semanage port -a -t ssh_port_t -p tcp $NEW_HOST_PORT
firewall-cmd --zone=public --permanent --add-port=$NEW_HOST_PORT/tcp
```

After reboot, all those settings will be in effect.

References:

* https://serverfault.com/questions/538037/sshd-service-fails-to-start
* https://serverfault.com/questions/790404/selinux-error-valueerror-port-tcp-5000-already-defined

## Deploying to Kubernetes

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
