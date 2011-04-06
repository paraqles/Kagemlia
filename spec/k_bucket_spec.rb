require 'socket'

require 'k_bucket'
require 'node'

describe KBucket do
  class TestKademlia
    attr_accessor :id, :options, :socket

    def initialize
      @id = "asdfpljasdflkjasdflkjasdflkj"
      @options = Hash.new
      @socket = UDPSocket.new
    end
  end

  context "(in general)" do
    before(:all) do
      @kademlia = TestKademlia.new
      @k = 5
    end

    before(:each) do
      @k_bucket = KBucket.new( @k )
    end

    after(:each) do
      @k_bucket = nil
      GC.start
    end

    it "should not be nil" do
      @k_bucket.should_not == nil
    end

    it "should store k nodes directly" do
      @k_bucket.length().should == 0

      @k.times { | i |
         node = Node.new( :endpoint => "localhost",
                          :port => 80,
                          :id => "234" + i.to_s,
                          :kademlia => @kademlia
                        )
         @k_bucket.add_node( node )
      }
      @k_bucket.length().should == @k

      @k.times { | i |
        node = Node.new( :endpoint => "localhost",
                         :port => 80,
                         :id => "2465" + i.to_s,
                         :kademlia => @kademlia
                        )
        @k_bucket.add_node( node )
      }
      @k_bucket.length().should == @k
    end
  end
end
