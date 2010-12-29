require 'Message'

class FindNode < Message
  attr_accessor :searchString
  
  def initialize( searchString )
    super()
    @searchString = searchString
  end
  
  def initialize( jsonMessage )
    super()
    @searchString = JSON.parse( jsonMessage['toFind'] )
    @nonce = JSON.parse( jsonMessage['nonce'] )
    @returnNodes = true
    @nodes = []
  end
  
  def addBucket( bucket )
    bucket.each do | peer | 
      @nodes.push(peer.id.to_s => peer.endpoint )
    end
  end
  
  def message()
    if @returnNodes
      msg = ["msgType" => "returnNodes" ]
      msg.push( "peers" => @nodes )
    end
    msg = ["msgType" => "FindNode", "toFind" => @serchString ] if not @returnNodes
      
    finalizeMessage( msg )
  end
end