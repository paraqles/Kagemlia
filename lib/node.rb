require 'rubygems'
require 'json'

require 'socket'
require 'thread'

require 'messages/datatypes/ping'

class Node
  attr_reader :endpoint, :id
  attr_accessor :last_seen

  def initialize( params )
    super
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
      elsif k == :kademlia
        @kademlia = v
      end
    end

    raise ArgumentError, "No endpoint" if @endpoint == nil or @endpoint == ""
    raise ArgumentError, "No port" if @port == nil or @port == 0
    if @kademlia == nil or @kademlia == ""
      raise ArgumentError, "No local kademlia instance" 
    else
      @socket = @kademlia.socket
    end
    if @id == nil or @id == ""
      msg = Ping.new( :node_id => @kademlia.id )
      @kademlia.register( "message." + msg.id.to_s,
                          :callback => Proc.new { | msg |
                              puts "Node gets: " + msg.to_s
                              @id = msg.node_id
                            }
                        )
      send( msg )
    end

    has_been_seen
  end

  def send( msg )
    msg = @kademlia.hook( "node.endpoint." + @endpoint + ".send", msg )
    msg = @kademlia.hook( "node.send", msg )
    begin
      @kademlia.socket_mutex.lock
    rescue ThreadError
    end
      @kademlia.socket.send( msg, 0, @endpoint, @port )
    @kademlia.socket_mutex.unlock if @kademlia.socket_mutex.locked?
  end

  def has_been_seen()
    @last_seen = Time.new
  end

  def to_json()
    ( "{ 'node_id': #{@id}, 'endpoint': #{@endpoint}, 'port': #{@port} }" )
  end

  def to_s()
    ( "##{self.class.name}:(#{self.object_id}) -- { 'node_id' => #{@id}, 'endpoint' => #{@endpoint}, 'port' => #{@port} }" )
  end
end
