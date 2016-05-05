#!/usr/bin/env ruby
require_relative "include/kmsgfilter.rb"
require_relative "include/kernelmessage.rb"

## Variables/Constants
ERRMSG="[CRITICAL] Nvidia Kernel Driver reports errors. Please check the logs listed below or run \"dmesg\" for more information."
DESCR="\nNote: Reported Error messages can be indicative of a hardware problem, an NVIDIA software problem, or a user application problem."
OKMSG="[OK] Nvidia kernel driver does not report any errors."
KMSG=`dmesg`
$ERR_EXIT=0 
REGEX=[ "\\[ .*NVRM.*Xid.*" ]
$ERR=0
$ERRLOG=[]
ERRLOG_KMSG=[]


kmsg_filter
if $ERR == 0
 puts "#{OKMSG}"
 puts "#{DESCR}"
else
 $ERRLOG.each do |x| 
 tmp_kmsg=Kernelmessage.new
 tmp_kmsg.update(x)
 ERRLOG_KMSG << tmp_kmsg
 end

ERRLOG_KMSG.sort! {|a,b| a.timestamp <=> b.timestamp }
print "#{ERRMSG} \n\n"
ERRLOG_KMSG.each do |y|
  puts "[#{y.timestamp}] #{y.message}"
 end

ERR_EXIT=2  ## SATA Bus errors are always critical
puts "#{DESCR}"
exit ERR_EXIT
end



