class MessageHandler
  def handle( msg )
    if load( '../datatype/' + msg['msgType'] + '.rb' )
      tmsg = msg['msgType'].new( msg )
      
      if tmsg.msgHandler != nil
        load( './' + tmsg.msg_handler )
        handler = tmsg.msg_handler
      end
      if tmsg.msg_handler == nil
        load( './' + msg['msgType'] + 'Handler.rb' )
        handler = msg['msgType'] + 'Handler.rb'
      end
      tmsgHandler = handler.new( tmsg )
    end
  end
end