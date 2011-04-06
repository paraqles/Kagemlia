module MessageParser
  def self.to_obj( msg )
    @msgTypes ||= Array.new
    if not @msgTypes.include? msg['msgType']
      classname = msg['msgType']
      msgType = msg['msgType'].gsub( /^[A-Z]/) { $&.downcase  }
      msgType.gsub!( /[A-Z]/ ) { | m | m = '_' + m.downcase }

      if require( 'messages/datatypes/' + msgType + '.rb' )
        @msgTypes.push( classname )
      end
    end
    mesg = Kernel.const_get(classname).new( msg )
  end
end
