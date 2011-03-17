require( "singleton" )

require( "k_bucket" )
require( "node" )

class BucketManager
  include Singleton

  def initialize()
    @buckets = Hash.new
  end

  def self.i
    self.instance
  end

  def []=( key, bucket )
    @buckets[key] = ( bucket )
  end

  def []( key )
    @buckets[key] if @buckets.key? key
  end

  def get_nodes_for( id )
    binDist = id.bin_dist_to( Kademlia.i.id )
    nodes = Array.new
    @buckets[binDist].each do | node |
      nodes.push( node ) if nodes.length < Kademlia.i.options['k']
    end
  end

  def add_node( node )
    if node.kind_of? Node
      binDist = node.id.bin_dist_to( Kademlia.i.id )
      @buckets[binDist].add_node( node )
    end
  end

  def get_node( node )
    if node.kind_of? String
      binDist = node.bin_dist_to Kademlia.i.id
      node = @buckets[binDist].get_node( node )
    end
  end

  def rem_node( node )
    if node.kind_of? String
      binDist = node.bin_dist_to Kademlia.i.id
    elsif node.kind_of? Node
      binDist = node.id.bin_dist_to Kademlia.i.id
    end
    @buckets[binDist].rem_node( node )
  end
end
