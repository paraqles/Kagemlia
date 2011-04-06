require 'modules/prefix_distance_extension'
require 'bucket_manager'
require 'k_bucket'

describe BucketManager do
  before( :all ) do
    String.send( "include", PrefixDistanceExtension )
  end

  before( :each ) do
    @bm = BucketManager.new( :id => "asdjpafibvapsovdhaposdvihpaosvdjicpoasdjivcoa", :K => 10 )
  end

  context "(in general)" do
    it "should store a bucket" do
      @bm["234"] = KBucket.new
      @bm["234"].should_not == nil
    end
  end
end
