require 'messages/handler/message_handler'
require 'messages/datatypes/return_node'

class FindNodeHandler < MessageHandler
  def initialize( params )
    super( params )
  end

  def handle( msg )
    node = @bucket_manager.get_node( msg.node_id )
    mesg = ReturnNode.new
    mesg.set( 'nodes' => BucketManager.i.get_nodes( msg.value ) )
    node.send( msg )
  end
end
