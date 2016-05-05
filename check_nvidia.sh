EXIT=0

##------------------------------------------##
## Check if kernel module is loaded
##------------------------------------------##

if lsmod|grep nvidia 2>&1 1>/dev/null
then
MOD_LOADED=1
else
MOD_LOADED=0
echo "Nvidia Kernel module not loaded. Graphics card not in use !"
exit 2
fi

##------------------------------------------##
## Check if nvidia-smi exists in the system
##------------------------------------------##


if ! which nvidia-smi  2>&1 1>/dev/null
then
echo "Nvidia Graphics card utility not found. Please contact administrator !"
exit 2
fi

##------------------------------------------##
## Check Power Usage
##------------------------------------------##


POWER_MAX=$(nvidia-smi --format=csv --query-gpu=power.max_limit|tail -n+2|cut -d " " -f 1)
POWER_DRAW=$(nvidia-smi --format=csv --query-gpu=power.draw|tail -n+2|cut -d " " -f 1)

if [ $(echo "${POWER_DRAW} < ${POWER_MAX} " |bc) -eq 1 ]
then
POWER_SAFE="OK"
else
POWER_SAFE="WARNING"
EXIT=1
fi


##------------------------------------------##
## Check GPU usage 
##------------------------------------------##

GPU_SAFE=OK
GPU_USE=$(nvidia-smi --format=csv --query-gpu=utilization.gpu|tail -n+2 |awk '{print $1}')
if [ $(echo "${GPU_USE} >= 80.00" |bc ) -eq 1 ]
then
GPU_SAFE="WARNING"
EXIT=1
elif [ $(echo "${GPU_USE} >= 90.00 "|bc) -eq 1 ]
then
GPU_SAFE="CRITICAL"
EXIT=2
fi

#echo "EXIT: ${EXIT}"
#echo "GPUSAFE: ${GPU_SAFE}"
#read

##-----------------------------------------##
## Check GPU Temperature
##-----------------------------------------##

GPU_TSAFE="OK"
GPU_TCURR=$(nvidia-smi --format=csv --query-gpu=temperature.gpu|tail -n+2 |awk '{print $1}')
GPU_TMAX=$(nvidia-smi -q |awk '/GPU Shut.*Temp/ {print $5}')
if [ $(echo "${GPU_TCURR} < ${GPU_TMAX}"|bc) -ne 1 ]
then
GPU_TSAFE="WARNING"
if [ ${EXIT} -ne 2 ]
then
EXIT=1
fi
fi

##-----------------------------------------##
## ADDITIONAL INFO
##-----------------------------------------##
PRDNAME=$(nvidia-smi --format=csv --query-gpu=name|tail -n+2)
FANSPEED=$(nvidia-smi --format=csv --query-gpu=fan.speed|tail -n+2)
DRVVERSION=$(nvidia-smi --format=csv --query-gpu=driver_version|tail -n+2)n

## Print messages and stats
##-----------------------------------------##

if [ ${EXIT} -eq 0 ]
then
echo "[OK]. All GPU parameters within safe limits."
elif [ ${EXIT} -eq 1 ]
then 
echo "[WARNING]. One or more GPU parameters in WARNING state. Please check stats below."
elif [ ${EXIT} -eq 2 ] 
then
echo "[CRITICAL]. One or more GPU parameters in CRITICAL state. Please check stats below."
fi

echo -e "\n\n------------------------------"
echo "	GPU stats"
echo "------------------------------"
echo -e "\nProduct Name: ${PRDNAME}"
echo -e "Driver Version: ${DRVVERSION}"
echo -e "Fan Speed: ${FANSPEED}"	
echo -e "GPU Usage: ${GPU_USE}% (State: [${GPU_SAFE}])"
echo -e "GPU Temperature: ${GPU_TCURR} C (State: [${GPU_TSAFE}]) Vendor-Specific Threshold : ${GPU_TMAX} C"
echo -e "GPU Power Usage: ${POWER_DRAW} W (State: [${POWER_SAFE}]) Vendor-Specific Threshold : ${POWER_MAX} W"









