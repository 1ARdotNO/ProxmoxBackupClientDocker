FROM debian:buster

#Install dependencies
RUN apt-get update
RUN apt-get install wget ca-certificates -y

#Add repository
RUN echo "deb http://download.proxmox.com/debian/pbs buster pbstest" > /etc/apt/sources.list.d/pbstest-beta.list
RUN wget http://download.proxmox.com/debian/proxmox-ve-release-6.x.gpg -O /etc/apt/trusted.gpg.d/proxmox-ve-release-6.x.gpg


#Install packages
RUN apt-get update
RUN apt-get install proxmox-backup-client -y


# Install powershell 7
RUN \
 apt-get update && \
 apt-get install wget -y && \
 apt-get install software-properties-common -y && \
 wget -q https://packages.microsoft.com/config/debian/10/packages-microsoft-prod.deb && \
 dpkg -i packages-microsoft-prod.deb && \
 apt-get update && \
 apt-get install -y powershell


#start!

COPY entrypoint.sh /
RUN chmod a+x /entrypoint.sh
STOPSIGNAL SIGINT
ENTRYPOINT ["/entrypoint.sh"]
