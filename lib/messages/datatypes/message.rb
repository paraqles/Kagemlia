require 'json'

require 'kademlia'

class Message
  attr_reader :nonce, :peer_id
  
  def initialize( msg = {} )
    if msg == {}
      @nonce = rand()
      @peer_id = Kademlia.i.id
    else
      @nonce = msg['nonce']
      @peer_id = msg['peer_id']
    end
  end
  
  def message( msg = {} )
    msg['msgType'] = self.class.name
    finalize_message( msg )
  end
  
  def finalize_message( msg = {} )
    msg['nonce'] = @nonce
    msg['peer_id'] = @peer_id
    return msg
  end
end
