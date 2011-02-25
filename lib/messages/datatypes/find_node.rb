require 'Message'

class FindNode < Message
  attr_reader :msgRespondType
  attr_accessor :searchString
  
  def initialize( searchString )
    super()
    @msgType = 'FindNode'
    @msgRespondType = 'ReturnNodes'
    @searchString = searchString
  end
  
  def initialize( jsonMessage )
    super(jsonMessage)
    @msgType = 'FindNode'
    @msgRespondType = 'ReturnNodes'
    @searchString = JSON.parse( jsonMessage['toFind'] )
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
      msg = ['msgType' => @msgRespondType ]
      msg.push( 'peers' => @nodes )
    end
    msg = ["msgType" => "FindNode", "toFind" => @serchString ] if not @returnNodes
      
    finalizeMessage( msg )
  end
end