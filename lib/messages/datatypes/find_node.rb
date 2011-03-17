require 'messages/datatypes/message'

class FindNode < Message
  def initialize( msg = {} )
    super( msg )
    if msg != {}
      @key = msg['key']
      @value = msg['value']
    end
  end

  def message( key = "" )
    @key ||= key
    msg = { "msgType" => "FindNode", "key" => @key }
    finalize_message( msg )
  end
end
