require 'bucket_manager'
require 'k_bucket'

describe BucketManager do
  before( :each ) do
    BucketManager.i
  end

  context "(in general)" do
    it "should store a bucket" do
      BucketManager.i["234"] = KBucket.new
      BucketManager.i["234"].should_not == nil
    end
  end
end
