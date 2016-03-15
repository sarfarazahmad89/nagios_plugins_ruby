#!/usr/bin/env ruby

require_relative "include/kmsgfilter.rb"

ERRMSG="[WARNING]  CPU Temperature exceeds safe thresholds limit. Kernel error messages are displayed below\n"
$ERR_EXIT=0 ## CPU Temperature errors are classified as warning"
OKMSG="[OK] CPU Temperature within safe limits"
#KMSG=`dmesg`
KMSG=`cat working_dir/dummydmesg`
REGEX=[".*CPU[0-9].*temperature above.*"]
$ERR=0
$ERRLOG=[]


kmsg_filter
if $ERR == 0
puts "#{OKMSG}"
else
puts "#{ERRMSG}"
puts $ERRLOG
ERR_EXIT=1
exit ERR_EXIT
end


