#!/bin/bash
set -Eeuo pipefail

##################################
###### Configure Database ########
##################################

# Set 'oracle' user home directory to ${ORACLE_BASE}
usermod -d "${ORACLE_BASE}" oracle

# Set 'oracle' user password to 'oracle'
echo "oracle" | passwd --stdin oracle

# Add listener port and skip validations to conf file
sed -i "s/LISTENER_PORT=/LISTENER_PORT=1521/g" /etc/sysconfig/oracle-free-23*.conf
sed -i "s/SKIP_VALIDATIONS=false/SKIP_VALIDATIONS=true/g" /etc/sysconfig/oracle-free-23*.conf
sed -i "s/CHARSET=.*/CHARSET=WE8ISO8859P1/g" /etc/sysconfig/oracle-free-23*.conf

# Disable netca to avoid "No IP address found" issue
mv "${ORACLE_HOME}"/bin/netca "${ORACLE_HOME}"/bin/netca.bak
ln -s /bin/true "${ORACLE_HOME}"/bin/netca 

echo "BUILDER: configuring database"

# Set random password
ORACLE_PASSWORD=$(date '+%s' | sha256sum | base64 | head -c 8)
# Configure the Oracle Database instance
/etc/init.d/oracle-free-23* configure <<EOF
${ORACLE_PASSWORD}
${ORACLE_PASSWORD}
EOF

# Stop unconfigured listener
su -p oracle -c "lsnrctl stop"

# Re-enable netca
mv "${ORACLE_HOME}"/bin/netca.bak "${ORACLE_HOME}"/bin/netca
