require 'messages/datatypes/message'

class GetData < Message
  attr_reader :key

  def initialize( msg = {} )
    super( msg )

    @key = msg['key'] if msg.include? 'key'
    @key ||= msg[:key] if msg.include? :key
    @key ||= ''
  end

  def message( key = '' )
    @key ||= key
    msg = { 'key' => @key }
    finalize_message( msg )
  end
end
