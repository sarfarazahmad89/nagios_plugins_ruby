module=$(lsmod|grep edac|grep -v "edac_core")
if  [  "${module}x" == "x" ]
then
echo "[CRITICAL] Kernel Modules not loaded. Cannot monitor memory errors"
exit 2
fi
