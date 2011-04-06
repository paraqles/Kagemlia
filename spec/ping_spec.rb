require 'messages/datatypes/ping'

describe Ping do
  before( :each ) do
  end

  context "(in general)" do
    it "should have a ID that is the same as Kademelia.i.id" do
      msg = Ping.new( :node_id => "asdf" )
    end
  end
end
