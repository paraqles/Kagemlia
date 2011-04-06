require 'thread'

require 'node'

class KBucket
  def initialize( size = 10 )
    @nodes_mutex      = Mutex.new
    @nodes            = Hash.new
    @timespan         = Array.new
    @queue_mutex      = Mutex.new
    @queue            = Hash.new
    @queue_timespan   = Array.new
    @max              = size
  end

  def get_nodes( k = 10 )
    ret_nodes = []
    if @nodes.length < k
      update
    end
    @nodes_mutex.synchronize {
      [k, @nodes.length].max.times do
        ret_nodes.push( @nodes[ rand( (@nodes.length -1) ) ])
      end
    }
    ret_nodes
  end

  def add_node( node )
    node_added = false
    @nodes_mutex.synchronize {
      if @nodes.length < @max
        if not @nodes.include?( node )
          @nodes[node.id] = node
          @timespan.push node.id
        end
        node_added = true
      end
    }
    if not node_added
      @queue_mutex.synchronize {
        if @queue.length < (2 ** @max)
          if not @queue.include? node
            @queue[node.id] = node
            @queue_timespan.push node.id
          end
        end
      }
    end
  end

  def rem_node( node )
    if node.kind_of? String
      @nodes_mutex.synchronize {
        node = @nodes[node] if @nodes.key? node
        is_in_bucket = true
      }
      if not node.kind_of Node
        @queue_mutex.synchronize {
          node = @queue[node] if @queue.key? node
          is_in_bucket = true
        }
      end
    end
    if node.kind_of Node
      @nodes_mutex.synchronize {
        @nodes.delete node.id
        @timespan.delete node.id
      }
      @queue_mutex.synchronize {
        @queue.delete node.id
        @queue_timespan.delete node.id
      }
    end
    update
  end

  def update()
    @nodes_mutex.synchronize {
      @queue_mutex.synchronize {
        if @nodes.length < @max and @queue.length > 0
          (@max - @nodes.length).times do | i |
              if i < @queue.length
                node = @queue[@queue_timespan[i]]
                @nodes[node.id] = node
                @timespan.push node.id
                @queue.delete node.id
                @queue_timespan.delete node.id
              else
                break
              end
          end
        end
      }
    }
  end

  def get_node( node_id )
    node = nil
    @nodes_mutex.synchronize {
      node = @nodes[node_id]
      node ||= @queue[node_id]
    }
    return node
  end

  def is_node_in_bucket?( node_id )
    @nodes_mutex.synchronize {
      node_in?( @nodes, node_id )
    }
  end

  def is_node_in_queue?( node_id )
    @queue_mutex.synchronize {
      node_in?( @queue, node_id )
    }
  end

  def is_node_in_KBucket?( node_id )
    r = is_node_in_bucket?( node_id )
    r ||= is_node_in_queue?( node_id )
    return r
  end

  def []( index, queue = false )
    if index > 0
      @queue_mutex.synchronize {
        if queue and index < @queue.length
          return @queue[@queue_timespan[index]]
        end
      }
      @nodes_mutex.synchronize {
        if index < @bucket.length
          return @bucket[@timespan[index]]
        end
      }
    end
    nil
  end

  def each_in_nodes( &blk )
    @nodes_mutex.synchronize {
      @nodes.each( &blk )
    }
  end

  def each_in_queue( &blk )
    @queue_mutex.synchronize {
      @queue.each( &blk )
    }
  end

  def each( &blk )
    each_in_nodes( &blk )
    each_in_queue( &blk )
  end

  def length( queue = false )
    len = 0
    if not queue
      @nodes_mutex.synchronize {
        len = @nodes.length
      }
    end
    if queue
      @queue_mutex.synchronize {
        len = @queue.length
      }
    end
    len
  end

  private

  def node_in?( list, node_id )
    list.each { | node | return true if node.id == node_id }
    false
  end
end
