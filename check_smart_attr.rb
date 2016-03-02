#!/usr/bin/ruby
require 'smart_status'
require 'pp'
device_valid = SMARTStatus::Parser.new(ARGV[0])
exit_code=0
printlist=[]
msg=""

########################################################################
## Error Handling for this script's arguments
########################################################################

if ARGV.length != 1 
	puts "Incorrect Usage. Add one parameter for disk device like '/dev/sda'"
	exit 1
end

########################################################################
## Calling smartcl
########################################################################

device_output= device_valid.process


########################################################################
## Temperature Check  (WARN/OK)
########################################################################

temp_attr=device_output[:temperature_celsius]
temp_crit_value=45
temp_warn_value="-"

if temp_attr.raw > temp_crit_value
   temp_msg="Value exceeds safe limits."
   temp_state="WARNING"
else 
   temp_msg="Value within limits"
   temp_state="OK"
end


########################################################################
## Reallocated Sector Count (WARN/CRITICAL/OK)
########################################################################

reallocated_attr=device_output[:reallocated_sector_ct]
if reallocated_attr.raw > reallocated_attr.threshold_level
   reallocated_msg = "HDD may fail."
   reallocated_state="WARNING"

elsif reallocated_attr.raw > reallocated_attr.threshold_value
   reallocated_msg = "HDD failure is imminent."
   reallocated_state="CRITICAL"

else
   reallocated_msg="Value within limits"
   reallocated_state="OK"
end

########################################################################
##  Current_Pending_Sector 
########################################################################

curr_pending_attr=device_output[:current_pending_sector]
curr_pending_warn="-"

if curr_pending_attr.raw > reallocated_attr.threshold_value
   curr_pending_msg = "HDD failure is imminent."
   curr_pending_state="CRITICAL"

else
   curr_pending_msg="Value within limits"
   curr_pending_state="OK"
end


########################################################################
##  Spin_Retry_Count
########################################################################

spin_retry_attr=device_output[:spin_retry_count]
spin_retry_warn=spin_retry_attr.threshold_value-spin_retry_attr.threshold_level



if spin_retry_attr.raw > spin_retry_attr.threshold_value
   spin_retry_msg = "HDD failure is imminent."
   spin_retry_state="CRITICAL"
elsif spin_retry_attr.raw > spin_retry_warn
   spin_retry_msg = "HDD may fail ."
   spin_retry_state="WARNING"

else
   spin_retry_msg="Value within limits"
   spin_retry_state="OK"
end


########################################################################
##  Offline uncorrectable
########################################################################

offline_uncorrect_attr=device_output[:offline_uncorrectable]
offline_uncorrect_warn="-"

if offline_uncorrect_attr.raw > offline_uncorrect_attr.threshold_value
   offline_uncorrect_msg = "HDD failure is imminent."
   offline_uncorrect_state="CRITICAL"
else
   offline_uncorrect_msg="Value within limits"
   offline_uncorrect_state="OK"
end




########################################################################
## the 'Printer' class for pretty printing
########################################################################

class Printer 
	
  @@max_title ||=0
  @@max_warn ||=0
  @@max_crit ||=0
  @@max_state ||=0
  @@max_msg ||=0
  @@max_current ||=0

attr_reader :title, :warn, :crit, :current, :state, :msg
	
 def initialize(title,warn,crit,current,state,msg)
  @title=title
  @warn=warn
  @crit=crit
  @current=current
  @state=state
  @msg=msg


    @@max_title = set_max(@title.length, @@max_title)
    @@max_warn = set_max(@warn.length, @@max_warn)
    @@max_crit = set_max(@crit.length, @@max_crit)
    @@max_current = set_max(@current.length, @@max_current)
    @@max_state = set_max(@state.length, @@max_state)
    @@max_msg = set_max(@msg.length, @@max_msg)

 end

 def set_max(current, max)
   current > max ? current : max
 end


  def self.max_title
    @@max_title
  end
 
  def self.max_warn
    @@max_warn
  end

  def self.max_crit
    @@max_crit
  end

  def self.max_current
    @@max_current
  end


  def self.max_state
    @@max_state
  end

  def self.max_msg
    @@max_msg
  end

end



##########################################################################
## 'main' object : instantiation
##########################################################################

temp=Printer.new("Temperature",temp_warn_value.to_s,temp_crit_value.to_s,temp_attr.raw.to_s,temp_state,temp_msg)
printlist <<temp

reallocated_st=Printer.new("ReallocatedSectorCount",reallocated_attr.threshold_level.to_s,reallocated_attr.threshold_value.to_s,reallocated_attr.raw.to_s,reallocated_state,reallocated_msg)
printlist <<reallocated_st

current_pending_st=Printer.new("CurrentPendingSectorCount",curr_pending_warn.to_s,curr_pending_attr.threshold_value.to_s,curr_pending_attr.raw.to_s,curr_pending_state,curr_pending_msg)
printlist <<current_pending_st

spin_retry_ct=Printer.new("SpinRetryCount",spin_retry_warn.to_s,spin_retry_attr.threshold_value.to_s,spin_retry_attr.raw.to_s,spin_retry_state,spin_retry_msg)
printlist <<spin_retry_ct


offline_uncorrect_st=Printer.new("OffineUncorrectableErrors",offline_uncorrect_warn.to_s,offline_uncorrect_attr.threshold_value.to_s,offline_uncorrect_attr.raw.to_s,offline_uncorrect_state,offline_uncorrect_msg)
printlist <<offline_uncorrect_st


printlist.each do |p|
    if p.state == "WARNING" && exit_code != 2
    exit_code=1
    msg="WARNING. Hardware faults detected in HDD."
    elsif p.state == "CRITICAL"
    exit_code=2
    msg="CRITICAL. HDD failure imminent. Backup data and replace drive."
    else 
    msg="OK. HDD healthy."
    end
    end

    puts "#{msg}\n\n"


format="%-#{Printer.max_title}s\t%#{Printer.max_warn}s\t%#{Printer.max_crit}s\t%#{Printer.max_current}s\t%#{Printer.max_state}s\t%#{Printer.max_msg}s\n"
printf(format, "Attribute", "Warn", "Crit","Current","State","Remarks")
printf(format, "------", "-----", "----","----","----","------")
printlist.each do |p|
printf(format, p.title,p.warn,p.crit,p.current,p.state,p.msg)
end

exit exit_code
