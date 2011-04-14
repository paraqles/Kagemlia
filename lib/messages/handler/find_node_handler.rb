require 'messages/handler/message_handler'
require 'messages/datatypes/return_node'

class FindNodeHandler < Handler
  def initialize( params )
    super( params )
  end

  def handle( msg )
    node = @bucket_manager.get_node( msg.node_id )
    if @store_manager.include? msg.key
      mesg = ReturnData(  :id => msg.id,
                          :key => msg.key,
                          :data => @store_manager[msg.key] )
      node.send( mesg )
    else
      mesg = ReturnNode.new
      mesg.set( 'nodes' => @bucket_manager.get_nodes_for( msg.key ) )
      node.send( msg )
    end
    return msg
  end
end
