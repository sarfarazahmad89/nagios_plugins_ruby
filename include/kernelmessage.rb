class Kernelmessage
  attr_accessor :timestamp,:message
  
  def initialize 
    @timestamp=0.0
    @message=" "
  end

  def update(var)
    @timestamp=var.match(/\[\s*([0-9]*\.[0-9]*)\]/).captures[0].to_f
    @message=var.match(/\]\s*(.*)/).captures[0].to_s
  end
end

