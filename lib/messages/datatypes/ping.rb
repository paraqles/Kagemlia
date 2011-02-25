require 'Message'

class Ping < Message
  attr_reader :msgResponseType
  
  def initialze()
    super()
    @peerID = ''
    @respond = true
    @msgResponseType = 'Pong'
  end
  
  def initialize( jsonMessage )
    super(jsonMessage)
    @respond = true
  end
  
  def message()
    finalizeMessage( msg )
  end
end