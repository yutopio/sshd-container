FROM centos:latest

LABEL maintainer="Yuto Takei <yuto.takei@basset.ai>"

RUN adduser user && \
    yum install -y openssh-server openssh-clients && \
    sed -i 's/.*\(PasswordAuthentication\).*/\1 no/g' /etc/ssh/sshd_config && \
    sed -i 's/.*\(GSSAPIAuthentication\).*/\1 no/g' /etc/ssh/sshd_config && \
    sed -i 's/.*\(PermitRootLogin\).*/\1 no/g' /etc/ssh/sshd_config && \
    sed -i 's/.*\(AllowAgentForwarding\).*/\1 yes/g' /etc/ssh/sshd_config && \
    sed -i 's/.*\(ClientAliveInterval\).*/\1 180/g' /etc/ssh/sshd_config

ADD launch.sh /bin/launch-sshd.sh
RUN chmod 755 /bin/launch-sshd.sh

EXPOSE 22
CMD ["/bin/launch-sshd.sh"]
