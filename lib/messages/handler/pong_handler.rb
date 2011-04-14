require 'messages/handler/message_handler'

class PongHandler < MessageHandler
  def initialize( msg )
    super( msg )
  end

  def handle( msg )
    @kademlia.hook( "message.id=" + msg.id.to_s, msg )
    return msg
  end
end
