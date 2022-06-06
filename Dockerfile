FROM debian:bullseye

#Install dependencies
RUN apt-get update
RUN apt-get install wget ca-certificates cron gnupg2 curl tar -y

#Add repository
RUN echo "deb http://download.proxmox.com/debian/pbs-client bullseye main" > /etc/apt/sources.list.d/pbs-client.list
RUN wget https://enterprise.proxmox.com/debian/proxmox-release-bullseye.gpg -O /etc/apt/trusted.gpg.d/proxmox-release-bullseye.gpg
#verify gpg
RUN md5sum /etc/apt/trusted.gpg.d/proxmox-release-bullseye.gpg | grep bcc35c7173e0845c0d6ad6470b70f50e


#Install packages
RUN apt-get update
RUN apt-get install proxmox-backup-client -y
RUN apt-get install git -y

#Install python3 and pip
RUN apt-get install python3 -y
RUN apt-get install python3-pip -y

#install instaloader for instagram backup
RUN pip3 install instaloader

# Install powershell 7
RUN \
 apt-get update && \
 apt-get install wget -y && \
 apt-get install software-properties-common -y && \
 wget -q https://packages.microsoft.com/config/debian/10/packages-microsoft-prod.deb && \
 dpkg -i packages-microsoft-prod.deb && \
 apt-get update && \
 apt-get install -y powershell
 
 #install powershell modules
 RUN pwsh -command "install-module pselasticsearch -force"
 RUN pwsh -command "install-module core -force"
 RUN pwsh -command "Install-Module -Name PowerShellForGitHub -force"
 


 
 #install packages for prescripts
 RUN apt install cifs-utils -y
 RUN echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] http://packages.cloud.google.com/apt cloud-sdk main" | tee -a /etc/apt/sources.list.d/google-cloud-sdk.list && curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key --keyring /usr/share/keyrings/cloud.google.gpg  add - && apt-get update -y && apt-get install google-cloud-sdk -y
 RUN apt install sshpass openssh-client -y #For scp backups. ie. unifi/pfsense
    #Bitwarden backups
    RUN apt install nodejs npm -y  #needed for bitwarden cli
    RUN npm install -g @bitwarden/cli
    RUN wget https://github.com/vwxyzjn/portwarden/releases/download/1.0.0/portwarden_linux_amd64 -P /usr/bin && mv /usr/bin/portwarden_linux_amd64 /usr/bin/portwarden && chmod a+x /usr/bin/portwarden

#Cleanup
RUN apt clean

#start!

COPY entrypoint.sh /
RUN chmod a+x /entrypoint.sh
COPY backupscript.ps1 /
COPY reporting.ps1 /
RUN chmod a+x /reporting.ps1
RUN chmod a+x /backupscript.ps1
COPY prescripts /
COPY postscript /
STOPSIGNAL SIGINT
ENTRYPOINT ["/entrypoint.sh"]
