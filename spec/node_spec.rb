require 'rubygems'
require 'json'

require 'socket'
require 'thread'

require 'kademlia'
require 'node'

describe Node do
  context "(in general)" do
    before( :all ) do
      Kademlia.i
      Kademlia.i.start_recv
    end

    before( :each ) do
      @mutex = Mutex.new
      @cv = ConditionVariable.new

      Kademlia.i
      Kademlia.i.start_recv
      @node = Node.new( :endpoint => '127.0.0.1',
                        :port => 3030,
                        :id => 'balifapewoijf' )
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
      @should_id = ""
      @server_thread = Thread.new {
        socket = UDPSocket::new
        socket.bind( '127.0.0.1', 3030 )

        puts "Test thread running"
        while true
          puts "Waitin for incomming"
          @cv.signal
          recv, from = socket.recvfrom( 2048 ) 
          msg = JSON.parse recv
          puts msg["msgType"]
          if msg["msgType"] == "Ping"
              msg = Pong.new
              puts msg
              msg = msg.message
              @should_id = Kademlia.i.new_id
              msg["node_id"] = @should_id
              puts "", "ID should #{@should_id}"
              socket.send( msg.to_json, 0, from[1], 3030 )
              @cv.signal
          end
        end
      }
      node = nil
      @mutex.synchronize {
        @cv.wait( @mutex )
        node = Node.new( :endpoint => '127.0.0.1', :port => 3030 )
      }
      @mutex.synchronize {
        @cv.wait( @mutex )
        sleep( 2 )
        puts node.to_s
        node.id.should == @should_id
      }
      @server_thread.exit
    end
  end
end
