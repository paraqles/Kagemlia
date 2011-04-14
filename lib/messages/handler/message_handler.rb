require 'bucket_manager'
require 'kademlia'
require 'store_manager'

require 'messages/handler/handler'

require 'messages/datatypes/message'
require 'messages/datatypes/acknowledge'

class MessageHandler < Handler
  def initialize( params )
    super( params )
  end

  def handle( msg )
    node = @bucket_manager.get_node( msg.node_id )
    mesg = Acknowledge.new( :node_id => @kademelia,
                            :id => msg.id )
    node.send( mesg )
    return msg
  end
end
