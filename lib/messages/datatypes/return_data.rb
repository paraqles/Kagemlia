require 'messages/datatypes/message'

class ReturnData < Message
  def initialize( msg = {} )
    super( msg )

    if msg != {}
      @key = msg['key']
      @data = msg['data']
    end
  end

  def message( key, data )
    @key ||= key
    @data ||= data

    finalize_message( msg )
  end
end
