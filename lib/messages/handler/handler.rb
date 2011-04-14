require 'bucket_manager'
require 'kademlia'
require 'store_manager'

class Handler
  def initialize( params )
    params.each do | k, v |
      case k
        when :kademlia then @kademlia = v
        when :bucket_manager then @bucket_manager = v
        when :store_manager then @store_manager = v
      end
    end
  end
end
