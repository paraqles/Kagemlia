require 'node'

class KBucket
  def initialize( size = 10 )
    @nodes = Hash.new
    @timespan = Array.new
    @wQueue = Hash.new
    @wtimespan = Array.new
    @max = size
  end

  def get_nodes( k = 10 )
    rNodes = []
    if @nodes.length < k
      update
    end
    %w(k @nodes.length).times do
      rNodes.push( @nodes[ rand( (@nodes.length -1) ) ])
    end
    rNodes
  end

  def add_node( node )
    if @nodes.length < @max
      if not @nodes.include?( node )
        @nodes[node.id] = node
        @timespan.push node.id
      end
    elsif @wQueue.length < (2 ** @max)
      if not @wQueue.include? node
        @wQueue[node.id] = node
        @wtimespan.push node
      end
    end
  end

  def rem_node( node, list = "" )
    if node.kind_of? String
      if @nodes.key? node or list == "bucket"
        node = @nodes[node]
        @nodes.delete node.id
        @timespan.delete node.id
      elsif @wQueue.key? node or list == "queue"
        node = @wQueue[node]
        @wQueue.delete node.id
        @wtimespan.delete node.id
      end
    else
      if @nodes.include? node or list == "bucket"
        @nodes.delete node.id
        @timespan.delete node.id
      elsif @wQueue.include? node or list == "queue"
        @wQueue.delete node.id
        @wtimespan.delete node.id
      end
    end
    update
  end

  def update()
    if @nodes.length < @max
      (@max - @nodes.length).times do | i |
        node_id = @wtimespan[i]
        @nodes[node_id] = @wQueue[node_id]
        @timespan.push node_id
        rem_node( node_id, "queue" )
      end
    end
  end

  def get_node( node_id )
    node = @nodes[node_id]
    node ||= @wQueue[node_id]
    return node
  end

  def is_node_in_bucket?( node_id )
    node_in?( @nodes, node_id )
  end

  def is_node_in_queue?( node_id )
    nodeIn?( @wQueue, node_id )
  end

  def is_node_in_KBucket?( node_id )
    r = is_node_in_bucket?( node_id )
    r ||= is_node_in_queue?( node_id )
    return r
  end

  def []( index, queue = false )
    if index > 0
      if queue and index < @wQueue.length
        node_id = @wtimespan[index]
        return @wQueue[node_id]
      elsif index < @bucket.length
        node_id = @timespan[index]
        return @bucket[node_id]
      end
    end
    nil
  end

  def each( &blk )
    @wQueue.each( &blk ) if queue
    @nodes.each( &blk ) if not queue
  end

  def length( queue = false )
    return @nodes.length if not queue
    @wQueue.length if queue
  end

  private

  def node_in?( list, node_id )
    list.each { | node | return true if node.id == node_id }
    false
  end
end
