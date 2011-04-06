require 'thread'

require 'k_bucket'
require 'node'

require 'messages/datatypes/message'

class BucketManager
  def initialize( params )
    @std = { :K => 10 }

    @buckets_mutex = Mutex.new
    @buckets = Hash.new

    @std.each do | k, v |
      if not params.include? k
        params[k] = v
      end
    end
    params.each do | k, v |
      if k == :id
        @id = v
      elsif k == :K
        @K = v
      end
    end

    @id.length.times do | i |
      @buckets[i] = KBucket.new( @K )
    end
  end

 def []=( key, bucket )
    bin_dist = (@id.bin_dist_to key) - 1
    @buckets_mutex.synchronize {
      @buckets[key] = bucket
    }
  end

  def []( key )
    @buckets_mutex.synchronize {
      @buckets[key] if @buckets.key? key
    }
  end

  def get_nodes_for( id )
    bin_dist = (@id.bin_dist_to id ) - 1
    nodes = Array.new
    dist = bin_dist
    @buckets_mutex.synchronize {
      while nodes.length < @K and dist > bin_dist / 2 and dist > 0
        @buckets[bin].get_nodes( @K ).each do | node |
          nodes.push node if nodes.length < @K
        end
        dist -= 1 if nodes.length < @K
      end
    }
  end

  def add_node( node )
    if node.kind_of? Node
      bin_dist = (@id.bin_dist_to node.id) - 1
      @buckets_mutex.synchronize {
        @buckets[bin_dist].add_node( node )
      }
    end
  end

  def get_node( node )
    if node.kind_of? String
      bin_dist = (@id.bin_dist_to node) - 1
      node_id = node
    elsif node.kind_of? Message
      bin_dist = (@id.bin_dist_to node.node_id ) - 1
      node_id = node.node_id
    end
    @buckets_mutex.synchronize {
      node = @buckets[bin_dist].get_node( node_id )
    }
  end

  def rem_node( node )
    if node.kind_of? String
      bin_dist = (@id.bin_dist_to node) - 1
    elsif node.kind_of? Node
      bin_dist = (@id.bin_dist_to node.id) - 1
    end
    @buckets_mutex.synchronize {
      @buckets[bin_dist].rem_node( node )
    }
  end

  def each( &blk )
    @buckets_mutex.synchronize {
      @buckets.each( blk )
    }
  end
end
