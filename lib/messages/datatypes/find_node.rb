require 'messages/datatypes/message'

class FindNode < Message
  def initialize( msg = {} )
    super( msg )
    if msg == {}
      @key = ''
      @value = ''
    else
      @key = msg['key']
      @value = msg['value']
    end
  end
  
  def message( key = "", value = "" )
    @key ||= key
    @value ||= value
    msg = { "msgType" => "FindNode", "key" => @key, "value" => @value }
    finalize_message( msg )
  end
end
