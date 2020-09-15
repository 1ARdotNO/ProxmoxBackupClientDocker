FROM debian:buster

#Install dependencies
RUN apt-get update
RUN apt-get install wget ca-certificates cron gnupg2 curl -y

#Add repository
RUN echo "deb http://download.proxmox.com/debian/pbs buster pbstest" > /etc/apt/sources.list.d/pbstest-beta.list
RUN wget http://download.proxmox.com/debian/proxmox-ve-release-6.x.gpg -O /etc/apt/trusted.gpg.d/proxmox-ve-release-6.x.gpg


#Install packages
RUN apt-get update
RUN apt-get install proxmox-backup-client=0.8.14-1 -y
##Install this version because of bug in 15 and 16 with benchmark being exchanged for backup for some reason, BUG

# Install powershell 7
RUN \
 apt-get update && \
 apt-get install wget -y && \
 apt-get install software-properties-common -y && \
 wget -q https://packages.microsoft.com/config/debian/10/packages-microsoft-prod.deb && \
 dpkg -i packages-microsoft-prod.deb && \
 apt-get update && \
 apt-get install -y powershell
 
 #install packages for prescripts
 RUN apt install cifs-utils -y
 RUN echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] http://packages.cloud.google.com/apt cloud-sdk main" | tee -a /etc/apt/sources.list.d/google-cloud-sdk.list && curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key --keyring /usr/share/keyrings/cloud.google.gpg  add - && apt-get update -y && apt-get install google-cloud-sdk -y
      

#start!

COPY entrypoint.sh /
RUN chmod a+x /entrypoint.sh
COPY backupscript.ps1 /
RUN chmod a+x /backupscript.ps1
COPY prescripts /
STOPSIGNAL SIGINT
ENTRYPOINT ["/entrypoint.sh"]
