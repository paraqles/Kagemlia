require 'messages/datatypes/message'

class ReturnNodes < Message
  def initialize( msg = {} )
    super( msg )
    if msg != {}
      msg['nodes'].each do | node |
        @peers.push( node )
      end
    end
  end

  def add_node( peer )
    
  end

  def message( nodes )
    msg = { 'nodes' => @peers }
    finalize_message( msg )
  end
end
