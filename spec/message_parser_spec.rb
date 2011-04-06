require 'messages/message_parser.rb'

describe MessageParser do
  context "(in general)" do
    it "should convert an hash to a message" do
      msg = { "msgType"  => "Ping",
              "nonce"    => 0.2898658681564369,
              "node_id"  => "275ad7c759fa77f49a7f603c7cd1f670ff23afcc",
              "id"       => "a247467ea7d4be9a945d569c4c12855a2885b669"
            }
      mesg = MessageParser.to_obj( msg )

      mesg.id.should == "a247467ea7d4be9a945d569c4c12855a2885b669"
    end
  end
end
