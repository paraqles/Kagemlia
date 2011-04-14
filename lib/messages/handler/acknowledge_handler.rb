require 'messages/handler/handler'
require 'messages/datatypes/acknowledge'

class AcknowledgeHandler < Handler
  def initialize( params )
    super( params )
  end

  def handle( msg )
    if msg.kind_of( Acknowledge )
      @kademlia.ack( msg.id )
    end
    return msg
  end
end
