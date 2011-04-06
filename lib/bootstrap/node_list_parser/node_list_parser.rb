require 'node'

module NodeListParser
  def to_nodes( list, kademlia_instance, bucket_manager )
    list.each do | n |
      node = Node.new(  :endpoint => n['endpoint'],
                        :port => n['port'],
                        :id => n['node_id'],
                        :socket => kademlia_instance.socket,
                        :kademlia => kademlia_instance )
      if bucket_manager != nil
        bucket_manager.add_node( node )
      end
    end
    list
  end
end
