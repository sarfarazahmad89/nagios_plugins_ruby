def kmsg_filter
REGEX.each do |i|
reg=Regexp.new i
result=KMSG.scan(reg)
if result.length == 0 && $ERR == 0
$ERR=0
else
$ERR=1
$ERRLOG << result
end
end
end

