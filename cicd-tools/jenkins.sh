#!/bin/bash

#resize disk from 20GB to 50GB
growpart /dev/nvme0n1 4

lvextend -L +10G /dev/RootVG/rootVol
lvextend -L +10G /dev/mapper/RootVG-varVol
lvextend -l +100%FREE /dev/mapper/RootVG-varTmpVol

xfs_growfs /
xfs_growfs /var/tmp
xfs_growfs /var


# ----------------------------
# Install Java 21
# ----------------------------
sudo dnf install -y fontconfig java-21-openjdk java-21-openjdk-devel

# Set Java 21 as the default Java
sudo alternatives --set java /usr/lib/jvm/java-21-openjdk/bin/java

# ----------------------------
# Configure Jenkins Repository
# ----------------------------
sudo tee /etc/yum.repos.d/jenkins.repo > /dev/null <<EOF
[jenkins]
name=Jenkins-stable
baseurl=https://pkg.jenkins.io/redhat-stable/
enabled=1
gpgcheck=0
gpgkey=https://pkg.jenkins.io/redhat-stable/jenkins.io-2023.key
EOF

# Refresh repository metadata
sudo dnf clean all
sudo dnf makecache

# ----------------------------
# Install Jenkins
# ----------------------------
sudo dnf install -y --nogpgcheck jenkins

# ----------------------------
# Enable and Start Jenkins
# ----------------------------
sudo systemctl daemon-reload
sudo systemctl enable jenkins
sudo systemctl start jenkins

# Verify Java and Jenkins status
java -version
sudo systemctl status jenkins --no-pager

echo "Jenkins Initial Admin Password:"
sudo cat /var/lib/jenkins/secrets/initialAdminPassword
