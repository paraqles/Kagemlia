require 'messages/datatypes/message'

class ReturnNodes < Message
  def initialize( msg = {} )
    super( msg )
    if msg == {}
      @peers = Array.new
    else
      msg['nodes'].each do | node |
        @peers.push( node )
      end
    end
  end

  def message( nodes )
    msg = { 'nodes' => nodes }
    finalize_message( msg )
  end
end
