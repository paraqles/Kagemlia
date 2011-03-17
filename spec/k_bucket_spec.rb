require 'k_bucket'
require 'node'

describe KBucket do
  context "(in general)" do
    before(:all) do
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

      @k.times { | i | @k_bucket.add_node( Node.new( :endpoint => "localhost",
                                                     :port => 80,
                                                     :id => "234" + i.to_s
                                                   )
                                         )
      }

      @k_bucket.length().should == @k

      @k.times { | i | @k_bucket.add_node( Node.new( :endpoint => "localhost",
                                                     :port => 80,
                                                     :id => "2465" + i.to_s ) ) }

      @k_bucket.length().should == @k
    end
  end
end
