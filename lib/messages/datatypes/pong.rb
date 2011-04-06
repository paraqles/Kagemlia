require 'messages/datatypes/message'

class Pong < Message
  def initialze( msg = {} )
    super( msg )
  end
  
  def message()
    msg = {}
    finalize_message( msg )
  end
end
