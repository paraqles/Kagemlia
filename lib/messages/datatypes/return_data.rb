require 'messages/datatypes/message'

class ReturnData < Message
  attr_reader :key, :data

  def initialize( msg = {} )
    super( msg )

    @key = msg['key'] if msg.include? 'key'
    @key = msg[:key] if msg.include? :key

    @data = msg['data'] if msg.include? 'data'
    @data = msg[:data] if msg.include? :data
  end

  def message( key = '', data = '' )
    @key ||= key
    @data ||= data
    msg = { 'key' => @key, 'data' => @data }
    finalize_message( msg )
  end
end
