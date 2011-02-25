require 'Message'

class Ping < Message
  def initialze()
    super()
    @msgType = 'Pong'
  end
  
  def initialize( jsonMessage )
    super(jsonMessage)
    @msgType = 'Pong'
  end
  
  def message()
    finalizeMessage( msg )
  end
end