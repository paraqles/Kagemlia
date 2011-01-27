require 'json'

class Message
  attr_reader :msg_type, :nonce, :peer_id, :respond
  attr_reader :msg_handler
  
  def initialize()
    @msg_type = 'Message'
    @nonce = rand()
    @peer_id
    @respond = false
  end
  
  def initialize( jsonMessage )
    @peer_id = jsonMessage['peerID']
  end
  
  def message()
    [ "msgType" => "Message"]
    finalize_message( msg )
  end
  
  def finalize_message( msg )
    msg.push( [ "nonce" => @nonce, 'msgType' => msgType ] )
    msg
  end
  
  def respond?
    @respond
  end
end