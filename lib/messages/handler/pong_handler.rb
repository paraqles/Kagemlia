require 'messages/handler/message_handler'

class PongHandler < MessageHandler
  def initialize( msg )
    super( msg )
  end

  def handle
    @node.id = msg.node_id
  end
end
