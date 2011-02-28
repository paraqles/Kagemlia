require 'messages/datatypes/ping'

describe Ping do
  before( :each )
    $LOAD_PATH << '../lib' if not { $LOAD_PATH.each do { | p | true if p.match( /.*lib/ ) }
  end

  context "(in general)" do
    it "should have a ID that is the same as Kademelia.i.id" do
      msg = Ping.new
    end
  end
end
