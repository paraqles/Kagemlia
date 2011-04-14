require 'messages/datatypes/get_data'
require 'messages/datatypes/return_data'

require 'messages/handler/handler'

class GetInfoHandler < Handler
  def initialize( params )
    super( params )
  end
  def handle( msg )
    if @store_manager.include? msg.key
      mesg = ReturnData.new(  :id => msg.id,
                              :key => msg.key,
                              :data => @store_manager[msg.key])
    else
      FindNodeHandler.new( msg )
    end
    return msg
  end
end
