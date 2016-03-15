#!/usr/bin/env ruby
require_relative "kmsgfilter.rb"
require_relative "kernelmessage.rb"

ERRMSG="[CRITICAL] SATA bus errors detected ! Please check SATA connections and HDD health(S.M.A.R.T).
Kernel error messages are displayed below. For more detailed information check /var/log/dmesg"
OKMSG="[OK] No Sata Bus Errors detected."
#KMSG=`dmesg`
KMSG=`cat working_dir/dummydmesg2`
$ERR_EXIT=0 
#REGEX=[ "\\[ .*ata[0-9].*DRDY.*",   "\\[ .*Emask.*ATA.*",".*ata[0-9].*SErr.*",   "\\[ .*ata[0-9].*error.*", "\\[ .*ata[0-9].*failed\scommand.*" ]
REGEX=[ "\\[ .*ata[0-9].*DRDY.*",   "\\[ .*Emask.*ATA.*",".*ata[0-9].*SErr.*",   "\\[ .*ata[0-9].*error.*", "\\[ .*ata[0-9].*failed\scommand.*" ]
$ERR=0
$ERRLOG=[]

kmsg_filter
if $ERR == 0
puts "#{OKMSG}"
else
puts "#{ERRMSG}"
puts $ERRLOG.sort { |x,y| x <=> y }
puts "\n\n"
puts $ERRLOG

#$ERRLOG.each do |x| 
#puts  x.to_s.split('').sort.join 
#end

ERR_EXIT=2  ## SATA Bus errors are always critical
ERRLOG_OBJ=Kernelmessage.new
puts ERRLOG_OBJ.timestamp.class
puts ERRLOG_OBJ.message.class

exit ERR_EXIT
end



