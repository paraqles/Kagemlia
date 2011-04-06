require 'bucket_manager'
require 'kademlia'
require 'store_manager'

require 'messages/datatypes/message'
require 'messages/datatypes/acknowledge'

class MessageHandler
  def initialize( params )
    params.each do | k, v |
      case k
        when :kademlia then @kademlia = kademelia
        when :buckets then  @bucket_manager = bucket_manager
        when :storage then  @store_manager = store_manager
      end
    end
  end

  def handle( msg )
    node = @bucket_manager.get_node( msg.node_id )
    mesg = Acknowledge.new( :node_id => @kademelia,
                            :id => msg.id )
    node.send( mesg )
  end
end
