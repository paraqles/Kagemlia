require 'messages/datatypes/message'

class ReturnNode < Message
  attr_reader :nodes

  def initialize( msg = {} )
    super( msg )
    @nodes = msg['nodes'] if msg.include? 'nodes'
    @nodes = msg[:nodes] if msg.include? :nodes
  end

  def message( nodes = '' )
    @nodes ||= nodes
    msg = { 'nodes' => @nodes }
    finalize_message( msg )
  end
end
