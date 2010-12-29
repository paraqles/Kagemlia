require 'socket'

class Peer
  attr_accessor :endpoint, :id
  attr_accessor :lastSeen
  
  def initialize( endpoint, sock )
    @endpoint = endpoint.split(':')[0]
    @port = endpoint.split(':')[1]
    @id
    @socket = sock
  end
  
  def send( msg )
    @socket.connect( @endpoint, @port )
    @socket.send( msg.pack(  ) )
  end

  def hasBeenSeen()
    @lastSeen = Time.new
  end
end
