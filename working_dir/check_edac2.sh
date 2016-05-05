dimmnames=($(find /sys/devices/system/edac/mc/ -name "dimm_label" -exec cat {} \; -exec echo   \; ))
dimmcount="${#dimmnames[@]}"
location_sum=0
fault_msg="[WARNING] High Count of Correctable(Soft) Memory Errors occured. Please consider replacing the fault DIMMs mentioned below or run a memtest."
fault=0
file=$(mktemp)
LIMIT=80

function dimm_map { 
regex=".*Chan#([0-9]*)_DIMM#([0-9]*).*"
if [[ $1 =~ $regex ]]
then
channel="${BASH_REMATCH[1]}"
slot="${BASH_REMATCH[2]}"
fi

case ${channel} in 
2) 
  case ${slot} in 
	0) echo "DIMM1" ;;
	1) echo "DIMM2" ;;
  esac
;;

3) 
  case $slot in 
	0) echo "DIMM3" ;;
	1) echo "DIMM4" ;;
  esac
;;

1) 
  case $slot in 
	0) echo "DIMM6" ;;
	1) echo "DIMM5" ;;
  esac
;;

0) 
  case $slot in 
	0) echo "DIMM8" ;;
	1) echo "DIMM7" ;;
  esac
;;

esac
}



module=$(lsmod|grep edac|grep -v "edac_core")
if  [  "${module}x" == "x" ]
then
echo "[CRITICAL] Linux kernel modules not loaded. Cannot check the system for memory errors."
exit 2
fi

echo "Module Location,Soft_Error_Count" >>${file}

for i in "${dimmnames[@]}"
do
count_i=$(dmesg|grep "CE addr/cmd error"|grep -c "$i")
location_i=$(dimm_map $i)
echo -e "${location_i},${count_i}" >> ${file}

if [ ${count_i} -gt 0 ]
then
fault=1
fi

if [ ${count_i} -ge ${LIMIT} ]
then
fault_dimm+=(${location_i})
fault=2
fi
done

if [ $fault -eq 0 ]
then 
echo "No Correctable Memory Errors(Soft Errors) detected. Total no. of RAM modules: $dimmcount"
exit 0
fi


if [  $fault -eq 1 ]
then
echo "Correctable Memory Errors(Soft Errors) detected. Please check stats below."
fault=0
fi

if [ $fault -eq 2 ]
then
echo "${fault_msg}"
echo "Faulty DIMM modules: ${fault_dimm[@]}"
fault=1
fi


echo ;cat ${file}|column -s "," -t -x
rm ${file}
exit ${fault}
