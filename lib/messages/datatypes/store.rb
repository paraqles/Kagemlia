require 'messages/datatypes/message'

class Store < Message
  def initialize( msg = {} )
    super( msg )
    if msg == {}
      @key = ''
      @value = ''
    else
      @key = msg['key']
      @key = msg['value']
    end
  end
  
  def message()
    msg = { 'key' => @key, 'value' => @value }
    finalize_message( msg )
  end
end
