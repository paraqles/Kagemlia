require 'messages/handler/handler'
require 'messages/datatypes/return_node'

class ReturnNodeHandler < Handler
  def initialize( params )
    super( params )
  end

  def handle( msg )
    nodes_for_value = Array.new
    msg.nodes.each do | node |
      @bucket_manager.add_node( node )
      if node.id.prefix_dist_to msg.key < @kademlia.options[:K]
        nodes_for_value.push node
      end
    end
    if nodes_for_value.length > 0
      mesg = GetInfo.new( :id => msg.key )
      nodes_for_value.each do | node |
        node.send( mesg.clone() )
      end
    else
      mesg = FindNode.new( msg )
      @bucket_manager.get_nodes_for( msg.key ).each do | node |
        node.send( mesg.clone )
      end
    end
    return msg
  end
end
