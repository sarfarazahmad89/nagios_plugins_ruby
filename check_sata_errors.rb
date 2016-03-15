#!/usr/bin/env ruby
require_relative "include/kmsgfilter.rb"
require_relative "include/kernelmessage.rb"

## Variables/Constants
ERRMSG="[CRITICAL] SATA bus errors detected ! Please check SATA connections and HDD health(S.M.A.R.T).
Kernel error messages are displayed below. For more detailed information check /var/log/dmesg"
OKMSG="[OK] No Sata Bus Errors detected."
#KMSG=`dmesg`
KMSG=`cat working_dir/dummydmesg2`
$ERR_EXIT=0 
REGEX=[ "\\[ .*ata[0-9].*DRDY.*",   "\\[ .*Emask.*ATA.*",".*ata[0-9].*SErr.*",   "\\[ .*ata[0-9].*error.*", "\\[ .*ata[0-9].*failed\scommand.*" ]
$ERR=0
$ERRLOG=[]
ERRLOG_KMSG=[]


kmsg_filter
if $ERR == 0
puts "#{OKMSG}"
else

$ERRLOG.each do |x| 
tmp_kmsg=Kernelmessage.new
tmp_kmsg.update(x)
ERRLOG_KMSG << tmp_kmsg
end

ERRLOG_KMSG.sort! {|a,b| a.timestamp <=> b.timestamp }

ERRLOG_KMSG.each do |y|
puts "[#{y.timestamp}] #{y.message}"
end

ERR_EXIT=2  ## SATA Bus errors are always critical
exit ERR_EXIT
end



