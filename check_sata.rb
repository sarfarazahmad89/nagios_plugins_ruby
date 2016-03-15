#!/usr/bin/env ruby
require_relative "kmsgfilter.rb"

ERRMSG="[CRITICAL] SATA bus errors detected ! Please check SATA connections and HDD health(S.M.A.R.T).
Kernel error messages  are displayed below\n"
OKMSG="[OK] No Sata Bus Errors detected."
KMSG=`dmesg`
#KMSG="[    9.647558]          res 40/00:18:c8:5c:0f/00:00:07:00:00/40 Emask 0x10 (ATA bus error)"
$ERR_EXIT=0 
REGEX=[ "\\[ .*ata[0-9].*DRDY.*",   "\\[ .*Emask.*ATA.*",".*ata[0-9].*SErr.*",   "\\[ .*ata[0-9].*error.*"]
$ERR=0
$ERRLOG=[]

kmsg_filter
if $ERR == 0
puts "#{OKMSG}"
else
puts "#{ERRMSG}"
puts $ERRLOG
ERR_EXIT=2  ## SATA Bus errors are always critical
exit ERR_EXIT
end



