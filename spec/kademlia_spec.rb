require 'rubygems'
require 'json'

require 'thread'

require 'kademlia'
require 'messages/datatypes/ping'

describe Kademlia do
  context "(in general)" do
    before( :all ) do
      @kademlia = Kademlia.new
    end

    after( :all ) do
      @kademlia.stop_recv
      @kademlia.socket.close
      @kademlia = nil
      GC.start
    end

    it "should not be nil" do
      @kademlia.should_not == nil
    end

    it "should have a id" do
      @kademlia.id.should_not == nil.to_s
    end

    it "should have options with k and local.port" do
      @kademlia.options[:K].should == 5
      @kademlia.options[:port].should == 4223
    end

    it "should be possible to set options" do
      @kademlia.options[:K].should == 5
      @kademlia.set( :K => 10, :port => 2323 )
      @kademlia.options[:K].should == 10
      @kademlia.options[:port].should == 2323
      @kademlia.set( :port => 4223, :K => 5 )
    end

    it "should execute hooks" do
      @kademlia.register( 'test_hook', :callback => Proc.new do | msg |
        msg.upcase!
      end )
      test_msg = "this is the msg"
      msg = @kademlia.hook( 'test_hook', test_msg )
      msg.should == test_msg.upcase
    end

    it "should recieve a msg and execute the hooks for this msg" do
      msg = Ping.new( 'node_id' => @kademlia.new_id )
      hook_id = "message.#{msg.id}"
      @kademlia.register( hook_id, :callback => Proc.new do | msg |
          @kademlia.options['msg'] = "this is a test"
          msg
        end
      )
      server_thread = Thread.new {
        socket = UDPSocket.new
        socket.bind( "127.0.0.1", 3333 )
        is_send = false
        trys = 0
        while not is_send
          socket.send( msg.message.to_json, 0, '127.0.0.1', 4223 )
          r = Kernel.select( [socket], nil, nil, 0.5 )
          if r != nil
            #puts "r => " + (r == nil ? 'nil' : r.to_s)
            recv, from = socket.recvfrom( 2048 )
            mesg = JSON.parse( recv )
            if mesg['msgType'] == 'Acknowledge'
              is_send = true
            else
              is_send = false
            end
          end
          if trys > 5
            is_send = true
          end
          trys += 1
        end
        socket.close
      }
      server_thread.join
      @kademlia.options['msg'].should == "this is a test"
    end
    it "should recieve a ping message and should return a pong message" do
      test_id = @kademlia.new_id
      msg = Ping.new( :node_id => test_id )
      
      server_thread = Thread.new {
        socket = UDPSocket.new
        socket.bind( "127.0.0.1", 3333 )
        is_send = false
        trys = 0
        mess_n = 0
        socket.send( msg.message.to_json, 0, '127.0.0.1', 4223 )
        while not is_send
          r = Kernel.select( [socket], nil, nil, 0.5 )
          if r != nil
            #puts "r => " + (r == nil ? 'nil' : r.to_s)
            recv, from = socket.recvfrom( 2048 )
            mesg = JSON.parse( recv )
            puts "Trys:          \t" + trys.to_s
            puts "Message:       \t" + mesg.to_s
            puts "Message Number:\t" + mess_n.to_s
            if mess_n == 0
              mesg['msgType'].should == 'Acknowledge'
              mess_n += 1
            else
              mesg['msgType'].should == 'Pong'
              break
            end
          end
          if trys > 1
            break
          else
            trys += 1
          end
        end
      }
      server_thread.join
    end
  end
end
