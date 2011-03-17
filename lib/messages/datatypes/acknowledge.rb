require 'messages/datatypes/message'

class Acknowledge < Message
  def initialize( params )
    super( params )
  end

  def message( state = true )
    msg = { 'acknowledged' => state }
    msg = finalize_message( msg )
  end
end
