#!/bin/bash

# BSD 2-Clause License

# Copyright (c) 2020, Supreeth Herle
# All rights reserved.

# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:

# 1. Redistributions of source code must retain the above copyright notice, this
#    list of conditions and the following disclaimer.

# 2. Redistributions in binary form must reproduce the above copyright notice,
#    this list of conditions and the following disclaimer in the documentation
#    and/or other materials provided with the distribution.

# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
# AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
# DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
# FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
# DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
# SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
# CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
# OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
# OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
export IP_ADDR=$(awk 'END{print $1}' /etc/hosts)

cp /mnt/ueransim/open5gs-ue.yaml /UERANSIM/config/open5gs-ue.yaml
sed -i 's|MNC|'$MNC'|g' /UERANSIM/config/open5gs-ue.yaml
sed -i 's|MCC|'$MCC'|g' /UERANSIM/config/open5gs-ue.yaml

sed -i 's|UE1_KI|'$UE1_KI'|g' /UERANSIM/config/open5gs-ue.yaml
sed -i 's|UE1_OPC|'$UE1_OPC'|g' /UERANSIM/config/open5gs-ue.yaml
sed -i 's|UE1_AMF|'$UE1_AMF'|g' /UERANSIM/config/open5gs-ue.yaml
sed -i 's|UE1_IMEISV|'$UE1_IMEISV'|g' /UERANSIM/config/open5gs-ue.yaml
sed -i 's|UE1_IMEI|'$UE1_IMEI'|g' /UERANSIM/config/open5gs-ue.yaml
sed -i 's|UE1_IMSI|'$UE1_IMSI'|g' /UERANSIM/config/open5gs-ue.yaml
sed -i 's|NR_GNB_IP|'$NR_GNB_IP'|g' /UERANSIM/config/open5gs-ue.yaml

cp -R /mnt/li/pyli5 ~
cat ~/pyli5/requirements.txt | xargs -n 1 pip install #skip failure on single package
sed -i 's|LEA_IP|'${LEA_IP}'|g' ~/pyli5/src/pyli5/catcher/catcher.json
sed -i 's|LEA_INTERCEPTION_PORT|'${LEA_INTERCEPTION_PORT}'|g' ~/pyli5/src/pyli5/catcher/catcher.json

mkdir /UERANSIM/var
mkdir /UERANSIM/var/log
touch /UERANSIM/var/log/nr_ue.log

echo "Starting catcher..."
cd ~/pyli5/src && python3 start_catcher.py &
echo "Done"
sleep 2
echo "Starting 100 UEs..."
/UERANSIM/build/nr-ue -c UERANSIM/config/open5gs-ue.yaml -n 100 --tempo 1010 &>> /UERANSIM/var/log/nr_ue.log


# Sync docker time
#ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone
