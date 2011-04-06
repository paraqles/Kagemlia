require 'handler'

require 'messages/datatypes/ping'
require 'messages/datatypes/pong'

class PingHandler < Handler
  def initialize( params )
    super( params )
  end

  def handle( msg )
    mesg = Pong.new( :id => msg.id, :node_id => @kademlia.id )
    @node.send( mesg )
  end
end
