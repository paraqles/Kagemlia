require 'Message'

class Store < Message
  def initialize()
    super()
  end
  def initialize( identifier, value )
    super()
    @identifier = identifier
    @value = value
  end
  
  def message()
    msg = [ 'msgType' => 'Store', 'identifier' => @identifier, 'value' => @value ]
    finalizeMessage( msg )
  end
end