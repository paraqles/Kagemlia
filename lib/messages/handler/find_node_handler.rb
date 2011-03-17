require 'messages/handler/message_handler'
require 'messages/datatypes/return_nodes'

class FindNodeHandler < MessageHandler
  def initialize( msg )
    super( msg )
    @target_id = msg.key
    @in_msg = msg
  end

  def handle
    msg = ReturnNodes.new
    msg.set( 'nodes' => BucketManager.i.get_nodes( @in_msg.value ) )
    @node.send( msg )
  end
end
