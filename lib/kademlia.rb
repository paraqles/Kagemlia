require 'rubygems'
require 'macaddr'
require 'digest/sha1'
require 'singleton'

require 'k_bucket'

class Kademlia
  include Singleton

  attr_reader :id
  attr_accessor :buckets

  private
  def initialize()
    @id = Digest::SHA1.new << (Mac.addr.to_s + rand( 2**256 )).to_s
    @recvQueue = Array.new
    @buckets = Array.new
  end

  public
  def self.i()
    Kademlia.instance
  end

  def set_up( kBucketMax = 5, port = '4223' )
    128.times do
      @buckets.push( KBucket.new( kBucketMax ) )
    end
    startRecv( port )
  end

  def startRecv( port )
    @socket = UDPSocket::new
    @socket.bind( '', port )
    @recvThread = Thread.new( @socket ) { | sock |
      exit = false
      while not exit
        result = select( [ sock, STDIN ], nil, nil )

        for r in result[0]
          if r == sock
            recv, from = sock.recvfrom( 2048 )
            msg = MessageParser::parse( recv )

            if peerSeenAlready( msg.peerID )
              peer = getPeer( msg.peerID )
              peer.hasBeenSeen
            else
              putPeerInBucket( msg.peerID, from[2], from[1] )
            end

          elsif r == STDIN
            str = STDIN.read
            if str == 'exit' or str == 'quit'
              exit = true
            else
              processUserInput( str )
            end
          end
        end
      end
    }
  end

  def registerForMsg( msgType, nonce, endpoint, port, callback )
    @recvQueue.push( [ nonce => ['msgType' => msgType, 'endpoint' => endpoint, 'port' => port, 'callback' => callback ] ])
  end

  def peerAlreadySeen( peerID )
    bucket = @buckets[ id.binDist( peerID ) ]
    return true if bucket.isPeerInKBucket?( peerID )
    return false
  end

  def getPeer( peerID )
    @buckets[ id.binDist( peerID ) ].getPeer( peerID )
  end

  def putPeerInBucket( peerID, endpoint, port )
    peer = Peer.new( endpoint, port, peerID )
    @buckets[ id.binDist( peerID ) ].addNode( peer )
  end

  def processUserInput( input )

  end

  def []( key )
    bucket = @buckets[ id.binDist( key ) ]

  end

  def []=( key, value )
    
  end
end
