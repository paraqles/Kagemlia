require '../../localhost.rb'
require '../Ping.rb'
require '../Pong.rb'

class PingHandler
  def initialize( msg )
    @msg = msg
  end
  
  def handle()
    nmsg = Pong.new( localhost.ID )
    
  end
end