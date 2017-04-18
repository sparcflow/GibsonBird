#!/bin/bash
## Launch smbclient on machines with port 445 open
##
## Array containing all viable targets
declare -a arr=("10.10.20.78" "10.10.20.199" "10.10.20.56" "10.10.20.41" "10.10.20.25" "10.10.20.90" "10.10.20.71" "10.10.20.22" "10.10.20.38" "10.10.20.15")

## now loop through the above array
for i in "${arr[@]}"
do
   echo $i
   ## List shares
   smbclient  -L $i -U GBSHOP\\dvoxon%Bird123!
   echo "--"

done
