require 'Message'

class Ping < Message
  def initialze()
    super()
  end
  
  def initialize( jsonMessage )
    super(jsonMessage)
    @isPong = true
  end
  
  def message()
    msg = [ "msgType" => "Pong" ] if @isPong
    msg = [ "msgType" => "Ping" ] if not @isPong
      
    finalizeMessage( msg )
  end
end