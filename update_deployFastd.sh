#!/bin/bash

mv deployFastd.sh deployFastd.sh.bak
mv update_deployFastd.sh update_deployFastd.sh.bak

wget https://raw.githubusercontent.com/FF-NRW/DeployScript/master/deployFastd.sh
wget https://raw.githubusercontent.com/FF-NRW/DeployScript/master/update_deployFastd.sh

chmod +x deployFastd.sh
chmod +x update_deployFastd.sh
