require 'rubygems'
require 'json'

require 'socket'
require 'thread'

require 'kademlia'
require 'node'
require 'messages/datatypes/ping'
require 'messages/datatypes/pong'

describe Node do
  context "(in general)" do
    before( :all ) do
      @kademlia = Kademlia.new( :port => 8998 )
    end

    before( :each ) do
      @node = Node.new( :endpoint => '127.0.0.1',
                        :port => 3030,
                        :id => 'balifapewoijf',
                        :kademlia => @kademlia )
    end

    after( :each ) do
      @node = nil
      GC.start
    end

    it "should not be nil" do
      @node.should_not == nil
    end

    it "should have a id" do
      @node.id.should_not == ""
    end

    it "should contact node if id not given" do
      sleep(2)
      @should_id = ""
      @server_thread = Thread.new {
        socket = UDPSocket::new
        socket.bind( '127.0.0.1', 3030 )
        puts "Test thread running"
        is_send = false
        while not is_send
          puts "Waitin for incomming"
          recv, from = socket.recvfrom( 2048 ) 
          msg = JSON.parse recv
          #puts "Get in spec: " + msg.to_s
          if msg["msgType"] == "Ping"
              @should_id = @kademlia.new_id
              resp = Pong.new( :node_id => @should_id,
                              'id' => msg['id'] )
              mesg = resp.message
              socket.send( mesg.to_json, 0, from[2], from[1] )
              is_send = true
              #puts "Send in spec: " + resp.to_s
          end
        end
      }
      node = Node.new(  :endpoint => '127.0.0.1',
                        :port => 3030,
                        :kademlia => @kademlia )
      @server_thread.join
      sleep( 1 )
      node.id.should == @should_id
    end
  end
end
