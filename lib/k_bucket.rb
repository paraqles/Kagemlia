class KBucket
  def initialize( size )
    @nodes = []
    @wQueue = []
    @max = size
  end
  
  def getNodes( k )
    rNodes = []
    k.times do
      rNodes.push( @nodes[ rand( (@nodes.length -1) ) ])
    end
    rNodes
  end
  
  def addNode( peer )
    if @nodes.length < @max -1
      @nodes.push( peer ) if not @nodes.include?( peer )
    elsif @wQueue < (2 ** @max) -1
      @wQueue.push( peer ) if not @wQueue.include?( peer )
    end
  end
  
  def getPeer( peerID )
    node = @nodes.each { | node | return node if node.id == peerID }
    node ||= @wQueue.each { | node | return node if node.id == peerID }
  end
  
  def isPeerInBucket?( peerID )
    peerIn?( @nodes, peerID )
  end
  
  def isPeerInQueue?( peerID )
    peerIn?( @wQueue, peerID )
  end
  
  def isPeerInKBucket?( peerID )
    r = isPeerInBucket?( peerID )
    r ||= isPeerInQueue?( peerID )
    return r
  end
  
  private
  
  def peerIn?( list, peerID )
    list.each { | node | return true if node.id == peerID }
    false
  end
end
