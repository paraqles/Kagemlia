require 'handler'

class PingHandler < Handler
  def initialize( msg )
    super( msg )
  end

  def handle
    msg = Pong.new
    @node.send( msg )
  end
end
