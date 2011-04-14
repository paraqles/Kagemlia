require 'messages/handler/handler'
require 'messages/datatypes/return_info'

class ReturnInfoHandler < Handler
  def initialize( params )
    super( params )
  end

  def handle( msg )
    @kademlia.hook( 'message.id=' + msg.id.to_s, msg )
    return msg
  end
end
