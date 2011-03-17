require 'kademlia'
require 'messages/datatypes/ping'

require 'modules/binary_distance_extension'

describe Kademlia do
  context "(in general)" do
    before( :all ) do
      String.send( 'include', BinaryDistanceExtension )
    end

    before( :each ) do
      Kademlia.i
    end

    it "should not be nil" do
      Kademlia.i.should_not == nil
    end

    it "should have a id" do
      Kademlia.i.id.should_not == nil.to_s
    end

    it "should have options with k and local.port" do
      Kademlia.i.options[:K].should == 5
      Kademlia.i.options[:port] == 4223
    end

    it "should be possible to set options" do
      Kademlia.i.options[:K].should == 5
      Kademlia.i.set( :K => 10, :port => 2323 )
      Kademlia.i.options[:K].should == 10
      Kademlia.i.options[:port].should == 2323
      Kademlia.i.set( :port => 4223, :K => 5 )
    end

    it "should execute hooks" do
      Kademlia.i.register( 'test_hook', Proc.new do | msg |
        msg.upcase!
      end )

      msg = Kademlia.i.hook( 'test_hook', "this is the msg" )
      msg.should == "this is the msg".upcase!
    end

    it "should recieve a msg and execute the hooks for this msg" do
      msg = Ping.new( 'node_id' => Kademlia.i.new_id )
      hook_id = "message.#{msg.id}"
      Kademlia.i.register( hook_id, Proc.new do | msg |
        Kademlia.i.options['msg'] = "this is a test"
        msg
      end )
      Kademlia.i.start_recv
      socket = UDPSocket.new
      socket.bind( "127.0.0.1", 3030 )
      is_send = false
      trys = 0
      while not is_send
        socket.send( msg.message.to_json, 0, '127.0.0.1', 4223 )
        r = Kernel.select( [socket], nil, nil, 0.5 )
        #puts "r => " + (r == nil ? 'nil' : r.to_s)
        if r != nil
          is_send = true
          recv, from = socket.recvfrom( 2048 )
        end
        if trys > 5
          is_send = true
        end
        trys += 1
      end
      Kademlia.i.options['msg'].should == "this is a test"
    end
  end
end
