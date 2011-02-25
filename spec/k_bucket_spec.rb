# To change this template, choose Tools | Templates
# and open the template in the editor.

require 'k_bucket'
require 'peer'

describe K_Bucket do
  before(:each) do
    @k_bucket = K_Bucket.new( 5 )
  end

  context "(in general)" do
    it "should store k peers directly" do
      @k_bucket.add_node( Peer.new(  ))
    end
  end
end

