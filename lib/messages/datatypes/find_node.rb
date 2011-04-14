require 'messages/datatypes/message'

class FindNode < Message
  attr_reader :key

  def initialize( msg = {} )
    super( msg )
    @key = msg['key'] if msg.include? 'key'
    @key = msg[:key] if msg.include? :key
  end

  def message( key = "" )
    @key ||= key
    msg = { "msgType" => "FindNode", "key" => @key }
    finalize_message( msg )
  end
end
