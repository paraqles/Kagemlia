require 'csv'

require 'bootstrap/node_list_parser/node_list_parser'

module CSVNodeListParser
  include NodeListParser

  def parse( obj, kademlia = nil, buckets_manager = nil )
    if obj.kind_of? String
      list = CSV.parse( obj )
      if kademlia != nil
        list = NodeListParser.to_nodes( list, kademlia, buckets_manager )
      end
      list
    end
  end
end
