class K_Bucket
  def initialize( size )
    @nodes = []
    @wSnake = []
    @max = size
  end
  def get_nodes( k )
    return_nodes = []
    k.times do
      return_nodes.push( @nodes[ rand( (@nodes.length -1) ) ])
    end
    return_nodes
  end
  def add_node( peer )
    
  end
end
