require 'socket'
require 'json'

class Peer
  attr_accessor :endpoint, :id
  attr_accessor :last_seen
  
  def initialize( endpoint, port = '', id = '' )
    @endpoint = endpoint.split(':')[0]
    
    @port = endpoint.split(':')[1] if port == ''
    @port ||= port
    
    @socket = UDPSocket.new( @endpoint, @port )
    
    if @id == ''
      msg = Ping.new.message
      Kademlia.i.reg_message( msg, callback )
      send( msg )
    end
    has_been_seen
  end
  
  def callback( msg )
    @id = msg.peer_id if msg.msgType == 'Pong'
  end
  
  def send( msg )
    @socket.send( to_send.to_json )
  end

  def has_been_seen()
    @last_seen = Time.new
  end
end
