require 'messages/datatypes/message'

class Ping < Message
  def initialze( msg = {} )
    super( msg )
  end
  
  def message()
    finalize_message()
  end
end
