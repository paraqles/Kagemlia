require 'json'

class Message
  attr_reader :nonce
  
  def initialize()
    @nonce = rand()
  end
  
  def initialize( jsonMessage )
  end
  
  def message()
    [ "msgType" => "Message"]
    finalizeMessage( msg )
  end
  
  def finalizeMessage( msg )
    msg.push( [ "nonce" => @nonce ] )
    msg.to_json()
  end
end