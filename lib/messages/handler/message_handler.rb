require 'bucket_manager'

class MessageHandler
  def initialize( msg )
    @node = BucketManager.i.get_node( msg.node_id )
  end

  def handle
  end
end
