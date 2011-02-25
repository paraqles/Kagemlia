require 'socket'
require 'JSON'
require 'Kademlia'

class Peer
  attr_accessor :endpoint, :id
  attr_accessor :last_seen
  
  def initialize( endpoint, port = '', id = '' )
    @endpoint = endpoint.split(':')[0]
    
    @port = endpoint.split(':')[1] if port == ''
    @port = port if port != ''
    
    @id = id
    
    @socket = UDPSocket.new( @endpoint, @port )
    
    if @id == ''
      msg = Ping.new.message
      send( msg )
    end
    has_been_seen
  end
  
  def callback( msg )
    @id = msg.peer_id if msg.msgType == 'Pong'
  end
  
  def send( msg, await_responce = true )
    to_send = msg.message
    
    to_send.push( [ 'peer_id' => Kademlia.get.id ])
    
    Kademlia.i.reqister_for_msg( msg.msg_response_type, msg.nonce, @endpoint, @port, callback ) if not resp
    
    @socket.send( to_send.to_json )
  end

  def has_been_seen()
    @last_seen = Time.new
  end
end
