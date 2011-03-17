require 'messages/datatypes/message'

class GetData < Message
  def initialize( msg = {} )
    super( msg )

    if msg == {}
      @key = ''
    else
      @key = msg['key']
    end
  end

  def set( key )
    @key = key
  end

  def message( key = '' )
    @key ||= key
    msg = { 'key' => @key }
    finalize_message( msg )
  end
end
