require 'rubygems'
require 'json'

require 'bootstrap/node_list_parser/node_list_parser'

module JsonNodeListParser
  include NodeListParser

  def parse( obj, kademlia = nil, buckets_manager = nil )
    if obj.kind_of? String
      list = JSON.parse( obj )
      if kademlia != nil
        list = NodeListParser.to_nodes( list, kademlia, buckets_manager )
      end
      list
    end
  end
end
