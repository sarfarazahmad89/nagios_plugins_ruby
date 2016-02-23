#!/usr/bin/ruby
require 'smart_status'
require 'pp'
device_valid = SMARTStatus::Parser.new(ARGV[0])

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
   temp_msg="HDD Temperature exceeds safe limits."
   temp_state="WARNING"
else 
   temp_msg="HDD Temperature within limits"
   temp_state="OK"
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

printlist=[]
temp=Printer.new("Temperature",temp_warn_value.to_s,temp_crit_value.to_s,temp_attr.raw.to_s,temp_state,temp_msg)
printlist <<temp
format="%#{Printer.max_title}s\t%#{Printer.max_warn}s\t%#{Printer.max_crit}s\t%#{Printer.max_current}s\t%#{Printer.max_state}s\t%#{Printer.max_msg}s\n"
printf(format, "Attribute", "Warn", "Crit","Current","State","Remarks")
#printf("----------------------------------------------------------\n")
printlist.each do |p|
    printf(format, p.title,p.warn,p.crit,p.current,p.state,p.msg)
    end
