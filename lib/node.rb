require 'rubygems'
require 'json'

require 'socket'
require 'thread'

require 'messages/datatypes/ping'

class Node
  attr_accessor :endpoint, :id
  attr_accessor :last_seen

  def initialize( params )
    super
    @send_mutex = Mutex.new
    @socket = UDPSocket.new()

    params.each do | k, v |
      if k == :endpoint
        if v.include? ':'
          @endpoint = v.split(':')[0]
          @port = v.split(':')[1].to_i
        else
          @endpoint = v
        end
      elsif k == :port
          @port = v
      elsif k == :id
          @id = v
      end
    end
    if @id == nil
      msg = Ping.new
      puts msg
      Kademlia.i.register( "message." + msg.id.to_s,
                          Proc.new do | msg |
                            puts msg
                            @id = msg.node_id
                          end
      )
      send( msg )
    end

    has_been_seen
  end

  def callback( msg )
    puts msg
    @id = msg.node_id if msg.msgType == 'Pong'
  end

  def send( msg )
    @send_mutex.synchronize {
      msg = Kademlia.i.hook( "node.endpoint." + @endpoint + ".send", msg )
      msg = Kademlia.i.hook( "node.send", msg )
      @socket.send( msg, 0, @endpoint, @port )
    }
  end

  def has_been_seen()
    @last_seen = Time.new
  end

  def to_json()
    ( "{ 'node_id': #{@id}, 'endpoint': #{@endpoint}, 'port': #{@port} }" )
  end

  def to_s()
    ( "{ 'node_id' => #{@id}, 'endpoint' => #{@endpoint}, 'port' => #{@port} }" )
  end
end
