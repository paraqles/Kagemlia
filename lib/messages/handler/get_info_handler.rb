require 'messages/datatypes/get_info'
require 'messages/datatypes/return_info'

require 'messages/handler/handler'

class GetInfoHandler < Handler
  def initialize( params )
    super( params )
  end
  def handle( msg )
    if msg.id.prefix_dist_to( @kademlia.id ) < @kademlia.options[:K]
      mesg = ReturnInfo.new( :value => @kademlia.store[msg.key] )
    else

  end
end
